/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.aspect_cj.driver

import std.collection.*
import std.env.*
import std.fs.*
import std.io.*
import std.process.*
import std.sort.*
import stdx.aspect_cj.*
import stdx.encoding.json.*
import stdx.encoding.json.stream.*

private struct PackageSpec {
    let name: String
    let files: Array<String>
    let options: Array<String>
    let outputType: String
    public init(name: String, files: Array<String>, options: Array<String>, outputType: String) {
        this.name = name
        this.files = files.clone()
        this.options = options.clone()
        this.outputType = outputType
    }
}

private struct BuildSpec {
    let sessionId: String
    let sessionRoot: String
    let compiler: String
    let stdxDir: String
    let sources: Array<PackageSpec>
    let targets: Array<PackageSpec>
    public init(sessionId: String, sessionRoot: String, compiler: String, stdxDir: String,
        sources: Array<PackageSpec>, targets: Array<PackageSpec>) {
        this.sessionId = sessionId
        this.sessionRoot = sessionRoot
        this.compiler = compiler
        this.stdxDir = stdxDir
        this.sources = sources.clone()
        this.targets = targets.clone()
    }
}

private func readStrings(reader: JsonReader): Array<String> {
    reader.startArray()
    let result = ArrayList<String>()
    while (reader.peek() != EndArray) {
        if (result.size >= 128) { throw IllegalArgumentException("driver-limit: array") }
        result.add(reader.readValue<String>())
    }
    reader.endArray()
    return result.toArray()
}

private func readPackage(reader: JsonReader, target: Bool): PackageSpec {
    reader.startObject()
    let seen = HashSet<String>()
    var name = ""
    var files: Array<String> = []
    var options: Array<String> = []
    var outputType = "staticlib"
    while (reader.peek() != EndObject) {
        let key = reader.readName()
        if (!seen.add(key)) { throw IllegalArgumentException("driver-config: duplicate package key") }
        match (key) {
            case "packageName" => name = reader.readValue<String>()
            case "files" => files = readStrings(reader)
            case "options" => options = readStrings(reader)
            case "outputType" => outputType = reader.readValue<String>()
            case _ => throw IllegalArgumentException("driver-config: unknown package key ${key}")
        }
    }
    reader.endObject()
    if (!seen.contains("packageName") || !seen.contains("files") || !seen.contains("options") ||
        name.isEmpty() || files.isEmpty() || (target && !seen.contains("outputType")) ||
        (!target && seen.contains("outputType")) ||
        (outputType != "exe" && outputType != "staticlib")) {
        throw IllegalArgumentException("driver-config: incomplete package")
    }
    validateRuleSourcePackage(name)
    for (file in files) {
        if (!file.startsWith("/") || !exists(Path(file))) {
            throw IllegalArgumentException("driver-config: source must be an existing absolute path ${file}")
        }
    }
    for (option in options) {
        // Arbitrary cjc options can add untracked imports/libraries or another
        // plugin, invalidating the action key and the single-plugin invariant.
        if (option != "-O0" && option != "-O1" && option != "-O2" &&
            option != "-Os" && option != "-Oz" && option != "--disable-reflection") {
            throw IllegalArgumentException("driver-config: unsupported compiler option ${option}")
        }
    }
    return PackageSpec(name, files, options, outputType)
}

