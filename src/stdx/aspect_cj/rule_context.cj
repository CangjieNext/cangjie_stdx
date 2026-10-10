/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.aspect_cj

import std.collection.*
import std.env.*
import std.fs.*
import std.io.*
import std.sort.*
import stdx.crypto.digest.*
import stdx.encoding.hex.*
import stdx.encoding.json.stream.*

protected struct RuleSourceInput {
    let packageName: String
    let path: String
    let sha256: String
    let sourceActionKey: String
    let metadataVersion: String
    public init(packageName: String, path: String, sha256: String, sourceActionKey: String,
        metadataVersion!: String = "v4") {
        this.packageName = packageName
        this.path = path
        this.sha256 = sha256
        this.sourceActionKey = sourceActionKey
        this.metadataVersion = metadataVersion
    }
}

protected struct RuleActionContext {
    let sessionId: String
    let action: String
    let packageName: String
    let sourceActionKey: String
    let toolchainAbiKey: String
    let sessionRoot: String
    let outputRelativePath: String
    let expectedPlanDigest: String
    let sources: Array<RuleSourceInput>

    public init(sessionId: String, action: String, packageName: String,
        sourceActionKey: String, toolchainAbiKey: String, sessionRoot: String,
        outputRelativePath: String, expectedPlanDigest: String,
        sources: Array<RuleSourceInput>) {
        this.sessionId = sessionId
        this.action = action
        this.packageName = packageName
        this.sourceActionKey = sourceActionKey
        this.toolchainAbiKey = toolchainAbiKey
        this.sessionRoot = sessionRoot
        this.outputRelativePath = outputRelativePath
        this.expectedPlanDigest = expectedPlanDigest
        this.sources = sources.clone()
    }
}

private func isLowerHex(value: String, count: Int64): Bool {
    if (value.size != count) { return false }
    for (ch in value.toArray()) {
        if (!((ch >= 48 && ch <= 57) || (ch >= 97 && ch <= 102))) { return false }
    }
    return true
}

private func safeRelativeFile(value: String): Bool {
    if (value.isEmpty() || value.startsWith("/") || value.startsWith("\\") ||
        value.contains(":") || value.contains("\\") || value.contains("\u{0}")) { return false }
    for (part in value.split("/", removeEmpty: false)) {
        if (part.isEmpty() || part == "." || part == "..") { return false }
    }
    return true
}

private func readSourceInput(reader: JsonReader): RuleSourceInput {
    reader.startObject()
    let seen = HashSet<String>()
    var packageName = ""
    var path = ""
    var digest = ""
    var sourceActionKey = ""
    var metadataVersion = "v4"
    while (reader.peek() != EndObject) {
        let key = reader.readName()
        if (!seen.add(key)) { throw IllegalArgumentException("build-phase-invalid: duplicate source key ${key}") }
        match (key) {
            case "packageName" => packageName = reader.readValue<String>()
            case "path" => path = reader.readValue<String>()
            case "sha256" => digest = reader.readValue<String>()
            case "sourceActionKey" => sourceActionKey = reader.readValue<String>()
            case "metadataVersion" => metadataVersion = reader.readValue<String>()
            case _ => throw IllegalArgumentException("build-phase-invalid: unknown source key ${key}")
        }
    }
    reader.endObject()
    if (seen.size < 4 || seen.size > 5 || packageName.isEmpty() || path.isEmpty() ||
        !isLowerHex(digest, 64) || !isLowerHex(sourceActionKey, 64) ||
        (metadataVersion != "v4" && metadataVersion != "v1" && metadataVersion != "v2")) {
        throw IllegalArgumentException("build-phase-invalid: incomplete source input")
    }
    validateRuleSourcePackage(packageName)
    return RuleSourceInput(packageName, path, digest, sourceActionKey,
        metadataVersion: metadataVersion)
}

