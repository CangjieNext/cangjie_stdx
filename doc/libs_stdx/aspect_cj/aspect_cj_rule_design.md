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

匹配版本的 Linux/cjnative 构建安装 `aspect-cj-driver`、`libstdx.collect_rules.so` 和 `libstdx.weave_rules.so`。驱动接受一个 JSON 配置，结构如下；路径均为已有绝对路径，`sessionRoot` 必须尚不存在。

```json
{
  "schemaVersion": 1,
  "sessionId": "0123456789abcdef0123456789abcdef",
  "sessionRoot": "/absolute/new-session",
  "compiler": "/absolute/cjc",
  "stdxDirectory": "/absolute/stdx-libraries",
  "sources": [{"packageName": "shop.aspect", "files": ["/absolute/aspect.cj"], "options": []}],
  "targets": [{"packageName": "shop.service", "files": ["/absolute/service.cj"], "options": [], "outputType": "exe"}]
}
```

执行 `aspect-cj-driver /absolute/config.json`。`options` 仅允许 `-O0/-O1/-O2/-Os/-Oz` 与 `--disable-reflection`；任意导入路径、插件或链接选项都不能从配置注入。来源包按配置顺序收集，新元数据记录会话、来源动作键、工具链 ABI 键、状态和结构化规则记录；旧 v1/v2 文件有独立适配器。来源产物与内容摘要成功后才发布 `sources.json`。每个目标先在不生成切面包导入的情况下纯选择实际命中的来源，再只导入这些来源做符号/签名预检；零命中来源不会被生成导入误记为新增依赖。预检不修改目标 CHIR，核对全部规则、符号、签名、依赖与候选，检查依赖环后发布 `plan.json`；应用时重新计算摘要，最终链接及所有一致性检查通过才发布 `complete.json`。中间失败不得把当前会话宣称为成功，也不覆盖旧会话。

驱动限制 Linux 原生构建；其他平台的动态库打包、原子发布与工具链验证需要各平台单独验收。所有切面代码及其构建输入必须可信；哈希用于一致性检查，不是安全沙箱。`Array<Any>` 可以读取包含敏感信息的业务实参。

## 验收入口

`tests/aspect_cj_driver/unit_smoke.py` 编译运行规则内核和 CHIR 快照单元测试；`semantic_smoke.py` 验证普通与 `-O2` 下的泛型专化、异常传播和合法递归；`smoke.py` 通过已安装驱动验证跨包/同包、复杂业务注解、关闭反射、旧新混合、失败发布屏障及循环依赖。三个脚本都要求与编译器 ABI 匹配的本地 stdx 构建。通过这些脚本不等于通过所有平台的社区 CI；提交前还需跑旧 AOP 回归及仓库门禁。