private func parseBuildSpec(bytes: Array<Byte>): BuildSpec {
    if (bytes.isEmpty() || bytes.size > 8388608) { throw IllegalArgumentException("driver-config: size") }
    let buffer = ByteBuffer()
    buffer.write(bytes)
    let reader = JsonReader(buffer)
    reader.startObject()
    let seen = HashSet<String>()
    var version: Int64 = -1
    var sessionId = ""
    var sessionRoot = ""
    var compiler = ""
    var stdxDir = ""
    var sources: Array<PackageSpec> = []
    var targets: Array<PackageSpec> = []
    while (reader.peek() != EndObject) {
        let key = reader.readName()
        if (!seen.add(key)) { throw IllegalArgumentException("driver-config: duplicate key ${key}") }
        match (key) {
            case "schemaVersion" => version = reader.readValue<Int64>()
            case "sessionId" => sessionId = reader.readValue<String>()
            case "sessionRoot" => sessionRoot = reader.readValue<String>()
            case "compiler" => compiler = reader.readValue<String>()
            case "stdxDirectory" => stdxDir = reader.readValue<String>()
            case "sources" =>
                reader.startArray()
                let values = ArrayList<PackageSpec>()
                while (reader.peek() != EndArray) {
                    if (values.size >= 128) { throw IllegalArgumentException("driver-limit: source packages") }
                    values.add(readPackage(reader, false))
                }
                reader.endArray()
                sources = values.toArray()
            case "targets" =>
                reader.startArray()
                let values = ArrayList<PackageSpec>()
                while (reader.peek() != EndArray) {
                    if (values.size >= 128) { throw IllegalArgumentException("driver-limit: target packages") }
                    values.add(readPackage(reader, true))
                }
                reader.endArray()
                targets = values.toArray()
            case _ => throw IllegalArgumentException("driver-config: unknown key ${key}")
        }
    }
    reader.endObject()
    if (reader.peek().isSome() || seen.size != 7 || version != 1 || sessionId.size != 32 ||
        !sessionRoot.startsWith("/") || !compiler.startsWith("/") ||
        !stdxDir.startsWith("/") ||
        sources.isEmpty() || targets.isEmpty()) {
        throw IllegalArgumentException("driver-config: incomplete or unsupported")
    }
    for (ch in sessionId.toArray()) {
        if (!((ch >= 48 && ch <= 57) || (ch >= 97 && ch <= 102))) {
            throw IllegalArgumentException("driver-config: session ID")
        }
    }
    if (!exists(Path(compiler)) || !exists(Path(stdxDir)) || exists(Path(sessionRoot))) {
        throw IllegalArgumentException("driver-config: toolchain or fresh session root")
    }
    let names = HashSet<String>()
    for (source in sources) {
        if (!names.add(source.name)) { throw IllegalArgumentException("driver-config: duplicate source") }
    }
    let targetNames = HashSet<String>()
    for (target in targets) {
        if (!targetNames.add(target.name)) { throw IllegalArgumentException("driver-config: duplicate target") }
    }
    return BuildSpec(sessionId, sessionRoot, compiler, stdxDir, sources, targets)
}

private func writeNew(path: Path, content: String): Unit {
    if (exists(path)) { throw IllegalArgumentException("driver-output: refusing overwrite ${path}") }
    try (file = File(path, OpenMode.Write)) {
        file.write(content.toArray())
        file.close()
    }
}

private func publish(root: String, name: String, body: JsonObject): String {
    let value = body.toString() + "\n"
    if (value.size > 8388608) { throw IllegalArgumentException("driver-limit: manifest size") }
    let temporary = Path(root).join(name + ".tmp")
    let final = Path(root).join(name)
    writeNew(temporary, value)
    rename(temporary, to: final, overwrite: false)
    return ruleSha256(value.toArray())
}

private func digest(path: String): String { ruleSha256(File.readFrom(Path(path))) }

private func directoryDigest(directory: String): String {
    let root = Path(directory)
    if (!exists(root)) { throw IllegalArgumentException("driver-config: missing toolchain directory ${directory}") }
    let paths = ArrayList<String>()
    Directory.walk(root) { entry =>
        if (entry.isRegular() || entry.isSymbolicLink()) {
            paths.add(entry.path.toString())
        }
        true
    }
    let ordered = paths.toArray()
    sort(ordered, by: {left: String, right: String => left.compare(right)})
    let lines = ArrayList<String>()
    for (path in ordered) { lines.add(path + "\u{1f}" + digest(path)) }
    return ruleSha256((String.join(lines.toArray(), delimiter: "\n") + "\n").toArray())
}

