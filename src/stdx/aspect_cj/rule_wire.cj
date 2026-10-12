/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.aspect_cj

import std.collection.*

protected const RULE_WIRE_V4_MAGIC = "#aspect_cj_annoinfo_v4"
protected const RULE_WIRE_FILE_LIMIT: Int64 = 8388608
protected const RULE_WIRE_FIELD_LIMIT: Int64 = 65536
protected const RULE_WIRE_RECORD_LIMIT: Int64 = 8192

// A wire package outlives the CHIR reader and is reused across phases. Own
// each byte sequence at this boundary, not only the Array containers.
private func ownedWireText(value: String): String { String.fromUtf8(value.toArray()) }

protected struct RuleWireRecord {
    let kind: String
    let sourceFile: String
    let line: Int64
    let column: Int64
    private let _fields: Array<String>
    public prop fields: Array<String> { get() { _fields.clone() } }

    public init(kind: String, sourceFile: String, line: Int64, column: Int64, fields: Array<String>) {
        this.kind = ownedWireText(kind)
        this.sourceFile = ownedWireText(sourceFile)
        this.line = line
        this.column = column
        this._fields = Array<String>(fields.size, {i => ownedWireText(fields[i])})
    }
}

private func copyWireRecord(record: RuleWireRecord): RuleWireRecord {
    return RuleWireRecord(record.kind, record.sourceFile, record.line, record.column, record.fields)
}

protected struct RuleWirePackage {
    let state: String
    let sessionId: String
    let sourcePackage: String
    let sourceActionKey: String
    let toolchainAbiKey: String
    let initSymbol: String
    private let _records: Array<RuleWireRecord>
    public prop records: Array<RuleWireRecord> {
        get() { Array<RuleWireRecord>(_records.size, {i => copyWireRecord(_records[i])}) }
    }

    public init(state: String, sessionId: String, sourcePackage: String, sourceActionKey: String,
        toolchainAbiKey: String, initSymbol: String, records: Array<RuleWireRecord>) {
        this.state = ownedWireText(state)
        this.sessionId = ownedWireText(sessionId)
        this.sourcePackage = ownedWireText(sourcePackage)
        this.sourceActionKey = ownedWireText(sourceActionKey)
        this.toolchainAbiKey = ownedWireText(toolchainAbiKey)
        this.initSymbol = ownedWireText(initSymbol)
        this._records = Array<RuleWireRecord>(records.size, {i => copyWireRecord(records[i])})
    }
}

private func badWire(message: String): Nothing {
    throw IllegalArgumentException("metadata-format: ${message}")
}

private func decimal(value: String): Int64 {
    if (value.isEmpty() || (value.size > 1 && value.startsWith("0"))) {
        badWire("noncanonical unsigned decimal")
    }
    var result: Int64 = 0
    for (ch in value.toArray()) {
        if (ch < 48 || ch > 57) { badWire("noncanonical unsigned decimal") }
        let digit = Int64(ch - 48)
        if (result > 922337203685477580 || (result == 922337203685477580 && digit > 7)) {
            badWire("decimal overflow")
        }
        result = result * 10 + digit
    }
    return result
}

private func boolText(value: String): Bool {
    if (value == "true") { return true }
    if (value == "false") { return false }
    badWire("noncanonical Bool")
}

private func lowerHex(value: String, length: Int64): Bool {
    if (value.size != length) { return false }
    for (ch in value.toArray()) {
        if (!((ch >= 48 && ch <= 57) || (ch >= 97 && ch <= 102))) { return false }
    }
    return true
}

private func checkWireField(value: String): Unit {
    if (value.size > RULE_WIRE_FIELD_LIMIT || containsMetadataControlCharacter(value)) {
        badWire("field size or control character")
    }
}

private func checkRuleReference(sourcePackage: String, id: String): Unit {
    validateRuleProgram(sourcePackage, [RuleToken(String.join(["REF:", id], delimiter: ""))])
}

