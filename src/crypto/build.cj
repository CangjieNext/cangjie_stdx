// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

import std.process.*
import std.fs.*

@When[os == "Windows"]
func getPythonCommand(): String {
    if (let Some(pyCommand) <- getPythonCommandFromEnv()){
        return pyCommand
 	}
    if(let Some(devecoPyCommand) <- getVariable("DEVECO_OH_NATIVE_HOME")){
        return devecoPyCommand + "/llvm/python3/bin/python3.11.exe"
    }
    throw Exception("Could not find 'python3' or 'python' in your system's PATH. Please ensure Python is installed and added to your environment variables!")
}

@When[os != "Windows"]
func getPythonCommand(): String {
    getPythonCommandFromEnv() ?? throw Exception(
        "Could not find 'python3' or 'python' in your system's PATH. Please ensure Python is installed and added to your environment variables!")
}

func getPythonCommandFromEnv(): ?String {
    let commands = ["python3", "python"]
    for (command in commands) {
        try {
            if (execute(command, "--version") == 0) {
                return command
            }
        } catch (_: Exception) {
            continue
        }
    }
    return None
}

func isInStdxProject(): Bool {
    let curFile = FileInfo("build.cj")
    if (let Some(crypto) <- curFile.parentDirectory && crypto.name == "crypto") {
        if (let Some(src) <- crypto.parentDirectory && src.name == "src") {
            if (let Some(stdx) <- src.parentDirectory && stdx.name.contains("stdx")) {
                return true
            }
        }
    }

    return false
}

func buildAllStdxNative(): Unit {
    if (!exists("../../target/linux_x86_64_cjnative/static/stdx/libcrypto.keysFFI.a")) {
        let info = FileInfo("../..")
        let path = info.path.normalize()
        execute(getPythonCommand(), ["cjpm_build.py", "build", "--build-stage", "preBuild", "--cjpm-dir", path.toString()], workingDirectory: path)
    }
}

func stagePreBuild(): Int64 {
    if (isInStdxProject()) {
        buildAllStdxNative()
        0
    } else {
        return execute(getPythonCommand(), ["cjpm_build.py", "build", "--build-stage", "preBuild"])
    }
}

func stagePreClean(): Int64 {
    return execute(getPythonCommand(), "cjpm_build.py", "clean")
}

main(): Int64 {
    match (Process.current.arguments[0]) {
        case "pre-clean" => stagePreClean()
        case "pre-build" => stagePreBuild()
        case _ => 0
    }
}