private func toolchainDigest(spec: BuildSpec): String {
    let sdk = getVariable("CANGJIE_HOME") ?? ""
    if (!sdk.startsWith("/")) {
        throw IllegalArgumentException("driver-config: CANGJIE_HOME must be an absolute SDK path")
    }
    let inputs = [sdk + "/lib", sdk + "/runtime/lib", sdk + "/modules",
        sdk + "/tools", spec.stdxDir]
    let lines = ArrayList<String>([spec.compiler, digest(spec.compiler)])
    for (directory in inputs) {
        lines.add(directory)
        lines.add(directoryDigest(directory))
    }
    return ruleSha256((String.join(lines.toArray(), delimiter: "\n") + "\n").toArray())
}

private func verifyToolchainState(spec: BuildSpec, expected: String): Unit {
    if (toolchainDigest(spec) != expected) {
        throw IllegalArgumentException("build-input-mismatch: compiler, SDK or stdx changed")
    }
}

private func sourceKey(spec: PackageSpec, abi: String): String {
    var text = abi + "\n" + spec.name + "\n" + spec.outputType + "\n"
    for (file in spec.files) { text += file + "\n" + digest(file) + "\n" }
    for (option in spec.options) { text += option + "\n" }
    return ruleSha256(text.toArray())
}

private func actionKey(spec: PackageSpec, abi: String, dependencies: Array<String>, root: Path): String {
    var text = sourceKey(spec, abi) + "\n"
    for (name in dependencies) {
        text += name + "\n" + digest(root.join("artifacts/lib${name}.a").toString()) + "\n"
    }
    return ruleSha256(text.toArray())
}

private func stringField(obj: JsonObject, key: String, value: String): Unit {
    obj.put(key, JsonString(value))
}

private func actionContext(spec: BuildSpec, action: String, packageName: String,
    actionKey: String, abi: String, output: String, sourceInputs: JsonArray,
    expectedPlan: String): JsonObject {
    let obj = JsonObject()
    obj.put("schemaVersion", JsonInt(1))
    stringField(obj, "sessionId", spec.sessionId)
    stringField(obj, "action", action)
    stringField(obj, "packageName", packageName)
    stringField(obj, "sourceActionKey", actionKey)
    stringField(obj, "toolchainAbiKey", abi)
    stringField(obj, "sessionRoot", spec.sessionRoot)
    stringField(obj, "outputRelativePath", output)
    stringField(obj, "expectedPlanDigest", expectedPlan)
    obj.put("sources", sourceInputs)
    return obj
}

private func runCompiler(spec: BuildSpec, label: String, args: Array<String>,
    context: JsonObject, dependencyReport: String): Unit {
    let contextPath = Path(spec.sessionRoot).join(label + ".json")
    writeNew(contextPath, context.toString() + "\n")
    let env = HashMap<String, String>()
    env["ASPECT_CJ_BUILD_CONTEXT"] = contextPath.toString()
    env["ASPECT_CJ_DEPENDENCY_REPORT"] = dependencyReport
    env["PATH"] = getVariable("PATH") ?? ""
    env["CANGJIE_HOME"] = getVariable("CANGJIE_HOME") ?? ""
    let stdxPath = spec.stdxDir
    let sdkRuntime = getVariable("LD_LIBRARY_PATH") ?? ""
    env["LD_LIBRARY_PATH"] = stdxPath + ":" + sdkRuntime
    let status = execute(spec.compiler, args, environment: env)
    if (status != 0) {
        throw IllegalArgumentException("driver-build: ${label} compiler exit ${status}")
    }
}

private func readDependencies(path: Path, packageName: String): Array<String> {
    let bytes = File.readFrom(path)
    if (bytes.isEmpty() || bytes.size > 1048576) {
        throw IllegalArgumentException("driver-build: dependency report size")
    }
    let text = String.fromUtf8(bytes)
    if (!text.endsWith("\n") || text.contains("\r") || text.contains("\u{0}")) {
        throw IllegalArgumentException("driver-build: dependency report encoding")
    }
    let lines = text.split("\n", removeEmpty: false)
    if (lines.size < 3 || lines[0] != "#aspect_cj_dependencies_v1" ||
        lines[1] != packageName || lines[lines.size - 1] != "") {
        throw IllegalArgumentException("driver-build: dependency report header")
    }
    let seen = HashSet<String>()
    let result = ArrayList<String>()
    for (i in 2..lines.size - 1) {
        let name = lines[i]
        validateRuleSourcePackage(name)
        if (name == packageName || !seen.add(name)) {
            throw IllegalArgumentException("driver-build: invalid dependency ${name}")
        }
        result.add(name)
    }
    return result.toArray()
}

