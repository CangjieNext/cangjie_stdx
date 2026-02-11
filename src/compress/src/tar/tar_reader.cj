/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package cangjie_stdx::compress.tar

import std.io.{InputStream, ByteBuffer}
import std.collection.{Map, HashMap, concat, forEach}
import std.deriving.Derive

// PAX record format
// <length> <keyword>=<value>\n
@Derive[Equatable]
private enum PaxDataState {
    Length |
    Keyword |
    Value
}

func calculateDataBlockPadding(size: Int64): Int64 {
    return (TAR_BLOCK_SIZE - (size % TAR_BLOCK_SIZE)) % TAR_BLOCK_SIZE
}

public class TarReader<T> <: Iterable<TarEntry> where T <: InputStream {
    let stream: T

    // IEEE 1003.1-2008, pax Format
    // Section: Extended Header Records
    // For each file in the archive, there may be one or more extended header records immediately preceding the file data.
    // Each record consists of a series of keyword/value pairs that apply to the file that follows it.
    // If a global extended header record appears before any file in the archive, its keywords shall be considered defaults for all subsequent files until another global extended header record is encountered.
    // Any keywords defined in a per-file extended header shall override the corresponding keywords defined by the most recent global extended header.
    private let paxGlobalData: Map<String, String> = HashMap()
    private let paxData: Map<String, String> = HashMap()
    private var gnuLongName: ?String = None
    private var gnuLongLink: ?String = None

    public init(stream: T) {
        this.stream = stream
    }

    public func iterator(): Iterator<TarEntry> {
        return TarEntryIterator(this)
    }

    func tryGetNextEntry(): ?TarEntry {
        var header: TarHeader
        do {
            header = TarHeader.tryReadHeader(TarHeaderBuffer(stream)) ?? return None
            match (header.entryType) {
                case TarEntryType.GlobalExtendedHeader => paxGlobalData.add(all: readPaxData(header.size))
                case TarEntryType.ExtendedHeader => paxData.add(all: readPaxData(header.size))
                case TarEntryType.GnuLongName => gnuLongName = String.fromUtf8(readDataBlock(header.size))
                case TarEntryType.GnuLongLink => gnuLongLink = String.fromUtf8(readDataBlock(header.size))
                case TarEntryType.GnuSparse |
                     TarEntryType.GnuDumpDir |
                     TarEntryType.GnuMultiVolume |
                     TarEntryType.GnuName |
                     TarEntryType.GnuVolumeHeader => () // Not support.
                case _ => break
            }
        } while (true)

        return generateEntry(header)
    }

    private func generateEntry(header: TarHeader): TarEntry {
        // Apply GNU first for legacy compatibility, then PAX to override per POSIX standard.
        // Industry convention: PAX takes precedence when both exist.
        applyGnuData(header)
        let hasPaxData = applyPaxData(header)

        let dataStream = readDataStream(header.size)
        if (hasPaxData) {
            return PaxTarEntry(header, dataStream)
        }
        return match (header.format) {
            case TarEntryFormat.Ustar => UstarTarEntry(header, dataStream)
            case TarEntryFormat.V7 => V7TarEntry(header, dataStream)
            case TarEntryFormat.Gnu => GnuTarEntry(header, dataStream)
            case TarEntryFormat.Pax => PaxTarEntry(header, dataStream)
        }
    }

    private func applyGnuData(header: TarHeader): Bool {
        var hasGnuData = false
        if (let Some(longName) <- gnuLongName && !longName.isEmpty()) {
            header.name = longName
            gnuLongName = None
            hasGnuData = true
        }
        if (let Some(longLink) <- gnuLongLink && !longLink.isEmpty()) {
            header.linkName = longLink
            gnuLongLink = None
            hasGnuData = true
        }
        return hasGnuData
    }

    private func applyPaxData(header: TarHeader): Bool {
        var hasPaxData = false
        if (paxGlobalData.size > 0 || paxData.size > 0) {
            hasPaxData = true
        }
        paxGlobalData |> concat(paxData) |> forEach(header.addPaxData)
        paxData.clear()
        return hasPaxData
    }

    private func readPaxData(size: Int64): HashMap<String, String> {
        let data = readDataBlock(size)

        let result = HashMap<String, String>()
        var state = PaxDataState.Length
        var position = 0
        var current = 0

        var length = -1
        var end = -1
        var key = ""
        var value = ""

        while (current < data.size) {
            let c = data[current]
            match (state) {
                case PaxDataState.Length =>
                    if (b'0' <= c && c <= b'9') {
                        current++
                    } else if (c == b' ') {
                        length = parseInt64(data[position..current])
                        end = position + length
                        current++
                        position = current
                        state = PaxDataState.Keyword
                    } else {
                        throw TarException("Invalid PAX record, length field includes non-digit character '${c}'.")
                    }
                case PaxDataState.Keyword =>
                    if (end - 1 <= current) {
                        throw TarException("Invalid PAX record, keyword length exceeds record length.")
                    } else if (c == b'=') {
                        key = String.fromUtf8(data[position..current])
                        current++
                        position = current
                        state = PaxDataState.Value
                    } else {
                        current++
                    }
                case PaxDataState.Value =>
                    if (end - 1 > current) {
                        current++
                    } else if (end - 1 < current) {
                        throw TarException("Invalid PAX record, value length exceeds record length.")
                    } else if (c != b'\n') {
                        throw TarException("Invalid PAX record, value does not end with newline.")
                    } else {
                        value = String.fromUtf8(data[position..current])
                        result[key] = value
                        current++
                        position = current
                        state = PaxDataState.Length
                    }
            }
        }
        if (state != PaxDataState.Length) { 
            throw TarException("Invalid PAX record, incomplete record.")
        }
        return result
    }

    private static func parseInt64(data: Array<UInt8>): Int64 {
        var result = 0
        for (digit in data) {
            result *= 10
            result += Int64(digit - b'0')
        }
        return result
    }

    private func skipDataBlockPadding(size: Int64) {
        let padding = calculateDataBlockPadding(size)
        skip(stream, padding)
        return padding
    }

    private func readDataBlock(size: Int64): Array<UInt8> {
        if (size == 0) {
            return []
        }

        let result = Array<UInt8>(size, repeat: 0)
        readExactly(stream, result)
        skipDataBlockPadding(size)
        return result
    }

    private func readDataStream(size: Int64): ?InputStream {
        return ByteBuffer(readDataBlock(size))
    }
}

extend<T> TarReader<T> <: Resource where T <: Resource {
    public func close(): Unit {
        this.stream.close()
    }

    public func isClosed(): Bool {
        return this.stream.isClosed()
    }
}

class TarEntryIterator<T> <: Iterator<TarEntry> where T <: InputStream {
    let tarReader: TarReader<T>
    
    init(tarReader: TarReader<T>) {
        this.tarReader = tarReader
    }

    public func next(): ?TarEntry {
        tarReader.tryGetNextEntry()
    }
}
