# stdx.aspect_cj 规则切点实现设计

本设计对应 [UsersForum #2248](https://gitcode.com/Cangjie/UsersForum/issues/2248) 中的业务注解切点及 AND/OR/NOT 规则组合，建立在原有通配符与 `Array<Any>` 实参能力之上。实现仍使用编译期 CHIR 插件织入，不引入宏、反射代理或业务侧胶水代码。

## 公共接口与语义

`PointcutRule` 标注当前切面包的顶层普通 class，必填 `packageName`、`className`、`methodName`、`funcTypeStr`、`targetKind`、`recursive` 和 `annotationName`。前四项沿用已有通配符语义；`targetKind` 仅可为 `any`、`global`、`static` 或 `instance`。非空 `annotationName` 必须是业务注解类的完整规范名，精确匹配函数源声明上的直接注解；别名解析为同一声明，同短名的其他类不命中。空串表示不施加注解条件。`recursive` 只扩展成员类型名的祖先匹配，不代表注解继承。

`PointcutExpression[packageScope: ..., expression: ...]` 同样标注规则 class。表达式引用本切面包规则类源码名，支持括号及 `NOT`、`AND`、`OR`；优先级依次递减。每层规则保留自己的包范围，外层范围不能覆盖内层范围。规则规范 ID 是声明包全名加类名；重复 ID、未知引用、环及超出预算的规则在收集阶段失败，未被切面引用的错误规则也不忽略。

`InsertAtEntryByRule` 与 `InsertAtExitByRule` 的 `rule` 必须是完整规范 ID。新式切面只能是 public 全局或静态函数，返回 `Unit`，显式参数为零个或一个准确的 `Array<Any>`；实例目标不会把隐式 `this` 放入数组。数组按入口时的显式实参构造独立容器，元素为浅快照，修改容器不会回写形参。旧式 Entry/Exit 和新式 Entry/Exit 可以同时选中同一目标，但新式切面和旧式 Replace 同时选中时预检失败。旧式 API 与元数据解码路径保持独立。

目标是本包有可执行体的普通业务函数及已形成的具体泛型实例体。排除模板、合成辅助、构造/析构、访问器、注解工厂、lambda、`main` 和切面函数。`Unknown` 注解快照是错误，不等于已知空列表，且不能被 `NOT` 取反成为命中。入口切面抛异常时业务体和正常出口切面均不执行；业务体未捕获异常时不执行正常出口切面。不同切面函数间顺序不承诺。

## 编译器与元数据

编译器通过 `--emit-chir-annotation-metadata` 生产版本化 CHIR 注解快照，保存语义分析解析的注解声明身份、源位置、可用的标量字段及来源角色。注解实参的隔离常量求值不执行用户配置的 CHIR 插件；业务注解即使有非标量字段，也保留完整的身份列表，只有标量字段状态可以不可用。关闭反射不移除编译期身份。字段和来源在 C++/仓颉 CHIR 序列化两端往返；旧格式无该能力时不能猜成空列表。

正式插件前冻结候选执行体集合，后续 CHIR 阶段如新增未登记的候选执行体则编译失败。快照读出及序列化前检查旧注解对象修订；修改列表或共享元素后快照失效。应用后的包标记为已织入并记录计划摘要；再次织入拒绝，必须从源构建。

## 分阶段构建

匹配版本的 Linux/cjnative 构建安装 `aspect-cj-driver`、`libstdx.collect_rules.so` 和 `libstdx.weave_rules.so`。运行前加载 SDK 的 `envsetup.sh`，并将同一构建的 stdx 动态库目录加入 `LD_LIBRARY_PATH`；驱动自身也依赖这些动态库。驱动接受一个 JSON 配置，结构如下；路径均为已有绝对路径，`sessionRoot` 必须尚不存在。

```json
{
  "schemaVersion": 2,
  "sessionId": "0123456789abcdef0123456789abcdef",
  "sessionRoot": "/absolute/new-session",
  "compiler": "/absolute/cjc",
  "stdxDirectory": "/absolute/stdx-libraries",
  "dependencies": [],
  "sources": [{"packageName": "shop.aspect", "files": ["/absolute/aspect.cj"], "options": []}],
  "targets": [{"packageName": "shop.service", "files": ["/absolute/service.cj"], "options": [], "outputType": "exe"}]
}
```

执行 `aspect-cj-driver /absolute/config.json`。`options` 仅允许 `-O0/-O1/-O2/-Os/-Oz` 与 `--disable-reflection`；任意导入路径、插件或链接选项都不能从配置注入。来源包按配置顺序收集，新元数据记录会话、来源动作键、工具链 ABI 键、状态和结构化规则记录；旧 v1/v2 文件有独立适配器。来源产物与内容摘要成功后才发布 `sources.json`。每个目标先在不生成切面包导入的情况下纯选择实际命中的来源，再只导入这些来源做符号/签名预检；零命中来源不会被生成导入误记为新增依赖。预检不修改目标 CHIR，核对全部规则、符号、签名、依赖与候选，检查依赖环后发布 `plan.json`；应用时重新计算摘要，最终链接及所有一致性检查通过才发布 `complete.json`。中间失败不得把当前会话宣称为成功，也不覆盖旧会话。

配置 v1 仍支持，但不允许 `dependencies` 字段；v2 必须填写该数组，即使没有外部依赖也使用 `[]`。预编译依赖的每条记录必填六项：

```json
{
  "packageName": "shop.support",
  "module": "/absolute/shop.support.cjo",
  "library": "/absolute/libshop.support.a",
  "compilerSha256": "<实际构建所用cjc文件的64位小写SHA-256>",
  "targetTriple": "linux_x86_64_cjnative",
  "dependencies": ["std.core"]
}
```

目前支持当前 Linux 原生架构的 `.cjo`/`.a` 配对；aarch64 使用 `linux_aarch64_cjnative`。包名不得占用 `std.*`、`stdx.*` 或与本次来源/目标冲突。依赖闭包必须完整声明，非标准库的间接依赖也须列入 `dependencies` 顶层数组或本次来源集合；缺失、重复、工具链或平台不一致均拒绝。驱动复制依赖到会话私有输入目录，并在后续阶段检查原文件与副本摘要。`compilerSha256` 是受信提供方的构建声明，不是驱动从任意二进制反推出的 ABI 证明；最终编译、链接及运行测试仍不可省略。

来源基线库和模块只用于收集、导入和声明解析，不是兼任目标包的最终实现。预检和应用采用同一 `--compile-target`，先分别生成每个目标的对象文件和模块，再归档所有最终静态库，最后链接可执行文件。实际依赖闭包中，静态库目标始终选其织入后的最终库，来源但非目标的包选基线库；不会同时链接同包的两份实现，也不依赖目标配置的排列顺序。静态库自身只归档对象，不把下游库合并进归档。可执行包不可作为依赖库。

同包来源/目标的预检还比较源声明接口摘要，应用阶段再次比较。摘要包含可见函数具体签名及相关标志、公开类型及其字段/继承关系、公开全局变量；它用于发现本次流程的声明不一致，不承诺覆盖任意版本/平台的完整二进制 ABI，也不代表函数体必须相同。模块、对象、最终库、最终可执行文件及预检报告分别绑定内容摘要；所有输出再次核验后才发布 COMPLETE。`complete.json` 的 `compileKey` 与 `linkKey` 分开记录；`linkInputs` 是实际链接使用的库，静态归档的下游依赖另列为 `requiredLinkInputs`。

## 规则复用、预算与诊断

每个编译动作在目标函数循环外，为每个来源构造一次用于目标求值的 `PreparedRuleSource`，拥有独立的已验证记录、原子规则和拓扑图。wire 输入读取另有独立验证；摘要中的准备来源数不是所有静态校验调用次数。根引用直接查表校验，不通过逐根运行整张图做静态验证。每个目标只保留本次求值的局部 scratch/memo，结果不会串到其他目标；共享工作预算覆盖 scratch 初始化、完整拓扑扫描、规则引用、表达式、记录扫描及底层通配符工作，零命中也计费。不把预处理统计冒充跨进程全局缓存：preselect/preflight/apply 各编译动作独立准备。

预检产生 `metadata/matches-<目标包>.json`，列出引用规则根及切面的命中目标数、准备来源数、求值目标数和预算消耗，并提示零命中规则根。未被切面引用的叶规则不在根命中表内；摘要不包含业务实参值。合法零命中是提示，不是失败；未知注解元数据、非法规则或预算超限仍是错误。摘要哈希进入 PLAN_READY/COMPLETE，后续变化会阻止成功发布。

驱动限制 Linux 原生构建；其他平台的动态库打包、原子发布与工具链验证需要各平台单独验收。所有切面代码及其构建输入必须可信；哈希用于一致性检查，不是安全沙箱。`Array<Any>` 可以读取包含敏感信息的业务实参。

## 验收入口

`tests/aspect_cj_driver/unit_smoke.py` 编译运行规则内核和 CHIR 快照单元测试；`semantic_smoke.py` 验证普通与 `-O2` 下的泛型专化、异常传播和合法递归；`smoke.py` 通过已安装驱动验证跨包/同包、复杂业务注解、关闭反射、旧新混合、失败发布屏障及循环依赖。三个脚本都要求与编译器 ABI 匹配的本地 stdx 构建。通过这些脚本不等于通过所有平台的社区 CI；提交前还需跑旧 AOP 回归及仓库门禁。

`unit_smoke.py --benchmark` 另记录一次准备、1024 条规则、512 条切面、1000 个零命中目标的默认及 `-O2` 耗时、峰值 RSS 和预算消耗；它是可复现的规模样本，不是上限 32768 条规则的完整压力验收，也不是新旧实现速度比。新增正式 Maple/LLT 在 `cangjie_test/testsuites/LLT/compiler/Plugins/AOP_tests/linux` 使用仓库已有指令格式：

| 审查修正 | 验证入口 | 检查点 |
|---|---|---|
| 最终库不能退回未织入基线 | `rule_final_library_linking.cj`；`smoke.py` | 默认/O2、正逆序、多应用共享库，运行切面计数，清单无重复基线库 |
| 同包声明及输入绑定 | `rule_final_library_linking.cj`；`smoke.py` | 声明不一致、基线模块修改、预检摘要修改、先前最终输出修改时拒绝 COMPLETE |
| 图复用与预算 | `rule_prepared_whitebox.cj`；`rule_unit.cj` | 防御性所有权、共享图求值、多目标隔离、未知根、Unknown、scratch 超限 |
| 显式预编译依赖 | `rule_final_library_linking.cj`；`smoke.py` | 真实依赖构建/织入/链接/运行，编译器、平台及闭包不匹配时提前拒绝 |
| 可排错匹配摘要 | `smoke.py` | 命中数、准备次数和预算统计，摘要与计划绑定 |

这两个正式用例补齐上述修正的自动回归入口，不代表设计中 T01—T29 的所有子场景都已转为正式 LLT 或多平台 CI。

### 本轮本地验证记录（2026-10-11）

验证环境为 Ubuntu 22.04 / WSL2 / Linux x86_64 / cjnative、Clang 15、官方 SDK `1.3.0-alpha.20261010001050`，配套编译器提交 `f59c171476c47de65b47ec3817e2e70ed9c7726b`。stdx Release 构建与安装通过，规则驱动及插件使用本轮修正源码构建。

| 验证入口 | 结果 |
|---|---|
| 规则内核，默认 / `-O2` | 各 `checks=201, failures=0` |
| CHIR 注解快照 | `snapshot checks=37, failures=0` |
| 泛型函数 / 泛型类 / 异常与递归，默认及 `-O2` | 6 组 PASS |
| 驱动端到端，包括最终库、外部依赖与失败屏障 | 20 组输出均 PASS；组数不等于独立测试用例数 |
| 官方 Maple/LLT AOP，默认 / `-O2` | 各 58/58 PASS，FAIL=0，UNRESOLVED=0；含上述两条新正式用例 |

2026-10-12 提交前核对了已构建源码与提交源码，并再次运行规则内核，默认 / `-O2` 仍各 201 项通过。本表是本地结果，不是社区 CI 或全部平台验收结果；未重编官方运行时与标准库，也未声称已通过全部 T01—T29 子场景。
