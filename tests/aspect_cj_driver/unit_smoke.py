"""Compile and run the rule and CHIR snapshot unit tests with a matching SDK.

Snapshot tests need the CHIR sources and flatbuffers archive from a stdx build;
they intentionally compile the real package instead of substituting stubs.
"""

import argparse
import os
from pathlib import Path
import subprocess
import tempfile


HERE = Path(__file__).resolve().parent
STDX = HERE.parents[1]
RULE_FILES = (
    "aspect_cj.cj",
    "rule_annotations.cj",
    "rule_expression.cj",
    "rule_graph.cj",
    "rule_match.cj",
    "rule_control.cj",
    "rule_wire.cj",
    "rule_plan.cj",
    "rule_apply.cj",
    "rule_context.cj",
)


def run(command, env, label):
    result = subprocess.run(command, env=env, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, text=True, check=False)
    if result.returncode != 0:
        raise RuntimeError(f"{label} failed ({result.returncode}):\n{result.stdout[-12000:]}")
    print(f"{label}: PASS")
    if label.endswith("run"):
        print(result.stdout.strip())


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--compiler", type=Path, required=True)
    parser.add_argument("--stdx-directory", type=Path, required=True)
    parser.add_argument("--chir-source-dir", type=Path)
    parser.add_argument("--chir-generated-file", type=Path)
    parser.add_argument("--modules-directory", type=Path)
    parser.add_argument("--flatbuffers-archive", type=Path)
    parser.add_argument("--benchmark", action="store_true")
    args = parser.parse_args()
    optional = (args.chir_source_dir, args.chir_generated_file,
                args.modules_directory,
                args.flatbuffers_archive)
    if any(value is not None for value in optional) and not all(
        value is not None for value in optional
    ):
        parser.error("snapshot options must be provided together")
    for path in (args.compiler, args.stdx_directory):
        assert path.is_absolute() and path.exists(), path
    env = dict(os.environ)
    sdk = Path(env.get("CANGJIE_HOME") or args.compiler.parent.parent)
    env["LD_LIBRARY_PATH"] = (
        f"{args.stdx_directory}:{sdk / 'runtime/lib/linux_x86_64_cjnative'}:"
        f"{sdk / 'lib/linux_x86_64_cjnative'}:{env.get('LD_LIBRARY_PATH', '')}"
    )
    with tempfile.TemporaryDirectory(prefix="aspect-cj-unit-") as temporary:
        temp = Path(temporary)
        rule_sources = [STDX / "src/stdx/aspect_cj" / name for name in RULE_FILES]
        for mode, flags in (("default", []), ("O2", ["-O2"])):
            output = temp / f"rule-{mode}"
            run([str(args.compiler), *(str(path) for path in rule_sources),
                 str(HERE / "rule_unit.cj"), "--import-path", str(args.stdx_directory),
                 "-L", str(args.stdx_directory), "-lstdx.chir",
                 "-lstdx.encoding.json", "-lstdx.encoding.json.stream", "-lstdx.encoding.hex",
                 "-lstdx.crypto.digest", *flags, "-o", str(output)], env,
                f"rule {mode} build")
            run([str(output)], env, f"rule {mode} run")
            if args.benchmark:
                run(["/usr/bin/time", "-f", "elapsed=%e seconds peak-rss=%M KiB", str(output), "--benchmark"],
                    env, f"rule {mode} benchmark run")

        if all(value is not None for value in optional):
            for path in optional:
                assert path.is_absolute() and path.exists(), path
            # The source checkout may contain a stale generated schema from a
            # different SDK. Compile only the hand-written sources plus the
            # exact generated file from the matching stdx build.
            sources = sorted(path for path in args.chir_source_dir.glob("*.cj")
                             if not path.name.endswith("_generated.cj"))
            assert sources, args.chir_source_dir
            output = temp / "snapshot"
            snapshot_env = dict(env)
            snapshot_env["LD_LIBRARY_PATH"] = (
                f"{args.modules_directory / 'stdx'}:{env['LD_LIBRARY_PATH']}"
            )
            run([str(args.compiler), *(str(path) for path in sources),
                 str(args.chir_generated_file),
                 str(HERE / "snapshot_unit.cj"), str(args.flatbuffers_archive),
                 "--import-path", str(args.modules_directory),
                 "--import-path", str(args.modules_directory / "stdx"),
                 "-o", str(output)], snapshot_env, "snapshot build")
            run([str(output)], snapshot_env, "snapshot run")


if __name__ == "__main__":
    main()
