# aspect_cj 分阶段构建驱动（cjnative / Linux）

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
  "schemaVersion": 1,
  "sessionId": "0123456789abcdef0123456789abcdef",
  "sessionRoot": "/tmp/aspect-cj-session-001",
  "compiler": "/opt/cangjie/bin/cjc",
  "stdxDirectory": "/opt/stdx/dynamic/stdx",
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

配置中的编译器、stdx 目录、会话目录和源码文件路径必须是 Linux 绝对路径。每个包的 `options` 目前仅接受 `-O0`、`-O1`、`-O2`、`-Os`、`-Oz` 和 `--disable-reflection`；额外导入路径、外部库或第二个插件尚未纳入输入摘要，不得通过任意编译选项绕过构建闭包。

驱动只接受全新的会话目录，并按以下顺序发布成功标志：全部来源包编译且候选文件校验成功后写 `sources.json`；各目标先在不生成切面包导入的情况下确定真正命中的来源，再只导入这些来源做正式预检、计划摘要与依赖图校验，完成后写 `plan.json`；所有目标正式编译/链接和摘要复核后才写 `complete.json`。看到 `sources.json` 或 `plan.json` **不等于**代码已成功交付。任何阶段失败均返回非零；不复用旧会话目录，也不覆盖已有标志文件。

对同一目标同时使用旧式与新式切面时，共用一份预检计划；同一切面函数上旧新控制注解混用会被拒绝。预检发现依赖环、候选元数据不匹配、来源/目标输入在阶段间变化或重复织入时均停止，不发布最终成功标志。

随仓库附有可独立运行的端到端测试：

```sh
python3 tests/aspect_cj_driver/smoke.py \
    --compiler /absolute/path/to/matching/cjc \
    --stdx-directory "$STDX_DIR" \
    --driver /absolute/path/to/aspect-cj-driver
```

测试会保留并打印临时工作目录，覆盖跨包调用与参数快照、AND/OR/NOT、共享规则去重、空注解取反、字面量字符串拼接、命名 `const func` 字段、解析后注解身份/别名/同短名、复杂业务注解字段、非法规则载体、旧新 Entry/Exit 同时织入、旧 Replace 冲突、来源兼目标、真实依赖环、零命中不产生假环及收集/预检/最终链接三个失败屏障。它使用配套工具链的真实编译和运行结果，不以模拟的 `.annoinfo` 文件代替正式 Collector。

泛型候选和异常传播另用一个仅用于测试的同包插件验证：

```sh
python3 tests/aspect_cj_driver/semantic_smoke.py \
    --compiler /absolute/path/to/matching/cjc \
    --stdx-directory "$STDX_DIR"
```

该脚本在默认及 `-O2` 下检查泛型函数、泛型类实例体的计划数和运行次数，以及 Entry/业务/Exit 异常、内部捕获、递归和重复织入拒绝。生产驱动仍只装载正式的 Collector 或 Weaver 插件，不使用测试插件。

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
