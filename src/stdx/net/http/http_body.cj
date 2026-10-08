/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.net.http

import std.io.*
import std.sync.*
import std.collection.*

interface SeekableInputStream <: InputStream & Seekable {}

interface BodyProviderConn {
    prop isReadTimeout: AtomicBool
    func getBufferConn(): BufferedConn
    func returnConn(): Unit
    func closeConn(): Unit
}

class HttpEmptyBody <: SeekableInputStream {
    static let INSTANCE = HttpEmptyBody()

    private init() {}

    public func read(_: Array<Byte>): Int64 {
        return 0
    }

    public func seek(_: SeekPosition): Int64 {
        0
    }

    public prop length: Int64 {
        get() {
            0
        }
    }
}

class HttpRawBody <: SeekableInputStream {
    var readLen: Int64 = 0
    let rawBody: Array<Byte>

    init(raw: Array<Byte>) {
        this.rawBody = raw
    }

    init(raw: String) {
        this.rawBody = unsafe { raw.rawData() }
    }

    public prop length: Int64 {
        get() {
            this.rawBody.size
        }
    }

    public func read(buf: Array<Byte>): Int64 {
        if (readLen >= rawBody.size) {
            return 0
        }
        let copyLen = min(buf.size, rawBody.size - readLen)
        rawBody.copyTo(buf, readLen, 0, copyLen)
        readLen += copyLen
        return copyLen
    }

    public func seek(_: SeekPosition): Int64 {
        0
    }
}

/*
 * wrap a unknown size input stream, cache all data read from stream
 */
class HttpBufferedBody <: SeekableInputStream {
    private let data: ArrayList<UInt8> = ArrayList<UInt8>()

    HttpBufferedBody(let body: InputStream) {}

    public prop length: Int64 {
        get() {
            this.data.size
        }
    }

    prop bytes: Array<UInt8> {
        get() {
            unsafe { data.getRawArray()[..length] }
        }
    }

    public func read(buf: Array<Byte>): Int64 {
        let len = body.read(buf)
        if (len > 0) {
            data.add(all: buf[..len])
        }
        return len
    }

    public func seek(_: SeekPosition): Int64 {
        0
    }
}

class HttpNormalBody <: SeekableInputStream {
    // 响应体按需从连接读取，不再在构造时把整个 body 收进内存。
    //
    // 原先的实现在构造里读完整个响应体并缓存在 `Array<Byte>` 中，内存占用与响应体大小
    // 成正比：接收大响应（大文件、大制品）时直接顶到堆上限并抛 OutOfMemoryError，
    // 使"协议允许的报文体积"无法兑现。而缓存对调用方没有任何语义价值 —— 本类继承
    // SeekableInputStream，但 `seek` 是空实现（不移动读位置），调用方无法回退读取，
    // 因此"先收全再交付"只带来内存开销。
    //
    // 底层 `HttpNormalBodyProvider.read` 本来就是按需从连接分块读取的，这里直接透传即可；
    // 连接归还、超时取消、EOF 判定仍由 provider 负责，语义不变。
    private let body: HttpNormalBodyProvider
    private let contentLength: Int64

    HttpNormalBody(let body: HttpNormalBodyProvider) {
        this.body = body
        this.contentLength = body.length
    }

    public prop length: Int64 {
        get() {
            contentLength
        }
    }

    public func read(buf: Array<Byte>): Int64 {
        body.read(buf)
    }

    public func seek(_: SeekPosition): Int64 {
        0
    }

    // 转发给 provider：resp.close() 需要能取消读超时 timer 并关闭连接，
    // 否则本类持有的活动连接与已武装的 timer 无人回收。
    public func close(): Unit {
        body.close()
    }
}

class HttpNormalBodyProvider <: SeekableInputStream & Resource {
    var readLen: Int64 = 0
    let conn: BufferedConn
    var eof = false

    HttpNormalBodyProvider(let providerConn: BodyProviderConn, let contentLength: Int64, let timer: HttpTimer) {
        if (contentLength == 0) {
            timer.cancel()
            eof = true
        }
        conn = providerConn.getBufferConn()
    }

    public prop length: Int64 {
        get() {
            contentLength
        }
    }

    public func read(buf: Array<Byte>): Int64 {
        if (eof) {
            return 0
        }
        // remain length of data
        let remainLen = contentLength - readLen
        // read from connection
        let len: Int64
        try {
            len = conn.read(buf, remainLen)
        } catch (e: Exception) {
            timer.cancel()
            providerConn.closeConn()
            if (providerConn.isReadTimeout.load()) {
                throw HttpTimeoutException("Read body timeout and the connection is closed.")
            }
            throw e
        }
        readLen += len
        if (readLen >= contentLength) {
            timer.cancel()
            providerConn.returnConn()
            eof = true
        }
        return len
    }

