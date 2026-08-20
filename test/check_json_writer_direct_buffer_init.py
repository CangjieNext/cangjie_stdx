#!/usr/bin/env python3
"""Guard JsonWriter(ByteBuffer) against recreating the obsolete staging array."""

from pathlib import Path


SOURCE = Path(__file__).resolve().parents[1] / "src/stdx/encoding/json/stream/json_writer.cj"


def constructor(source: str, signature: str) -> str:
    start = source.index(signature)
    return source[start:source.index("\n    }", start) + 6]


def main() -> None:
    source = SOURCE.read_text()
    assert "var buffer = Array<Byte>()" in source, "buffer must not eagerly allocate 4 KiB"

    stream_init = constructor(source, "public init(out: OutputStream)")
    assert "buffer = Array<Byte>(DEFAULT_CAPACITY, repeat: 0)" in stream_init

    byte_buffer_init = constructor(source, "public init(out: ByteBuffer)")
    assert "writableRegion(0, 0)" in byte_buffer_init
    assert "Array<Byte>(DEFAULT_CAPACITY" not in byte_buffer_init


if __name__ == "__main__":
    main()
