# cangjie_stdx::compress

## Feature Introduction

compress is a collection module for compression and archiving capabilities, designed to provide streaming, efficient, and easy-to-use compression and archiving tools. It supports single-file compression, data stream compression, and combined use of archiving (packaging) features.

Compression refers to representing data with fewer bits to enable more efficient storage and transmission. This capability is provided by the submodule cangjie_stdx::compress.zlib.

Archiving refers to packaging metadata and content of multiple files/directories into a continuous archive stream (without implicit compression). This capability is provided by the submodule cangjie_stdx::compress.tar, which supports V7/USTAR/PAX/GNU formats.

Compression and archiving are typically used in combination, with a common practice being to archive first and then compress (e.g., tar.gz). This package provides convenient combination tools at the top level (e.g., TarGzip), which integrate packaging and compression into a single-step read-write interface for easy use in common scenarios.

## API List

### Classes

|                 Class Name              |                Function                 |
| --------------------------------- | ---------------------------------- |
| [TarGzip](./compress_package_api/compress_package_classes.md#class-targzip) | One-stop tar.gz compression and extraction tool |