private func commonArgs(spec: BuildSpec, unit: PackageSpec): ArrayList<String> {
    let result = ArrayList<String>()
    for (file in unit.files) { result.add(file) }
    result.add("--experimental")
    result.add("--emit-chir-annotation-metadata")
    result.add("--import-path")
    result.add(spec.stdxDir)
    result.add("-L")
    result.add(spec.stdxDir)
    result.add("-lstdx.aspect_cj")
    for (option in unit.options) { result.add(option) }
    return result
}

private func sourceList(spec: BuildSpec, except: String): Array<String> {
    let result = ArrayList<String>()
    for (source in spec.sources) {
        if (source.name != except) { result.add(source.name) }
    }
    return result.toArray()
}

private func symbolFile(spec: BuildSpec, targetName: String,
    selectedSources: Array<String>, root: Path): Path {
    let symbols = HashSet<String>()
    let selected = HashSet<String>()
    for (source in selectedSources) { selected.add(source) }
    for (source in spec.sources) {
        if (source.name == targetName || !selected.contains(source.name)) { continue }
        let wire = decodeRuleWire(String.fromUtf8(
            File.readFrom(root.join("metadata/${source.name}.annoinfo"))))
        for (record in wire.records) {
            if (record.kind == "A") { symbols.add(record.fields[1]) }
            if (record.kind == "L") { symbols.add(record.fields[2]) }
        }
    }
    let ordered = ArrayList<String>()
    for (symbol in symbols) { ordered.add(symbol) }
    let values = ordered.toArray()
    sort(values, by: {left: String, right: String => left.compare(right)})
    let path = root.join("aspect-import-symbols-${targetName}.txt")
    writeNew(path, if (values.isEmpty()) { "" } else { String.join(values, delimiter: "\n") + "\n" })
    return path
}

private func readSelectedSources(path: Path, spec: BuildSpec): Array<String> {
    let bytes = File.readFrom(path)
    if (bytes.isEmpty() || bytes.size > 1048576) {
        throw IllegalArgumentException("driver-build: preselection report size")
    }
    let text = String.fromUtf8(bytes)
    if (!text.endsWith("\n") || text.contains("\r") || text.contains("\u{0}")) {
        throw IllegalArgumentException("driver-build: preselection report encoding")
    }
    let lines = text.split("\n", removeEmpty: false)
    if (lines.size < 2 || lines[0] != "#aspect_cj_selected_sources_v1" ||
        lines[lines.size - 1] != "") {
        throw IllegalArgumentException("driver-build: preselection report header")
    }
    let known = HashSet<String>()
    for (source in spec.sources) { known.add(source.name) }
    let seen = HashSet<String>()
    let result = ArrayList<String>()
    for (i in 1..lines.size - 1) {
        let name = lines[i]
        if (!known.contains(name) || !seen.add(name)) {
            throw IllegalArgumentException("driver-build: invalid selected source ${name}")
        }
        result.add(name)
    }
    return result.toArray()
}

private func hasDependencyCycle(node: String, graph: HashMap<String, Array<String>>,
    visiting: HashSet<String>, visited: HashSet<String>, trail: ArrayList<String>): Bool {
    if (visiting.contains(node)) {
        trail.add(node)
        return true
    }
    if (visited.contains(node)) { return false }
    visiting.add(node)
    trail.add(node)
    for (next in graph.get(node) ?? []) {
        if (hasDependencyCycle(next, graph, visiting, visited, trail)) { return true }
    }
    visiting.remove(node)
    visited.add(node)
    trail.remove(at: trail.size - 1)
    return false
}

private func rejectDependencyCycles(graph: HashMap<String, Array<String>>): Unit {
    let visited = HashSet<String>()
    for ((key, _) in graph) {
        let trail = ArrayList<String>()
        if (hasDependencyCycle(key, graph, HashSet<String>(), visited, trail)) {
            throw IllegalArgumentException("dependency-cycle: " +
                String.join(trail.toArray(), delimiter: " -> "))
        }
    }
}

