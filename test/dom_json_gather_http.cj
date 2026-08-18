import std.io.*
import std.net.*
import std.collection.*
import stdx.encoding.json.*
import stdx.net.http.*

func ensure(value: Bool, message: String): Unit {
    if (!value) {
        throw Exception(message)
    }
}

func readAll(response: HttpResponse): Array<Byte> {
    let expected = response.bodySize.getOrThrow()
    let result = Array<Byte>(expected, repeat: 0)
    var offset: Int64 = 0
    while (offset < expected) {
        let read = response.body.read(result.slice(offset, expected - offset))
        if (read <= 0) {
            break
        }
        offset += read
    }
    ensure(offset == expected, "segmented HTTP body ended early")
    return result
}

func testSegmentedJsonAndHttpBody(): Unit {
    let payload = Array<Byte>(100_000, repeat: b'a')
    payload[8190] = b'\\'
    payload[8191] = b'"'
    payload[16382] = b'\n'

    let root = JsonObject()
    root.put("payload", JsonString(String.fromUtf8(payload)))
    root.put("minimum", JsonInt(Int64.Min))
    root.put("fraction", JsonFloat(12345.625))
    root.put("emptyObject", JsonObject())
    root.put("emptyArray", JsonArray())

    let expected = root.toStringWithCapacity(110_000).toArray()
    let segmented = root.toSegmentedBytes(segmentSize: 8192)
    ensure(segmented.segmentCount() > 1, "large JSON output was not segmented")
    ensure(segmented.size == expected.size, "segmented JSON length differs")
    for (i in 0..segmented.segmentCount()) {
        ensure(segmented.get(i).size > 0, "segmented JSON contains an empty segment")
        ensure(segmented.get(i).size <= 8192, "segment exceeds configured size")
    }
    ensure(segmented.toArray() == expected, "segmented writer changed JSON bytes")

    let response = HttpResponseBuilder().body(segmented.getSegments()).build()
    ensure(response.bodySize.getOrThrow() == expected.size, "HTTP body lost Content-Length")
    ensure(readAll(response) == expected, "HTTP segmented body changed JSON bytes")
    match (response.body) {
        case body: Seekable => ensure(body.seek(Begin(0)) == 0, "HTTP segmented body cannot rewind")
        case _ => throw Exception("segmented HTTP body is not seekable")
    }
    ensure(readAll(response) == expected, "HTTP segmented body changed after rewind")
}

func testTcpGatherWrite(): Unit {
    // More than 64 non-empty segments forces writeGathered to issue multiple
    // sendmsg batches. Interspersed empty segments also exercise cursor skip.
    let segmentList = ArrayList<Array<Byte>>()
    segmentList.add(Array<Byte>(0, repeat: 0))
    segmentList.add(Array<Byte>(17, repeat: 1))
    for (i in 0..80) {
        if (i % 9 == 0) {
            segmentList.add(Array<Byte>(0, repeat: 0))
        }
        segmentList.add(Array<Byte>(16_384 + i % 17, repeat: UInt8(i % 251)))
    }
    segmentList.add(Array<Byte>(65_537, repeat: 253))
    let segments = segmentList.toArray()
    var expectedSize: Int64 = 0
    for (segment in segments) {
        expectedSize += segment.size
    }
    let totalSize = expectedSize
    let expected = Array<Byte>(totalSize, repeat: 0)
    var expectedOffset: Int64 = 0
    for (segment in segments) {
        segment.copyTo(expected, 0, expectedOffset, segment.size)
        expectedOffset += segment.size
    }

    let server = TcpServerSocket(bindAt: 0u16)
    server.bind()
    let port = (server.localAddress as IPSocketAddress).getOrThrow().port
    let receiver = spawn {
        let peer = server.accept()
        let received = Array<Byte>(totalSize, repeat: 0)
        var offset: Int64 = 0
        while (offset < totalSize) {
            let count = peer.read(received.slice(offset, totalSize - offset))
            if (count <= 0) {
                break
            }
            offset += count
        }
        peer.close()
        ensure(offset == totalSize, "TCP gather write ended early")
        received
    }

    let client = TcpSocket("127.0.0.1", port)
    client.connect()
    client.writeGathered(segments)
    let received = receiver.get()
    client.close()
    server.close()
    ensure(received == expected, "TCP gather write changed segment bytes")
}

main() {
    testSegmentedJsonAndHttpBody()
    testTcpGatherWrite()
    println("PASS dom_json_gather_http")
}
