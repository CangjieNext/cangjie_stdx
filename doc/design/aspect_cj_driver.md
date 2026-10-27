# aspect_cj 分阶段构建驱动（cjnative / Linux）

开发参考：[规则切点实现设计](aspect_cj_rule_design.md)说明内部架构，本文提供生产驱动的构建配置与使用方法。用户公共接口另见[API 类文档](../libs_stdx/aspect_cj/aspect_cj_package_api/aspect_cj_package_classes.md)。

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

测试脚本、测试插件与测试数据统一放在 [cangjie_test 的 aspect_cj 测试目录](https://gitcode.com/Cangjie/cangjie_test/tree/main/testsuites/support/aspect_cj_driver)。该目录的 README 提供独立回归命令；测试素材不参与 stdx 的构建或安装。