/** Stream parsing rejects duplicate JSON names before a map can overwrite them. */
protected func parseRuleActionContext(raw: Array<Byte>): RuleActionContext {
    if (raw.isEmpty() || raw.size > 8388608) {
        throw IllegalArgumentException("build-phase-invalid: context size")
    }
    let buffer = ByteBuffer()
    buffer.write(raw)
    let reader = JsonReader(buffer)
    reader.startObject()
    let seen = HashSet<String>()
    var schemaVersion: Int64 = -1
    var sessionId = ""
    var action = ""
    var packageName = ""
    var sourceActionKey = ""
    var toolchainAbiKey = ""
    var sessionRoot = ""
    var outputRelativePath = ""
    var expectedPlanDigest = ""
    var sources: Array<RuleSourceInput> = []
    while (reader.peek() != EndObject) {
        let key = reader.readName()
        if (!seen.add(key)) { throw IllegalArgumentException("build-phase-invalid: duplicate key ${key}") }
        match (key) {
            case "schemaVersion" => schemaVersion = reader.readValue<Int64>()
            case "sessionId" => sessionId = reader.readValue<String>()
            case "action" => action = reader.readValue<String>()
            case "packageName" => packageName = reader.readValue<String>()
            case "sourceActionKey" => sourceActionKey = reader.readValue<String>()
            case "toolchainAbiKey" => toolchainAbiKey = reader.readValue<String>()
            case "sessionRoot" => sessionRoot = reader.readValue<String>()
            case "outputRelativePath" => outputRelativePath = reader.readValue<String>()
            case "expectedPlanDigest" => expectedPlanDigest = reader.readValue<String>()
            case "sources" =>
                reader.startArray()
                let items = ArrayList<RuleSourceInput>()
                while (reader.peek() != EndArray) {
                    if (items.size >= 128) { throw IllegalArgumentException("rule-limit: source packages exceed 128") }
                    items.add(readSourceInput(reader))
                }
                reader.endArray()
                sources = items.toArray()
            case _ => throw IllegalArgumentException("build-phase-invalid: unknown context key ${key}")
        }
    }
    reader.endObject()
    if (reader.peek().isSome() || seen.size != 10 || schemaVersion != 1 ||
        !isLowerHex(sessionId, 32) || !isLowerHex(sourceActionKey, 64) ||
        !isLowerHex(toolchainAbiKey, 64) ||
        (action != "collect" && action != "preselect" && action != "preflight" && action != "apply") ||
        !safeRelativeFile(outputRelativePath) || sessionRoot.isEmpty() || packageName.isEmpty()) {
        throw IllegalArgumentException("build-phase-invalid: incomplete or unsupported context")
    }
    validateRuleSourcePackage(packageName)
    if ((action == "collect" && (!sources.isEmpty() || !expectedPlanDigest.isEmpty())) ||
        ((action == "preselect" || action == "preflight") &&
            (!expectedPlanDigest.isEmpty() || sources.isEmpty())) ||
        (action == "apply" && (!isLowerHex(expectedPlanDigest, 64) || sources.isEmpty()))) {
        throw IllegalArgumentException("build-phase-invalid: action fields")
    }
    return RuleActionContext(sessionId, action, packageName, sourceActionKey,
        toolchainAbiKey, sessionRoot, outputRelativePath, expectedPlanDigest, sources)
}

protected func readRuleActionContext(action: String, packageName: String): RuleActionContext {
    let result = readRuleActionContextAny(packageName)
    if (result.action != action) {
        throw IllegalArgumentException("build-phase-invalid: action mismatch")
    }
    return result
}

protected func readRuleActionContextAny(packageName: String): RuleActionContext {
    let path = getVariable("ASPECT_CJ_BUILD_CONTEXT").getOrThrow({ =>
        IllegalArgumentException("build-phase-invalid: missing ASPECT_CJ_BUILD_CONTEXT")
    })
    let bytes = File.readFrom(Path(path))
    let result = parseRuleActionContext(bytes)
    if (result.packageName != packageName) {
        throw IllegalArgumentException("build-phase-invalid: package mismatch")
    }
    return result
}

protected func ruleSha256(bytes: Array<Byte>): String {
    let sha = SHA256()
    sha.write(bytes)
    return toHexString(sha.finish())
}

