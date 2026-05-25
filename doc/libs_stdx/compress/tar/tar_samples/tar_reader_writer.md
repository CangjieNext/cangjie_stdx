# Tar 格式数据的归档与提取

示例：

<!-- verify -->
```cangjie
import stdx.compress.tar.*
import std.fs.*
import std.io.*

main() {
    let originalFile = Path("./tgz_src.txt")
    let archiveFile = Path("./archive.tar")
    let extractedFile = Path("./tgz_dst.txt")
    let size = 1024 * 1024

    createFile(originalFile, size)

    let tgzSize = archive(originalFile, archiveFile)
    if (tgzSize > 0) {
        println("Pack(.tar) size: ${tgzSize}")
    } else {
        println("Failed to pack .tar!")
    }

    let extractedBytes = extract(archiveFile, extractedFile)
    if (extractedBytes > 0) {
        println("Unpacked bytes: ${extractedBytes}")
    } else {
        println("Failed to unpack .tar!")
    }

    if (compareFile(originalFile, extractedFile)) {
        println("success")
    } else {
        println("failed")
    }

    remove(originalFile)
    remove(archiveFile)
    remove(extractedFile)
    return 0
}

func archive(srcFileName: Path, tarFileName: Path): Int64 {
    try (outFile: File = File(tarFileName, Write)) {
        var tar = TarWriter(outFile)

        tar.write(srcFileName, entryName: srcFileName.fileName)
        tar.finish()

        return outFile.length
    }
    return 0
}

func extract(tarFileName: Path, destFileName: Path): Int64 {
    var written: Int64 = 0
    try (inFile: File = File(tarFileName, Read), outFile: File = File(destFileName, Write)) {
        var reader = TarReader(inFile)
        for (entry in reader) {
            if (entry.entryType == TarEntryType.RegularFile) {
                if (let Some(data) <- entry.stream) {
                    written = copy(data, to: outFile)
                    break
                }
            }
        }
    }
    return written
}

func createFile(file: Path, size: Int64) {
    File.writeTo(file, Array<Byte>(size, {i => UInt8(i % 256)}))
}

func compareFile(fileName1: Path, fileName2: Path): Bool {
    return File.readFrom(fileName1) == File.readFrom(fileName2)
}
```

运行结果：

```text
Pack(.tar) size: 1050112
Unpacked bytes: 1048576
success
```
