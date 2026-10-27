#!/usr/bin/env python3
# Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
# See https://cangjie-lang.cn/pages/LICENSE for license information.

"""Exercise the real driver CMake rule with synthetic package/compiler outputs.

This checks build dependencies, not Cangjie compilation. Run the driver smoke
tests separately against a matching, freshly built compiler and stdx.
Requires Linux, Python 3, CMake, Ninja and Make; never modifies the caller's SDK.
"""

import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import time


TARGETS = (
    "aspect_cj", "collect_rules", "weave_rules", "cangjieCJNATIVEJson",
    "cangjieCJNATIVEJsonStream", "encoding.json", "encoding.json.stream",
)


def production_rules(repo):
    source = (repo / "build/common/modules/AddCangjieSource.cmake").read_text()
    begin = source.index("function(cj_resolve_depends out_var)")
    end = source.index("endfunction()", begin) + len("endfunction()")
    resolver = source[begin:end]
    source = (repo / "build/libs/AddCJNATIVELibrary.cmake").read_text()
    begin = source.index("# The staged aspect_cj driver is a host tool.")
    end = source.index("\nif(NOT WIN32)", begin)
    return resolver + "\n" + source[begin:end]


def run_generator(repo, generator, scratch):
    source = scratch / "source with spaces"
    build = scratch / "build with spaces"
    source.mkdir(parents=True)
    tools = scratch / "tools"
    tools.mkdir()
    counter = scratch / "compiler.calls"
    compiler = tools / "cjc"
    compiler.write_text(
        "#!/usr/bin/env python3\n"
        "import os, pathlib, sys\n"
        "with open(os.environ['ASPECT_CMAKE_CALLS'], 'a') as stream:\n"
        "    stream.write('compile\\n')\n"
        "output = pathlib.Path(sys.argv[sys.argv.index('-o') + 1])\n"
        "output.write_text('synthetic driver\\n')\n"
    )
    compiler.chmod(0o755)
    main = source / "build/aspect_cj_driver/main.cj"
    main.parent.mkdir(parents=True)
    main.write_text("// Synthetic input; not compiled as Cangjie.\n")
    for target in TARGETS:
        (source / (target + ".input")).write_text("initial\n")
    definitions = """cmake_minimum_required(VERSION 3.16.5)
project(aspect_driver_dependencies NONE)
set(TARGET_TRIPLE_DIRECTORY_PREFIX linux_x86_64)
set(CJNATIVE_BACKEND cjnative)
set(BACKEND_TYPE CJNATIVE)
"""
    definitions += "foreach(dep " + " ".join(TARGETS) + ")\n"
    definitions += """    set(output "${CMAKE_BINARY_DIR}/${dep}.stamp")
    add_custom_command(OUTPUT "${output}"
        COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_SOURCE_DIR}/${dep}.input" "${output}"
        DEPENDS "${CMAKE_SOURCE_DIR}/${dep}.input" VERBATIM)
    add_custom_target(${dep} DEPENDS "${output}")
    if(dep MATCHES "^cangjie")
        set_target_properties(${dep} PROPERTIES CJ_OUTPUT_FILE "${output}")
    else()
        set_target_properties(${dep} PROPERTIES CJ_LIB_OUTPUT_FILE "${output}")
    endif()
endforeach()
"""
    (source / "CMakeLists.txt").write_text(definitions + production_rules(repo))
    env = dict(os.environ, PATH=str(tools) + os.pathsep + os.environ["PATH"],
               ASPECT_CMAKE_CALLS=str(counter))

    def command(*args):
        result = subprocess.run(args, env=env, text=True, stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT, timeout=120, check=False)
        if result.returncode:
            raise RuntimeError(result.stdout)

    command("cmake", "-S", str(source), "-B", str(build), "-G", generator)

    def check_calls(expected):
        command("cmake", "--build", str(build), "--target", "aspect_cj_driver", "-j2")
        actual = len(counter.read_text().splitlines())
        if actual != expected:
            raise AssertionError(f"{generator}: expected {expected} compiler calls, got {actual}")

    check_calls(1)
    check_calls(1)  # No-op builds must not invoke the compiler again.
    expected = 1
    # Cover each package output, compiler replacement and driver source edit.
    for changed in [*(source / (target + ".input") for target in TARGETS), compiler, main]:
        time.sleep(1.1)  # Also cover generators/filesystems with coarse timestamps.
        with changed.open("a") as stream:
            stream.write("\n")
        expected += 1
        check_calls(expected)
        check_calls(expected)
    (source / "unrelated.input").write_text("not a dependency\n")
    check_calls(expected)
    # Reconfiguring with another SDK must resolve the new compiler, not a
    # find_program cache entry left over from the previous environment.
    replacement_tools = scratch / "replacement tools"
    replacement_tools.mkdir()
    replacement = replacement_tools / "cjc"
    shutil.copyfile(compiler, replacement)
    replacement.chmod(0o755)
    env["PATH"] = str(replacement_tools) + os.pathsep + os.environ["PATH"]
    command("cmake", "-S", str(source), "-B", str(build), "-G", generator)
    expected += 1
    check_calls(expected)
    check_calls(expected)
    command("cmake", "--install", str(build), "--prefix", str(scratch / "install"))
    installed = scratch / "install/linux_x86_64_cjnative/bin/aspect-cj-driver"
    if installed.read_bytes() != (build / "bin/aspect-cj-driver").read_bytes():
        raise AssertionError("Installed driver differs from the rebuilt output")
    print(f"cmake-dependencies-{generator}: PASS (10 invalidations, no-op and install checks)")


def main():
    if not sys.platform.startswith("linux"):
        raise SystemExit("This host-tool build test requires Linux.")
    for tool in ("cmake", "ninja", "make", "python3"):
        if not shutil.which(tool):
            raise SystemExit(f"Required tool not found: {tool}")
    repo = Path(__file__).resolve().parents[2]
    with tempfile.TemporaryDirectory(prefix="aspect-cmake-dependencies-") as temp:
        for index, generator in enumerate(("Ninja", "Unix Makefiles")):
            run_generator(repo, generator, Path(temp) / str(index))


if __name__ == "__main__":
    main()
