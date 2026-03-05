# cangjie_stdx::compress.zlib

## Function Description

Compression refers to representing data with fewer bits to enable more efficient storage and transmission. In practical applications, compression is widely used in file compression, web page compression, database backups, etc.

The implementation of compression relies on compression algorithms. Mainstream compression algorithms include deflate, lz77, lzw, etc. These algorithms can remove redundant information from data or replace it with more compact representations, thereby achieving data compression. Currently, the deflate algorithm is used.

Based on the deflate compression algorithm, compressed data can be encapsulated into different formats by adding headers and trailers, such as deflate-raw (no encapsulation), gzip, zip, png, etc. Among these, zip can be used for compressing and packaging multiple files, while gzip contains only a single compressed file. Currently supported data formats are deflate-raw and gzip, with file packaging functionality not yet supported.

Additionally, compression levels can be configured. Higher compression levels correspond to higher compression ratios and slower compression speeds, while lower compression levels correspond to lower compression ratios and faster compression speeds.

Specifically, zlib refers to an implementation library for compression functionality. The zlib package implements the deflate algorithm and supports deflate-raw and gzip compression formats.

This package is based on the open-source zlib library, uses the deflate algorithm, supports deflate-raw and gzip data formats, and offers three compression levels: fast, default, and high compression ratio. Compression speed decreases sequentially, while compression ratio increases sequentially.

This package provides streaming compression and decompression functionality, meaning it supports reading data from an input stream, compressing or decompressing it, and writing it to a byte array, or reading data from a byte array, compressing or decompressing it, and writing it to an output stream.

> **Note:**
>
> For file packaging, please use cangjie_stdx::compress.tar for archiving or use the cangjie_stdx::compress combination tool TarGzip for archive compression operations.

## API List

### Classes

|                 Class Name                |                Function                |
| ----------------------------------------- | -------------------------------------- |
| [CompressInputStream](./zlib_package_api/zlib_package_classes.md#class-compressinputstream) | Compression input stream.    |
| [CompressOutputStream](./zlib_package_api/zlib_package_classes.md#class-compressoutputstream) | Compression output stream.       |
| [DecompressInputStream](./zlib_package_api/zlib_package_classes.md#class-decompressinputstream) | Decompression input stream.    |
| [DecompressOutputStream](./zlib_package_api/zlib_package_classes.md#class-decompressoutputstream) | Decompression output stream.      |

### Enums

|                 Enum Name                |                Function                |
| --------------------------------------- | -------------------------------------- |
| [CompressLevel](./zlib_package_api/zlib_package_enums.md#enum-compresslevel) | Compression level.      |
| [WrapType](./zlib_package_api/zlib_package_enums.md#enum-wraptype) | Compressed data format.    |

### Exception Classes

|                 Exception Class Name                |                Function                |
| ------------------------------------------------- | -------------------------------------- |
| [ZlibException](./zlib_package_api/zlib_package_exceptions.md#class-zlibexception) | Exception class for the `zlib` package.      |