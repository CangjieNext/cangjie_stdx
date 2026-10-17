# Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

"""Exercise production wire snapshots under concurrent GC, including defensive copies.

The actual driver collects mixed rule/legacy metadata with the real compiler.
Only its CLI entry point is replaced for the bounded stress probe; wire parsing,
validation, encoding and ownership code are imported from the production package.
Temporary artifacts and per-stage logs are retained for failure inspection.
"""

import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import time


ASPECT_SOURCE = """package wire_gc_source
import stdx.aspect_cj.*

@PointcutRule[packageName: "wire_gc_target", className: "", methodName: "handle",
    funcTypeStr: "(Int64)->Unit", targetKind: "global", recursive: false, annotationName: ""]
class Handle {}
@PointcutRule[packageName: "wire_gc_target", className: "", methodName: "other",
    funcTypeStr: "(Int64)->Unit", targetKind: "global", recursive: false, annotationName: ""]
class Other {}
@PointcutRule[packageName: "wire_gc_target", className: "", methodName: "internalRun",
    funcTypeStr: "(Int64)->Unit", targetKind: "global", recursive: false, annotationName: ""]
class InternalCalls {}
@PointcutExpression[packageScope: "wire_gc_target", expression: "(Handle OR Other) AND NOT InternalCalls"]
class Selected {}

@InsertAtEntryByRule[rule: "wire_gc_source.Selected"]
public func before(args: Array<Any>): Unit {
    println("rule-entry:${(args[0] as Int64).getOrThrow()}")
}
@InsertAtExitByRule[rule: "wire_gc_source.Selected"]
public func after(): Unit { println("rule-exit") }
@InsertAtEntry[packageName: "wire_gc_target", className: "", methodName: "handle",
    isStatic: false, recursive: false, funcTypeStr: "(Int64)->Unit"]
public func legacyBefore(): Unit { println("legacy-entry") }
@InsertAtExit[packageName: "wire_gc_target", className: "", methodName: "handle",
    isStatic: false, recursive: false, funcTypeStr: "(Int64)->Unit"]
public func legacyAfter(): Unit { println("legacy-exit") }
"""

TARGET_SOURCE = """package wire_gc_target
public func handle(value: Int64): Unit { println("target:${value}") }
public func other(value: Int64): Unit { println("other:${value}") }
public func internalRun(value: Int64): Unit { println("internal:${value}") }
main() { handle(7) }
"""

