# Classes

## class TarGzip

```cangjie
public class TarGzip {}
```

Function: Compress and extract directories or streams.

### static func archive(Path, (Path) -> Bool, Path, Bool)

```cangjie
public static func archive(fromDir!: Path, filter!: (Path) -> Bool, destFile!: Path, includeBaseDirectory!: Bool): Unit
```

Function: Selectively compress the specified directory into a .tar.gz file with a filter function. Internally, the directory is first archived in tar format, and then the archive result is compressed with gzip.

Parameters:

- fromDir!: Path - The directory to be compressed.

- filter!: (Path) -> Bool - A filter function that receives paths of directories, files, and symbolic links encountered during traversal. Returns true to keep the item, otherwise discards it.

- destFile!: Path - The path of the output .tar.gz file.

- includeBaseDirectory!: Bool - Whether to include the base directory.

Exceptions:

- [TarException](../tar/tar_package_api/tar_package_exceptions.md#class-tarexception) - Thrown if an error occurs during tar archiving.

- [ZlibException](../zlib/zlib_package_api/zlib_package_exceptions.md#class-zlibexception) - Thrown if an error occurs during zlib compression.

### static func archive(Path, Path, Bool)

```cangjie
public static func archive(fromDir!: Path, destFile!: Path, includeBaseDirectory!: Bool): Unit
```

Function: Compress the specified directory into a .tar.gz file. Internally, the directory is first archived in tar format, and then the archive result is compressed with gzip.

Parameters:

- fromDir!: Path - The path of the directory to be compressed.

- destFile!: Path - The path of the generated .tar.gz file.

- includeBaseDirectory!: Bool - Whether to include the directory itself as the top-level directory. If true, the archive contains the directory; if false, only its contents are included.

Exceptions:

- [TarException](../tar/tar_package_api/tar_package_exceptions.md#class-tarexception) - Thrown if an error occurs during tar archiving.

- [ZlibException](../zlib/zlib_package_api/zlib_package_exceptions.md#class-zlibexception) - Thrown if an error occurs during zlib compression.

### static func archive(String, (String) -> Bool, String, Bool)

```cangjie
public static func archive(fromDir!: String, filter!: (String) -> Bool, destFile!: String, includeBaseDirectory!: Bool): Unit
```

Function: Selectively compress the specified directory into a .tar.gz file with a filter function. Internally, the directory is first archived in tar format, and then the archive result is compressed with gzip.

Parameters:

- fromDir!: String - The directory to be compressed.

- filter!: (String) -> Bool - A filter function that receives paths of directories, files, and symbolic links encountered during traversal. Returns true to keep the item, otherwise discards it.

- destFile!: String - The path of the output .tar.gz file.

- includeBaseDirectory!: Bool - Whether to include the base directory.

Exceptions:

- [TarException](../tar/tar_package_api/tar_package_exceptions.md#class-tarexception) - Thrown if an error occurs during tar archiving.

- [ZlibException](../zlib/zlib_package_api/zlib_package_exceptions.md#class-zlibexception) - Thrown if an error occurs during zlib compression.

### static func archive(String, String, Bool)

```cangjie
public static func archive(fromDir!: String, destFile!: String, includeBaseDirectory!: Bool): Unit
```

Function: Compress the specified directory into a .tar.gz file. Internally, the directory is first archived in tar format, and then the archive result is compressed with gzip.

Parameters:

- fromDir!: String - The path of the directory to be compressed.

- destFile!: String - The path of the generated .tar.gz file.

- includeBaseDirectory!: Bool - Whether to include the directory itself as the top-level directory. If true, the archive contains the directory; if false, only its contents are included.

Exceptions:

- [TarException](../tar/tar_package_api/tar_package_exceptions.md#class-tarexception) - Thrown if an error occurs during tar archiving.

- [ZlibException](../zlib/zlib_package_api/zlib_package_exceptions.md#class-zlibexception) - Thrown if an error occurs during zlib compression.

### static func archive\<T>(Path, T, Bool) where T <: OutputStream

```cangjie
public static func archive<T>(fromDir!: Path, destStream!: T, includeBaseDirectory!: Bool): Unit where T <: OutputStream
```

Function: Compress a directory into .tar.gz data and write it to the specified output stream.

> **Note:**
>
> The function does not handle the release of destStream resources; the caller must manage the lifecycle of this output stream.

Parameters:

- fromDir!: Path - The path of the directory to be compressed.

- destStream!: T - The output stream for compressed data.

- includeBaseDirectory!: Bool - Whether to include the base directory.

Exceptions:

- [TarException](../tar/tar_package_api/tar_package_exceptions.md#class-tarexception) - Thrown if an error occurs during tar archiving.

- [ZlibException](../zlib/zlib_package_api/zlib_package_exceptions.md#class-zlibexception) - Thrown if an error occurs during zlib compression.

### static func archive\<T>(String, T, Bool) where T <: OutputStream

```cangjie
public static func archive<T>(fromDir!: String, destStream!: T, includeBaseDirectory!: Bool): Unit where T <: OutputStream
```

Function: Compress a directory into .tar.gz data and write it to the specified output stream.

> **Note:**
>
> The function does not handle the release of destStream resources; the caller must manage the lifecycle of this output stream.

Parameters:

- fromDir!: String - The path of the directory to be compressed.

- destStream!: T - The output stream for compressed data.

- includeBaseDirectory!: Bool - Whether to include the base directory.

Exceptions:

- [TarException](../tar/tar_package_api/tar_package_exceptions.md#class-tarexception) - Thrown if an error occurs during tar archiving.

- [ZlibException](../zlib/zlib_package_api/zlib_package_exceptions.md#class-zlibexception) - Thrown if an error occurs during zlib compression.

### static func extract(Path, Path, Bool)

```cangjie
public static func extract(fromTarGzip!: Path, destDir!: Path, overwrite!: Bool): Unit
```

Function: Extract a .tar.gz file to the specified directory. Internally, it first decompresses with gzip, then unpacks with tar.

Parameters:

- fromTarGzip!: Path - The path of the .tar.gz file to be extracted.

- destDir!: Path - The target directory for extraction.

- overwrite!: Bool - If true, allows overwriting existing files and directories; otherwise, an exception is thrown when encountering files or directories with duplicate names.

Exceptions:

- [TarException](../tar/tar_package_api/tar_package_exceptions.md#class-tarexception) - Thrown if an error occurs during tar extraction.

- [ZlibException](../zlib/zlib_package_api/zlib_package_exceptions.md#class-zlibexception) - Thrown if an error occurs during zlib decompression.

### static func extract(String, String, Bool)

```cangjie
public static func extract(fromTarGzip!: String, destDir!: String, overwrite!: Bool): Unit
```

Function: Extract a .tar.gz file to the specified directory. Internally, it first decompresses with gzip, then unpacks with tar.

Parameters:

- fromTarGzip!: String - The path of the .tar.gz file to be extracted.

- destDir!: String - The target directory for extraction.

- overwrite!: Bool - If true, allows overwriting existing files and directories; otherwise, an exception is thrown when encountering files or directories with duplicate names.

Exceptions:

- [TarException](../tar/tar_package_api/tar_package_exceptions.md#class-tarexception) - Thrown if an error occurs during tar extraction.

- [ZlibException](../zlib/zlib_package_api/zlib_package_exceptions.md#class-zlibexception) - Thrown if an error occurs during zlib decompression.

### static func extract\<T>(T, Path, Bool) where T <: InputStream

```cangjie
public static func extract<T>(fromStream!: T, destDir!: Path, overwrite!: Bool): Unit where T <: InputStream
```

Function: Read .tar.gz data from an input stream and extract it to the specified directory.

Parameters:

- fromStream!: T - The input stream of .tar.gz data to be extracted.

- destDir!: Path - The target directory for extraction.

- overwrite!: Bool - If true, allows overwriting existing files and directories; otherwise, an exception is thrown when encountering files or directories with duplicate names.

Exceptions:

- [TarException](../tar/tar_package_api/tar_package_exceptions.md#class-tarexception) - Thrown if an error occurs during tar extraction.

- [ZlibException](../zlib/zlib_package_api/zlib_package_exceptions.md#class-zlibexception) - Thrown if an error occurs during zlib decompression.

### static func extract\<T>(T, String, Bool) where T <: InputStream

```cangjie
public static func extract<T>(fromStream!: T, destDir!: String, overwrite!: Bool): Unit where T <: InputStream
```

Function: Read .tar.gz data from an input stream and extract it to the specified directory.

Parameters:

- fromStream!: T - The input stream of .tar.gz data to be extracted.

- destDir!: String - The target directory for extraction.

- overwrite!: Bool - If true, allows overwriting existing files and directories; otherwise, an exception is thrown when encountering files or directories with duplicate names.

Exceptions:

- [TarException](../tar/tar_package_api/tar_package_exceptions.md#class-tarexception) - Thrown if an error occurs during tar extraction.

- [ZlibException](../zlib/zlib_package_api/zlib_package_exceptions.md#class-zlibexception) - Thrown if an error occurs during zlib decompression.
