# Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

"""Real-compiler checks for generic candidates and advice control flow."""

import argparse
import os
from pathlib import Path
import subprocess
import tempfile


HERE = Path(__file__).resolve().parent


def run(command, env):
    result = subprocess.run(command, env=env, text=True, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, check=False)
    assert result.returncode == 0, result.stdout[-10000:]
    return result.stdout


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--compiler", type=Path, required=True)
    parser.add_argument("--stdx-directory", type=Path, required=True)
    parser.add_argument("--work-root", type=Path)
    args = parser.parse_args()
    for path in (args.compiler, args.stdx_directory):
        assert path.is_absolute() and path.exists(), path
    root = (args.work_root or Path(tempfile.mkdtemp(prefix="aspect-cj-semantic-"))).resolve()
    root.mkdir(parents=True, exist_ok=True)
    print(f"work root: {root}")
    env = dict(os.environ)
    sdk = Path(env.get("CANGJIE_HOME") or args.compiler.parent.parent)
    env["LD_LIBRARY_PATH"] = (
        f"{args.stdx_directory}:{sdk / 'runtime/lib/linux_x86_64_cjnative'}:"
        f"{sdk / 'lib/linux_x86_64_cjnative'}:{env.get('LD_LIBRARY_PATH', '')}"
    )
    plugin = root / "libaspect_cj_semantic_test.so"
    run([
        str(args.compiler), str(HERE / "semantic_plugin.cj"),
        "--output-type=dylib", "--import-path", str(args.stdx_directory),
        "-L", str(args.stdx_directory), "-lstdx.aspect_cj", "-lstdx.chir",
        "-lstdx.plugin.manager", "-o", str(plugin),
    ], env)

    cases = (
        ("generic-function", "aspect-v4-generic-smoke.cj", 2, 2, 1),
        ("generic-class", "aspect-v4-generic-class-smoke.cj", 2, 2, 1),
        ("exception-recursion", "aspect-v4-exception-smoke.cj", 5, None, None),
        ("replacement-receiver", "aspect-replace-receiver-smoke.cj", 12, None, None),
    )
    for label, fixture, planned, broad_count, exact_count in cases:
        for optimized in (False, True):
            suffix = "-o2" if optimized else ""
            executable = root / f"{label}{suffix}"
            command = [
                str(args.compiler), str(HERE / "fixtures" / fixture),
                "--experimental", "--emit-chir-annotation-metadata",
                f"--plugin={plugin}", "--output-type=exe",
                "--import-path", str(args.stdx_directory),
                "-L", str(args.stdx_directory), "-lstdx.aspect_cj",
                "-o", str(executable),
            ]
            if optimized:
                command.append("-O2")
            compilation = run(command, env)
            assert f"semantic planned={planned}" in compilation, compilation
            assert "semantic reentry=rejected" in compilation, compilation
            output = run([str(executable)], env)
            if label == "generic-function":
                assert output.count("generic-entry:1\n") == broad_count, output
                assert output.count("generic-exact-entry\n") == exact_count, output
                assert "generic-result:7" in output and "generic-result:second" in output
            elif label == "generic-class":
                assert output.count("box-any:1\n") == broad_count, output
                assert output.count("box-int\n") == exact_count, output
                assert output.count("box-body\n") == 2, output
            elif label == "replacement-receiver":
                assert output.splitlines() == [
                    "111", "111", "121", "121", "131", "131", "212", "222", "232", "110",
                    "151", "161"
                ], output
            else:
                assert output.splitlines() == [
                    "entry:99", "caught-entry",
                    "entry:88", "body:88", "exit:88", "caught-exit",
                    "entry:2", "body-throw:2", "caught-body",
                    "entry:3", "body-caught:3", "exit:3",
                    "entry:4", "body-branch:4", "exit:4",
                    "entry:0", "body-fallthrough:0", "exit:0",
                    "entry:1", "body-recursive:1", "entry:0", "body-recursive:0",
                    "exit:0", "exit:1",
                ], output
            print(f"{label}{suffix}: PASS")


if __name__ == "__main__":
    main()
