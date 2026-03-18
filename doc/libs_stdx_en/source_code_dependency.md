# Extension Library Source Code Integration Guide

## Two Integration Methods

stdx has three source code integration methods: git source dependency, local source dependency, and Cangjie central repository source dependency.

### git source code dependency

In project's `cjpm.toml` file, add the following source code dependency configuration:

```toml
[dependencies]
  stdx = { git = "https://gitcode.com/Cangjie/cangjie_stdx.git", branch = "dev", output-type = "dynamic" }
```

In the directory where project's cjpm.toml file is located, execute the `cjpm update` command to synchronously update the source code of this repository.

### local Source Code Dependency

If developers do not wish to depend on this repository via git, Developers can directly download the full source code of this repository branch (including the cjpm.toml configuration file of this repository), and then add a local module dependency in the project's cjpm.toml file.

```toml
[dependencies]
  stdx = { path = "/path/to/cangjie_stdx", output-type="dynamic"}
```

After completing the addition of local module dependencies, developers can use stdx in the project.

### Cangjie Central Repository Source Code Dependency

If developers do not wish to directly depend on local source code, they can also depend on stdx via the Cangjie central repository.

To depend on stdx via the Cangjie central repository, developers need to add a central repository configuration file in the project and add a central repository module dependency in the project's cjpm.toml file. Please refer to [Cangjie central repository usage guide](https://pkgdocs.cangjie-lang.cn/docs/zh/1.0.0/central-repo/source_zh_cn/overview.html) for specific configuration steps.

```toml
[dependencies]
  stdx = { version = "x.y.z", output-type="dynamic"}
```

After completing the addition of central repository module dependencies, developers can use stdx in the project.

## Package Scope

Currently, the integrated stdx for source code dependencies does not include aspectCJ and syntax, and there is no fuzz package on the Windows platform.

## Supported Platforms

- Linux
- macOS
- Windows
- Cross-compile OpenHarmony

## Cross-compiling OpenHarmony

Cross-compiling OpenHarmony on Linux and macOS platforms requires configuring environment variables for the cross-compilation toolchain (non DevEco Studio projects). [Please refer to compiling ohos-x86_64 and ohos-aarch64 toolchains](https://gitcode.com/Cangjie/cangjie_build/blob/dev/docs/linux_ohos_toolchain.md)

1. OHOS_TOOLCHAIN_PATH (Binary directory of Clang/LLVM compiler in the compilation toolchain, e.g., /opt/buildtools/ohos_root/prebuilts/clang/ohos/linux-x86_64/llvm/bin)

2. OHOS_SYSROOT_PATH (OpenHarmony system header directory, e.g., /opt/buildtools/ohos_root/out/sdk/obj/third_party/musl/sysroot)

DevEco Studio comes with its own OpenHarmony toolchain, so there is no need to set the environment variables above.

Cross-compilation command: cjpm build --target aarch64-linux-ohos or cjpm build --target x86_64-linux-ohos

> **Note**:
>
> Some versions of DevEco Studio may lack openssl header files. If the build process reports an error stating that openssl header files cannot be found, developers need to prepare the openssl header files and place them in the sysroot of DevEco Studio.
>
> - Common Windows paths such as `C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\native\sysroot\usr\include\openssl`.
>
> - Common macOS paths such as  `/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/native/sysroot/usr/include/openssl`.

## Dependencies

Since stdx needs to pull and compile external open-source C libraries, and there are also packages involving C interoperability, the current build has some additional dependencies (except when using DevEco Studio, which comes with the following tools). Please prepare the following dependencies in advance and configure the environment variables.

- python: > 3.7
- cmake: >= 3.16.5 且 < 4
- ninja: >1.10
- openssl: >= 3 (The environment variable OPENSSL_ROOT_DIR needs to be configured to point to the root directory of the OpenSSL installation)
- clang: >= 15.0.4 且 < 16 (Linux or macOS)
- mingw-w64 (Windows) [Download link](https://github.com/niXman/mingw-builds-binaries/releases/download/12.2.0-rt_v10-rev2/x86_64-12.2.0-release-posix-seh-msvcrt-rt_v10-rev2.7z)

## Common Issues

- **Cannot find OPENSSL**: Please check if the environment variable OPENSSL_ROOT_DIR is configured, and if the lib directory under OPENSSL_ROOT_DIR contains the openssl dynamic library.
- **zlib compilation fails**: First check if the third_party/zlib directory contains zlib source files. If not, it is a code pull failure. Please check the network connection. If it is present, please check if the cmake version is compatible (>= 3.16.5 and < 4).
- **vsnprintf_s redefinition error on Windows**: Please check if gcc is the one provided by the mingw-w64 dependency.
- **undefined reference to `CJ_XXX`**: Either depend on the stdx dynamic library or manually add compile-option `-lstdx.encoding.jsonFFI -lstdx.encoding.json.streamFFI -lstdx.compress.zlibFFI -lstdx.compress.tarFFI -lstdx.crypto.keysFFI -lstdx.crypto.x509FFI -lstdx.net.tlsFFI -lcangjie-dynamicLoader-opensslFFI` to the project's cjpm.toml file.