protected func validatedRuleWireGraph(wire: RuleWirePackage,
    records: Array<RuleWireRecord>): RuleGraph {
    if (wire.state != "READY" && wire.state != "PENDING") { badWire("unknown state") }
    if (!lowerHex(wire.sessionId, 32) || !lowerHex(wire.sourceActionKey, 64) ||
        !lowerHex(wire.toolchainAbiKey, 64)) { badWire("invalid session or key") }
    validateRuleSourcePackage(wire.sourcePackage)
    checkWireField(wire.sourcePackage)
    checkWireField(wire.initSymbol)
    if (records.size > RULE_WIRE_RECORD_LIMIT) { badWire("record limit") }
    if (wire.state == "PENDING" && !records.isEmpty()) { badWire("PENDING has records") }
    let definitions = ArrayList<RuleDefinition>()
    let atoms = HashMap<String, RuleAtomSpec>()
    let adviceKeys = HashSet<String>()
    let newSymbols = HashSet<String>()
    let legacySymbols = HashSet<String>()
    var adviceCount: Int64 = 0
    for (record in records) {
        checkWireField(record.kind)
        checkWireField(record.sourceFile)
        if (record.line < 0 || record.column < 0 || record.fields.size > 260) { badWire("record header") }
        for (field in record.fields) { checkWireField(field) }
        match (record.kind) {
            case "R" =>
                if (record.fields.size != 8) { badWire("R field count") }
                let f = record.fields
                checkRuleReference(wire.sourcePackage, f[0])
                let atom = RuleAtomSpec(f[1], f[2], f[3], f[4], f[5], boolText(f[6]), f[7])
                validateRuleAtom(atom)
                atoms[f[0]] = atom
                definitions.add(RuleDefinition(f[0], f[1]))
            case "C" =>
                if (record.fields.size < 4) { badWire("C field count") }
                let f = record.fields
                checkRuleReference(wire.sourcePackage, f[0])
                if (!isValidPackageNamePattern(f[1])) { badWire("invalid C package scope") }
                let count = decimal(f[2])
                if (count != f.size - 3 || count > RULE_EXPRESSION_TOKENS) { badWire("C token count") }
                let program = Array<RuleToken>(count, {i => RuleToken(f[i + 3])})
                validateRuleProgram(wire.sourcePackage, program)
                definitions.add(RuleDefinition(f[0], f[1], program))
            case "A" =>
                if (record.fields.size != 5) { badWire("A field count") }
                let f = record.fields
                if (f[0] != "ENTRY" && f[0] != "EXIT") { badWire("A kind") }
                if (f[1].isEmpty() || (f[2] != "global" && f[2] != "static") ||
                    (f[3] != "none" && f[3] != "array-any")) { badWire("A signature mode") }
                checkRuleReference(wire.sourcePackage, f[4])
                if (!adviceKeys.add(String.join([f[1], f[0]], delimiter: "\u{1f}"))) {
                    badWire("duplicate A")
                }
                newSymbols.add(f[1])
                adviceCount++
            case "L" =>
                if (record.fields.size != 13) { badWire("L field count") }
                let f = record.fields
                if (f[0] != INSERT_AT_ENTRY_ANNO_CLASS_NAME && f[0] != INSERT_AT_EXIT_ANNO_CLASS_NAME &&
                    f[0] != REPLACE_FUNC_BODY_ANNO_CLASS_NAME) { badWire("L control identity") }
                if (f[1] != wire.sourcePackage || f[2].isEmpty()) { badWire("L source identity") }
                decimal(f[3])
                boolText(f[4]); boolText(f[5]); boolText(f[6]); boolText(f[11]); boolText(f[12])
                if (!isValidPackageNamePattern(f[7]) || !isValidFunctionTypePattern(f[10])) {
                    badWire("L target pattern")
                }
                legacySymbols.add(f[2])
                adviceCount++
            case _ => badWire("unknown record kind")
        }
    }
    if (adviceCount > 0 && wire.initSymbol.isEmpty()) { badWire("missing source initializer") }
    if (adviceCount > RULE_PACKAGE_COUNT) { badWire("advice limit") }
    for (symbol in newSymbols) {
        if (legacySymbols.contains(symbol)) { badWire("old/new advice mix") }
    }
    let graph = RuleGraph(wire.sourcePackage, definitions.toArray(),
        {id => if (!atoms.contains(id)) { badWire("missing R atom") } },
        {scope => if (!isValidPackageNamePattern(scope)) { badWire("invalid rule scope") } })
    let roots = ArrayList<String>()
    for (record in records) { if (record.kind == "A") { roots.add(record.fields[4]) } }
    graph.validateRoots(roots.toArray())
    return graph
}

protected func validateWirePackage(wire: RuleWirePackage): Unit {
    validatedRuleWireGraph(wire, wire.records)
}

/** Exact encoded size of already validated records, without another graph build. */
protected func validatedRuleWireSize(wire: RuleWirePackage, records: Array<RuleWireRecord>): Int64 {
    var size = RULE_WIRE_V4_MAGIC.size + wire.state.size + wire.sessionId.size + wire.sourcePackage.size +
        wire.sourceActionKey.size + wire.toolchainAbiKey.size + wire.initSymbol.size +
        "1".size + records.size.toString().size + 9
    for (record in records) {
        size += record.kind.size + record.fields.size.toString().size + record.sourceFile.size +
            record.line.toString().size + record.column.toString().size + 5
        for (field in record.fields) { size += field.size + 1 }
        if (size > RULE_WIRE_FILE_LIMIT) { badWire("file limit") }
    }
    return size
}

