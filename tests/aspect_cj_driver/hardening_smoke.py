# Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
# See https://cangjie-lang.cn/pages/LICENSE for license information.

"""Bounded metadata and session confinement checks using real CHIR plugins."""

import argparse
import os
from pathlib import Path
import subprocess
import tempfile


HERE = Path(__file__).resolve().parent


def run(command, env, cwd, diagnostic=None):
    result = subprocess.run(command, env=env, cwd=cwd, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                            timeout=120, check=False)
    if diagnostic is None:
        assert result.returncode == 0, result.stdout[-10000:]
    else:
        assert result.returncode != 0 and diagnostic in result.stdout, result.stdout[-10000:]
        assert "core dumped" not in result.stdout.lower(), result.stdout[-10000:]
    return result.stdout


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--compiler", type=Path, required=True)
    parser.add_argument("--stdx-directory", type=Path, required=True)
    args = parser.parse_args()
    for path in (args.compiler, args.stdx_directory):
        assert path.is_absolute() and path.exists(), path
    env = dict(os.environ)
    env["LD_LIBRARY_PATH"] = f"{args.stdx_directory}:{env.get('LD_LIBRARY_PATH', '')}"
    common = [str(args.compiler), "--import-path", str(args.stdx_directory),
              "-L", str(args.stdx_directory), "-lstdx.aspect_cj"]
    with tempfile.TemporaryDirectory(prefix="aspect-hardening-") as temporary:
        root = Path(temporary)
        session = root / "session"
        session.mkdir()
        inside = session / "input"
        inside.write_bytes(b"safe")
        outside = root / "session-other"
        outside.mkdir()
        (outside / "input").write_bytes(b"safe")
        (session / "escape").symlink_to(outside / "input")
        (session / "alias").symlink_to(inside)
        exact = session / "exact"
        exact.write_bytes(b"x" * (8 * 1024 * 1024))
        excess = session / "excess"
        excess.write_bytes(b"x" * (8 * 1024 * 1024 + 1))
        for mode, flags in (("default", []), ("O2", ["-O2"])):
            helper = root / f"hardening-{mode}"
            run([*common, str(HERE / "hardening_unit.cj"), *flags, "-o", str(helper)], env, root)
            for label, path, diagnostic in (
                ("inside", inside, None),
                ("inside-symlink", session / "alias", None),
                ("prefix-sibling", outside / "input", "source input escapes session"),
                ("parent-traversal", session / ".." / "session-other/input", "source input escapes session"),
                ("outside-symlink", session / "escape", "source input escapes session"),
            ):
                run([str(helper), "path", str(session), str(path)], env, root, diagnostic)
                print(f"{mode} {label}: PASS")
            assert "bytes=8388608" in run([str(helper), "read", str(session), str(exact)], env, root)
            run([str(helper), "read", str(session), str(excess)], env, root, "file size limit")
            run([str(helper), "read", str(session), str(session)], env, root, "regular file")
            print(f"{mode} bounded read exact/over/directory: PASS")

        # Non-driver legacy weaving must enforce limits before building any calls.
        record = ["aspect", "init", "InsertAtEntry", "aspect", "advice", "0",
                  "false", "false", "false", "other", "", "run", "()->Unit", "false", "false"]
        valid = "\n".join(["#aspect_cj_annoinfo_v2", *record, ""])
        long_record = list(record)
        long_record[4] = "a" * 65537
        long_data = "\n".join(["#aspect_cj_annoinfo_v2", *long_record, ""])
        legacy_plugin = args.stdx_directory / "libstdx.weave_aspects.so"
        assert legacy_plugin.is_file(), legacy_plugin
        for label, data, diagnostic in (
            ("valid", valid, None),
            ("field", long_data, "field size limit"),
            ("first-field", "a" * 65537 + "\n", "field size limit"),
            ("file", "x" * (8 * 1024 * 1024 + 1), "file size limit"),
            ("records", "#aspect_cj_annoinfo_v2\n" + "\n".join(record + [""]) * 8193, "record limit"),
            ("truncated", "#aspect_cj_annoinfo_v2\naspect\n", "Missing aspect metadata field"),
        ):
            directory = root / label
            directory.mkdir()
            source = directory / "main.cj"
            source.write_text("package hardening_target\nmain(): Int64 { 0 }\n", encoding="utf-8")
            (directory / "aspect-hardening_target.annoinfo").write_text(data, encoding="utf-8")
            run([*common, str(source), f"--plugin={legacy_plugin}", "--output-type=exe",
                 "-o", str(directory / "main")], env, directory, diagnostic)
            print(f"legacy {label}: PASS")


if __name__ == "__main__":
    main()
