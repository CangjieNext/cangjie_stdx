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
