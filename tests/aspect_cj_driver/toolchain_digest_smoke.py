# Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

"""Exercise the driver's actual directory digest with SDK-style symlinks."""

import argparse
import os
from pathlib import Path
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--compiler", type=Path, required=True)
    parser.add_argument("--stdx-directory", type=Path, required=True)
    parser.add_argument("--driver-source", type=Path, default=
                        Path(__file__).resolve().parents[2] / "build/aspect_cj_driver/main.cj")
    args = parser.parse_args()
    root = Path(tempfile.mkdtemp(prefix="aspect-toolchain-digest-"))
    print("work root:", root, flush=True)
    source = args.driver_source.read_text(encoding="utf-8")
    assert source.count("\nmain(): Int64 {") == 1
    # Only replace the CLI entry point; all production digest code is unchanged.
    source = source.replace("\nmain(): Int64 {", "\nprivate func originalMain(): Int64 {")
    source += """
main(): Int64 {
    try {
        println(directoryDigest(getCommandLine()[1]))
        return 0
    } catch (error: Exception) {
        println(error.message)
        return 1
    }
}
"""
    test_source = root / "digest.cj"
    test_source.write_text(source, encoding="utf-8")
    env = dict(os.environ)
    env["LD_LIBRARY_PATH"] = str(args.stdx_directory) + ":" + env.get("LD_LIBRARY_PATH", "")
    for mode in ([], ["-O2"]):
        label = "O2" if mode else "default"
        executable = root / ("digest-" + label)
        subprocess.run([str(args.compiler), str(test_source), "--experimental",
                        "--import-path", str(args.stdx_directory), "-L", str(args.stdx_directory),
                        "-lstdx.aspect_cj", "-lstdx.encoding.json", "-lstdx.encoding.json.stream",
                        "-Woff", "unused", *mode, "-o", str(executable)], env=env, check=True)
        tree = root / label
        tree.mkdir()

        def digest(path=tree, success=True):
            result = subprocess.run([str(executable), str(path)], env=env, text=True,
                                    stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=20)
            assert (result.returncode == 0) == success, result.stdout
            return result.stdout.strip()

        initial = digest()
        nested = tree / "platform" / "nested"
        nested.mkdir(parents=True)
        item = nested / "module.cjo"
        item.write_bytes(b"first")
        nested_digest = digest()
        assert nested_digest != initial
        item.write_bytes(b"other")
        assert digest() != nested_digest
        item.write_bytes(b"first")
        assert digest() == nested_digest

        alias = tree / "platform-alias"
        alias.symlink_to("platform", target_is_directory=True)
        linked = digest()
        assert linked != nested_digest and linked == digest()
        (tree / "module-alias").symlink_to(item)
        assert digest() != linked

        outside = root / (label + "-external")
        outside.mkdir()
        external_file = outside / "external.a"
        external_file.write_bytes(b"one")
        (tree / "external").symlink_to(outside, target_is_directory=True)
        external_digest = digest()
        external_file.write_bytes(b"two")
        assert digest() != external_digest

        (nested / "back").symlink_to(tree, target_is_directory=True)
        cyclic = digest()
        assert cyclic == digest()  # directory aliases must terminate, not be silently dropped
        alternate = tree / "alternate"
        alternate.mkdir()
        (alternate / "module.cjo").write_bytes(b"first")
        before_retarget = digest()
        alias.unlink()
        alias.symlink_to(alternate, target_is_directory=True)
        assert digest() != before_retarget

        dangling = tree / "dangling"
        dangling.symlink_to("absent")
        digest(success=False)
        dangling.unlink()
        fifo = tree / "unsupported-fifo"
        os.mkfifo(fifo)
        assert "unsupported toolchain entry" in digest(success=False)
        fifo.unlink()
        assert "expected toolchain directory" in digest(item, success=False)
        print(f"toolchain-digest-{label}: PASS (nested files, aliases, retargeting, cycles, fail-closed)",
              flush=True)


if __name__ == "__main__":
    main()
