# 类

## class TarGzip

```cangjie
public class TarGzip {}
```

功能：压缩和解压目录或流。

### static func archive(Path, (Path) -> Bool, Path, Bool)

```cangjie
public static func archive(fromDir!: Path, filter!: (Path) -> Bool, destFile!: Path, includeBaseDirectory!: Bool): Unit
```

功能：配合过滤函数选择性地将指定目录压缩为 .tar.gz 文件。内部先以 tar 格式归档目录，再以 gzip 压缩归档结果。

参数：

- fromDir!: Path - 待压缩目录。

- filter!: (Path) -> Bool - 过滤函数，会传入遍历到的目录、文件和软链接路径，返回 true 表示保留，否则丢弃。

- destFile!: Path - 输出的 .tar.gz 文件路径。

- includeBaseDirectory!: Bool - 是否包含根目录。

异常：

- [TarException](../tar/tar_package_api/tar_package_exceptions.md#class-tarexception) - 如果 tar 归档时发生错误，抛出异常。

- [ZlibException](../zlib/zlib_package_api/zlib_package_exceptions.md#class-zlibexception) - 如果 zlib 压缩时发生错误，抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.compress.*
import std.fs.*

main(): Unit {
    // 测试路径
    let testDir = Path("./test_dir")
    let testFile = Path("./test_dir/test.txt")
    let destFile = Path("./test.tar.gz")

    // 创建目录和文件(创建前清理)
    removeIfExists(testDir, recursive: true)
    Directory.create(testDir)
    File.writeTo(testFile, "Hello, TarGzip!".toArray())

    // 使用TarGzip压缩目录，使用过滤函数
    TarGzip.archive(
        fromDir: testDir,
        filter: {path: Path => return path.toString().endsWith(".txt")},
        destFile: destFile,
        includeBaseDirectory: true
    )

    println("Did the TarGzip archive with filter complete successfully? ${exists(destFile)}")

    // 清理测试文件
    removeIfExists(testDir, recursive: true)
    removeIfExists(destFile)
}
```

运行结果：

```text
Did the TarGzip archive with filter complete successfully? true
```

### static func archive(Path, Path, Bool)

```cangjie
public static func archive(fromDir!: Path, destFile!: Path, includeBaseDirectory!: Bool): Unit
```

功能：将指定目录压缩为 .tar.gz 文件。内部先以 tar 格式归档目录，再以 gzip 压缩归档结果。

参数：

- fromDir!: Path - 待压缩的目录路径。

- destFile!: Path - 生成的 .tar.gz 文件路径。

- includeBaseDirectory!: Bool - 是否包含目录本身作为顶级目录。若为 true，归档包内包含该目录；若为 false，仅包含其内容。

异常：

- [TarException](../tar/tar_package_api/tar_package_exceptions.md#class-tarexception) - 如果 tar 归档时发生错误，抛出异常。

- [ZlibException](../zlib/zlib_package_api/zlib_package_exceptions.md#class-zlibexception) - 如果 zlib 压缩时发生错误，抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.compress.*
import std.fs.*

main(): Unit {
    // 测试路径
    let testDir = Path("./test_dir_simple")
    let testFile = Path("./test_dir_simple/test.txt")
    let destFile = Path("./test_simple.tar.gz")

    // 创建目录和文件(创建前清理)
    removeIfExists(testDir, recursive: true)
    Directory.create(testDir)
    File.writeTo(testFile, "Hello, TarGzip Simple Archive!".toArray())

    // 使用TarGzip压缩目录，不使用过滤函数
    TarGzip.archive(
        fromDir: testDir,
        destFile: destFile,
        includeBaseDirectory: true
    )

    println("Did the TarGzip simple archive complete successfully? ${exists(destFile)}")

    // 清理测试文件
    removeIfExists(testDir, recursive: true)
    removeIfExists(destFile)
}
```

运行结果：

```text
Did the TarGzip simple archive complete successfully? true
```

### static func archive(String, (String) -> Bool, String, Bool)

```cangjie
public static func archive(fromDir!: String, filter!: (String) -> Bool, destFile!: String, includeBaseDirectory!: Bool): Unit
```

功能：配合过滤函数选择性地将指定目录压缩为 .tar.gz 文件。内部先以 tar 格式归档目录，再以 gzip 压缩归档结果。

参数：

- fromDir!: String - 待压缩目录。

- filter!: (String) -> Bool - 过滤函数，会传入遍历到的目录、文件和软链接路径，返回 true 表示保留，否则丢弃。

- destFile!: String - 输出的 .tar.gz 文件路径。

- includeBaseDirectory!: Bool - 是否包含根目录。

异常：

- [TarException](../tar/tar_package_api/tar_package_exceptions.md#class-tarexception) - 如果 tar 归档时发生错误，抛出异常。

- [ZlibException](../zlib/zlib_package_api/zlib_package_exceptions.md#class-zlibexception) - 如果 zlib 压缩时发生错误，抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.compress.*
import std.fs.*

main(): Unit {
    // 测试路径
    let testDir = "./test_dir_str_filter"
    let testFile = "./test_dir_str_filter/test.txt"
    let testLogFile = "./test_dir_str_filter/test.log"
    let destFile = "./test_str_filter.tar.gz"

    // 创建目录和文件(创建前清理)
    removeIfExists(testDir, recursive: true)
    Directory.create(testDir)
    File.writeTo(testFile, "Hello, TarGzip String Filter Archive!".toArray())
    File.writeTo(testLogFile, "This is a log file that should be filtered out".toArray())

    // 使用TarGzip压缩目录，使用字符串过滤函数
    TarGzip.archive(
        fromDir: testDir,
        filter: {path: String => return path.endsWith(".txt")},
        destFile: destFile,
        includeBaseDirectory: true
    )

    println("Did the TarGzip archive with string filter complete successfully? ${exists(Path(destFile))}")

    // 清理测试文件
    removeIfExists(testDir, recursive: true)
    removeIfExists(destFile)
}
```

运行结果：

```text
Did the TarGzip archive with string filter complete successfully? true
```

### static func archive(String, String, Bool)

```cangjie
public static func archive(fromDir!: String, destFile!: String, includeBaseDirectory!: Bool): Unit
```

功能：将指定目录压缩为 .tar.gz 文件。内部先以 tar 格式归档目录，再以 gzip 压缩归档结果。

参数：

- fromDir!: String - 待压缩的目录路径。

- destFile!: String - 生成的 .tar.gz 文件路径。

- includeBaseDirectory!: Bool - 是否包含目录本身作为顶级目录。若为 true，归档包内包含该目录；若为 false，仅包含其内容。

异常：

- [TarException](../tar/tar_package_api/tar_package_exceptions.md#class-tarexception) - 如果 tar 归档时发生错误，抛出异常。

- [ZlibException](../zlib/zlib_package_api/zlib_package_exceptions.md#class-zlibexception) - 如果 zlib 压缩时发生错误，抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.compress.*
import std.fs.*

main(): Unit {
    // 测试路径
    let testDir = "./test_dir_str_simple"
    let testFile = "./test_dir_str_simple/test.txt"
    let destFile = "./test_str_simple.tar.gz"

    // 创建目录和文件(创建前清理)
    removeIfExists(testDir, recursive: true)
    Directory.create(testDir)
    File.writeTo(testFile, "Hello, TarGzip String Simple Archive!".toArray())

    // 使用TarGzip压缩目录，使用字符串参数
    TarGzip.archive(
        fromDir: testDir,
        destFile: destFile,
        includeBaseDirectory: true
    )

    println("Did the TarGzip string simple archive complete successfully? ${exists(destFile)}")

    // 清理测试文件
    removeIfExists(testDir, recursive: true)
    removeIfExists(destFile)
}
```

运行结果：

```text
Did the TarGzip string simple archive complete successfully? true
```

### static func archive\<T>(Path, T, Bool) where T <: OutputStream

```cangjie
public static func archive<T>(fromDir!: Path, destStream!: T, includeBaseDirectory!: Bool): Unit where T <: OutputStream
```

功能：将目录压缩为 .tar.gz 数据并写入指定输出流。

> **注意：**
>
> 函数不负责 destStream 资源的释放，调用方需自行管理该输出流的生命周期。

参数：

- fromDir!: Path - 待压缩的目录路径。

- destStream!: T - 压缩后数据的输出流。

- includeBaseDirectory!: Bool - 是否包含根目录。

异常：

- [TarException](../tar/tar_package_api/tar_package_exceptions.md#class-tarexception) - 如果 tar 归档时发生错误，抛出异常。

- [ZlibException](../zlib/zlib_package_api/zlib_package_exceptions.md#class-zlibexception) - 如果 zlib 压缩时发生错误，抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.compress.*
import std.fs.*
import std.io.*

main(): Unit {
    // 测试路径
    let testDir = Path("./test_dir_stream")
    let testFile = Path("./test_dir_stream/test.txt")
    let destFile = Path("./test_stream.tar.gz")

    // 创建目录和文件(创建前清理)
    removeIfExists(testDir, recursive: true)
    Directory.create(testDir)
    File.writeTo(testFile, "Hello, TarGzip Stream Archive!".toArray())

    // 创建文件输出流
    let fileStream = File(destFile, Write)

    // 使用TarGzip压缩目录到输出流
    TarGzip.archive(
        fromDir: testDir,
        destStream: fileStream,
        includeBaseDirectory: true
    )

    // 关闭流
    fileStream.close()

    println("Did the TarGzip archive to stream complete successfully? ${exists(destFile)}")

    // 清理测试文件
    removeIfExists(testDir, recursive: true)
    removeIfExists(destFile)
}
```

运行结果：

```text
Did the TarGzip archive to stream complete successfully? true
```

### static func archive\<T>(String, T, Bool) where T <: OutputStream

```cangjie
public static func archive<T>(fromDir!: String, destStream!: T, includeBaseDirectory!: Bool): Unit where T <: OutputStream
```

功能：将目录压缩为 .tar.gz 数据并写入指定输出流。

> **注意：**
>
> 函数不负责 destStream 资源的释放，调用方需自行管理该输出流的生命周期。

参数：

- fromDir!: String - 待压缩的目录路径。

- destStream!: T - 压缩后数据的输出流。

- includeBaseDirectory!: Bool - 是否包含根目录。

异常：

- [TarException](../tar/tar_package_api/tar_package_exceptions.md#class-tarexception) - 如果 tar 归档时发生错误，抛出异常。

- [ZlibException](../zlib/zlib_package_api/zlib_package_exceptions.md#class-zlibexception) - 如果 zlib 压缩时发生错误，抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.compress.*
import std.fs.*
import std.io.*

main(): Unit {
    // 测试路径
    let testDir = "./test_dir_stream_str"
    let testFile = "./test_dir_stream_str/test.txt"
    let destFile = "./test_stream_str.tar.gz"

    // 创建目录和文件(创建前清理)
    removeIfExists(testDir, recursive: true)
    Directory.create(testDir)
    File.writeTo(testFile, "Hello, TarGzip Stream Archive with String Path!".toArray())

    // 创建文件输出流
    let fileStream = File(destFile, Write)

    // 使用TarGzip压缩目录到输出流（使用字符串路径）
    TarGzip.archive(
        fromDir: testDir,
        destStream: fileStream,
        includeBaseDirectory: true
    )

    // 关闭流
    fileStream.close()

    println("Did the TarGzip archive to stream with string path complete successfully? ${exists(destFile)}")

    // 清理测试文件
    removeIfExists(testDir, recursive: true)
    removeIfExists(destFile)
}
```

运行结果：

```text
Did the TarGzip archive to stream with string path complete successfully? true
```

### static func extract(Path, Path, Bool)

```cangjie
public static func extract(fromTarGzip!: Path, destDir!: Path, overwrite!: Bool): Unit
```

功能：将 .tar.gz 文件解压至指定目录。内部先以 gzip 解压缩，再以 tar 解包。

参数：

- fromTarGzip!: Path - 待解压的 .tar.gz 文件路径。

- destDir!: Path - 解压目标目录。

- overwrite!: Bool - 若为 true，允许覆盖已存在文件、目录；否则遇到重名文件、目录将抛出异常。

异常：

- [TarException](../tar/tar_package_api/tar_package_exceptions.md#class-tarexception) - 如果 tar 提取时发生错误，抛出异常。

- [ZlibException](../zlib/zlib_package_api/zlib_package_exceptions.md#class-zlibexception) - 如果 zlib 解压时发生错误，抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.compress.*
import std.fs.*

main(): Unit {
    // 测试路径
    let testDir = Path("./test_extract_dir")
    let testFile = Path("./test_extract_dir/test.txt")
    let archiveFile = Path("./test_extract.tar.gz")
    let extractDir = Path("./extracted_dir")

    // 创建目录和文件(创建前清理)
    removeIfExists(testDir, recursive: true)
    Directory.create(testDir)
    File.writeTo(testFile, "Hello, TarGzip Extract!".toArray())

    // 首先创建一个压缩文件
    TarGzip.archive(
        fromDir: testDir,
        destFile: archiveFile,
        includeBaseDirectory: true
    )

    // 清理测试目录，保留压缩文件
    removeIfExists(testDir, recursive: true)

    // 创建解压目标目录
    removeIfExists(extractDir, recursive: true)
    Directory.create(extractDir)

    // 解压文件
    TarGzip.extract(
        fromTarGzip: archiveFile,
        destDir: extractDir,
        overwrite: true
    )

    println("Did the TarGzip extract complete successfully? ${exists(extractDir)}")

    // 清理测试文件
    removeIfExists(archiveFile)
    removeIfExists(extractDir, recursive: true)
}
```

运行结果：

```text
Did the TarGzip extract complete successfully? true
```

### static func extract(String, String, Bool)

```cangjie
public static func extract(fromTarGzip!: String, destDir!: String, overwrite!: Bool): Unit
```

功能：将 .tar.gz 文件解压至指定目录。内部先以 gzip 解压缩，再以 tar 解包。

参数：

- fromTarGzip!: String - 待解压的 .tar.gz 文件路径。

- destDir!: String - 解压目标目录。

- overwrite!: Bool - 若为 true，允许覆盖已存在文件、目录；否则遇到重名文件、目录将抛出异常。

异常：

- [TarException](../tar/tar_package_api/tar_package_exceptions.md#class-tarexception) - 如果 tar 提取时发生错误，抛出异常。

- [ZlibException](../zlib/zlib_package_api/zlib_package_exceptions.md#class-zlibexception) - 如果 zlib 解压时发生错误，抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.compress.*
import std.fs.*

main(): Unit {
    // 测试路径
    let testDir = "./test_extract_dir_str"
    let testFile = "./test_extract_dir_str/test.txt"
    let archiveFile = "./test_extract_str.tar.gz"
    let extractDir = "./extracted_dir_str"

    // 创建目录和文件(创建前清理)
    removeIfExists(testDir, recursive: true)
    Directory.create(testDir)
    File.writeTo(testFile, "Hello, TarGzip Extract with String Paths!".toArray())

    // 首先创建一个压缩文件
    TarGzip.archive(
        fromDir: testDir,
        destFile: archiveFile,
        includeBaseDirectory: true
    )

    // 清理测试目录，保留压缩文件
    removeIfExists(testDir, recursive: true)

    // 创建解压目标目录
    removeIfExists(extractDir, recursive: true)
    Directory.create(extractDir)

    // 解压文件（使用字符串路径）
    TarGzip.extract(
        fromTarGzip: archiveFile,
        destDir: extractDir,
        overwrite: true
    )

    println("Did the TarGzip extract with string paths complete successfully? ${exists(extractDir)}")

    // 清理测试文件
    removeIfExists(archiveFile)
    removeIfExists(extractDir, recursive: true)
}
```

运行结果：

```text
Did the TarGzip extract with string paths complete successfully? true
```

### static func extract\<T>(T, Path, Bool) where T <: InputStream

```cangjie
public static func extract<T>(fromStream!: T, destDir!: Path, overwrite!: Bool): Unit where T <: InputStream
```

功能：将 .tar.gz 数据从输入流中读取并解压至指定目录。

参数：

- fromStream!: T - 待解压的 .tar.gz 数据输入流。

- destDir!: Path - 解压目标目录。

- overwrite!: Bool - 若为 true，允许覆盖已存在文件、目录；否则遇到重名文件、目录将抛出异常。

异常：

- [TarException](../tar/tar_package_api/tar_package_exceptions.md#class-tarexception) - 如果 tar 提取时发生错误，抛出异常。

- [ZlibException](../zlib/zlib_package_api/zlib_package_exceptions.md#class-zlibexception) - 如果 zlib 解压时发生错误，抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.compress.*
import std.fs.*
import std.io.*

main(): Unit {
    // 测试路径
    let testDir = Path("./test_extract_stream_dir")
    let testFile = Path("./test_extract_stream_dir/test.txt")
    let archiveFile = Path("./test_extract_stream.tar.gz")
    let extractDir = Path("./extracted_stream_dir")

    // 创建目录和文件(创建前清理)
    removeIfExists(testDir, recursive: true)
    Directory.create(testDir)
    File.writeTo(testFile, "Hello, TarGzip Extract with Stream!".toArray())

    // 首先创建一个压缩文件
    TarGzip.archive(
        fromDir: testDir,
        destFile: archiveFile,
        includeBaseDirectory: true
    )

    // 清理测试目录，保留压缩文件
    removeIfExists(testDir, recursive: true)

    // 创建解压目标目录
    removeIfExists(extractDir, recursive: true)
    Directory.create(extractDir)

    // 创建输入流并从文件读取
    let inputStream = File(archiveFile, Read)

    // 从输入流解压文件
    TarGzip.extract(
        fromStream: inputStream,
        destDir: extractDir,
        overwrite: true
    )

    // 关闭输入流
    inputStream.close()

    println("Did the TarGzip extract from stream complete successfully? ${exists(extractDir)}")

    // 清理测试文件
    removeIfExists(archiveFile)
    removeIfExists(extractDir, recursive: true)
}
```

运行结果：

```text
Did the TarGzip extract from stream complete successfully? true
```

### static func extract\<T>(T, String, Bool) where T <: InputStream

```cangjie
public static func extract<T>(fromStream!: T, destDir!: String, overwrite!: Bool): Unit where T <: InputStream
```

功能：将 .tar.gz 数据从输入流中读取并解压至指定目录。

参数：

- fromStream!: T - 待解压的 .tar.gz 数据输入流。

- destDir!: String - 解压目标目录。

- overwrite!: Bool - 若为 true，允许覆盖已存在文件、目录；否则遇到重名文件、目录将抛出异常。

异常：

- [TarException](../tar/tar_package_api/tar_package_exceptions.md#class-tarexception) - 如果 tar 提取时发生错误，抛出异常。

- [ZlibException](../zlib/zlib_package_api/zlib_package_exceptions.md#class-zlibexception) - 如果 zlib 解压时发生错误，抛出异常。

示例：

<!-- verify -->
```cangjie
import stdx.compress.*
import std.fs.*
import std.io.*

main(): Unit {
    // 测试路径
    let testDir = Path("./test_extract_stream_str_dir")
    let testFile = Path("./test_extract_stream_str_dir/test.txt")
    let archiveFile = Path("./test_extract_stream_str.tar.gz")
    let extractDir = "./extracted_stream_str_dir"

    // 创建目录和文件(创建前清理)
    removeIfExists(testDir, recursive: true)
    Directory.create(testDir)
    File.writeTo(testFile, "Hello, TarGzip Extract with Stream and String Path!".toArray())

    // 首先创建一个压缩文件
    TarGzip.archive(
        fromDir: testDir,
        destFile: archiveFile,
        includeBaseDirectory: true
    )

    // 清理测试目录，保留压缩文件
    removeIfExists(testDir, recursive: true)

    // 创建解压目标目录
    removeIfExists(extractDir, recursive: true)
    Directory.create(extractDir)

    // 创建输入流并从文件读取
    let inputStream = File(archiveFile, Read)

    // 从输入流解压文件（目标目录使用字符串路径）
    TarGzip.extract(
        fromStream: inputStream,
        destDir: extractDir,
        overwrite: true
    )

    // 关闭输入流
    inputStream.close()

    println("Did the TarGzip extract from stream with string path complete successfully? ${exists(extractDir)}")

    // 清理测试文件
    removeIfExists(archiveFile)
    removeIfExists(extractDir, recursive: true)
}
```

运行结果：

```text
Did the TarGzip extract from stream with string path complete successfully? true
```
