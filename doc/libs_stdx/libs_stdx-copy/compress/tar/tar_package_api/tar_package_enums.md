# 枚举

## enum TarEntryFormat

```cangjie
public enum TarEntryFormat {
    | V7
    | Ustar
    | Pax
    | Gnu
}
```

功能：tar 条目格式。

该枚举表示不同版本的 tar 文件头部格式，用于区分各格式在元数据与扩展字段上的支持程度。

### Gnu

```cangjie
Gnu
```

功能：构造一个 GNU 扩展格式枚举实例。

### Pax

```cangjie
Pax
```

功能：构造一个 PAX 格式枚举实例，表示 POSIX.1-2001 扩展格式，兼容 USTAR，并可通过扩展头记录额外元数据。

### Ustar

```cangjie
Ustar
```

功能：构造一个 USTAR 格式枚举实例，表示 POSIX.1-1988 定义的标准格式。

### V7

```cangjie
V7
```

功能：构造一个 V7 格式枚举实例，表示最初的 UNIX 第七版 tar 格式（1979）。

### func toString(): String

```cangjie
public func toString(): String
```

功能：返回当前 tar 文件头部格式枚举实例的 字符串表示。

返回值：

- String - 当前 tar 文件头部格式枚举实例的 字符串表示。

示例：

<!-- verify -->
```cangjie
import stdx.compress.tar.*

main(): Unit {
    let format = TarEntryFormat.Pax
    println("Tar entry format: ${format}")
}
```

运行结果：

```text
Tar entry format: TarEntryFormat.Pax
```

### operator func !=(TarEntryFormat): Bool

```cangjie
operator func !=(rhs: TarEntryFormat): Bool
```

功能：判断当前 tar 文件头部格式枚举实例是否与传入的 tar 文件头部格式枚举实例不相等。

参数：

- rhs: TarEntryFormat - 要比较的 tar 文件头部格式枚举实例。

返回值：

- Bool - 如果两个 tar 文件头部格式枚举实例不相等，则返回 true；否则返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.compress.tar.*

main(): Unit {
    let format1 = TarEntryFormat.Pax
    let format2 = TarEntryFormat.Gnu

    if (format1 != format2) {
        println("${format1} is not equal to ${format2}")
    } else {
        println("${format1} is equal to ${format2}")
    }
}
```

运行结果：

```text
TarEntryFormat.Pax is not equal to TarEntryFormat.Gnu
```

### operator func ==(TarEntryFormat): Bool

```cangjie
operator func ==(rhs: TarEntryFormat): Bool
```

功能：判断当前 tar 文件头部格式枚举实例是否与传入的 tar 文件头部格式枚举实例相等。

参数：

- rhs: TarEntryFormat - 要比较的 tar 文件头部格式枚举实例。

返回值：

- Bool - 如果两个 tar 文件头部格式枚举实例相等，则返回 true；否则返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.compress.tar.*

main(): Unit {
    let format1 = TarEntryFormat.Pax
    let format2 = TarEntryFormat.Pax
    let format3 = TarEntryFormat.Gnu

    if (format1 == format2) {
        println("${format1} is equal to ${format2}")
    } else {
        println("${format1} is not equal to ${format2}")
    }

    if (format1 == format3) {
        println("${format1} is equal to ${format3}")
    } else {
        println("${format1} is not equal to ${format3}")
    }
}
```

运行结果：

```text
TarEntryFormat.Pax is equal to TarEntryFormat.Pax
TarEntryFormat.Pax is not equal to TarEntryFormat.Gnu
```

## enum TarEntryType

```cangjie
public enum TarEntryType {
    | V7RegularFile
    | RegularFile
    | ContiguousFile
    | HardLink
    | Symlink
    | CharDevice
    | BlockDevice
    | Directory
    | Fifo
    | ExtendedHeader
    | GlobalExtendedHeader
    | GnuLongName
    | GnuLongLink
    | GnuSparse
    | GnuDumpDir
    | GnuMultiVolume
    | GnuName
    | GnuVolumeHeader
    | Unknown(UInt8)
}
```

功能：tar 条目类型。

该枚举定义了所有 tar 文件条目的类型，对应 tar 头部中的 `typeflag` 字段。

### BlockDevice

```cangjie
BlockDevice
```

功能：构造一个块设备文件类型枚举实例，对应 typeflag `'4'`。

### CharDevice

```cangjie
CharDevice
```

功能：构造一个字符设备文件类型枚举实例，对应 typeflag `'3'`。

### ContiguousFile

```cangjie
ContiguousFile
```

功能：构造一个连续文件类型枚举实例，用于表示数据在存储介质上连续排列的文件（typeflag `'7'`）。

### Directory

```cangjie
Directory
```

功能：构造一个目录类型枚举实例，对应 typeflag `'5'`。

### ExtendedHeader

```cangjie
ExtendedHeader
```

功能：构造一个 PAX 扩展头类型枚举实例，对应 typeflag `'x'`，用于存储附加元数据。

### Fifo

```cangjie
Fifo
```

功能：构造一个命名管道（FIFO）类型枚举实例，对应 typeflag `'6'`。

### GlobalExtendedHeader

```cangjie
GlobalExtendedHeader
```

功能：构造一个 PAX 全局扩展头类型枚举实例，对应 typeflag `'g'`，适用于作用于整个归档的全局元信息。

### GnuDumpDir

```cangjie
GnuDumpDir
```

功能：构造一个 GNU Dump 目录类型枚举实例，对应 typeflag `'D'`。

### GnuLongLink

```cangjie
GnuLongLink
```

功能：构造一个 GNU 长链接名扩展类型枚举实例，对应 typeflag `'K'`。

