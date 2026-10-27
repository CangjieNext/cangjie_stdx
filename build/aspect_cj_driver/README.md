# aspect_cj 分阶段构建驱动（cjnative / Linux）

开发参考：[规则切点实现设计](../../doc/design/aspect_cj_rule_design.md)说明内部架构，本文提供构建配置与可复跑测试命令。用户公共接口另见[API 类文档](../../doc/libs_stdx/aspect_cj/aspect_cj_package_api/aspect_cj_package_classes.md)。

本驱动负责把规则来源包的收集、目标包的纯来源选择、预检和正式织入串成同一次全量构建。它需要带有 `--emit-chir-annotation-metadata` 与 `--aspect-import-symbols` 支持的配套仓颉编译器，以及本仓库构建出的 `stdx.aspect_cj`、`collect_rules`、`weave_rules`。不要把它与旧版编译器或插件混用。

Linux 原生的 stdx 全量构建会生成并安装 `aspect-cj-driver` 到目标三元组的 `bin` 目录。开发中如配套编译器的 `StdxChirFormat.fbs` 尚未随 SDK 安装，可通过 `CANGJIE_CHIR_FORMAT_FBS` 指定该匹配版本 Schema 的绝对路径；正式发布仍应使用同版本 SDK 自带 Schema。也可手工构建可执行文件（从仓库根目录运行；`STDX_DIR` 指向已安装的动态 `stdx` 库目录）：

```sh
cjc build/aspect_cj_driver/main.cj --experimental \
    --import-path "$STDX_DIR" -L "$STDX_DIR" \
    -lstdx.aspect_cj -lstdx.encoding.json -lstdx.encoding.json.stream \
    -o aspect-cj-driver
```

最小配置示例（所有路径均为绝对路径，`sessionRoot` 必须不存在）：

```json
{
  "schemaVersion": 2,
  "sessionId": "0123456789abcdef0123456789abcdef",
  "sessionRoot": "/tmp/aspect-cj-session-001",
  "compiler": "/opt/cangjie/bin/cjc",
  "stdxDirectory": "/opt/stdx/dynamic/stdx",
  "dependencies": [],
  "sources": [
    {
      "packageName": "example.aspect",
      "files": ["/absolute/path/aspect.cj"],
      "options": []
    }
  ],
  "targets": [
    {
      "packageName": "example.app",
      "files": ["/absolute/path/app.cj"],
      "options": [],
      "outputType": "exe"
    }
  ]
}
```

运行前设置指向配套 SDK 的绝对 `CANGJIE_HOME`，将 `stdxDirectory` 加入 `LD_LIBRARY_PATH`，然后执行 `aspect-cj-driver config.json`。目标可选 `exe` 或 `staticlib`；来源包按配置顺序构建，较后的来源包可以使用较早来源包的静态库。同一包可以既是来源又是目标，最终产物与来源基线分别校验。驱动把编译器文件、SDK 的 `lib`/`runtime/lib`/`modules`/`tools` 树及整个 stdx 库目录纳入工具链摘要，在来源、预检和最终发布前复核。

配置中的编译器、stdx 目录、会话目录和源码文件路径必须是 Linux 绝对路径。每个包的 `options` 目前仅接受 `-O0`、`-O1`、`-O2`、`-Os`、`-Oz` 和 `--disable-reflection`；不得通过任意编译选项注入导入路径、外部库或第二个插件。

工具链目录摘要递归覆盖子目录和符号链接指向的内容，记录链接路径及解析后的目标。目录别名（包括回指祖先的链接）只遍历一次，避免循环；断开的链接和非普通文件/目录条目报错，不静默忽略。构建期间不要修改 SDK 或 stdx 安装目录。此摘要用于阶段间输入一致性校验，不是针对并发恶意修改的文件系统沙箱。

配置 v1 仍可使用，但不接受 `dependencies` 字段；v2 必须显式填写该数组，无外部依赖时使用 `[]`。每项预编译依赖声明包名、匹配的 `.cjo`/`.a` 绝对路径、构建编译器 SHA-256、目标三元组和直接依赖包名列表，例如：

