#!/usr/bin/env python3

import pathlib
import re
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]
WRITER = ROOT / "src/stdx/encoding/json/stream/json_writer.cj"
SERIALIZABLE = ROOT / "src/stdx/encoding/json/stream/json_serializable.cj"
STRING_SERIALIZE = ROOT / "src/stdx/encoding/json/stream/string_serialize.cj"
JSON4CJ_ROOT = ROOT.parent / "json4cj"
CORE_WRITER = JSON4CJ_ROOT / "json4cj-core/src/stream/JsonWriter.cj"
BUILTIN_ENCODERS = JSON4CJ_ROOT / "json4cj-core/src/codec/BuiltinEncoders.cj"
JSON_CODEC = JSON4CJ_ROOT / "json4cj-databind/src/bind/JsonCodec.cj"
CODEC_WRITER = JSON4CJ_ROOT / "json4cj-databind/src/bind/CodecWriter.cj"
CLASS_MACRO = JSON4CJ_ROOT / "json4cj-annotations/src/macros/HandleClass.cj"
STRUCT_MACRO = JSON4CJ_ROOT / "json4cj-annotations/src/macros/HandleStruct.cj"


class StreamIntegerWriterFastPathTest(unittest.TestCase):
    def test_int64_serialization_uses_writer_owned_direct_buffer_path(self):
        writer = WRITER.read_text(encoding="utf-8")
        serializable = SERIALIZABLE.read_text(encoding="utf-8")

        self.assertRegex(
            writer,
            r"func writeInt64\(value: Int64\): Unit",
            "JsonWriter must own the signed integer write path",
        )
        self.assertRegex(
            writer,
            r"func appendUInt64\(value: UInt64\): Int64",
            "JsonWriter must append digits directly to its buffer",
        )
        self.assertIn("if (value < 10)", writer)
        self.assertIn("if (value < 100)", writer)
        self.assertIn("if (value < 10000)", writer)

        int64_impl = re.search(
            r"extend Int64 <: JsonSerializable \{(?P<body>.*?)\n\}",
            serializable,
            re.DOTALL,
        )
        self.assertIsNotNone(int64_impl)
        self.assertIn("w.writeInt64(this)", int64_impl.group("body"))
        self.assertNotIn("w.buffer[w.curPos..]", int64_impl.group("body"))

    def test_int64_array_has_compact_batch_writer(self):
        writer = WRITER.read_text(encoding="utf-8")

        batch_impl = re.search(
            r"public func writeInt64Array\(values: Array<Int64>\): Unit \{(?P<body>.*?)\n    \}",
            writer,
            re.DOTALL,
        )
        self.assertIsNotNone(
            batch_impl,
            "JsonWriter must provide a batch path for Array<Int64>",
        )
        body = batch_impl.group("body")
        self.assertIn("writeCompactInt64Array(values)", body)
        self.assertIn("writeInt64(value)", body)

        compact_impl = re.search(
            r"func writeCompactInt64Array\(values: Array<Int64>\): Unit \{(?P<body>.*?)\n    \}",
            writer,
            re.DOTALL,
        )
        self.assertIsNotNone(compact_impl)
        compact_body = compact_impl.group("body")
        self.assertIn("appendUInt64", compact_body)
        self.assertNotIn("writeValue<Int64>", compact_body)
        self.assertRegex(
            writer,
            r"static const FLUSH_THRESHOLD: Int64 = DEFAULT_CAPACITY - 32",
        )
        self.assertIn("static const LARGE_VALUE_THRESHOLD: Int64 = 3500", writer)

    def test_json4cj_generates_and_forwards_int64_array_batch_write(self):
        core_writer = CORE_WRITER.read_text(encoding="utf-8")
        self.assertRegex(
            core_writer,
            r"public func writeInt64Array\(values: Array<Int64>\): JsonWriter",
        )
        self.assertIn("inner.writeInt64Array(values)", core_writer)

        for macro_path in (CLASS_MACRO, STRUCT_MACRO):
            macro = macro_path.read_text(encoding="utf-8")
            self.assertIn('collTypeStr == "Array<Int64>"', macro)
            self.assertIn("writer.writeInt64Array($(identifierTemp))", macro)

    def test_all_integer_arrays_have_batch_apis_and_recursive_macro_dispatch(self):
        writer = WRITER.read_text(encoding="utf-8")
        core_writer = CORE_WRITER.read_text(encoding="utf-8")
        for type_name in (
            "Int8", "Int16", "Int32", "Int64", "IntNative",
            "UInt8", "UInt16", "UInt32", "UInt64", "UIntNative",
        ):
            method = f"write{type_name}Array"
            signature = rf"public func {method}\(values: Array<{type_name}>\): Unit"
            self.assertRegex(writer, signature)
            self.assertRegex(
                core_writer,
                rf"public func {method}\(values: Array<{type_name}>\): JsonWriter",
            )

        for macro_path in (CLASS_MACRO, STRUCT_MACRO):
            macro = macro_path.read_text(encoding="utf-8")
            recursive_start = macro.index("private func buildStreamElementWrite")
            recursive_collection = macro.index("if (isCollectionType(typeTokens))", recursive_start)
            recursive_int64 = macro.index('typeStr == "Array<Int64>"', recursive_start)
            self.assertLess(recursive_int64, recursive_collection)
            self.assertIn("writer.writeInt64Array($(value))", macro[recursive_start:])

    def test_codec_entry_points_expose_int64_array_fast_path(self):
        builtin_encoders = BUILTIN_ENCODERS.read_text(encoding="utf-8")
        json_codec = JSON_CODEC.read_text(encoding="utf-8")
        codec_writer = CODEC_WRITER.read_text(encoding="utf-8")

        self.assertIn("public static func int64ArrayEncoder(): Encoder<Array<Int64>>", builtin_encoders)
        self.assertIn("class Int64ArrayEncoder <: Encoder<Array<Int64>>", builtin_encoders)
        self.assertIn("writer.writeInt64Array(value)", builtin_encoders)
        self.assertRegex(json_codec, r"public func stringify\(value: Array<Int64>\): String")
        self.assertRegex(json_codec, r"public func write\(value: Array<Int64>, writer: JsonWriter\): Unit")
        self.assertRegex(codec_writer, r"public func stringify\(value: Array<Int64>\): String")
        self.assertRegex(codec_writer, r"public func write\(value: Array<Int64>, writer: JsonWriter\): Unit")

    def test_static_json_field_names_use_raw_name_fast_path(self):
        core_writer = CORE_WRITER.read_text(encoding="utf-8")
        self.assertRegex(
            core_writer,
            r"public func writeStaticName\(fieldName: String\): JsonWriter",
        )
        self.assertIn("fieldName.rawData()", core_writer)
        self.assertIn("inner.writeRawName", core_writer)

        for macro_path in (CLASS_MACRO, STRUCT_MACRO):
            macro = macro_path.read_text(encoding="utf-8")
            self.assertIn("isRawJsonFieldNameSafe", macro)
            self.assertIn("buildStreamFieldNameWrite", macro)
            self.assertIn("return quote(writer.writeStaticName($(nameTok)))", macro)

    def test_to_bytes_returns_an_owned_copy(self):
        core_writer = CORE_WRITER.read_text(encoding="utf-8")
        self.assertRegex(core_writer, r"public func toBytes\(\): Array<Byte>")
        to_bytes_start = core_writer.index("public func toBytes(): Array<Byte>")
        to_string_start = core_writer.index("public func toString(): String", to_bytes_start)
        to_bytes = core_writer[to_bytes_start:to_string_start]
        self.assertIn("inner.flush()", to_bytes)
        self.assertIn("buf.bytes().clone()", to_bytes)

    def test_long_plain_strings_use_native_no_escape_probe(self):
        string_serialize = STRING_SERIALIZE.read_text(encoding="utf-8")
        self.assertIn("NATIVE_NO_ESCAPE_SCAN_THRESHOLD", string_serialize)
        self.assertIn("CJ_JSON_StringEscapeCharNumGet", string_serialize)
        self.assertIn("hasNativeEscape", string_serialize)
        self.assertIn("!w.writeConfig.htmlSafe", string_serialize)

    def test_string_int64_map_has_compact_batch_writer_and_macro_dispatch(self):
        writer = WRITER.read_text(encoding="utf-8")
        core_writer = CORE_WRITER.read_text(encoding="utf-8")
        self.assertRegex(
            writer,
            r"public func writeStringInt64Map\(values: HashMap<String, Int64>\): Unit",
        )
        self.assertIn("writeCompactStringInt64Map(values)", writer)
        self.assertRegex(
            core_writer,
            r"public func writeStringInt64Map\(values: HashMap<String, Int64>\): JsonWriter",
        )
        for macro_path in (CLASS_MACRO, STRUCT_MACRO):
            macro = macro_path.read_text(encoding="utf-8")
            self.assertIn('typeStr == "HashMap<String,Int64>"', macro)
            self.assertIn("writer.writeStringInt64Map($(value))", macro)

    def test_json_writer_reset_reuses_buffer_and_resets_stream_state(self):
        writer = WRITER.read_text(encoding="utf-8")
        core_writer = CORE_WRITER.read_text(encoding="utf-8")
        self.assertRegex(writer, r"public func reset\(\): Unit")
        reset_start = writer.index("public func reset(): Unit")
        reset_end = writer.index("public func jsonValue", reset_start)
        reset_body = writer[reset_start:reset_end]
        self.assertIn("curPos = 0", reset_body)
        self.assertIn("stack.clear()", reset_body)
        self.assertIn("stack.add(EmptyText)", reset_body)
        self.assertIn("haveName = false", reset_body)

        self.assertRegex(core_writer, r"public func reset\(\): JsonWriter")
        core_reset_start = core_writer.index("public func reset(): JsonWriter")
        core_reset_end = core_writer.index("public func flush(): Unit", core_reset_start)
        core_reset = core_writer[core_reset_start:core_reset_end]
        self.assertIn("inner.reset()", core_reset)
        self.assertIn("buf.clear()", core_reset)

    def test_range_macro_uses_static_names_for_fixed_protocol_fields(self):
        for macro_path in (CLASS_MACRO, STRUCT_MACRO):
            macro = macro_path.read_text(encoding="utf-8")
            range_start = macro.rindex("if (isRangeType(typeTokens))")
            range_end = macro.index("// DateTime", range_start)
            range_body = macro[range_start:range_end]
            for field_name in ("start", "end", "step", "isClosed"):
                self.assertIn(f'writer.writeStaticName("{field_name}")', range_body)
                self.assertNotIn(f'writer.writeName("{field_name}")', range_body)


if __name__ == "__main__":
    unittest.main()
