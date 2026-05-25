# 仓颉编程语言扩展库API写作指导

## 扩展库API文档说明

文档层级：

```text
libs_stdx // 扩展库API文档
  ├── xxx // 扩展库包名
    ├── figures // 如果有图片，包目录下新建 figures 文件夹
    ├── xxx_package_api // 此包内各类型 API 文档
      ├── xxx_package_classes.md // 此包内 class 类型的 API 文档
      ├── xxx_package_funcs.md // 此包内 function 类型的 API 文档
      └── ...
    ├── xxx_samples // 此包内各场景示例教程
    └── xxx_package_overview.md // 包概述，API 汇总页面
  └── libs_overview.md // 库概述，包汇总页面，展示扩展库包含的所有包及各自的功能简介
└── summary_xxx.md // 文档目录，所有文档需在该文件中“注册”才会最终呈现在构建包中
```

扩展库API文档写作规范与模板详见[仓颉标准库API文档写作指导](https://gitcode.com/Cangjie/cangjie_runtime/blob/dev/stdlib/doc/contribute/template/overview.md)。