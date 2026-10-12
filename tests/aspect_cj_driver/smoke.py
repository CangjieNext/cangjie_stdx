# Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

"""End-to-end checks for the staged aspect_cj build driver.

Run against a matching compiler, stdx build, and driver binary. The script
keeps each session under the printed work directory for failure inspection.
"""

import argparse
import hashlib
import json
import os
import platform
from pathlib import Path
import subprocess
import tempfile


FIXTURES = Path(__file__).resolve().parent / "fixtures"


def package(name, filename, *, output_type=None):
    result = {
        "packageName": name,
        "files": [str(FIXTURES / filename)],
        "options": [],
    }
    if output_type is not None:
        result["outputType"] = output_type
    return result


def run_driver(driver, config, directory, env, *, expected_success):
    config_path = directory / "config.json"
    config_path.write_text(json.dumps(config, ensure_ascii=False), encoding="utf-8")
    result = subprocess.run(
        [str(driver), str(config_path)],
        env=env,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    (directory / "driver.log").write_text(result.stdout, encoding="utf-8")
    assert (result.returncode == 0) == expected_success, result.stdout[-8000:]
    return result


def executable_output(session):
    complete = json.loads((session / "complete.json").read_text(encoding="utf-8"))
    assert complete["state"] == "COMPLETE"
    output = Path(complete["outputs"][0]["path"])
    assert output.is_file()
    return output


def run_executable(path, env):
    result = subprocess.run(
        [str(path)], env=env, text=True, stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT, check=True,
    )
    return result.stdout


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--compiler", type=Path, required=True)
    parser.add_argument("--stdx-directory", type=Path, required=True)
    parser.add_argument("--driver", type=Path, required=True)
    parser.add_argument("--work-root", type=Path)
    parser.add_argument("--regressions-only", action="store_true")
    args = parser.parse_args()
    for path in (args.compiler, args.stdx_directory, args.driver):
        assert path.is_absolute() and path.exists(), path
    root = args.work_root or Path(tempfile.mkdtemp(prefix="aspect-cj-driver-"))
    root = root.resolve()
    root.mkdir(parents=True, exist_ok=True)
    print(f"work root: {root}")
    env = dict(os.environ)
    sdk = Path(env.get("CANGJIE_HOME") or args.compiler.parent.parent)
    env["LD_LIBRARY_PATH"] = (
        f"{args.stdx_directory}:{sdk / 'runtime/lib/linux_x86_64_cjnative'}:"
        f"{sdk / 'lib/linux_x86_64_cjnative'}:{env.get('LD_LIBRARY_PATH', '')}"
    )

    def config(label, sources, targets):
        directory = root / label
        directory.mkdir()
        result = {
            "schemaVersion": 1,
            "sessionId": os.urandom(16).hex(),
            "sessionRoot": str(directory / "session"),
            "compiler": str(args.compiler),
            "stdxDirectory": str(args.stdx_directory),
            "sources": sources,
            "targets": targets,
        }
        return directory, result

    if not args.regressions_only:
        cross_source = package("aspect_v4_cross_source", "aspect-v4-cross-source.cj")
        extra_source = package("aspect_v4_extra_source", "aspect-v4-cross-second-source.cj")
        cross_target = package("aspect_v4_target", "aspect-v4-cross-target.cj",
                               output_type="exe")
        directory, spec = config("cross", [cross_source, extra_source], [cross_target])
        run_driver(args.driver, spec, directory, env, expected_success=True)
        session = directory / "session"
        assert (session / "sources.json").is_file()
        assert (session / "plan.json").is_file()
        output = run_executable(executable_output(session), env)
        for marker in ("cross-entry:7", "cross-entry-second:7", "target:7",
                       "cross-exit", "extra-exit", "instance-entry:9",
                       "instance-body:9", "static-entry:11", "static-body:11"):
            assert marker in output, output
        print("cross-package entry/exit and Array<Any>: PASS")

        directory, spec = config(
            "cross-o2", [dict(cross_source, options=["-O2"]),
                         dict(extra_source, options=["-O2"])],
            [dict(cross_target, options=["-O2"])],
        )
        run_driver(args.driver, spec, directory, env, expected_success=True)
        output = run_executable(executable_output(directory / "session"), env)
        for marker in ("cross-entry:7", "cross-entry-second:7", "target:7",
                       "cross-exit", "extra-exit", "instance-entry:9",
                       "instance-body:9", "static-entry:11", "static-body:11"):
            assert marker in output, output
        print("optimized cross-package entry/exit and Array<Any>: PASS")

        broken_source = root / "broken-source.cj"
        broken_source.write_text("package aspect_v4_cross_source\nthis is invalid\n",
                                 encoding="utf-8")
        directory, spec = config("collect-failure", [dict(cross_source, files=[str(broken_source)])],
                                 [cross_target])
        run_driver(args.driver, spec, directory, env, expected_success=False)
        assert not (directory / "session/sources.json").exists()
        assert not (directory / "session/complete.json").exists()

        broken_target = root / "broken-target.cj"
        broken_target.write_text("package aspect_v4_target\nthis is invalid\n",
                                 encoding="utf-8")
        directory, spec = config("preflight-failure", [cross_source, extra_source],
                                 [dict(cross_target, files=[str(broken_target)])])
        run_driver(args.driver, spec, directory, env, expected_success=False)
        assert (directory / "session/sources.json").is_file()
        assert not (directory / "session/plan.json").exists()
        assert not (directory / "session/complete.json").exists()
        print("failure publication barriers: PASS")

        directory, spec = config(
            "link-failure", [cross_source],
            [package("aspect_v4_target", "aspect-v4-link-fail-target.cj", output_type="exe")],
        )
        result = run_driver(args.driver, spec, directory, env, expected_success=False)
        assert (directory / "session/sources.json").is_file()
        assert (directory / "session/plan.json").is_file(), result.stdout
        assert not (directory / "session/complete.json").exists()
        assert "link-aspect_v4_target" in result.stdout, result.stdout
        print("apply link failure leaves PLAN_READY without COMPLETE: PASS")

        for label, name, filename, diagnostic in (
            ("invalid-unused-rule", "aspect_v4_invalid_rule_source",
             "aspect-v4-invalid-rule-source.cj", "invalid-rule-field"),
            ("invalid-rule-carrier", "aspect_v4_invalid_carrier_source",
             "aspect-v4-invalid-carrier-source.cj", "invalid-rule-carrier"),
            ("invalid-advice-signature", "aspect_v4_invalid_advice_source",
             "aspect-v4-invalid-advice-source.cj",
             "invalid-advice-signature"),
        ):
            directory, spec = config(label, [package(name, filename)], [cross_target])
            result = run_driver(args.driver, spec, directory, env, expected_success=False)
            assert diagnostic in result.stdout, result.stdout
            assert not (directory / "session/sources.json").exists()
            assert not (directory / "session/complete.json").exists()
        print("unreferenced invalid rule and invalid advice rejected at collection: PASS")

        directory, spec = config(
            "untracked-option", [dict(cross_source, options=["-L/tmp/untracked"])],
            [cross_target],
        )
        result = run_driver(args.driver, spec, directory, env, expected_success=False)
        assert "unsupported compiler option" in result.stdout, result.stdout
        assert not (directory / "session").exists()
        print("untracked compiler option rejected before session creation: PASS")

        self_source = package("aspect_v4_self", "aspect-v4-self-source-target.cj")
        directory, spec = config("source-is-target", [self_source],
                                 [dict(self_source, outputType="exe")])
        run_driver(args.driver, spec, directory, env, expected_success=True)
        output = run_executable(executable_output(directory / "session"), env)
        assert "self-entry:3" in output and "self-body:3" in output, output
        print("same package as source and target: PASS")

        dependent_source = package("aspect_v4_self_dep", "aspect-v4-cycle-source.cj")
        directory, spec = config("dependency-cycle", [self_source, dependent_source],
                                 [dict(self_source, outputType="exe")])
        result = run_driver(args.driver, spec, directory, env, expected_success=False)
        assert "dependency-cycle" in result.stdout, result.stdout
        assert (directory / "session/sources.json").is_file()
        assert not (directory / "session/plan.json").exists()
        assert not (directory / "session/complete.json").exists()
        print("real dependency cycle rejected before plan publication: PASS")

        zero_match_source = package(
            "aspect_v4_self_dep", "aspect-v4-zero-match-dependent-source.cj")
        directory, spec = config("zero-match-no-false-cycle", [self_source, zero_match_source],
                                 [dict(self_source, outputType="exe")])
        run_driver(args.driver, spec, directory, env, expected_success=True)
        output = run_executable(executable_output(directory / "session"), env)
        assert "self-entry:3" in output and "unexpected-unused-advice" not in output, output
        selected = (directory / "session/metadata/selected-aspect_v4_self.txt").read_text(
            encoding="utf-8")
        assert "aspect_v4_self_dep" not in selected, selected
        print("zero-match source does not introduce a false dependency cycle: PASS")

        directory, spec = config(
            "rule-logic",
            [package("aspect_v4_logic_source", "aspect-v4-logic-source.cj")],
            [package("aspect_v4_logic_target", "aspect-v4-logic-target.cj",
                     output_type="exe")],
        )
        run_driver(args.driver, spec, directory, env, expected_success=True)
        output = run_executable(executable_output(directory / "session"), env)
        assert output.splitlines() == [
            "hot:1", "body-hot:1", "exit",
            "nonhot:2", "body-cold:2", "exit",
            "nonhot:3", "body-plain:3", "exit",
        ], output
        print("AND/OR/NOT, shared rule, empty annotation, scalar concatenation: PASS")

        directory, spec = config(
            "annotation-identity",
            [package("aspect_v4_anno_right", "aspect-v4-annotation-right.cj"),
             package("aspect_v4_anno_wrong", "aspect-v4-annotation-wrong.cj"),
             package("aspect_v4_anno_source", "aspect-v4-annotation-source.cj")],
            [package("aspect_v4_anno_target", "aspect-v4-annotation-target.cj",
                     output_type="exe")],
        )
        run_driver(args.driver, spec, directory, env, expected_success=True)
        output = run_executable(executable_output(directory / "session"), env)
        assert output.splitlines() == ["right-entry", "right-body:1", "wrong-body:2",
                                       "plain-body:3"], output
        print("resolved annotation identity, aliases and same short name: PASS")

        directory, spec = config(
            "annotation-identity-no-reflection",
            [dict(package("aspect_v4_anno_right", "aspect-v4-annotation-right.cj"),
                  options=["--disable-reflection"]),
             dict(package("aspect_v4_anno_wrong", "aspect-v4-annotation-wrong.cj"),
                  options=["--disable-reflection"]),
             dict(package("aspect_v4_anno_source", "aspect-v4-annotation-source.cj"),
                  options=["--disable-reflection"])],
            [dict(package("aspect_v4_anno_target", "aspect-v4-annotation-target.cj",
                          output_type="exe"), options=["--disable-reflection"])],
        )
        run_driver(args.driver, spec, directory, env, expected_success=True)
        output = run_executable(executable_output(directory / "session"), env)
        assert output.splitlines() == ["right-entry", "right-body:1", "wrong-body:2",
                                       "plain-body:3"], output
        print("resolved annotation identity with reflection disabled: PASS")

        directory, spec = config(
            "mixed-legacy-and-new",
            [package("aspect_v4_mixed_source", "aspect-v4-mixed-source.cj")],
            [package("aspect_v4_mixed_target", "aspect-v4-mixed-target.cj",
                     output_type="exe")],
        )
        run_driver(args.driver, spec, directory, env, expected_success=True)
        lines = run_executable(executable_output(directory / "session"), env).splitlines()
        assert len(lines) == 5 and lines[2] == "body:7", lines
        assert set(lines[:2]) == {"legacy-entry:7", "new-entry:7"}, lines
        assert set(lines[3:]) == {"legacy-exit", "new-exit"}, lines
        print("legacy/new Entry and Exit jointly weave without argument rewrite: PASS")

        directory, spec = config(
            "replace-conflict",
            [package("aspect_v4_replace_conflict_source",
                     "aspect-v4-replace-conflict-source.cj")],
            [package("aspect_v4_mixed_target", "aspect-v4-mixed-target.cj",
                     output_type="exe")],
        )
        result = run_driver(args.driver, spec, directory, env, expected_success=False)
        assert "replace-rule-conflict" in result.stdout, result.stdout
        assert (directory / "session/sources.json").is_file()
        assert not (directory / "session/plan.json").exists()
        assert not (directory / "session/complete.json").exists()
        print("new advice with legacy Replace rejected in preflight: PASS")

    linked_library = package("aspect_v4_linked_library", "aspect-final-library.cj")
    linked_app = package("aspect_v4_linked_app", "aspect-final-application.cj", output_type="exe")
    linked_second = package("aspect_v4_linked_second", "aspect-final-application-second.cj", output_type="exe")
    for label, targets in (
        ("final-libraries", [dict(linked_library, outputType="staticlib"), linked_app, linked_second]),
        ("final-libraries-reversed", [linked_second, linked_app, dict(linked_library, outputType="staticlib")]),
    ):
        directory, spec = config(label, [linked_library], targets)
        run_driver(args.driver, spec, directory, env, expected_success=True)
        complete = json.loads((directory / "session/complete.json").read_text(encoding="utf-8"))
        outputs = {entry["packageName"]: entry for entry in complete["outputs"]}
        for name, value in (("aspect_v4_linked_app", 7), ("aspect_v4_linked_second", 9)):
            output = run_executable(Path(outputs[name]["path"]), env)
            assert output.splitlines() == [f"linked-entry:{value}", f"linked-entry:{value}",
                                           f"linked-body:{value}"], output
            libraries = [entry["path"] for entry in outputs[name]["linkInputs"]]
            assert outputs["aspect_v4_linked_library"]["path"] in libraries, libraries
            assert not any(path.endswith("baseline/libaspect_v4_linked_library.a") for path in libraries), libraries
            assert len(libraries) == len(set(libraries)), libraries
        source_manifest = json.loads((directory / "session/sources.json").read_text(encoding="utf-8"))
        source_entry = source_manifest["sources"][0]
        module = directory / "session" / source_entry["modulePath"]
        assert hashlib.sha256(module.read_bytes()).hexdigest() == source_entry["moduleSha256"]
    print("woven final libraries, both target orders and multiple executable roots: PASS")

    directory, spec = config("source-target-abi", [linked_library], [
        package("aspect_v4_linked_library", "aspect-final-library-incompatible.cj", output_type="staticlib"),
        linked_app,
    ])
    result = run_driver(args.driver, spec, directory, env, expected_success=False)
    assert "source/target declaration ABI" in result.stdout, result.stdout
    assert not (directory / "session/plan.json").exists()
    assert not (directory / "session/complete.json").exists()
    print("source/target declaration interface mismatch rejected: PASS")

    # Fault injection delegates every compilation to the real compiler, then
    # changes a baseline module after the first preselection has succeeded.
    wrapper = root / "mutating-compiler.py"
    wrapper.write_text(
        "#!/usr/bin/env python3\nimport json, os, pathlib, subprocess, sys\n"
        f"status = subprocess.call([{str(args.compiler)!r}] + sys.argv[1:])\n"
        "context = json.loads(pathlib.Path(os.environ['ASPECT_CJ_BUILD_CONTEXT']).read_text())\n"
        "if status == 0 and context['action'] == 'preselect':\n"
        "    path = pathlib.Path(context['sessionRoot']) / 'baseline/aspect_v4_linked_library.cjo'\n"
        "    path.write_bytes(path.read_bytes() + b'changed')\n"
        "sys.exit(status)\n", encoding="utf-8")
    wrapper.chmod(0o755)
    directory, spec = config("baseline-module-changed", [linked_library], [linked_app])
    spec["compiler"] = str(wrapper)
    result = run_driver(args.driver, spec, directory, env, expected_success=False)
    assert "build-input-mismatch: source changed" in result.stdout, result.stdout
    assert not (directory / "session/complete.json").exists()
    print("baseline module changes cannot escape the input digest: PASS")

    for label, mutation in (
        ("matching-summary-changed", """
if status == 0 and os.environ.get('ASPECT_CJ_BUILD_CONTEXT'):
    context = json.loads(pathlib.Path(os.environ['ASPECT_CJ_BUILD_CONTEXT']).read_text())
    if context['action'] == 'apply':
        path = pathlib.Path(context['sessionRoot']) / ('metadata/matches-' + context['packageName'] + '.json')
        path.write_bytes(path.read_bytes() + b'changed')
"""),
        ("earlier-executable-changed", """
if status == 0 and not os.environ.get('ASPECT_CJ_BUILD_CONTEXT') and '-o' in sys.argv:
    output = pathlib.Path(sys.argv[sys.argv.index('-o') + 1])
    if output.name == 'final-aspect_v4_linked_second':
        path = output.parent / 'final-aspect_v4_linked_app'
        path.write_bytes(path.read_bytes() + b'changed')
"""),
    ):
        wrapper = root / f"{label}-compiler.py"
        wrapper.write_text(
            "#!/usr/bin/env python3\nimport json, os, pathlib, subprocess, sys\n"
            f"status = subprocess.call([{str(args.compiler)!r}] + sys.argv[1:])\n"
            + mutation + "\nsys.exit(status)\n", encoding="utf-8")
        wrapper.chmod(0o755)
        directory, spec = config(label, [linked_library], [
            dict(linked_library, outputType="staticlib"), linked_app, linked_second])
        spec["compiler"] = str(wrapper)
        result = run_driver(args.driver, spec, directory, env, expected_success=False)
        assert "build-input-mismatch: staged file changed" in result.stdout, result.stdout
        assert not (directory / "session/complete.json").exists()
    print("matching report and earlier executable mutation block COMPLETE: PASS")

    dependency_dir = root / "prebuilt-input"
    dependency_dir.mkdir()
    library = dependency_dir / "libaspect_v4_support.a"
    result = subprocess.run([str(args.compiler), str(FIXTURES / "aspect-external-support.cj"),
                             "--output-type=staticlib", "-o", str(library)], env=env,
                            text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    assert result.returncode == 0, result.stdout
    triple = {"x86_64": "linux_x86_64_cjnative", "aarch64": "linux_aarch64_cjnative"}[platform.machine()]
    dependency = {"packageName": "aspect_v4_support", "module": str(dependency_dir / "aspect_v4_support.cjo"),
                  "library": str(library), "compilerSha256": hashlib.sha256(args.compiler.read_bytes()).hexdigest(),
                  "targetTriple": triple, "dependencies": ["std.core"]}
    directory, spec = config("prebuilt-dependency",
        [package("aspect_v4_external_source", "aspect-external-source.cj")],
        [package("aspect_v4_external_app", "aspect-external-application.cj", output_type="exe")])
    spec.update(schemaVersion=2, dependencies=[dependency])
    run_driver(args.driver, spec, directory, env, expected_success=True)
    assert run_executable(executable_output(directory / "session"), env).splitlines() == [
        "support:5", "external-body:5"]
    summary = json.loads((directory / "session/metadata/matches-aspect_v4_external_app.json").read_text())
    assert summary["preparedSources"] == 1 and summary["workUnits"] > 0, summary
    assert summary["ruleRoots"][0]["matchedTargets"] == 1, summary
    print("version 2 prebuilt dependency, snapshot and matching summary: PASS")

    for label, invalid in (("dependency-compiler", dict(dependency, compilerSha256="0" * 64)),
                           ("dependency-platform", dict(dependency, targetTriple="invalid")),
                           ("dependency-unknown", dict(dependency, dependencies=["missing.package"]))):
        directory, spec = config(label, [linked_library], [linked_app])
        spec.update(schemaVersion=2, dependencies=[invalid])
        run_driver(args.driver, spec, directory, env, expected_success=False)
        assert not (directory / "session").exists()
    print("dependency compiler, platform and closure validation: PASS")


if __name__ == "__main__":
    main()
