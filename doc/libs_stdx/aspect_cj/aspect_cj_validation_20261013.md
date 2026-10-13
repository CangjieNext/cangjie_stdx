# AspectCJ 联合修复本地验证（2026-10-13）

本记录对应 stdx #862、compiler #2224、test #2306 的本轮增量修复。环境为 Ubuntu 22.04 / WSL2 / Linux x86_64 / cjnative、Clang 15 和官方 SDK `1.3.0-alpha.20261010001050`。运行时及标准库使用 SDK，未声称全量重编；以下是本地结果，不是社区多平台 CI 结论。

## 修复与评审对应

- Replace：保留目标成员身份及虚派发入口，正确绑定原函数回调的接收者；迁移 CHIR 函数体时同步块组与参数所有权。默认和 O2 下覆盖类、结构体、枚举、静态与实例方法、接口派发和重复替换。
- CHIR 属性：补齐 `ObjCImpl`，保证 42 个属性的 wire 索引与编译器一致。
- 候选封存：匿名插件辅助体不算源候选；新增命名候选在优化前后均被拒绝，不能依赖 DCE 隐藏非法声明。
- 编译选项：`--emit-chir-annotation-metadata` 按无参数 FLAG 规则注册为 `MULTIPLE_OCCURRENCE`，原 `FlagOccurrenceSetTest` 不变，新增重复选项解析测试。
- 白盒非阻塞建议 H-1/H-2：legacy 类型匹配共用预算实现；文件读取、字段、记录及 legacy 跨文件累计用量有上限。
- H-3/H-4：旧版织入显式检查实参数组、顶层捕获异常；规则来源路径 canonicalize 后必须位于本次会话内，拒绝兄弟目录、父路径越界及外部符号链接。

## 验证结果

| 范围 | 结果 |
|---|---|
| 编译器构建、stdx Release 构建及安装 | 通过 |
| 上游 OptionTest 两份测试源码，含新增测试 | 31/31；上游原有 1 条禁用测试保持禁用 |
| 注解元数据白盒 | 27/27 |
| 规则内核，默认 / O2 | 各 206/206 |
| CHIR 快照与所有权 | 45/45 |
| 泛型、异常递归、Replace 接收者语义 | 默认/O2 共 8 组通过 |
| 分阶段驱动 | 20 组输出通过（组数不等于独立用例数） |
| 上游 AOP HLT，默认 / O2 | 各 80/80；没有排除以前失败的 Replace 用例 |
| AOP LLT，默认 / O2 | 各 61/61；另跑新增 `metadata_hardening.cj`，各 1/1 |
| CHIR 插件 API，默认 / O2 | 各 18/18 |
| 依赖报告路径检查 | 12/12 |
| `hardening_smoke.py` | 22 个执行场景通过：路径和读取边界默认/O2 共 16 个，legacy 元数据 6 个 |
| 属性索引一致性 | 42/42 |
| 本地 cjlint（aspect_cj 源码目录） | MANDATORY 0；保留 360 条 SUGGESTIONS，不等于所有告警清零 |
| 本轮新增 C++ 修改的 Lizard 补充检查 | 无新增超限函数/行宽；不替代社区 Codecheck |
| 构建输入一致性 | 32 个 stdx、32 个编译器变更源文件逐一与构建副本相同 |

本地 OptionTest 使用现有 LLVM checkout 的 GoogleTest 和同一批编译器目标对象单独链接；未跑编译器所有 CTest，不能把 31 项结果当成全部编译器单元测试通过。此次实际执行测试的 `cjc` 与构建目录二进制 SHA-256 相同：`f68150a213e86da85e54aec2bfc48676814ff5a73591de93d4ba15c2d7aa578b`。

## 可复跑入口

- `tests/aspect_cj_driver/unit_smoke.py`：规则内核与快照，参数见驱动 README。
- `tests/aspect_cj_driver/semantic_smoke.py`、`smoke.py`、`hardening_smoke.py`：真实编译与执行；均使用匹配的 compiler/stdx。
- `cangjie_test/testsuites/HLT/API/stdx/aspect_cj` 和 `LLT/compiler/Plugins/AOP_tests`：仓库 Maple 测试框架，分别以默认及 `-O2` 运行。
- 本轮新增正式 LLT：`move_body_ownership.cj`、`replace_member_callback_regression.cj`、`negative_cases/late_source_candidate.cj`、`negative_cases/metadata_hardening.cj`。
- 编译器启用测试构建后运行 `ctest -R '^OptionTest$' --output-on-failure`。

