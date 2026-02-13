/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.compress.tar

import std.fs.{Path, File, FileInfo, Directory, SymbolicLink, HardLink, OpenMode, remove, exists, canonicalize}
import std.io.{InputStream, OutputStream, copy}

public class Tar {
    private init() { } // static class

    public static func archive(fromDir!: String, destFile!: String, includeBaseDirectory!: Bool): Unit {
        try (file = File(destFile, OpenMode.Write)) {
            Tar.archive(fromDir: Path(fromDir), destStream: file, includeBaseDirectory: includeBaseDirectory)
        }
    }

    public static func archive(fromDir!: Path, destFile!: Path, includeBaseDirectory!: Bool): Unit {
        try (file = File(destFile, OpenMode.Write)) {
            Tar.archive(fromDir: fromDir, destStream: file, includeBaseDirectory: includeBaseDirectory)
        }
    }

    public static func archive<T>(fromDir!: String, destStream!: T, includeBaseDirectory!: Bool): Unit where T <: OutputStream {
        Tar.archive(fromDir: Path(fromDir), destStream: destStream, includeBaseDirectory: includeBaseDirectory)
    }

    public static func archive<T>(fromDir!: Path, destStream!: T, includeBaseDirectory!: Bool): Unit where T <: OutputStream {
        Tar.archive(fromDir: fromDir, filter: { _ => true }, destStream: destStream, includeBaseDirectory: includeBaseDirectory)
    }

    public static func archive(fromDir!: String, filter!: (String) -> Bool, destFile!: String, includeBaseDirectory!: Bool): Unit {
        try (file = File(destFile, OpenMode.Write)) {
            Tar.archive(fromDir: Path(fromDir), filter: { p: Path => filter(p.toString()) },
                destStream: file, includeBaseDirectory: includeBaseDirectory)
        }
    }

    public static func archive(fromDir!: Path, filter!: (Path) -> Bool, destFile!: Path, includeBaseDirectory!: Bool): Unit {
        try (file = File(destFile, OpenMode.Write)) {
            Tar.archive(fromDir: fromDir, filter: filter,
                destStream: file, includeBaseDirectory: includeBaseDirectory)
        }
    }

    protected static func archive<T>(fromDir!: Path, filter!: (Path) -> Bool, destStream!: T, includeBaseDirectory!: Bool): Unit where T <: OutputStream {
        if (!exists(fromDir)) {
            throw TarException("From directory not exists: ${fromDir}.")
        }
        if (!FileInfo(fromDir).isDirectory()) {
            throw TarException("From directory is not a directory: ${fromDir}.")
        }
        let fromDirCanonicalized = canonicalize(fromDir)
        if (isRootPath(fromDirCanonicalized.toString())) {
            throw TarException("Can not archive root directory: ${fromDir}.")
        }
        let fromDirNormalized = fromDirCanonicalized.normalizePath()
        let fromDirNormalizedPath = Path(fromDirNormalized)
        let tarWriter = TarWriter(destStream)
        let prefixLength: Int64
        if (includeBaseDirectory) {
            tarWriter.write(path: fromDirNormalized, entryName: fromDirNormalizedPath.fileName)
            prefixLength = fromDirNormalizedPath.parent.toString().size + 1
        } else {
            prefixLength = fromDirNormalized.size + 1
        }
        Directory.walkRecursively(Path(fromDirNormalized)) { fileInfo, targetType =>
            if (!filter(fileInfo.path)) {
                return
            }
            var entryName = fileInfo.path.toString()[prefixLength..]
            if (targetType == TargetType.Directory) {
                entryName += "/"
            }
            tarWriter.write(fileInfo, entryName: entryName)
        }
        tarWriter.finish()
    }

    public static func extract(fromTar!: String, destDir!: String, overwrite!: Bool): Unit {
        try (file = File(fromTar, OpenMode.Read)) {
            Tar.extract(fromStream: file, destDir: Path(destDir), overwrite: overwrite)
        }
    }

    public static func extract(fromTar!: Path, destDir!: Path, overwrite!: Bool): Unit {
        try (file = File(fromTar, OpenMode.Read)) {
            Tar.extract(fromStream: file, destDir: destDir, overwrite: overwrite)
        }
    }

    public static func extract<T>(fromStream!: T, destDir!: String, overwrite!: Bool): Unit where T <: InputStream {
        Tar.extract(fromStream: fromStream, destDir: Path(destDir), overwrite: overwrite)
    }

    public static func extract<T>(fromStream!: T, destDir!: Path, overwrite!: Bool): Unit where T <: InputStream {
        if (!exists(destDir)) {
            Directory.create(destDir, recursive: true)
        }
        let destAbsoluteDir = canonicalize(destDir)
        
        let tarReader = TarReader(fromStream)
        for (entry in tarReader) {
            let entryPath = destAbsoluteDir.join(entry.name)

            if (!entryPath.normalize().toString().startsWith(destAbsoluteDir.toString())) {
                throw TarException("Zip Slip detected: ${entry.name}.")
            }

            if (exists(entryPath)) {
                if (!overwrite) {
                    throw TarException("File ${entryPath} already exists and overwrite is false.")
                }
                if (!FileInfo(entryPath).isDirectory()) {
                    remove(entryPath)
                }
            }

            match (entry.entryType) {
                case TarEntryType.Directory =>
                    if (!exists(entryPath)) {
                        Directory.create(entryPath, recursive: true)
                    }
                case TarEntryType.RegularFile | TarEntryType.V7RegularFile | TarEntryType.ContiguousFile =>
                    let parentDir = entryPath.parent
                    if (!parentDir.isEmpty() && !exists(parentDir)) {
                        Directory.create(parentDir, recursive: true)
                    }
                    if (let Some(stream) <- entry.stream) {
                        try (outputFile = File(entryPath.toString(), OpenMode.Write)) {
                            copy(stream, to: outputFile)
                        }
                    }
                case TarEntryType.Symlink =>
                    checkSymbolicLinkTarget(entry.linkName, destAbsoluteDir)
                    SymbolicLink.create(entryPath, to: Path(entry.linkName))
                case TarEntryType.HardLink =>
                    checkHardLinkTarget(entry.linkName, destAbsoluteDir)
                    HardLink.create(entryPath, to: Path(entry.linkName))
                case _ => continue
            }
            Native.setFileAttributes(entryPath, entry)
        }
    }

    private static func checkSymbolicLinkTarget(linkName: String, destDir: Path) {
        var linkTarget = Path(linkName)
        if (linkTarget.isRelative()) {
            linkTarget = destDir.join(linkTarget).normalize()
        }
        if (!linkTarget.toString().startsWith(destDir.toString())) {
            throw TarException("Symlink points outside target dir.")
        }
    }

    private static func checkHardLinkTarget(linkName: String, destDir: Path) {
        var linkTarget = Path(linkName)
        if (linkTarget.isRelative()) {
            linkTarget = destDir.join(linkTarget).normalize()
        } else {
            throw TarException("Hardlink points to absolute path outside target dir.")
        }
        if (!linkTarget.toString().startsWith(destDir.toString())) {
            throw TarException("Hardlink points outside target dir.")
        }
    }
}
