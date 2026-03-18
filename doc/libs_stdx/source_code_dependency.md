# 扩展库源码集成指南

## 两种集成方式

stdx 有三种源码集成方式：git 源码依赖、本地源码依赖和仓颉中心仓源码依赖。

### git 源码依赖

在工程的 `cjpm.toml` 文件中，新增如下源码依赖配置：

```toml
[dependencies]
  stdx = { git = "https://gitcode.com/Cangjie/cangjie_stdx.git", branch = "dev", output-type = "dynamic" }
```

在工程的 cjpm.toml 文件所在目录，执行 `cjpm update` 命令即可同步更新本仓源码。

### 本地源码依赖

如果不希望通过 git 依赖本仓，开发者可以直接下载本仓库分支的全量源码（包括本仓库的 cjpm.toml 配置文件），然后在工程的 cjpm.toml 文件中添加本地模块依赖。

```toml
[dependencies]
  stdx = { path = "/path/to/cangjie_stdx", output-type="dynamic"}
```

完成本地模块依赖添加之后，即可在项目中使用 stdx。

### 仓颉中心仓源码依赖

如果开发者不希望直接依赖本地源码，也可以通过仓颉中心仓依赖 stdx。

通过仓颉中心仓依赖 stdx 时，需要在工程中添加仓颉中心仓配置文件，并且在 cjpm.toml 文件中添加仓颉中心仓模块依赖。具体请参考[仓颉中心仓使用说明](https://pkgdocs.cangjie-lang.cn/docs/zh/1.0.0/central-repo/source_zh_cn/overview.html)

```toml
[dependencies]
  stdx = { version = "x.y.z", output-type="dynamic"}
```

完成仓颉中心仓模块依赖添加之后，即可在项目中使用 stdx。

## 包范围

目前源码依赖集成的 stdx 不包含 aspectCJ 和 syntax，并且在 Windows 平台上没有 fuzz 包。

## 支持平台

- Linux
- macOs
- Windows
- 交叉编译 OpenHarmony

## 交叉编译 OpenHarmony

Linux 和 macOS 平台交叉编译 OpenHarmony 需要配置交叉编译工具链的环境变量（非 DevEco Studio 项目），[请参考编译 ohos-x86_64、ohos-aarch64 工具链](https://gitcode.com/Cangjie/cangjie_build/blob/dev/docs/linux_ohos_toolchain.md)

1. OHOS_TOOLCHAIN_PATH (编译工具链中 Clang/LLVM 编译器的二进制目录, 如 /opt/buildtools/ohos_root/prebuilts/clang/ohos/linux-x86_64/llvm/bin)

2. OHOS_SYSROOT_PATH (OpenHarmony 系统头文件目录，如 /opt/buildtools/ohos_root/out/sdk/obj/third_party/musl/sysroot)

DevEco Studio 自带 OpenHarmony 交叉编译工具链，无需设置上面的环境变量。

交叉编译命令：cjpm build --target aarch64-linux-ohos 或者 cjpm build --target x86_64-linux-ohos

> **注意**：
>
> 部分版本 DevEco Studio 可能缺少 openssl 头文件， 构建过程中报错找不到 openssl 头文件，需要准备 openssl 头文件放入 DevEco Studio 的 sysroot 下。
>
> - Windows 常见路径如 `C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\native\sysroot\usr\include\openssl`。
>
> - macOS 常见路径如  `/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/native/sysroot/usr/include/openssl`。

## 依赖

由于 stdx 需要拉取并编译外部开源 C 库，也有涉及 C 互操作的包，目前构建有一些额外依赖（使用 DevEco Studio 除外，DevEco Studio 自带了下面的工具），提前准备好下面的依赖，同时配置好环境变量。

- python: > 3.7
- cmake: >= 3.16.5 且 < 4
- ninja: >1.10
- openssl: >= 3 （需要配置环境变量 OPENSSL_ROOT_DIR，指向 OpenSSL 安装的根目录）
- clang: >= 15.0.4 且 < 16 (Linux or macOS)
- mingw-w64 (Windows) [下载地址](https://github.com/niXman/mingw-builds-binaries/releases/download/12.2.0-rt_v10-rev2/x86_64-12.2.0-release-posix-seh-msvcrt-rt_v10-rev2.7z)

## 常见问题

- 找不到 OPENSSL：请检查是否配置了环境变量 OPENSSL_ROOT_DIR，并且 OPENSSL_ROOT_DIR/lib 目录下包含 openssl 动态库。
- stdx 编译过程中 zlib 编译失败：首先检查 third_party/zlib 目录下是否包含 zlib 源文件，如果没有则是代码拉取失败，请检查网络连接。如果有请检查 cmake 版本是否符合要求（>= 3.16.5 且 < 4）。
- windows 平台编译时出现 vsnprintf_s 重复定义：请检查 gcc 是否是依赖中的 mingw-w64 提供的。
- 编译时出现 undefined reference to `CJ_XXX`：改为依赖stdx动态库，或在项目的 cjpm.toml 文件的 `compile-option` 中手动添加 `-lstdx.encoding.jsonFFI -lstdx.encoding.json.streamFFI -lstdx.compress.zlibFFI -lstdx.compress.tarFFI -lstdx.crypto.keysFFI -lstdx.crypto.x509FFI -lstdx.net.tlsFFI -lcangjie-dynamicLoader-opensslFFI`。