仍需社区 CI 验证其他操作系统和架构，并由 Owner/Committer 完成检视及合入；本记录不代表这些步骤已完成。

## 后续 LLT 门禁失败复核与修复

流水线 `1b17eab824a04932be7d23972b11cbd1` 的 `test_linux_llt_cjc_libs` 最终有 8 条失败。本节是该失败后的增量复核，不能用前一轮本地通过结果代替本节。

前一轮本地环境额外设置了 stdx 动态库搜索路径，未覆盖门禁的完整链接配置；这会掩盖插件/辅助程序缺少运行库路径的问题。本轮直接使用 `cangjie_test/testsuites/LLT/configs/cjnative/cjnative_test.cfg` 的完整 `%import-cangjie-stdx` 配置，外层 `LD_LIBRARY_PATH` 仅保留 SDK runtime/tools，stdx 路径由用例显式设置。没有修改官方配置、移除失败用例或降低诊断断言。

修复内容：

- `metadata_hardening`、`late_source_candidate`、`replace_member_callback_regression` 使用 `%set_stdx_path` 执行依赖 stdx 的辅助程序或自定义插件；元数据测试初始化支持同目录重试。
- 未知注解、参数数量不符、损坏 `.annoinfo` 继续作为编译错误；对应负向测试改为验证非零返回和原诊断，损坏元数据不得产生可执行文件。
- `test_showall` 的完整黄金文本补齐两项新增实验选项，不改为模糊匹配。
- 驱动区分普通文件和目录符号链接，递归读取子目录，并对 canonical 目录去重以终止链接环。此前既会误读目录链接，也会漏掉普通子目录内的内容变化。新增生产源码摘要回归，正式 LLT 使用临时 SDK 链接布局验证实际构建。
- 驱动的文件读取及 ABI 读取移出短路布尔表达式，清理 `G.EXP.03` 强制告警；只有同包来源/目标才读取来源 ABI，保持原适用范围和失败屏障。

本轮本地结果（Linux x86_64 / cjnative）：

| 范围 | 结果 |
|---|---|
| 本次 CI 的 8 条失败用例，默认/O2 | 各 8/8；静态修正后的最终驱动再次验证通过 |
| AOP 插件、stdx AOP API、CHIR 插件 API、帮助选项的完整目录，官方默认配置 | 168/168；另外 9 个辅助 `.cj` 文件无 EXEC 指令，框架记为 UNRESOLVED，不计入通过数 |
| 同一组目录额外统一加 `-O2` | 164/168；4 条旧 CHIR 计数断言不适用该配置，见下表，不能报告为全通过 |
| 生产驱动目录摘要回归，默认/O2 | 均通过：嵌套内容、文件/目录别名、外部目标、重定向、目录环、断链、FIFO、非法根 |
| 驱动编译、`--self-test`、Python 语法检查 | 通过 |
| 最终驱动 `smoke.py` 端到端 | 20 组通过，含跨包、默认/O2、链接正逆序、接口不一致及篡改拒绝 |
| 本地 cjlint，`build/aspect_cj_driver` | MANDATORY 0；SUGGESTIONS 118，未声称所有告警清零 |
| 两仓本轮差异的 `git diff --check` | 通过 |

额外 O2 的 4 条失败均已用未修改的 SDK `cjc` 与本 PR 配套 `cjc` 对照，二者实测输出完全一致；默认配置全部通过。本次未调整这些上游测试的断言，避免为不适用的全局选项覆盖放宽原测试：

| 上游用例（均在 `LLT/API/stdx/AOP_tests/custom_plugin`） | 固定断言 | 两种编译器的 O2 输出 |
|---|---:|---:|
| `case1.cj` | function count 3 | 59 |
| `case2.cj` | function count 8 | 64 |
| `case3.cj` | function count 5 | 7 |
| `chir_anno/case_chir_anno.cj` | user non-ext linkage 6 | 90 |

上述是有边界的本地复核，不是全量 LLT/所有平台门禁通过的声明。最终仍以关联三个 PR 的新一轮社区 CI 为准。
