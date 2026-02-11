/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

import std.process.*
import std.io.*
import std.fs.*
import std.convert.*
import std.env.*

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
    let commands = ["python3", "python"];
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

main(): Int64 {
    let pyCommand: String = getPythonCommand()
    match (getCommandLine()[1]) {
        case "pre-build" => stagePreBuild(pyCommand)              
        // case "post-build" => stagePostBuild(pyCommand)
        case "pre-clean" => stagePreClean(pyCommand)
        case _ => 0
    }
}

public func stagePreBuild(pyCommand: String): Int64 {
    return execute(pyCommand, "cjpm_build.py", "build", "--build-stage", "preBuild")
}

public func stagePostBuild(pyCommand: String): Int64 {
    return execute(pyCommand, "cjpm_build.py", "build", "--build-stage", "postBuild")
}

public func stagePreClean(pyCommand: String): Int64 {
    return execute(pyCommand, "cjpm_build.py", "clean")
}