private func verifySourceState(spec: BuildSpec, abi: String, root: Path,
    keys: HashMap<String, String>, metadata: HashMap<String, String>,
    artifacts: HashMap<String, String>, dependencies: HashMap<String, String>): Unit {
    let prior = ArrayList<String>()
    for (source in spec.sources) {
        if (actionKey(source, abi, prior.toArray(), root) != keys[source.name] ||
            digest(root.join("metadata/${source.name}.annoinfo").toString()) != metadata[source.name] ||
            digest(root.join("artifacts/lib${source.name}.a").toString()) != artifacts[source.name] ||
            digest(root.join("dependencies-collect-${source.name}.txt").toString()) !=
                dependencies[source.name]) {
            throw IllegalArgumentException("build-input-mismatch: source changed ${source.name}")
        }
        prior.add(source.name)
    }
}

private func runBuild(spec: BuildSpec): Unit {
    let root = Path(spec.sessionRoot)
    Directory.create(root)
    Directory.create(root.join("metadata"))
    Directory.create(root.join("artifacts"))
    let abi = toolchainDigest(spec)
    let sourceInputs = JsonArray()
    let sourceKeys = HashMap<String, String>()
    let metadataDigests = HashMap<String, String>()
    let artifactDigests = HashMap<String, String>()
    let sourceDependencyDigests = HashMap<String, String>()
    let graph = HashMap<String, Array<String>>()
    let sourceManifest = JsonObject()
    sourceManifest.put("schemaVersion", JsonInt(1))
    stringField(sourceManifest, "sessionId", spec.sessionId)
    stringField(sourceManifest, "state", "SOURCES_READY")
    stringField(sourceManifest, "toolchainAbiKey", abi)
    let sourceArtifacts = JsonArray()
    let priorSources = ArrayList<String>()
    for (source in spec.sources) {
        let key = actionKey(source, abi, priorSources.toArray(), root)
        let metadata = "metadata/${source.name}.annoinfo"
        let artifact = "artifacts/lib${source.name}.a"
        let args = commonArgs(spec, source)
        args.add("--import-path")
        args.add(root.join("artifacts").toString())
        args.add("-L")
        args.add(root.join("artifacts").toString())
        for (name in priorSources) { args.add("-l:lib${name}.a") }
        args.add("--plugin=${spec.stdxDir}/libstdx.collect_rules.so")
        args.add("--output-type=staticlib")
        args.add("-o")
        args.add(root.join(artifact).toString())
        let dependencyPath = root.join("dependencies-collect-${source.name}.txt")
        runCompiler(spec, "collect-${source.name}", args.toArray(),
            actionContext(spec, "collect", source.name, key, abi, metadata, JsonArray(), ""),
            dependencyPath.toString())
        graph[source.name] = readDependencies(dependencyPath, source.name)
        let metaPath = root.join(metadata).toString()
        let artifactPath = root.join(artifact).toString()
        if (!exists(Path(metaPath)) || !exists(Path(artifactPath))) {
            throw IllegalArgumentException("driver-build: missing collect output ${source.name}")
        }
        let wire = decodeRuleWire(String.fromUtf8(File.readFrom(Path(metaPath))))
        if (wire.state != "READY" || wire.sourcePackage != source.name ||
            wire.sessionId != spec.sessionId || wire.sourceActionKey != key ||
            wire.toolchainAbiKey != abi) {
            throw IllegalArgumentException("driver-build: invalid collect metadata ${source.name}")
        }
        let input = JsonObject()
        stringField(input, "packageName", source.name)
        stringField(input, "path", metaPath)
        stringField(input, "sha256", digest(metaPath))
        stringField(input, "sourceActionKey", key)
        sourceInputs.add(input)
        sourceKeys[source.name] = key
        metadataDigests[source.name] = digest(metaPath)
        artifactDigests[source.name] = digest(artifactPath)
        sourceDependencyDigests[source.name] = digest(dependencyPath.toString())
        let entry = JsonObject()
        stringField(entry, "packageName", source.name)
        stringField(entry, "metadataPath", metadata)
        stringField(entry, "metadataSha256", digest(metaPath))
        stringField(entry, "artifactPath", artifact)
        stringField(entry, "artifactSha256", digest(artifactPath))
        stringField(entry, "dependencyReportSha256", digest(dependencyPath.toString()))
        stringField(entry, "sourceActionKey", key)
        sourceArtifacts.add(entry)
        priorSources.add(source.name)
    }
    sourceManifest.put("sources", sourceArtifacts)
    verifyToolchainState(spec, abi)
    let sourcesDigest = publish(spec.sessionRoot, "sources.json", sourceManifest)

    let plans = JsonArray()
    let digests = HashMap<String, String>()
    let targetDependencyDigests = HashMap<String, String>()
    let targetPlanFileDigests = HashMap<String, String>()
    let knownSources = HashSet<String>()
    for (source in spec.sources) { knownSources.add(source.name) }
    for (target in spec.targets) {
        let importedSources = sourceList(spec, target.name)
        let key = actionKey(target, abi, importedSources, root)
        let selectionPath = root.join("metadata/selected-${target.name}.txt")
        let selectionArgs = commonArgs(spec, target)
        selectionArgs.add("--plugin=${spec.stdxDir}/libstdx.weave_rules.so")
        selectionArgs.add("--import-path")
        selectionArgs.add(root.join("artifacts").toString())
        selectionArgs.add("-L")
        selectionArgs.add(root.join("artifacts").toString())
        for (name in importedSources) { selectionArgs.add("-l:lib${name}.a") }
        selectionArgs.add("--output-type=staticlib")
        selectionArgs.add("-o")
        selectionArgs.add(root.join("artifacts/preselect-${target.name}.a").toString())
        verifySourceState(spec, abi, root, sourceKeys, metadataDigests, artifactDigests,
            sourceDependencyDigests)
        runCompiler(spec, "preselect-${target.name}", selectionArgs.toArray(),
            actionContext(spec, "preselect", target.name, key, abi,
                "metadata/selected-${target.name}.txt", sourceInputs, ""),
            root.join("dependencies-preselect-${target.name}.txt").toString())
        verifySourceState(spec, abi, root, sourceKeys, metadataDigests, artifactDigests,
            sourceDependencyDigests)
        if (actionKey(target, abi, importedSources, root) != key ||
            !exists(root.join("artifacts/preselect-${target.name}.a"))) {
            throw IllegalArgumentException("build-input-mismatch: target changed during preselection")
        }
        let selectedSources = readSelectedSources(selectionPath, spec)
        let generatedImports = ArrayList<String>()
        for (sourceName in selectedSources) {
            if (sourceName != target.name) { generatedImports.add("import ${sourceName}.*") }
        }
        let imports = "package ${target.name}\n" +
            String.join(generatedImports.toArray(), delimiter: "\n") + "\n"
        let importPath = root.join("imports-${target.name}.cj")
        writeNew(importPath, imports)
        let symbols = symbolFile(spec, target.name, selectedSources, root)
        let args = commonArgs(spec, target)
        args.add(importPath.toString())
        args.add("--plugin=${spec.stdxDir}/libstdx.weave_rules.so")
        args.add("--aspect-import-symbols")
        args.add(symbols.toString())
        args.add("--import-path")
        args.add(root.join("artifacts").toString())
        args.add("-L")
        args.add(root.join("artifacts").toString())
        for (name in importedSources) { args.add("-l:lib${name}.a") }
        // Preflight produces a temporary archive. Linking is deliberately
        // deferred to apply so a link failure cannot publish COMPLETE.
        args.add("--output-type=staticlib")
        args.add("-o")
        args.add(root.join("artifacts/preflight-${target.name}.a").toString())
        let report = "metadata/plan-${target.name}.digest"
        let importDigest = digest(importPath.toString())
        let symbolDigest = digest(symbols.toString())
        let dependencyPath = root.join("dependencies-preflight-${target.name}.txt")
        verifySourceState(spec, abi, root, sourceKeys, metadataDigests, artifactDigests,
            sourceDependencyDigests)
        runCompiler(spec, "preflight-${target.name}", args.toArray(),
            actionContext(spec, "preflight", target.name, key, abi, report, sourceInputs, ""),
            dependencyPath.toString())
        verifySourceState(spec, abi, root, sourceKeys, metadataDigests, artifactDigests,
            sourceDependencyDigests)
        if (actionKey(target, abi, importedSources, root) != key ||
            digest(importPath.toString()) != importDigest ||
            digest(symbols.toString()) != symbolDigest ||
            !exists(root.join("artifacts/preflight-${target.name}.a"))) {
            throw IllegalArgumentException("build-input-mismatch: target changed during preflight")
        }
        let reportLines = String.fromUtf8(File.readFrom(root.join(report))).split("\n", removeEmpty: false)
        if (reportLines.size < 2 || reportLines[0].size != 64 || reportLines[reportLines.size - 1] != "") {
            throw IllegalArgumentException("driver-build: invalid plan report")
        }
        digests[target.name] = reportLines[0]
        targetDependencyDigests[target.name] = digest(dependencyPath.toString())
        targetPlanFileDigests[target.name] = digest(root.join(report).toString())
        let dependencies = ArrayList<String>()
        let dependencySeen = HashSet<String>()
        for (name in readDependencies(dependencyPath, target.name)) {
            if (dependencySeen.add(name)) { dependencies.add(name) }
        }
        let aspectEdges = HashSet<String>()
        for (i in 1..reportLines.size - 1) {
            let sourceName = reportLines[i]
            if (!knownSources.contains(sourceName) || sourceName == target.name ||
                !aspectEdges.add(sourceName)) {
                throw IllegalArgumentException("driver-build: invalid dependency edge ${sourceName}")
            }
            if (dependencySeen.add(sourceName)) { dependencies.add(sourceName) }
        }
        let expectedEdges = HashSet<String>()
        for (sourceName in selectedSources) {
            if (sourceName != target.name) { expectedEdges.add(sourceName) }
        }
        if (aspectEdges.size != expectedEdges.size) {
            throw IllegalArgumentException("build-input-mismatch: selected source set changed")
        }
        for (sourceName in aspectEdges) {
            if (!expectedEdges.contains(sourceName)) {
                throw IllegalArgumentException("build-input-mismatch: selected source set changed")
            }
        }
        graph[target.name] = dependencies.toArray()
        let entry = JsonObject()
        stringField(entry, "packageName", target.name)
        stringField(entry, "planDigest", reportLines[0])
        stringField(entry, "reportSha256", digest(root.join(report).toString()))
        stringField(entry, "dependencyReportSha256", digest(dependencyPath.toString()))
        let edges = JsonArray()
        for (name in dependencies) { edges.add(JsonString(name)) }
        entry.put("actualSourceEdges", edges)
        plans.add(entry)
    }
    rejectDependencyCycles(graph)
    verifyToolchainState(spec, abi)
    let planManifest = JsonObject()
    planManifest.put("schemaVersion", JsonInt(1))
    stringField(planManifest, "sessionId", spec.sessionId)
    stringField(planManifest, "state", "PLAN_READY")
    stringField(planManifest, "sourcesSha256", sourcesDigest)
    planManifest.put("targets", plans)
    let planDigest = publish(spec.sessionRoot, "plan.json", planManifest)

    let complete = JsonObject()
    complete.put("schemaVersion", JsonInt(1))
    stringField(complete, "sessionId", spec.sessionId)
    stringField(complete, "state", "COMPLETE")
    stringField(complete, "sourcesSha256", sourcesDigest)
    stringField(complete, "planSha256", planDigest)
    let outputs = JsonArray()
    for (target in spec.targets) {
        let imports = root.join("imports-${target.name}.cj")
        let symbols = root.join("aspect-import-symbols-${target.name}.txt")
        let importedSources = sourceList(spec, target.name)
        let key = actionKey(target, abi, importedSources, root)
        let args = commonArgs(spec, target)
        args.add(imports.toString())
        args.add("--plugin=${spec.stdxDir}/libstdx.weave_rules.so")
        args.add("--aspect-import-symbols")
        args.add(symbols.toString())
        args.add("--import-path")
        args.add(root.join("artifacts").toString())
        args.add("-L")
        args.add(root.join("artifacts").toString())
        for (name in importedSources) { args.add("-l:lib${name}.a") }
        args.add("--output-type=${target.outputType}")
        args.add("-o")
        let output = root.join("artifacts/final-${target.name}").toString()
        args.add(output)
        let dependencyPath = root.join("dependencies-apply-${target.name}.txt")
        let importDigest = digest(imports.toString())
        let symbolDigest = digest(symbols.toString())
        verifySourceState(spec, abi, root, sourceKeys, metadataDigests, artifactDigests,
            sourceDependencyDigests)
        if (digest(root.join("dependencies-preflight-${target.name}.txt").toString()) !=
            targetDependencyDigests[target.name] ||
            digest(root.join("metadata/plan-${target.name}.digest").toString()) !=
                targetPlanFileDigests[target.name]) {
            throw IllegalArgumentException("build-input-mismatch: preflight dependency report changed")
        }
        runCompiler(spec, "apply-${target.name}", args.toArray(),
            actionContext(spec, "apply", target.name, key, abi, "metadata/unused-${target.name}",
                sourceInputs, digests[target.name]), dependencyPath.toString())
        let preflightDeps = readDependencies(root.join("dependencies-preflight-${target.name}.txt"),
            target.name)
        let applyDeps = readDependencies(dependencyPath, target.name)
        if (preflightDeps != applyDeps) {
            throw IllegalArgumentException("build-input-mismatch: dependency closure changed")
        }
        verifySourceState(spec, abi, root, sourceKeys, metadataDigests, artifactDigests,
            sourceDependencyDigests)
        if (actionKey(target, abi, importedSources, root) != key ||
            digest(imports.toString()) != importDigest ||
            digest(symbols.toString()) != symbolDigest) {
            throw IllegalArgumentException("build-input-mismatch: target changed during apply")
        }
        if (!exists(Path(output))) { throw IllegalArgumentException("driver-build: missing final artifact") }
        let entry = JsonObject()
        stringField(entry, "packageName", target.name)
        stringField(entry, "path", output)
        stringField(entry, "sha256", digest(output))
        stringField(entry, "targetActionKey", key)
        stringField(entry, "planDigest", digests[target.name])
        stringField(entry, "toolchainAbiKey", abi)
        stringField(entry, "dependencyReportSha256", digest(dependencyPath.toString()))
        if (sourceKeys.contains(target.name)) {
            stringField(entry, "sourceActionKey", sourceKeys[target.name])
            stringField(entry, "sourceBaselineSha256", artifactDigests[target.name])
        }
        outputs.add(entry)
    }
    complete.put("outputs", outputs)
    verifyToolchainState(spec, abi)
    publish(spec.sessionRoot, "complete.json", complete)
    println("aspect_cj build complete: ${spec.sessionRoot}")
}

private func selfTest(): Unit {
    let acyclic = HashMap<String, Array<String>>()
    acyclic["target"] = ["source"]
    acyclic["source"] = []
    rejectDependencyCycles(acyclic)
    let cyclic = HashMap<String, Array<String>>()
    cyclic["a"] = ["b"]
    cyclic["b"] = ["a"]
    var rejected = false
    try {
        rejectDependencyCycles(cyclic)
    } catch (error: IllegalArgumentException) {
        rejected = error.message.contains("dependency-cycle")
    }
    if (!rejected) { throw IllegalArgumentException("driver-self-test: dependency cycle accepted") }
    println("aspect_cj driver self-test: pass")
}

main(): Int64 {
    try {
        let args = getCommandLine()
        if (args.size != 2) { throw IllegalArgumentException("usage: aspect-cj-driver <config.json>") }
        if (args[1] == "--self-test") { selfTest(); return 0 }
        runBuild(parseBuildSpec(File.readFrom(Path(args[1]))))
        return 0
    } catch (error: Exception) {
        println("aspect_cj driver failed: ${error.message}")
        return 1
    }
}