protected func encodeRuleWire(wire: RuleWirePackage): String {
    validateWirePackage(wire)
    let records = wire.records
    let lines = ArrayList<String>([
        RULE_WIRE_V4_MAGIC, wire.state, wire.sessionId, wire.sourcePackage,
        wire.sourceActionKey, wire.toolchainAbiKey, wire.initSymbol, "1", records.size.toString()])
    for (record in records) {
        lines.add(record.kind)
        lines.add(record.fields.size.toString())
        lines.add(record.sourceFile)
        lines.add(record.line.toString())
        lines.add(record.column.toString())
        for (field in record.fields) { lines.add(field) }
    }
    let text = String.join(lines.toArray(), delimiter: "\n") + "\n"
    if (text.size > RULE_WIRE_FILE_LIMIT) { badWire("file limit") }
    return text
}

protected func decodeRuleWire(text: String): RuleWirePackage {
    if (text.size > RULE_WIRE_FILE_LIMIT || !text.endsWith("\n") || text.contains("\r") || text.contains("\u{0}")) {
        badWire("file size or newline")
    }
    let lines = text.split("\n", removeEmpty: false)
    if (lines.size < 10 || lines[0] != RULE_WIRE_V4_MAGIC || lines[lines.size - 1] != "") {
        badWire("magic or header")
    }
    if (lines[7] != "1") { badWire("annotation metadata version") }
    let count = decimal(lines[8])
    if (count > RULE_WIRE_RECORD_LIMIT) { badWire("record limit") }
    var cursor: Int64 = 9
    let records = ArrayList<RuleWireRecord>()
    for (_ in 0..count) {
        if (cursor + 5 > lines.size - 1) { badWire("truncated record") }
        let kind = lines[cursor]
        let n = decimal(lines[cursor + 1])
        if (n > 260 || n > lines.size - 1 - (cursor + 5)) { badWire("field count or truncated record") }
        let location = lines[cursor + 2]
        let line = decimal(lines[cursor + 3])
        let column = decimal(lines[cursor + 4])
        let firstField = cursor + 5
        let fields = Array<String>(n, {i => lines[firstField + i]})
        records.add(RuleWireRecord(kind, location, line, column, fields))
        cursor += 5 + n
    }
    if (cursor != lines.size - 1) { badWire("trailing data") }
    let wire = RuleWirePackage(lines[1], lines[2], lines[3], lines[4], lines[5], lines[6], records.toArray())
    validateWirePackage(wire)
    return wire
}

/** Explicit v1/v2 input adapter. The driver supplies the source identity and file digest. */
protected func decodeLegacyRuleWire(text: String, sessionId: String, sourcePackage: String,
    sourceActionKey: String, toolchainAbiKey: String): RuleWirePackage {
    if (text.isEmpty() || text.size > RULE_WIRE_FILE_LIMIT || text.contains("\r") ||
        text.contains("\u{0}")) { badWire("legacy file size or control character") }
    let lines = text.split("\n", removeEmpty: false)
    let end = lines.size - if (lines[lines.size - 1] == "") { 1 } else { 0 }
    if (end == 0) { badWire("empty legacy file") }
    let version2 = lines[0] == ANNO_INFO_VERSION_HEADER
    if (lines[0].startsWith("#aspect_cj_annoinfo_") && !version2) {
        badWire("unsupported legacy version")
    }
    var cursor: Int64 = if (version2) { 1 } else { 0 }
    let width: Int64 = if (version2) { 15 } else { 14 }
    if (cursor >= end || (end - cursor) % width != 0 || (end - cursor) / width > RULE_WIRE_RECORD_LIMIT) {
        badWire("legacy record length")
    }
    var initSymbol = ""
    let records = ArrayList<RuleWireRecord>()
    while (cursor < end) {
        if (lines[cursor] != sourcePackage) { badWire("legacy source package mismatch") }
        let candidateInit = lines[cursor + 1]
        if (candidateInit.isEmpty() || (!initSymbol.isEmpty() && initSymbol != candidateInit)) {
            badWire("legacy source initializer mismatch")
        }
        initSymbol = candidateInit
        let arrayMode = if (version2) { lines[cursor + 8] } else { "false" }
        let toOffset: Int64 = if (version2) { 9 } else { 8 }
        records.add(RuleWireRecord("L", "", 0, 0, [
            lines[cursor + 2], lines[cursor + 3], lines[cursor + 4], lines[cursor + 5],
            lines[cursor + 6], lines[cursor + 7], arrayMode,
            lines[cursor + toOffset], lines[cursor + toOffset + 1],
            lines[cursor + toOffset + 2], lines[cursor + toOffset + 3],
            lines[cursor + toOffset + 4], lines[cursor + toOffset + 5]]))
        cursor += width
    }
    let result = RuleWirePackage("READY", sessionId, sourcePackage, sourceActionKey,
        toolchainAbiKey, initSymbol, records.toArray())
    validateWirePackage(result)
    return result
}