    public func close(): Unit {
        timer.cancel()
        providerConn.closeConn()
    }

    public func isClosed(): Bool {
        providerConn.getBufferConn().isClosed()
    }

    public func seek(_: SeekPosition): Int64 {
        0
    }
}

/*
 * This body provider is used to read chunk body from peer.
 * chunked-body   = *chunk
 *                 last-chunk
 *                 trailer-section
 *                 CRLF
 *
 * chunk          = chunk-size [ chunk-ext ] CRLF
 *                 chunk-data CRLF
 * chunk-size     = 1*HEXDIG
 * last-chunk     = 1*("0") [ chunk-ext ] CRLF
 *
 * chunk-data     = 1*OCTET ; a sequence of chunk-size octets
 * RFC 9112 7.1.
 */
class HttpChunkedBodyProvider <: InputStream & Resource {
    var eof: Bool = false
    var contentLength = 0
    var remainChunkSize = 0
    var isLastChunk = false
    var maxRequestBodySize: Int64 = 0
    let header: HttpHeaders
    let trailer: HttpHeaders
    let isReq: Bool
    let conn: BufferedConn

    HttpChunkedBodyProvider(let providerConn: BodyProviderConn, let msg: Object, let timer: HttpTimer,
        let maxBodySize: Int64) {
        conn = providerConn.getBufferConn()
        maxRequestBodySize = maxBodySize
        match (msg) {
            case req: HttpRequest =>
                header = req.headers
                trailer = req.trailers
                isReq = true
            case rsp: HttpResponse =>
                header = rsp.headers
                trailer = rsp.trailers
                isReq = false
            case _ => throw HttpException("Internal error: unsupported message type.")
        }
    }

    public func read(dst: Array<Byte>): Int64 {
        if (eof) {
            return 0
        }
        var dstReadLen = 0
        try {
            // parse the existing content in the buffer.
            // chunk-data is from the buffer,
            // but CRLF
            // and chunk-size [ chunk-ext ] CRLF
            // and 1*("0") [ chunk-ext ] CRLF may not.
            // break when eof or buffer is empty or dst is full.
            do {
                remainChunkSize = getRemainSize(remainChunkSize)
                if (remainChunkSize == 0) {
                    return dstReadLen
                }
                let readLen = conn.read(dst[dstReadLen..], remainChunkSize)
                dstReadLen += readLen
                remainChunkSize -= readLen
                if (remainChunkSize == 0) {
                    readNextChunkLine(isReq)
                }
            } while (conn.bufferedReader.remainingData != 0 && dstReadLen != dst.size)
        } catch (e: Exception) {
            timer.cancel()
            providerConn.closeConn()
            if (providerConn.isReadTimeout.load()) {
                throw HttpTimeoutException("Read body timeout and the connection is closed.")
            }
            throw e
        }
        return dstReadLen
    }

    public func close(): Unit {
        timer.cancel()
        providerConn.closeConn()
    }

    public func isClosed(): Bool {
        providerConn.getBufferConn().isClosed()
    }

    private func getRemainSize(remainChunkSize: Int64): Int64 {
        if (remainChunkSize == 0) {
            let chunkSize = readChunkSize()
            this.contentLength += chunkSize
            if (maxRequestBodySize != 0 && this.contentLength > maxRequestBodySize) {
                throw HttpStatusException(HttpStatusCode.STATUS_REQUEST_CONTENT_TOO_LARGE, "Content too large.")
            }
            // last-chunk = 1*("0") [ chunk-ext ] CRLF
            if (chunkSize == 0) {
                eof = true
                readTrailer()
                clearHeader()
                updateBodySize()
                timer.cancel()
                providerConn.returnConn()
            }
            return chunkSize
        }
        return remainChunkSize
    }

    // chunk-data CRLF
    // read CRLF and next chunk-size [ chunk-ext ] CRLF
    private func readNextChunkLine(isReq: Bool) {
        let lf = readLine()
        if (!lf.isEmpty()) {
            if (isReq) {
                throw HttpStatusException(HttpStatusCode.STATUS_BAD_REQUEST, "Bad request.")
            } else {
                throw HttpException("Invalid chunked data.")
            }
        }
    }

