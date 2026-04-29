# cangjie_stdx

## 简介

拓展库 `stdx` 是仓颉编程语言提供的拓展模块（即非核心的标准库，但官方提供的附加功能集），是该语言生态中的重要组成部分，为仓颉补充了更多实用能力，涵盖面向切面编程、压缩和解压缩、安全（安全加密能力/消息摘要算法/非对称加解密和签名算法/数字证书处理功能）、编解码（base64/hex/json/url）、网络（http/tls）、日志、语法解析、单元测试拓展、序列化、并发编程模型、非局部控制操作等多个领域。 

架构图：

![](figures/stdx_Architecture_Diagram_zh.png)

- actors: 提供了一种并发编程模型，旨在简化并发任务的处理。
- aspectCJ: 提供了 Cangjie 中面向切面编程的相关注解。
- compress: 提供了压缩解压功能。
- crypto: 提供了密码学操作的工具库。
- effect: 提供了一种强大的非局部控制操作。
- encoding: 提供了数据编码与解码的基础工具库。
- fuzz: 提供了一种自动化软件测试方法。
- log: 提供了一个单一的日志 API。
- logger: 提供了文本格式和 JSON 格式日志打印功能。
- net: 提供了网络通信和安全传输功能。
- serialization: 提供了序列化和反序列化的能力。
- string_intern: 提供了string对象的池化缓存能力
- syntax：提供了对仓颉源码进行语法解析的功能。
- unittest: 提供了在编写仓颉项目单元测试代码时输入序列化格式的测试数据的能力。

## 使用说明

`stdx` 相关 API 请参见 [API接口说明](./doc/libs_stdx/summary_cjnative.md)。
相关指导请参见 [开发指南](https://gitcode.com/Cangjie/cangjie_docs/)。

## 目录结构

```text
/stdx
├─ build                        # 工程构建目录，编译构建工具、脚本等
├─ doc                          # STDX 库资料目录
├─ figures                      # 存放readme中的架构图
├─ src                          # STDX 各个包代码目录                        
│   └─ stdx
│       ├── actors              # 提供 Actors 功能                     
│       ├── aspectCJ            # 提供 AOP 功能
│       ├── compress            # 提供压缩和解压缩功能
│       ├── crypto              # 提供安全相关能力
│       ├── effect              # 提供用于处理 Effect Handler 特性的用户级 API。这是一个实验性功能，需要使用支持该机制的 Cangjie 编译器。
│       ├── dynamicLoader       # Openssl 动态加载模块
│       ├── encoding            # 提供 JSON 和字符串编码相关能力。
│       ├── fuzz                # 提供基于覆盖率反馈的仓颉 fuzz 引擎及对应的接口
│       ├── log                 # 提供了日志记录相关的能力
│       ├── logger              # 提供文本格式和 JSON 格式日志打印功能
│       ├── net                 # 提供网络通信等能力
│       ├── serialization       # 提供序列化和反序列化能力
│       ├── string_intern       # 提供string对象的池化缓存能力
│       ├── syntax              # 提供语法解析能力
│       └── unittest            # 提供单元测试扩展能力
│
├─ third_party                  # 第三方组件目录
└─ target                       # 编译构建产物目录
```

## OpenHarmony如何使用stdx

`stdx` 提供静态和动态两种二进制 ，两者独立使用，OpenHarmony下开发者可根据实际情况引用。

## OpenHarmony如何集成stdx

stdx编译出二进制，在代码工程的 `cjpm.toml` 进行配置导入。

### 1. stdx的编译

参考[OHOS 仓颉SDK构建指导书 (Ubuntu 22.04)](https://gitcode.com/Cangjie/cangjie_build/blob/dev/docs/linux_ohos_zh.md)

### 2. stdx的使用

开发者使用 DevEco Studio 开发时， `cjpm.toml` 配置文件中会自带 `target` 信息，因此，该场景仅需要修改 `path-option` 表示的 `stdx` 路径。

由于真机和模拟器的环境信息不同（真机系统信息为 `target.aarch64-linux-ohos`，模拟器为 `target.x86_64-linux-ohos` ），所以请根据程序实际编译调测的环境修改对应位置的配置信息。

```toml
[target]
  [target.aarch64-linux-ohos]
    compile-option = ""
    [target.aarch64-linux-ohos.bin-dependencies]
      path-option = [ "D:\\cangjiestdx\\linux_ohos_aarch64_llvm\\dynamic\\stdx" ]  # 手机调测在此处配置，stdx 路径根据实际情况配置
      [target.aarch64-linux-ohos.bin-dependencies.package-option]
  [target.x86_64-linux-ohos]
    compile-option = ""
    [target.x86_64-linux-ohos.bin-dependencies]
      path-option = ["D:\\cangjiestdx\\linux_ohos_x86_64_llvm\\dynamic\\stdx" ]    # 模拟器调测在此处配置，stdx 路径根据实际情况配置
```

**配置示例**：此处给出 Windows 环境（架构为 x86_64）下，使用 DevEco Studio 开发，且程序在真机环境编译调测的 `cjpm.toml` 配置示例。

```toml
[target]
  [target.aarch64-linux-ohos]
    compile-option = ""
    [target.aarch64-linux-ohos.bin-dependencies]
      path-option = [  "D:\\cangjiestdx\\linux_ohos_aarch64_llvm\\dynamic\\stdx" ] # stdx 路径根据实际情况配置
      [target.aarch64-linux-ohos.bin-dependencies.package-option]
  [target.x86_64-linux-ohos]
    compile-option = ""
    [target.x86_64-linux-ohos.bin-dependencies]
      path-option = []
  [target.x86_64-unknown-windows-gnu]
    [target.x86_64-unknown-windows-gnu.bin-dependencies]
      path-option = []
      [target.x86_64-unknown-windows-gnu.bin-dependencies.package-option]

[package]
  cjc-version = "0.48.2"
  compile-option = "--dy-std"
  description = "CangjieUI Application"
  link-option = ""
  name = "ohos_app_cangjie_entry"
  output-type = "dynamic"
  src-dir = "./src/main/cangjie"
  target-dir = ""
  version = "1.0.0"
  [package.package-configuration]
  [package.scripts]

[profile]
  [profile.build]
    incremental = true
    lto = ""
    [profile.build.combined]
      ohos_app_cangjie_entry = "dynamic"
  [profile.customized-option]
    debug = "-g -Woff all"
    release = "--fast-math -O2 -s -Woff all"
  [profile.test]
```

## License 许可

本项目开源许可请参阅 [LICENSE](LICENSE)。

## 参与贡献

欢迎开发者们提供任何形式的贡献，包括但不限于代码、文档、issue 等。