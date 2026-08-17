/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

/**
 * @file
 *
 * This is a library for JsonValue class and JsonKind enum.
 */
package stdx.encoding.json


/**
 * This enum used for identify the JSON type.
 */
public enum JsonKind {
    JsNull | JsBool | JsInt | JsFloat | JsString | JsArray | JsObject
}

/**
 * JsonValue abstract class used for JSON manipulations.
 */
sealed abstract class JsonValue <: ToString {

    /**
     * Write the compact representation using virtual dispatch. This avoids
     * repeating a runtime subtype-test chain for every DOM node.
     */
    protected func writeCompactTo(buff: WriteBuffer, depth: Int64, htmlSafe: Bool): Unit

    /**
     * Convert JsonValue to String.
     *
     * @return json-converted String.
     *
     * @since 0.17.4
     *
     * @throws JsonException if there exists JsonValue which cannot be converted to String.
     */
    public func toString(): String

    /**
     * Convert JsonValue to json-String.
     *
     * @return json-converted prettified String.
     *
     * @since 0.21.1
     *
     * @throws JsonException if there exists JsonValue which cannot be converted to String.
     */
    public func toJsonString(): String

    /**
     * Convert JsonValue to String Without Escaping.
     *
     * @return json-converted String.
     *
     * @throws JsonException if there exists JsonValue which cannot be converted to String.
     */
    public func toStringWithoutEscaping(): String

    /**
     * Convert JsonValue to json-String Without Escaping.
     *
     * @return json-converted prettified String.
     *
     * @throws JsonException if there exists JsonValue which cannot be converted to String.
     */
    public func toJsonStringWithoutEscaping(): String

    /**
     * Parses string data into JsonValue.
     *
     * @param s String in JSON data format.
     * @throws IllegalArgumentException if string contains null character.
     * @return parsed JsonValue.
     *
     * @since 0.17.4
     *
     * @throws JsonException if malloc failed or json structure is non-standard.
     */
    public static func fromStr(s: String): JsonValue {
        parseString(s)
    }

    /**
     * Parses UTF-8 JSON bytes into JsonValue.
     *
     * The input is copied before parsing. The returned DOM may retain slices of
     * that private copy for unescaped strings, so later writes to the caller's
     * byte array cannot affect the parsed value.
     *
     * @param data UTF-8 encoded JSON bytes.
     * @return parsed JsonValue.
     * @throws JsonException if data is invalid UTF-8 or JSON is non-standard.
     */
    public static func fromUtf8Bytes(data: Array<Byte>): JsonValue {
        parseUtf8Bytes(data)
    }

    /**
     * Parses owned UTF-8 JSON bytes into JsonValue without copying the input.
     *
     * The returned DOM may retain slices of `data`. Ownership transfers to the
     * DOM when this function is called; the caller must not modify `data` or any
     * array view sharing its backing storage after the call.
     *
     * @param data Owned UTF-8 encoded JSON bytes.
     * @return parsed JsonValue retaining the supplied byte-array storage.
     * @throws JsonException if data is invalid UTF-8 or JSON is non-standard.
     */
    public static func fromOwnedUtf8Bytes(data: Array<Byte>): JsonValue {
        parseOwnedUtf8Bytes(data)
    }

    /**
     * Convert JsonValue to a JSON string using the caller-provided output capacity.
     *
     * @param capacity Initial output-buffer capacity in bytes.
     * @return json-converted String.
     */
    public func toStringWithCapacity(capacity: Int64): String {
        if (capacity < 0) {
            throw IllegalArgumentException("Capacity cannot be negative.")
        }
        let buff = WriteBuffer(capacity)
        jsonWriteWithoutFormat(this, buff)
        return unsafe { String.withRawData(buff.getAndClear()) }
    }

    /**
     * Determine the JSON type to which the JsonValue belongs.
     *
     * @return type of this JsonValue.
     *
     * @since 0.17.4
     */
    public func kind(): JsonKind

    /**
     * Convert JsonValue to JsonNull. If the failure occurs, Exception will be throwed.
     *
     * @return converted JsonNull.
     *
     * @since 0.17.4
     *
     * @throws JsonException if JsonValue cannot be converted to JsonNull.
     */
    public func asNull(): JsonNull {
        match (this) {
            case jsonNull: JsonNull => jsonNull
            case _ => throw JsonException("Fail to convert to JsonNull")
        }
    }

    /**
     * Convert JsonValue to JsonBool. If the failure occurs, Exception will be throwed.
     *
     * @return converted JsonBool.
     *
     * @since 0.17.4
     *
     * @throws JsonException if JsonValue cannot be converted to JsonBool.
     */
    public func asBool(): JsonBool {
        match (this) {
            case jsonBool: JsonBool => jsonBool
            case _ => throw JsonException("Fail to convert to JsonBool")
        }
    }

    /**
     * Convert JsonValue to JsonInt. If the failure occurs, Exception will be throwed.
     *
     * @return converted JsonInt.
     *
     * @since 0.17.4
     *
     * @throws JsonException if JsonValue cannot be converted to JsonInt.
     */
    public func asInt(): JsonInt {
        match (this) {
            case jsonInt: JsonInt => jsonInt
            case _ => throw JsonException("Fail to convert to JsonInt")
        }
    }

    /**
     * Convert JsonValue to JsonFloat. If the failure occurs, Exception will be throwed.
     *
     * @return converted JsonFloat.
     *
     * @since 0.17.4
     *
     * @throws JsonException if JsonValue cannot be converted to JsonFloat.
     */
    public func asFloat(): JsonFloat {
        match (this) {
            case jsonFloat: JsonFloat => jsonFloat
            case jsonInt: JsonInt => JsonFloat(jsonInt.getValue())
            case _ => throw JsonException("Fail to convert to JsonFloat")
        }
    }

    /**
     * Convert JsonValue to JsonString. If the failure occurs, Exception will be throwed.
     *
     * @return converted JsonString.
     *
     * @since 0.17.4
     *
     * @throws JsonException if JsonValue cannot be converted to JsonString.
     */
    public func asString(): JsonString {
        match (this) {
            case jsonString: JsonString => jsonString
            case _ => throw JsonException("Fail to convert to JsonString")
        }
    }

    /**
     * Convert JsonValue to JsonArray. If the failure occurs, Exception will be throwed.
     *
     * @return converted JsonArray.
     *
     * @since 0.17.4
     *
     * @throws JsonException if JsonValue cannot be converted to JsonArray.
     */
    public func asArray(): JsonArray {
        match (this) {
            case jsonArray: JsonArray => jsonArray
            case _ => throw JsonException("Fail to convert to JsonArray")
        }
    }

    /**
     * Convert JsonValue to JsonObject. If the failure occurs, Exception will be throwed.
     *
     * @return converted JsonObject.
     *
     * @since 0.17.4
     *
     * @throws JsonException if JsonValue cannot be converted to JsonObject.
     */
    public func asObject(): JsonObject {
        match (this) {
            case jsonObject: JsonObject => jsonObject
            case _ => throw JsonException("Fail to convert to JsonObject")
        }
    }
}