    /*
     * Trailer = #field-name
     * trailer-section = *( field-line CRLF )
     * The "Trailer" header field provides a list of field names that the sender anticipates sending as
     * trailer fields within that message. This allows a recipient to prepare for receipt of the indicated
     * metadata before it starts processing the content
     * RFC 9110 6.6.2.
     */
    private func readTrailer(): Unit {
        var trailerLineCount = 0
        while (true) {
            let trailerLine = readLine()
            if (trailerLine.isEmpty()) {
                break
            }
            trailerLineCount++
            if (trailerLineCount > MAX_TRAILER_LINE_COUNT) {
                if (isReq) {
                    throw HttpStatusException(HttpStatusCode.STATUS_BAD_REQUEST, "Too many trailer fields.")
                } else {
                    throw HttpException("Too many trailer fields.")
                }
            }

            let (name, value) = parseAndCheckHeaderLine(trailerLine, isReq)
            if (validTrailerName(name)) {
                trailer.add(name, value)
            }
        }
    }

    private func clearHeader(): Unit {
        // set `Content-Length`
        header.add("content-length", "${contentLength}")
        // remove `chunked` from last
        var hv = header.map.get(Str("transfer-encoding")) ?? return ()
        hv.removeLastValue()
        match (hv.isEmpty()) {
            case true => header.del("transfer-encoding")
            case false => header.map.add(Str("transfer-encoding"), hv)
        }
    }

    private func updateBodySize(): Unit {
        match (msg) {
            case req: HttpRequest => req._bodySize = contentLength
            case rsp: HttpResponse => rsp._bodySize = contentLength
            case _ => ()
        }
    }

    private func validTrailerName(name: String): Bool {
        let trailersArray = header.getInternal("Trailer") ?? return false
        return trailersArray |> splitValuesByComma |> name.toAsciiLower().caseInsensitiveMatchOne
    }

    private func readLine(): Str {
        let line: Str
        try {
            line = conn.readLine()
        } catch (e: HttpException) {
            if (isReq) {
                throw HttpStatusException(HttpStatusCode.STATUS_BAD_REQUEST, "Invalid line.")
            } else {
                throw e
            }
        }
        if (line.contains(CR)) {
            if (isReq) {
                throw HttpStatusException(HttpStatusCode.STATUS_BAD_REQUEST, "Invalid line: contains raw CR.")
            } else {
                throw HttpException("Trailer section cannot contain raw CR.")
            }
        }
        return line
    }

    /*
     * chunk      = chunk-size [ chunk-ext ] CRLF
     *              chunk-data CRLF
     * chunk-size = 1 *HEXDIG
     */
    private func readChunkSize(): Int64 {
        let line = readLine()
        let chunkSize = line.splitFirst(SEMICOLON) ?? throw HttpException("Failed to extract chunk-size from line '${line}'.") // extract chunk-size
        try {
            return Int64.fromHexStr(chunkSize)
        } catch (e: Exception) {
            if (isReq) {
                throw HttpStatusException(HttpStatusCode.STATUS_BAD_REQUEST, "Bad request.")
            } else {
                throw HttpException("Invalid chunked data.")
            }
        }
    }
}

class HttpExpectBodyProvider <: InputStream {
    let realBody: InputStream
    var respondedContinue: Bool = false
    var context: ?HttpContext = None

    HttpExpectBodyProvider(let conn: HttpEngineConn1, let request: HttpRequest, let chunked: Bool,
        let contentLength: ?Int64, let timer: HttpTimer, let maxRequestBodySize: Int64) {
        realBody = match {
            case chunked =>
                request._bodySize = None
                HttpChunkedBodyProvider(conn, request, timer, maxRequestBodySize)
            case _ => match (contentLength) {
                case Some(length) =>
                    request._bodySize = length
                    HttpNormalBodyProvider(conn, length, timer)
                case None =>
                    timer.cancel()
                    throw HttpException("Content-length is missing.")
            }
        }
    }

    func setContext(ctx: HttpContext): Unit {
        this.context = ctx
    }

    public func read(buf: Array<Byte>): Int64 {
        let ctx = context.getOrThrow()
        synchronized(ctx.writerMtx) {
            if (!respondedContinue && !ctx.responseFlushedByUser && !ctx.upgraded && !ctx.responded) {
                // response 100-continue
                let response = HttpResponseBuilder().version(request.version).status(100).build()
                conn.writeWithoutBody(response)
                respondedContinue = true
            }
        }
        // read body
        return realBody.read(buf)
    }
}