PROBE_ENTRY = """
private func requireWireGc(value: Bool, message: String): Unit {
    if (!value) { throw Exception("wire-gc: " + message) }
}

private func checkWireGcSnapshot(wire: RuleWirePackage, expected: String): Unit {
    let records = wire.records
    requireWireGc(records.size == 8, "expected exactly eight collected records")
    var atoms = 0
    var expressions = 0
    var advices = 0
    var legacy = 0
    var conjunctions = 0
    var disjunctions = 0
    var negations = 0
    for (record in records) {
        let fields = record.fields
        requireWireGc(!fields.isEmpty(), "empty record fields")
        match (record.kind) {
            case "R" => atoms++
            case "C" =>
                expressions++
                for (field in fields) {
                    if (field == "AND") { conjunctions++ }
                    if (field == "OR") { disjunctions++ }
                    if (field == "NOT") { negations++ }
                }
            case "A" => advices++
            case "L" => legacy++
            case _ => throw Exception("wire-gc: unexpected record kind")
        }
        let original = fields[0]
        fields[0] = "mutated-returned-fields"
        requireWireGc(record.fields[0] == original, "fields getter exposed owned array")
        let second = record.fields
        second[0] = "mutated-second-fields"
        requireWireGc(record.fields[0] == original, "independent fields snapshots alias")
    }
    requireWireGc(atoms == 3 && expressions == 1 && advices == 2 && legacy == 2,
        "R/C/A/L record counts changed")
    requireWireGc(conjunctions == 1 && disjunctions == 1 && negations == 1,
        "AND/OR/NOT program changed")

    let first = records[0]
    let inputFields = first.fields
    let original = inputFields[0]
    let owned = RuleWireRecord(first.kind, first.sourceFile, first.line, first.column, inputFields)
    inputFields[0] = "mutated-constructor-input"
    requireWireGc(owned.fields[0] == original, "record constructor retained caller array")
    records[0] = RuleWireRecord("invalid", "", 0, 0, ["mutated-records-view"])
    requireWireGc(encodeRuleWire(wire) == expected, "records snapshot mutated wire package")
}

main(): Int64 {
    let arguments = getCommandLine()
    if (arguments[1] == "build-fixture") {
        runBuild(parseBuildSpec(File.readFrom(Path(arguments[2]))))
        return 0
    }
    requireWireGc(arguments[1] == "stress", "unknown probe action")
    let expected = String.fromUtf8(File.readFrom(Path(arguments[2])))
    let empty = RuleWireRecord("", "", 0, 0, [])
    requireWireGc(empty.fields.isEmpty() && empty.fields.isEmpty(), "empty fields copy changed")
    let stop = AtomicBool(false)
    let started = AtomicBool(false)
    let gcCalls = AtomicInt64(0)
    let completed = AtomicInt64(0)
    let overlaps = AtomicInt64(0)
    let collector = spawn {
        while (!stop.load()) {
            let before = completed.load()
            gc(heavy: true)
            gcCalls.fetchAdd(1)
            started.store(true)
            if (completed.load() > before) { overlaps.fetchAdd(1) }
        }
    }
    try {
        while (!started.load()) { sleep(Duration.millisecond) }
        for (_ in 0..2000) {
            let wire = decodeRuleWire(expected)
            checkWireGcSnapshot(wire, expected)
            let encoded = encodeRuleWire(wire)
            requireWireGc(encoded == expected, "encoded metadata changed")
            let decoded = decodeRuleWire(encoded)
            requireWireGc(encodeRuleWire(decoded) == expected, "roundtrip changed metadata")
            completed.fetchAdd(1)
        }
    } finally {
        stop.store(true)
        collector.get()
    }
    requireWireGc(completed.load() == 2000, "iteration count changed")
    requireWireGc(gcCalls.load() > 0 && overlaps.load() > 0, "no concurrent GC/probe progress")
    // These are GC API requests, not a claim about completed collection cycles.
    println("WIRE_GC iterations=${completed.load()} gcCalls=${gcCalls.load()} overlaps=${overlaps.load()}")
    println("wire-gc: PASS")
    return 0
}
"""


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--compiler", type=Path, required=True)
    parser.add_argument("--stdx-directory", type=Path, required=True)
    parser.add_argument("--driver-source", type=Path, default=
                        Path(__file__).resolve().parents[2] / "build/aspect_cj_driver/main.cj")
    parser.add_argument("--evidence-directory", type=Path)
    args = parser.parse_args()
    for path in (args.compiler, args.stdx_directory, args.driver_source):
        if not path.is_absolute() or not path.exists():
            parser.error(f"expected an existing absolute path: {path}")
    root = Path(tempfile.mkdtemp(prefix="aspect-wire-gc-"))
    evidence = args.evidence_directory or root
    evidence.mkdir(parents=True, exist_ok=True)
    print("work root:", root, flush=True)
    print("evidence:", evidence, flush=True)
    source = args.driver_source.read_text(encoding="utf-8")
    if source.count("\nmain(): Int64 {") != 1 or source.count("import std.collection.*") != 1:
        raise RuntimeError("driver entry point/import layout changed; review the probe injection")
    source = source.replace("\nmain(): Int64 {", "\nprivate func originalMain(): Int64 {")
    source = source.replace("import std.collection.*", "import std.collection.*\n"
                            "import std.runtime.gc\nimport std.sync.{AtomicBool, AtomicInt64}", 1)
    probe = root / "wire-gc.cj"
    probe.write_text(source + PROBE_ENTRY, encoding="utf-8")
    aspect = root / "source.cj"
    aspect.write_text(ASPECT_SOURCE, encoding="utf-8")
    target = root / "target.cj"
    target.write_text(TARGET_SOURCE, encoding="utf-8")
    env = dict(os.environ)
    sdk = Path(env.get("CANGJIE_HOME") or args.compiler.parent.parent)
    env["LD_LIBRARY_PATH"] = ":".join((str(args.stdx_directory),
                                      str(sdk / "runtime/lib/linux_x86_64_cjnative"),
                                      str(sdk / "tools/lib"), env.get("LD_LIBRARY_PATH", "")))
    env["cjHeapSize"] = "256MB"
    stress_env = dict(env, cjHeapSize="64MB")
    results = []

    def run(command, label, process_env, timeout):
        start = time.monotonic()
        try:
            result = subprocess.run(command, env=process_env, text=True, stdout=subprocess.PIPE,
                                    stderr=subprocess.STDOUT, timeout=timeout, check=False)
        except subprocess.TimeoutExpired as error:
            output = error.stdout or b""
            if isinstance(output, bytes):
                output = output.decode("utf-8", errors="replace")
            (evidence / (label + ".log")).write_text(output, encoding="utf-8")
            results.append({"stage": label, "status": "timeout", "timeout": timeout,
                            "command": command})
            (evidence / "results.json").write_text(json.dumps(results, indent=2), encoding="utf-8")
            raise RuntimeError(f"{label}: timed out after {timeout}s") from error
        (evidence / (label + ".log")).write_text(result.stdout, encoding="utf-8")
        results.append({"stage": label, "returncode": result.returncode,
                        "seconds": round(time.monotonic() - start, 2), "command": command,
                        "heap": process_env["cjHeapSize"]})
        (evidence / "results.json").write_text(json.dumps(results, indent=2), encoding="utf-8")
        if result.returncode != 0:
            raise RuntimeError(f"{label}: exit {result.returncode}\n{result.stdout[-8000:]}")
        return result.stdout

    for label, flags in (("default", []), ("O2", ["-O2"])):
        executable = root / ("wire-gc-" + label)
        run([str(args.compiler), str(probe), "--experimental", "-Woff", "unused",
             "--import-path", str(args.stdx_directory), "-L", str(args.stdx_directory),
             "-lstdx.aspect_cj", "-lstdx.encoding.json", "-lstdx.encoding.json.stream",
             *flags, "-o", str(executable)], label + "-compile", env, 180)
        session = root / ("session-" + label)
        config = {"schemaVersion": 1, "sessionId": os.urandom(16).hex(),
                  "sessionRoot": str(session), "compiler": str(args.compiler),
                  "stdxDirectory": str(args.stdx_directory),
                  "sources": [{"packageName": "wire_gc_source", "files": [str(aspect)],
                               "options": flags}],
                  "targets": [{"packageName": "wire_gc_target", "files": [str(target)],
                               "options": flags, "outputType": "exe"}]}
        config_path = root / (label + ".json")
        config_path.write_text(json.dumps(config), encoding="utf-8")
        run([str(executable), "build-fixture", str(config_path)], label + "-fixture", env, 240)
        complete = json.loads((session / "complete.json").read_text(encoding="utf-8"))
        if complete["state"] != "COMPLETE" or len(complete["outputs"]) != 1:
            raise RuntimeError(f"{label}: fixture build did not publish exactly one complete output")
        output = run([complete["outputs"][0]["path"]], label + "-target", env, 30)
        for marker in ("rule-entry:7", "rule-exit", "legacy-entry", "legacy-exit", "target:7"):
            if output.splitlines().count(marker) != 1:
                raise RuntimeError(f"{label}: expected exactly one {marker!r}, got:\n{output}")
        metadata = session / "metadata/wire_gc_source.annoinfo"
        output = run([str(executable), "stress", str(metadata)], label + "-gc", stress_env, 120)
        summary = re.findall(r"^WIRE_GC iterations=(\d+) gcCalls=(\d+) overlaps=(\d+)$",
                             output, flags=re.MULTILINE)
        if len(summary) != 1 or output.splitlines().count("wire-gc: PASS") != 1:
            raise RuntimeError(f"{label}: missing unique successful GC summary:\n{output}")
        iterations, calls, overlaps = map(int, summary[0])
        if iterations != 2000 or calls <= 0 or not 0 < overlaps <= iterations:
            raise RuntimeError(f"{label}: invalid GC/progress counters: {summary[0]}")
        results[-1].update(iterations=iterations, gcCalls=calls, overlaps=overlaps,
                           records={"R": 3, "C": 1, "A": 2, "L": 2})
        (evidence / "results.json").write_text(json.dumps(results, indent=2), encoding="utf-8")
        print(f"wire-gc-{label}: PASS (R3/C1/A2/L2, 2000 roundtrips, copies isolated, "
              f"gcCalls={calls}, overlaps={overlaps})", flush=True)


if __name__ == "__main__":
    main()
