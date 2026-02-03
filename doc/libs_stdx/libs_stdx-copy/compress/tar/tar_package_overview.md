# stdx.compress.tar

## 功能介绍

compress.tar 提供了归档和读取功能。

归档是一种将多个文件或目录组织成单个文件的方法，通常用于将多个文件或目录压缩成单个文件，并保存在磁盘上。归档文件通常包含文件的元数据（如文件名、权限、时间戳等）以及文件的内容。常见的归档格式有 tar、zip、rar 等。

本包实现了 tar 归档格式，支持 V7、USTAR、PAX 和 GNU 四种格式。tar 格式广泛用于备份和分发文件的场景中。

> **说明：**
>
> 要进行文件压缩请使用 stdx.compress.zlib 进行压缩或使用 stdx.compress 的组合工具 TarGzip 进行归档压缩操作。

## API 列表

### 类

|                 类名              |                功能                 |
| --------------------------------- | ---------------------------------- |
| [Tar](./tar_package_api/tar_package_classes.md#class-tar) |  tar 文件操作类。      |
| [TarEntry](./tar_package_api/tar_package_classes.md#class-tarentry) | 表示 tar 文件条目。      |
| [V7TarEntry](./tar_package_api/tar_package_classes.md#class-v7tarentry) | 表示 V7 tar 文件条目。      |
| [PosixTarEntry](./tar_package_api/tar_package_classes.md#class-posixtarentry) | 表示 Posix tar 文件条目。      |
| [UstarTarEntry](./tar_package_api/tar_package_classes.md#class-ustartarentry) | 表示 USTAR tar 文件条目。      |
| [GnuTarEntry](./tar_package_api/tar_package_classes.md#class-gnutarentry) | 表示 GNU tar 文件条目。      |
| [PaxTarEntry](./tar_package_api/tar_package_classes.md#class-paxtarentry) | 表示 Pax tar 文件条目。      |
| [TarReader](./tar_package_api/tar_package_classes.md#class-tarreader) | 用于读取 tar 文件的读取器。      |
| [TarWriter](./tar_package_api/tar_package_classes.md#class-tarwriter) | 用于写入 tar 文件的写入器。      |

### 枚举

|                 枚举名              |                功能                 |
| --------------------------------- | ---------------------------------- |
| [TarEntryFormat](./tar_package_api/tar_package_enums.md#enum-tarentryformat) | tar 条目格式。      |
| [TarEntryType](./tar_package_api/tar_package_enums.md#enum-tarentrytype) | tar 条目类型。      |

### 异常类

|                 异常类名              |                功能                 |
| --------------------------------- | ---------------------------------- |
| [TarException](./tar_package_api/tar_package_exceptions.md#class-tarexception) | `tar` 包的异常类。      |
