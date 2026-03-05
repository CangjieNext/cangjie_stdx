# cangjie_stdx::compress.tar

## Feature Introduction

compress.tar provides archiving and reading capabilities.

Archiving is a method of organizing multiple files or directories into a single file, typically used to package multiple files or directories into a single file and save it on disk. Archive files usually contain file metadata (such as file names, permissions, timestamps, etc.) as well as file contents. Common archive formats include tar, zip, rar, etc.

This package implements the tar archive format, supporting four formats: V7, USTAR, PAX, and GNU. The tar format is widely used in scenarios for backing up and distributing files.

> **Note:**
>
> For file compression, please use cangjie_stdx::compress.zlib for compression or use the cangjie_stdx::compress combination tool TarGzip for archive compression operations.

## API List

### Classes

|                 Class Name              |                Function                 |
| --------------------------------- | ---------------------------------- |
| [Tar](./tar_package_api/tar_package_readerwriter.md#class-tar) |  tar file operation class.      |
| [TarEntry](./tar_package_api/tar_package_entry.md#class-tarentry) | Represents a tar file entry.      |
| [V7TarEntry](./tar_package_api/tar_package_entry.md#class-v7tarentry) | Represents a V7 tar file entry.      |
| [PosixTarEntry](./tar_package_api/tar_package_entry.md#class-posixtarentry) | Represents a Posix tar file entry.      |
| [UstarTarEntry](./tar_package_api/tar_package_entry.md#class-ustartarentry) | Represents a USTAR tar file entry.      |
| [GnuTarEntry](./tar_package_api/tar_package_entry.md#class-gnutarentry) | Represents a GNU tar file entry.      |
| [PaxTarEntry](./tar_package_api/tar_package_entry.md#class-paxtarentry) | Represents a Pax tar file entry.      |
| [TarReader](./tar_package_api/tar_package_readerwriter.md#class-tarreader) | Reader for reading tar files.      |
| [TarWriter](./tar_package_api/tar_package_readerwriter.md#class-tarwriter) | Writer for writing tar files.      |

### Enums

|                 Enum Name              |                Function                 |
| --------------------------------- | ---------------------------------- |
| [TarEntryFormat](./tar_package_api/tar_package_enums.md#enum-tarentryformat) | tar entry format.      |
| [TarEntryType](./tar_package_api/tar_package_enums.md#enum-tarentrytype) | tar entry type.      |

### Exception Classes

|                 Exception Class Name              |                Function                 |
| --------------------------------- | ---------------------------------- |
| [TarException](./tar_package_api/tar_package_exceptions.md#class-tarexception) | Exception class for the `tar` package.      |