```json
{
  "packageName": "example.support",
  "module": "/absolute/example.support.cjo",
  "library": "/absolute/libexample.support.a",
  "compilerSha256": "<实际构建所用cjc文件的64位小写SHA-256>",
  "targetTriple": "linux_x86_64_cjnative",
  "dependencies": ["std.core"]
}
```

目前只接受匹配当前 Linux 原生架构的静态库；aarch64 使用 `linux_aarch64_cjnative`。非标准库间接依赖也必须纳入顶层依赖数组或来源集合，不得占用 `std.*`/`stdx.*` 名称或与来源/目标重名。驱动校验声明闭包、工具链与平台，将外部模块和库复制到会话私有输入目录，并在后续阶段核验原文件及副本摘要。编译器哈希是受信提供方的构建声明，不是任意二进制的 ABI 证明；最终编译和链接仍必须通过。

驱动只接受全新的会话目录，并按以下顺序发布成功标志：全部来源包编译且候选文件校验成功后写 `sources.json`；各目标先在不生成切面包导入的情况下确定真正命中的来源，再只导入这些来源做正式预检、计划摘要与依赖图校验，完成后写 `plan.json`；所有目标正式编译/链接和摘要复核后才写 `complete.json`。正式产物先生成对象文件及模块，再归档全部织入后的静态库，最后链接可执行文件；同包既为来源又为目标时，下游只链接最终库，不回退到未织入的基线库，也不依赖目标列表顺序。静态归档不合并依赖库，其下游依赖记录为 `requiredLinkInputs`；可执行文件的 `linkInputs` 记录实际链接输入。

同包来源/目标的源声明接口、基线模块、对象文件、预检报告及最终产物均做一致性检查，任何变化都会阻止成功发布。看到 `sources.json` 或 `plan.json` **不等于**代码已成功交付。任何阶段失败均返回非零；不复用旧会话目录，也不覆盖已有标志文件。

`metadata/matches-<目标包>.json` 给出规则根及切面的命中目标数、来源准备次数、求值目标数、预算消耗和零命中提示。合法零命中不算失败；未知注解元数据、非法规则和预算超限仍失败。摘要不记录业务实参，内容哈希与计划及最终清单绑定。

对同一目标同时使用旧式与新式切面时，共用一份预检计划；同一切面函数上旧新控制注解混用会被拒绝。预检发现依赖环、候选元数据不匹配、来源/目标输入在阶段间变化或重复织入时均停止，不发布最终成功标志。

随仓库附有可独立运行的端到端测试：

```sh
python3 tests/aspect_cj_driver/smoke.py \
    --compiler /absolute/path/to/matching/cjc \
    --stdx-directory "$STDX_DIR" \
    --driver /absolute/path/to/aspect-cj-driver
```

测试会保留并打印临时工作目录，覆盖跨包调用与参数快照、AND/OR/NOT、共享规则去重、空注解取反、字面量字符串拼接、命名 `const func` 字段、解析后注解身份/别名/同短名、复杂业务注解字段、非法规则载体、旧新 Entry/Exit 同时织入、旧 Replace 冲突、来源兼目标、真实依赖环、零命中不产生假环及收集/预检/最终链接三个失败屏障。另覆盖最终库链接的正逆序及多应用、源声明接口不一致、模块/报告/最终输出篡改拒绝，以及 v2 预编译依赖的真实编译和错误闭包拒绝。它使用配套工具链的真实编译和运行结果，不以模拟的 `.annoinfo` 文件代替正式 Collector。

泛型候选和异常传播另用一个仅用于测试的同包插件验证：

```sh
python3 tests/aspect_cj_driver/semantic_smoke.py \
    --compiler /absolute/path/to/matching/cjc \
    --stdx-directory "$STDX_DIR"
```