### GnuLongName

```cangjie
GnuLongName
```

功能：构造一个 GNU 长文件名扩展类型枚举实例，对应 typeflag `'L'`。

### GnuMultiVolume

```cangjie
GnuMultiVolume
```

功能：构造一个 GNU 多卷归档条目类型枚举实例，对应 typeflag `'M'`。

### GnuName

```cangjie
GnuName
```

功能：构造一个 GNU 文件名表条目类型枚举实例，对应 typeflag `'N'`。

### GnuSparse

```cangjie
GnuSparse
```

功能：构造一个 GNU 稀疏文件类型枚举实例，对应 typeflag `'S'`。

### GnuVolumeHeader

```cangjie
GnuVolumeHeader
```

功能：构造一个 GNU 卷头条目类型枚举实例，对应 typeflag `'V'`。

### HardLink

```cangjie
HardLink
```

功能：构造一个硬链接类型枚举实例，对应 typeflag `'1'`。

### RegularFile

```cangjie
RegularFile
```

功能：构造一个标准普通文件类型枚举实例，对应 POSIX/USTAR 格式中的普通文件（typeflag `'0'`）。

### Symlink

```cangjie
Symlink
```

功能：构造一个符号链接类型枚举实例，对应 typeflag `'2'`。

### Unknown(UInt8)

```cangjie
Unknown(UInt8)
```

功能：构造一个未知类型条目枚举实例，用于保留无法识别或自定义的 `typeflag` 字节值。

### V7RegularFile

```cangjie
V7RegularFile
```

功能：构造一个 V7 格式的普通文件类型枚举实例，对应早期 Unix V7 格式（typeflag `\0`）。

### prop flag

```cangjie
public prop flag: UInt8
```

功能：获取当前条目的 `typeflag` 字节值。

类型：UInt8

示例：

<!-- verify -->
```cangjie
import stdx.compress.tar.*

main(): Unit {
    let fileType = TarEntryType.RegularFile
    println("Tar entry type flag: ${fileType.flag}")
}
```

运行结果：

```text
Tar entry type flag: 48
```

### static func fromFlag(UInt8)

```cangjie
public static func fromFlag(flag: UInt8): TarEntryType
```

功能：根据传入的 `typeflag` 字节值构造对应的 `TarEntryType` 枚举实例。

参数：

- flag: UInt8 - tar 头部中 `typeflag` 的字节值。

返回值：

- TarEntryType - 对应的条目类型枚举实例。如果无法识别，将返回 `Unknown(flag)`。

示例：

<!-- verify -->
```cangjie
import stdx.compress.tar.*

main(): Unit {
    let fileType = TarEntryType.fromFlag(48) // 48 is the flag for RegularFile
    println("Tar entry type from flag 48: ${fileType}")

    let unknownType = TarEntryType.fromFlag(99) // 99 is an unknown flag
    println("Tar entry type from unknown flag 99: ${unknownType}")
}
```

运行结果：

```text
Tar entry type from flag 48: TarEntryType.RegularFile
Tar entry type from unknown flag 99: TarEntryType.Unknown(99)
```

### func toString(): String

```cangjie
public func toString(): String
```

功能：返回当前条目类型枚举实例的字符串表示。

返回值：

- String - 当前条目类型枚举实例的字符串表示。

示例：

<!-- verify -->
```cangjie
import stdx.compress.tar.*

main(): Unit {
    let fileType = TarEntryType.RegularFile
    println("Tar entry type: ${fileType.toString()}")

    let dirType = TarEntryType.Directory
    println("Tar entry type: ${dirType.toString()}")
}
```

运行结果：

```text
Tar entry type: TarEntryType.RegularFile
Tar entry type: TarEntryType.Directory
```

### operator func !=(TarEntryType): Bool

```cangjie
operator func !=(rhs: TarEntryType): Bool
```

功能：判断当前条目类型枚举实例是否与传入的条目类型枚举实例不相等。

参数：

- rhs: TarEntryType - 要比较的条目类型枚举实例。

返回值：

- Bool - 如果两个条目类型枚举实例不相等，则返回 true；否则返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.compress.tar.*

main(): Unit {
    let fileType = TarEntryType.RegularFile
    let dirType = TarEntryType.Directory

    if (fileType != dirType) {
        println("${fileType} is not equal to ${dirType}")
    } else {
        println("${fileType} is equal to ${dirType}")
    }
}
```

运行结果：

```text
TarEntryType.RegularFile is not equal to TarEntryType.Directory
```

### operator func ==(TarEntryType): Bool

```cangjie
operator func ==(rhs: TarEntryType): Bool
```

功能：判断当前条目类型枚举实例是否与传入的条目类型枚举实例相等。

参数：

- rhs: TarEntryType - 要比较的条目类型枚举实例。

返回值：

- Bool - 如果两个条目类型枚举实例相等，则返回 true；否则返回 false。

示例：

<!-- verify -->
```cangjie
import stdx.compress.tar.*

main(): Unit {
    let fileType1 = TarEntryType.RegularFile
    let fileType2 = TarEntryType.RegularFile
    let dirType = TarEntryType.Directory

    if (fileType1 == fileType2) {
        println("${fileType1} is equal to ${fileType2}")
    } else {
        println("${fileType1} is not equal to ${fileType2}")
    }

    if (fileType1 == dirType) {
        println("${fileType1} is equal to ${dirType}")
    } else {
        println("${fileType1} is not equal to ${dirType}")
    }
}
```

运行结果：

```text
TarEntryType.RegularFile is equal to TarEntryType.RegularFile
TarEntryType.RegularFile is not equal to TarEntryType.Directory
```