protected func readRuleSourceInputs(context: RuleActionContext): Array<RuleWirePackage> {
    let result = ArrayList<RuleWirePackage>()
    for (input in context.sources) {
        let bytes = File.readFrom(Path(input.path))
        if (bytes.size > RULE_WIRE_FILE_LIMIT || ruleSha256(bytes) != input.sha256) {
            throw IllegalArgumentException("build-input-mismatch: ${input.packageName} metadata digest")
        }
        let content = String.fromUtf8(bytes)
        if ((input.metadataVersion == "v2") != content.startsWith(ANNO_INFO_VERSION_HEADER + "\n") &&
            input.metadataVersion != "v4") {
            throw IllegalArgumentException("build-input-mismatch: legacy metadata version")
        }
        let wire = if (input.metadataVersion == "v4") { decodeRuleWire(content) } else {
            decodeLegacyRuleWire(content, context.sessionId, input.packageName,
                input.sourceActionKey, context.toolchainAbiKey)
        }
        if (wire.sourcePackage != input.packageName || wire.sessionId != context.sessionId ||
            wire.toolchainAbiKey != context.toolchainAbiKey ||
            wire.sourceActionKey != input.sourceActionKey) {
            throw IllegalArgumentException("build-input-mismatch: ${input.packageName} metadata header")
        }
        result.add(wire)
    }
    let wires = result.toArray()
    validateRuleSourceSet(wires)
    return wires
}

protected func ruleContextOutputPath(context: RuleActionContext): Path {
    let root = canonicalize(Path(context.sessionRoot))
    let target = root.join(context.outputRelativePath)
    let parent = canonicalize(target.parent)
    let prefix = root.toString() + Path.Separator
    if ((parent.toString() != root.toString() && !parent.toString().startsWith(prefix)) || exists(target)) {
        throw IllegalArgumentException("build-phase-invalid: output escapes or overwrites session")
    }
    return target
}

/** Stable digest of the complete frozen plan, including repeated L occurrences. */
protected func rulePlanDigest(plans: Array<RuleTargetPlan>): String {
    let lines = ArrayList<String>()
    for (plan in plans) {
        var occurrence: Int64 = 0
        for (call in plan.calls) {
            let record = call.record
            lines.add(String.join([
                plan.target.identifierWithoutPrefix,
                qualifiedNameWithTypeArgs(plan.target.funcType),
                call.sourcePackage, call.callee.identifierWithoutPrefix,
                record.kind, occurrence.toString(), record.sourceFile,
                record.line.toString(), record.column.toString(),
                String.join(record.fields, delimiter: "\u{1f}")], delimiter: "\u{1e}"))
            occurrence++
        }
    }
    let ordered = lines.toArray()
    sort(ordered, by: {l: String, r: String => l.compare(r)})
    return ruleSha256((String.join(ordered, delimiter: "\n") + "\n").toArray())
}

/** Bind the semantic plan to every declared input, even sources with zero matches. */
protected func ruleBuildPlanDigest(plans: Array<RuleTargetPlan>, context: RuleActionContext): String {
    let sourceLines = ArrayList<String>()
    for (source in context.sources) {
        sourceLines.add(String.join([source.packageName, source.metadataVersion,
            source.sha256, source.sourceActionKey],
            delimiter: "\u{1e}"))
    }
    let ordered = sourceLines.toArray()
    sort(ordered, by: {l: String, r: String => l.compare(r)})
    let canonical = String.join(["rule-build-plan-v1", context.sessionId, context.packageName,
        context.sourceActionKey, context.toolchainAbiKey, rulePlanDigest(plans),
        String.join(ordered, delimiter: "\n")], delimiter: "\n") + "\n"
    return ruleSha256(canonical.toArray())
}

/** Actual source-package edges; zero-match sources create no new dependency. */
protected func rulePlanSourcePackages(plans: Array<RuleTargetPlan>, targetPackage: String): Array<String> {
    let seen = HashSet<String>()
    for (plan in plans) {
        for (call in plan.calls) {
            if (call.sourcePackage != targetPackage) { seen.add(call.sourcePackage) }
        }
    }
    let ordered = ArrayList<String>()
    for (name in seen) { ordered.add(name) }
    let values = ordered.toArray()
    sort(values, by: {l: String, r: String => l.compare(r)})
    return values
}

/** The driver will publish only after compilation succeeds; plugin outputs are candidates. */
protected func writeRuleCandidate(context: RuleActionContext, value: String): Unit {
    let path = ruleContextOutputPath(context)
    let temporary = Path(path.toString() + ".tmp")
    if (exists(temporary)) {
        throw IllegalArgumentException("build-phase-invalid: temporary output already exists")
    }
    try (output = File(temporary, OpenMode.Write)) {
        output.write(value.toArray())
        output.close()
    }
    rename(temporary, to: path, overwrite: false)
}