该脚本在默认及 `-O2` 下检查泛型函数、泛型类实例体的计划数和运行次数，以及 Entry/业务/Exit 异常、内部捕获、递归和重复织入拒绝。生产驱动仍只装载正式的 Collector 或 Weaver 插件，不使用测试插件。

元数据读取、会话路径约束和旧版织入限额另有真实编译测试：

```sh
python3 tests/aspect_cj_driver/hardening_smoke.py \
    --compiler /absolute/path/to/matching/cjc \
    --stdx-directory "$STDX_DIR"
```

测试覆盖会话内文件/别名、会话外同名前缀目录、父目录穿越、越界符号链接、8 MiB 文件读取边界、普通文件检查，以及 legacy 字段/记录/文件超限和截断元数据。仅用于 Linux 验证，不需要网络；所有输入在独立临时目录生成并清理。旧式单个目标编译动作的元数据合计上限为 8 MiB、8192 条记录，单字段上限 65536 字节；超限是编译错误而不是静默跳过织入。

SDK 目录摘要另有直接编译生产驱动源码的默认/O2 回归：

```sh
python3 tests/aspect_cj_driver/toolchain_digest_smoke.py \
    --compiler /absolute/path/to/matching/cjc \
    --stdx-directory "$STDX_DIR"
```

该测试覆盖嵌套文件变更/恢复、目录及文件别名、外部链接目标内容变更、链接重定向、祖先目录环、断链、FIFO 和非目录根输入；只在独立临时目录创建测试数据，不修改 SDK。正式 LLT `rule_final_library_linking.cj` 还通过临时 SDK 链接布局验证真实构建、最终库链接及接口不一致拒绝。

规则元数据的并发 GC 与副本隔离另有独立回归：

```sh
python3 tests/aspect_cj_driver/wire_gc_smoke.py \
    --compiler /absolute/path/to/matching/cjc \
    --stdx-directory "$STDX_DIR"
```

该脚本直接编译生产驱动源码，仅替换测试入口。默认及 `-O2` 分别真实收集、织入并运行包含 R/C/A/L 的混合切面；随后在 64 MiB 堆下并发请求 GC，完成 2000 轮完整编码/解码比对，并检查输入数组、返回字段和记录副本隔离。它保留临时目录及逐阶段日志，超时、异常或崩溃均失败，不自动重试。输出中的 `gcCalls` 是 GC API 调用次数，不等于运行时完成的独立回收次数。配套 cangjie_test 中的 `rule_wire_gc_whitebox.cj` 通过正式 Linux/CJNATIVE LLT 入口检查同类内核行为；此 Python 脚本本身仍需独立运行。

规则内核与 CHIR 快照的可复跑单元测试位于 `tests/aspect_cj_driver`。快照测试需要同版本 stdx 构建的 CHIR 源码、对应 schema 生成文件、模块目录和 `flatbuffers.a`；四项参数同时提供时运行快照测试，否则只运行规则内核默认及 `-O2`。脚本不会误用源码目录中遗留的旧生成文件：

```sh
python3 tests/aspect_cj_driver/unit_smoke.py \
    --compiler /absolute/path/to/matching/cjc \
    --stdx-directory "$STDX_DIR" \
    --chir-source-dir /absolute/path/to/stdx-checkout/src/stdx/chir \
    --chir-generated-file /absolute/path/to/stdx-build/build_temp/build/StdxChirFormat_generated.cj \
    --modules-directory /absolute/path/to/stdx-build/build_temp/build/modules/linux_x86_64_cjnative \
    --flatbuffers-archive /absolute/path/to/stdx-build/build_temp/build/modules/linux_x86_64_cjnative/flatbuffers.a
```

CMake 增量构建依赖可独立检查：

```sh
python3 tests/aspect_cj_driver/cmake_dependency_smoke.py
```

该检查需要 Linux、Python 3、CMake、Ninja 和 Make。它在独立临时目录中加载实际驱动构建规则，用模拟编译器和包产物验证依赖变更后的重建、无变更构建及安装；不修改 SDK，也不替代上述真实仓颉编译与运行测试。
