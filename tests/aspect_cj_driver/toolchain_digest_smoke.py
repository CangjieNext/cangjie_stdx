# Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

"""Exercise the driver's actual file and directory digests without copying their implementation."""

import argparse
import hashlib
import json
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
        let arguments = getCommandLine()
        if (arguments[1] == "file") {
            println(digest(arguments[2]))
        } else {
            println(directoryDigest(arguments[2]))
        }
        return 0
    } catch (error: Exception) {
        println("digest-rejected: ${error.message}")
        return 1
    }
}
"""
    test_source = root / "digest.cj"
    test_source.write_text(source, encoding="utf-8")
    env = dict(os.environ)
    env["LD_LIBRARY_PATH"] = str(args.stdx_directory) + ":" + env.get("LD_LIBRARY_PATH", "")
    # Do not let an inherited enlarged heap hide a whole-file allocation.
    # This setting is scoped to the compiler/probe child processes only.
    env["cjHeapSize"] = "256MB"
    files = root / "files"
    files.mkdir()
    references = []
    # Include SHA-256's block boundary and the driver's 64 KiB read boundary.
    binary = bytes(range(256)) * 513
    for size in (0, 1, 63, 64, 65, 65535, 65536, 65537, 131073):
        path = files / f"binary-{size}"
        path.write_bytes(binary[:size])
        references.append((path, hashlib.sha256(binary[:size]).hexdigest()))
    # One shared sparse file exceeds the standard 256 MiB Cangjie heap. Both
    # the fixture and its Python reference hash use bounded memory.
    large = files / "large-280MiB"
    with large.open("wb") as stream:
        stream.write(bytes(range(256)))
        stream.seek(140 * 1024 * 1024 + 7)
        stream.write(b"\x00\xff\x80middle\x00")
        stream.seek(280 * 1024 * 1024 - 1)
        stream.write(b"\xff")
    expected_large = hashlib.sha256()
    with large.open("rb") as stream:
        for block in iter(lambda: stream.read(65536), b""):
            expected_large.update(block)
    references.append((large, expected_large.hexdigest()))
    file_results = []
    failures = []
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
            result = subprocess.run([str(executable), "directory", str(path)], env=env, text=True,
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
        for path, expected in references:
            result = subprocess.run([str(executable), "file", str(path)], env=env, text=True,
                                    stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=120)
            actual = result.stdout.strip()
            passed = result.returncode == 0 and actual == expected
            file_results.append({"mode": label, "file": path.name, "size": path.stat().st_size,
                                 "expected": expected, "actual": actual,
                                 "returncode": result.returncode, "passed": passed})
            (root / "file-digests.json").write_text(json.dumps(file_results, indent=2), encoding="utf-8")
            if not passed:
                failures.append(f"{label}/{path.name}: exit={result.returncode}, output={actual}")
        print(f"toolchain-file-digest-{label}: "
              f"{sum(item['passed'] for item in file_results if item['mode'] == label)}/{len(references)}",
              flush=True)
        rejected = root / (label + "-rejected")
        rejected.mkdir()
        missing = rejected / "missing"
        dangling_file = rejected / "dangling"
        dangling_file.symlink_to("missing")
        fifo_file = rejected / "fifo"
        os.mkfifo(fifo_file)
        rejection_results = []
        for name, path, diagnostic in (
            ("directory", rejected, "expected a regular file for digest"),
            ("missing", missing, "digest-rejected:"),
            ("dangling", dangling_file, "digest-rejected:"),
            ("fifo", fifo_file, "expected a regular file for digest"),
        ):
            # Opening a FIFO would block. Require a caught validation exception,
            # rather than treating a timeout, process crash or OOM as rejection.
            result = subprocess.run([str(executable), "file", str(path)], env=env, text=True,
                                    stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=5)
            output = result.stdout.strip()
            passed = (result.returncode == 1 and output.startswith("digest-rejected:")
                      and diagnostic in output)
            rejection_results.append({"case": name, "returncode": result.returncode,
                                      "output": output, "passed": passed})
            (root / f"file-rejections-{label}.json").write_text(
                json.dumps(rejection_results, indent=2), encoding="utf-8")
            assert passed, f"{label}/{name}: {result.returncode}: {output}"
        print(f"toolchain-file-rejections-{label}: PASS (directory, missing, dangling, FIFO)", flush=True)
    assert not failures, "file SHA-256 regression failed:\n" + "\n".join(failures)


if __name__ == "__main__":
    main()
