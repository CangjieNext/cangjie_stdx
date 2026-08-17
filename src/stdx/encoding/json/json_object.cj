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
 * This is a library for class JsonNull, JsonBool, JsonInt, JsonFloat, JsonString, JsonArray, JsonObject.
 */
package stdx.encoding.json

import std.collection.*

const SMALL_JSON_OBJECT_CAPACITY = 8

// Object keys are always written in HTML-safe mode. Cache only their aggregate
// safety on JsonObject so ordinary JsonString nodes keep their compact layout.
func isJsonObjectKeyHtmlSafe(value: String): Bool {
    let data = unsafe { value.rawData() }
    for (b in data) {
        if (b < 32 || b == 127 || b == b'\"' || b == b'\\' || b == b'&') {
            return false
        }
    }
    return true
}

/**
 * JsonNull class used for encapsulate JSON data: null.
 */
public class JsonNull <: JsonValue { // cjlint-ignore !G.ENU.01

    protected override func writeCompactTo(buff: WriteBuffer, depth: Int64, htmlSafe: Bool): Unit {
        buff.append(NULL_STRING)
    }

    /**
     * Determine the JSON type to which the JsonNull belongs.
     *
     * @return type of the JsonNull is JsNull.
     *
     * @since 0.17.4
     */
    public func kind(): JsonKind {
        return JsNull
    }

    /**
     * Convert JsonNull to String.
     *
     * @return json-converted String is "".
     *
     * @since 0.17.4
     */
    public func toString(): String {
        return "null"
    }

    /**
     * Convert JsonNull to json-String.
     *
     * @return json-converted prettified String is "".
     *
     * @since 0.21.1
     */
    public func toJsonString(): String {
        return toString()
    }

    /**
     * Convert JsonNull to String Without Escaping.
     *
     * @return json-converted String is "".
     */
    public func toStringWithoutEscaping(): String {
        return "null"
    }

    /**
     * Convert JsonNull to json-String Without Escaping.
     *
     * @return json-converted prettified String is "".
     */
    public func toJsonStringWithoutEscaping(): String {
        return toJsonString()
    }
}

/**
 * JsonBool class used for encapsulate JSON data: true or false.
 */
public class JsonBool <: JsonValue { // cjlint-ignore !G.ENU.01
    /* Json data of the JsonBool(Bool). */
    private var value: Bool

    protected override func writeCompactTo(buff: WriteBuffer, depth: Int64, htmlSafe: Bool): Unit {
        buff.append(value)
    }

    /**
     * Create a new JsonBool object.
     * Construction with parameters.
     *
     * @param bv The json data of JsonBool.
     *
     * @since 0.17.4
     */
    public init(bv: Bool) {
        this.value = bv
    }

    /**
     * Get the value data of the JsonBool.
     *
     * @return value of the JsonBool.
     *
     * @since 0.17.4
     */
    public func getValue(): Bool {
        return value
    }

    /**
     * Determine the JSON type to which the JsonBool belongs.
     *
     * @return type of the JsonBool is JsBool.
     *
     * @since 0.17.4
     */
    public func kind(): JsonKind {
        return JsBool
    }

    /**
     * Convert JsonBool to String.
     *
     * @return json-converted String is value string data: true or false.
     *
     * @since 0.17.4
     */
    public func toString(): String {
        return jsonPrimitiveToString(value)
    }

    /**
     * Convert JsonBool to json-String.
     *
     * @return json-converted prettified String is value string data: true or false.
     *
     * @since 0.21.1
     */
    public func toJsonString(): String {
        return toString()
    }

    /**
     * Convert JsonBool to String.
     *
     * @return json-converted String is value string data: true or false Without Escaping.
     */
    public func toStringWithoutEscaping(): String {
        return jsonPrimitiveToString(value)
    }

    /**
     * Convert JsonBool to json-String.
     *
     * @return json-converted prettified String is value string data: true or false Without Escaping.
     */
    public func toJsonStringWithoutEscaping(): String {
        return toString()
    }
}

/**
 * JsonInt class used for encapsulate JSON data: number(integer).
 */
public class JsonInt <: JsonValue {
    /* Json data of the JsonInt(Int64). */
    private var value: Int64

    protected override func writeCompactTo(buff: WriteBuffer, depth: Int64, htmlSafe: Bool): Unit {
        buff.append(value)
    }

    /**
     * Create a new JsonInt object.
     * Construction with parameters.
     *
     * @param iv The json data of JsonInt.
     *
     * @since 0.17.4
     */
    public init(iv: Int64) {
        this.value = iv
    }

    /**
     * Get the value data of the JsonInt.
     *
     * @return value of the JsonInt.
     *
     * @since 0.17.4
     */
    public func getValue(): Int64 {
        return value
    }

    /**
     * Update this integer value in place.
     *
     * All references to this JsonInt observe the new value.
     */
    public func setValue(iv: Int64): Unit {
        value = iv
    }

    /**
     * Determine the JSON type to which the JsonInt belongs.
     *
     * @return type of the JsonInt is JsInt.
     *
     * @since 0.17.4
     */
    public func kind(): JsonKind {
        return JsInt
    }

    /**
     * Convert JsonInt to String.
     *
     * @return json-converted String is value string data.
     *
     * @since 0.17.4
     */
    public func toString(): String {
        return jsonPrimitiveToString(value)
    }

    /**
     * Convert JsonInt to json-String.
     *
     * @return json-converted prettified String is value string data.
     *
     * @since 0.21.1
     */
    public func toJsonString(): String {
        return toString()
    }

    /**
     * Convert JsonInt to String Without Escaping.
     *
     * @return json-converted String is value string data.
     */
    public func toStringWithoutEscaping(): String {
        return jsonPrimitiveToString(value)
    }

    /**
     * Convert JsonInt to json-String Without Escaping.
     *
     * @return json-converted prettified String is value string data.
     */
    public func toJsonStringWithoutEscaping(): String {
        return toString()
    }
}

/**
 * JsonFloat class used for encapsulate JSON data: number(float).
 */
public class JsonFloat <: JsonValue {
    /* Json data of the JsonFloat(Float64). */
    private var value: Float64
    private var rawData: ?Array<Byte> = None
    private var rawStart: Int64 = 0
    private var rawSize: Int64 = 0

    protected override func writeCompactTo(buff: WriteBuffer, depth: Int64, htmlSafe: Bool): Unit {
        appendTo(buff)
    }

    /**
     * Create a new JsonFloat object.
     * Construction with parameters.
     *
     * @param fv The json data of JsonFloat.
     *
     * @since 0.17.4
     */
    public init(fv: Float64) {
        this.value = fv
    }

    /**
     * Create a new JsonFloat object.
     * Construction with parameters.
     *
     * @param v The json data of JsonInt.
     *
     * @since 0.17.4
     */
    public init(v: Int64) {
        this.value = Float64(v)
    }

    init(fv: Float64, rawData: Array<Byte>, rawStart: Int64, rawSize: Int64) {
        this.value = fv
        this.rawData = rawData
        this.rawStart = rawStart
        this.rawSize = rawSize
    }

    /**
     * Get the value data of the JsonFloat.
     *
     * @return value of the JsonFloat.
     *
     * @since 0.17.4
     */
    public func getValue(): Float64 {
        return value
    }

    /**
     * Update this floating-point value in place.
     *
     * A parsed float may retain its original JSON token for lossless output.
     * Clear that token so subsequent serialization emits the updated value.
     */
    public func setValue(fv: Float64): Unit {
        value = fv
        rawData = None
        rawStart = 0
        rawSize = 0
    }

    /**
     * Determine the JSON type to which the JsonFloat belongs.
     *
     * @return type of the JsonFloat is JsFloat.
     *
     * @since 0.17.4
     */
    public func kind(): JsonKind {
        return JsFloat
    }

    /**
     * Convert JsonFloat to String.
     *
     * @return json-converted String is value string data.
     *
     * @since 0.17.4
     */
    public func toString(): String {
        let buff = WriteBuffer(writeCapacity())
        appendTo(buff)
        return unsafe { String.fromUtf8Unchecked(buff.getAndClear()) }
    }

    /**
     * Convert JsonFloat to json-String.
     *
     * @return json-converted prettified String is value string data.
     *
     * @since 0.21.1
     */
    public func toJsonString(): String {
        return toString()
    }

    /**
     * Convert JsonFloat to String Without Escaping.
     *
     * @return json-converted String is value string data.
     */
    public func toStringWithoutEscaping(): String {
        return toString()
    }

    /**
     * Convert JsonFloat to json-String Without Escaping.
     *
     * @return json-converted prettified String is value string data.
     */
    public func toJsonStringWithoutEscaping(): String {
        return toString()
    }

    func appendTo(buff: WriteBuffer): Unit {
        if (let Some(data) <- rawData) {
            buff.append(data, rawStart, rawSize)
        } else {
            buff.append(value)
        }
    }

    func writeCapacity(): Int64 {
        if (let Some(_) <- rawData) {
            return rawSize
        }
        return MAX_FLOAT64_JSON_SIZE
    }
}

/**
 * JsonString class used for encapsulate JSON data: string.
 */
public class JsonString <: JsonValue { // cjlint-ignore !G.ENU.01
    /* Json data of the JsonString(String). */
    var value: String

    protected override func writeCompactTo(buff: WriteBuffer, depth: Int64, htmlSafe: Bool): Unit {
        buff.append(b'\"').appendEscape(value, htmlSafe: htmlSafe).append(b'\"')
    }

    /**
     * Create a new JsonString object.
     * Construction with parameters.
     *
     * @param sv The json data of JsonString.
     *
     * @since 0.17.4
     */
    public init(sv: String) {
        this.value = sv
    }

    /**
     * Get the value data of the JsonString.
     *
     * @return value of the JsonString.
     *
     * @since 0.17.4
     */
    public func getValue(): String {
        return value
    }

    /**
     * Update this string value in place.
     *
     * All references to this JsonString observe the new value.
     */
    public func setValue(sv: String): Unit {
        value = sv
    }

    /**
     * Determine the JSON type to which the JsonString belongs.
     *
     * @return type of the JsonString is JsString.
     *
     * @since 0.17.4
     */
    public func kind(): JsonKind {
        return JsString
    }

    /**
     * Convert JsonString to String.
     *
     * @return json-converted String is value string data.
     *
     * @since 0.17.4
     */
    public func toString(): String {
        let buff = WriteBuffer(value.size + 2)
        jsonWriteWithoutFormat(this, buff)
        return bufferToString(buff)
    }

    /**
     * Convert JsonString to json-String.
     *
     * @return json-converted prettified String is value string data.
     *
     * @since 0.21.1
     */
    public func toJsonString(): String {
        let buff = WriteBuffer(value.size + 2)
        jsonWriteWithoutFormat(this, buff)
        return bufferToString(buff)
    }

    /**
     * Convert JsonString to String Without Escaping.
     *
     * @return json-converted String is value string data.
     */
    public func toStringWithoutEscaping(): String {
        let buff = WriteBuffer(value.size + 2)
        jsonWriteWithoutFormat(this, buff, htmlSafe: false)
        return bufferToString(buff)
    }

    /**
     * Convert JsonString to json-String Without Escaping.
     *
     * @return json-converted prettified String is value string data.
     */
    public func toJsonStringWithoutEscaping(): String {
        let buff = WriteBuffer(value.size + 2)
        jsonWriteWithoutFormat(this, buff, htmlSafe: false)
        return bufferToString(buff)
    }
}

/**
 * JsonArray class used for encapsulate JSON data: array.
 */
public class JsonArray <: JsonValue {
    /* Json data of the JsonArray(ArrayList<JsonValue>). */
    private var items: ArrayList<JsonValue>

    protected override func writeCompactTo(buff: WriteBuffer, depth: Int64, htmlSafe: Bool): Unit {
        checkJsonWriteDepth(depth)
        if (items.size == 0) {
            buff.append(EMPTY_ARRAY_BYTES)
            return
        }
        buff.append(b'[')
        for (item in items) {
            jsonWriteWithoutFormat(item, buff, depth + 1, htmlSafe: htmlSafe)
            buff.append(b',')
        }
        buff.removetail()
        buff.append(b']')
    }

    /**
     * Create a new JsonArray object.
     * Construction without parameters.
     *
     * @since 0.17.4
     */
    init(capacity: Int64) {
        items = ArrayList<JsonValue>(capacity)
    }

    public init() {
        items = ArrayList<JsonValue>()
    }
    /**
     * Create a new JsonArray object.
     * Construction with parameters.
     *
     * @param list type ArrayList<JsonValue>, the json data of JsonArray.
     *
     * @since 0.17.4
     */
    public init(list: ArrayList<JsonValue>) {
        items = list
    }

    /**
     * Create a new JsonArray object.
     * Construction with parameters.
     *
     * @param list type Array<JsonValue>,The json data of JsonArray.
     *
     * @since 0.17.4
     */
    public init(list: Array<JsonValue>) {
        items = ArrayList<JsonValue>(list)
    }

    /**
     * Determine the JSON type to which the JsonArray belongs.
     *
     * @return type of the JsonArray is JsArray.
     *
     * @since 0.17.4
     */
    public func kind(): JsonKind {
        return JsArray
    }

    /**
     * Convert JsonArray to Json-String.
     *
     * @return json-converted String is items string data.
     *
     * @since 0.17.4
     *
     * @throws JsonException if there exists JsonValue which cannot be converted to String.
     */
    public func toJsonString(): String {
        return toJsonStringBase(0)
    }

    /**
     * Convert JsonArray to Json-String Without Escaping.
     *
     * @return json-converted String is items string data.
     *
     * @throws JsonException if there exists JsonValue which cannot be converted to String.
     */
    public func toJsonStringWithoutEscaping(): String {
        return toJsonStringBase(0, htmlSafe: false)
    }

    /**
     * Convert JsonArray to Json-String.
     *
     * @param depth of indentation in JSON format.
     * @return json-converted String is items string data.
     *
     * @since 0.17.4
     *
     * @throws JsonException if there exists JsonValue which cannot be converted to String.
     */
    public func toJsonString(depth: Int64, bracketInNewLine!: Bool = false, indent!: String = "  "): String {
        return toJsonStringBase(depth, bracketInNewLine: bracketInNewLine, indent: indent)
    }

    /**
     * Convert JsonArray to Json-String.
     *
     * @param depth of indentation in JSON format.
     * @return json-converted String is items string data.
     *
     * @throws JsonException if there exists JsonValue which cannot be converted to String.
     */
    func toJsonStringBase(depth: Int64, bracketInNewLine!: Bool = false, indent!: String = "  ", htmlSafe!: Bool = true): String {
        return jsonArrayToFormattedString(this, depth, bracketInNewLine, indent, htmlSafe: htmlSafe)
    }

    /**
     * Convert JsonArray to Json-String Without Escaping.
     *
     * @param depth of indentation in JSON format.
     * @return json-converted String is items string data.
     *
     * @throws JsonException if there exists JsonValue which cannot be converted to String.
     */
    public func toJsonStringWithoutEscaping(depth: Int64, bracketInNewLine!: Bool = false, indent!: String = "  "): String {
        return toJsonStringBase(depth, bracketInNewLine: bracketInNewLine, indent: indent, htmlSafe: false)
    }

    /**
     * Convert JsonArray to String.
     *
     * @return json-converted String is items string data.
     *
     * @since 0.21.1
     *
     * @throws JsonException if there exists JsonValue which cannot be converted to String.
     */
    public func toString(): String {
        return jsonValueToCompactString(this)
    }

    /**
     * Convert JsonArray to String Without Escaping.
     *
     * @return json-converted String is items string data.
     *
     * @throws JsonException if there exists JsonValue which cannot be converted to String.
     */
    public func toStringWithoutEscaping(): String {
        return jsonValueToCompactString(this, htmlSafe: false)
    }

    /**
     * Get the size of JsonArray.
     *
     * @return the size of items.
     *
     * @since 0.17.4
     */
    public func size(): Int64 {
        return items.size
    }

    /**
     * Add the Data to JsonArray.
     *
     * @param jv JsonValue data to be added.
     *
     * @since 0.17.4
     */
    public func add(jv: JsonValue): JsonArray {
        items.add(jv)
        return this
    }

    /**
     * Obtains the option version of JsonValue data of JsonArray at a specified location.
     *
     * @param index Index position.
     * @return get the option version of element of the index.
     *
     * @since 0.17.4
     */
    public func get(index: Int64): Option<JsonValue> {
        return items.get(index)
    }

    /**
     * Obtains JsonValue data of JsonArray at a specified location.
     *
     * @param index Index position.
     * @return get the element of the index.
     *
     * @since 0.17.4
     *
     * @throws JsonException if index of JsonArray does not exist.
     */
    public operator func [](index: Int64): JsonValue {
        return match (items.get(index)) {
            case Some(v) => v
            case None => throw JsonException("The index ${index} of JsonArray does not exist.")
        }
    }

    /**
     * Get the items data of JsonArray.
     *
     * @return the items of JsonArray.
     *
     * @since 0.17.4
     */
    public func getItems(): ArrayList<JsonValue> {
        return items
    }
}

/**
 * JsonObject class used for encapsulate JSON data: object.
 */
public class JsonObject <: JsonValue {
    // Most parsed objects have only a handful of fields. Keep those entries in
    // one sequential backing array and allocate HashMap buckets only after the
    // ninth distinct key (or when the public map view must escape).
    private var flatFields: Array<(String, JsonValue)>
    private var flatSize: Int64
    private var hashFields: ?HashMap<String, JsonValue>
    private var allKeysHtmlSafe: Bool

    protected override func writeCompactTo(buff: WriteBuffer, depth: Int64, htmlSafe: Bool): Unit {
        checkJsonWriteDepth(depth)
        if (size() == 0) {
            buff.append(EMPTY_OBJECT_BYTES)
            return
        }
        buff.append(b'{')
        match (hashFields) {
            case Some(fields) =>
                for ((key, value) in fields) {
                    writeCompactField(buff, key, value, depth, htmlSafe)
                }
            case None =>
                for (i in 0..flatSize) {
                    let field = flatFields[i]
                    writeCompactField(buff, field[0], field[1], depth, htmlSafe)
                }
        }
        buff.removetail()
        buff.append(b'}')
    }

    private func writeCompactField(
        buff: WriteBuffer,
        key: String,
        value: JsonValue,
        depth: Int64,
        htmlSafe: Bool
    ): Unit {
        buff.append(b'\"')
        if (allKeysHtmlSafe) {
            buff.append(key)
        } else {
            buff.appendEscape(key)
        }
        buff.append(KEY_VALUE_SEPARATOR_BYTES)
        jsonWriteWithoutFormat(value, buff, depth + 1, htmlSafe: htmlSafe)
        buff.append(b',')
    }

    private func promoteToHashFields(): HashMap<String, JsonValue> {
        match (hashFields) {
            case Some(fields) => return fields
            case None =>
                let fields = HashMap<String, JsonValue>(flatSize + 1)
                for (i in 0..flatSize) {
                    let field = flatFields[i]
                    fields.add(field[0], field[1])
                }
                hashFields = Some(fields)
                flatFields = Array<(String, JsonValue)>()
                flatSize = 0
                return fields
        }
    }

    private func putField(key: String, value: JsonValue): Unit {
        match (hashFields) {
            case Some(fields) => fields.add(key, value)
            case None =>
                for (i in 0..flatSize) {
                    if (flatFields[i][0] == key) {
                        flatFields[i] = (key, value)
                        return
                    }
                }
                if (flatSize < SMALL_JSON_OBJECT_CAPACITY) {
                    flatFields[flatSize] = (key, value)
                    flatSize++
                } else {
                    promoteToHashFields().add(key, value)
                }
        }
    }

    private func getFlatField(key: String): Option<JsonValue> {
        for (i in 0..flatSize) {
            let field = flatFields[i]
            if (field[0] == key) {
                return Some(field[1])
            }
        }
        return None
    }

    /**
     * Create a new JsonObject object.
     * Construction without parameters.
     *
     * @since 0.17.4
     */
    public init() {
        flatFields = Array<(String, JsonValue)>(
            SMALL_JSON_OBJECT_CAPACITY,
            repeat: unsafe { zeroValue<(String, JsonValue)>() }
        )
        flatSize = 0
        hashFields = None
        allKeysHtmlSafe = true
    }

    init(capacity: Int64) {
        if (capacity < 0) {
            throw IllegalArgumentException("Invalid size of JsonObject: ${capacity}.")
        }
        if (capacity <= SMALL_JSON_OBJECT_CAPACITY) {
            flatFields = Array<(String, JsonValue)>(
                SMALL_JSON_OBJECT_CAPACITY,
                repeat: unsafe { zeroValue<(String, JsonValue)>() }
            )
            hashFields = None
        } else {
            flatFields = Array<(String, JsonValue)>()
            hashFields = Some(HashMap<String, JsonValue>(capacity))
        }
        flatSize = 0
        allKeysHtmlSafe = true
    }

    /**
     * Create a new JsonObject object.
     * Construction with parameters.
     *
     * @param map The json data of JsonObject.
     *
     * @since 0.17.4
     */
    public init(map: HashMap<String, JsonValue>) {
        flatFields = Array<(String, JsonValue)>()
        flatSize = 0
        hashFields = Some(map)
        // The caller retains a mutable reference to map, so a permanent
        // conservative fallback is required for correctness.
        allKeysHtmlSafe = false
    }

    /**
     * Determine the JSON type to which the JsonObject belongs.
     *
     * @return type of the JsonObject is JsObject.
     *
     * @since 0.17.4
     */
    public func kind(): JsonKind {
        return JsObject
    }

    /**
     * Convert JsonObject to Json-String.
     *
     * @return json-converted String is fields string data.
     *
     * @since 0.17.4
     *
     * @throws JsonException if there exists JsonValue which cannot be converted to String.
     */
    public func toJsonString(): String {
        return toJsonStringBase(0)
    }

     /**
     * Convert JsonObject to Json-String Without Escaping.
     *
     * @return json-converted String is fields string data.
     *
     * @throws JsonException if there exists JsonValue which cannot be converted to String.
     */
    public func toJsonStringWithoutEscaping(): String {
        return toJsonStringBase(0, htmlSafe: false)
    }

    /**
     * Convert JsonObject to Json-String.
     *
     * @param depth of indentation in JSON format.
     * @return json-converted String is fields string data.
     *
     * @since 0.17.4
     *
     * @throws JsonException if there exists JsonValue which cannot be converted to String.
     */
    public func toJsonString(depth: Int64, bracketInNewLine!: Bool = false, indent!: String = "  "): String {
        return toJsonStringBase(depth, bracketInNewLine: bracketInNewLine, indent: indent)
    }

    /**
     * Convert JsonObject to Json-String.
     *
     * @param depth of indentation in JSON format.
     * @return json-converted String is fields string data.
     *
     * @throws JsonException if there exists JsonValue which cannot be converted to String.
     */
    func toJsonStringBase(depth: Int64, bracketInNewLine!: Bool = false, indent!: String = "  ", htmlSafe!: Bool = true): String {
        return jsonObjectToFormattedString(this, depth, bracketInNewLine, indent, htmlSafe: htmlSafe)
    }

    /**
     * Convert JsonObject to Json-String Without Escaping.
     *
     * @param depth of indentation in JSON format.
     * @return json-converted String is fields string data.
     *
     * @throws JsonException if there exists JsonValue which cannot be converted to String.
     */
    public func toJsonStringWithoutEscaping(depth: Int64, bracketInNewLine!: Bool = false, indent!: String = "  "): String {
        return toJsonStringBase(depth, bracketInNewLine: bracketInNewLine, indent: indent, htmlSafe: false)
    }

    /**
     * Convert JsonObject to String.
     *
     * @return json-converted String is fields string data.
     *
     * @since 0.21.1
     *
     * @throws JsonException if there exists JsonValue which cannot be converted to String.
     */
    public func toString(): String {
        return jsonValueToCompactString(this)
    }

    /**
     * Convert JsonObject to String Without Escaping.
     *
     * @return json-converted String is fields string data.
     *
     * @throws JsonException if there exists JsonValue which cannot be converted to String.
     */
    public func toStringWithoutEscaping(): String {
        return jsonValueToCompactString(this, htmlSafe: false)
    }

    /**
     * Get the size of JsonObject.
     *
     * @return the size of fields.
     *
     * @since 0.17.4
     */
    public func size(): Int64 {
        return match (hashFields) {
            case Some(fields) => fields.size
            case None => flatSize
        }
    }

    /**
     * Check whether the JsonObject contains a key.
     *
     * @param key Key position.
     * @return check whether the fields contains the key.
     *
     * @since 0.17.4
     */
    public func containsKey(key: String): Bool {
        return match (hashFields) {
            case Some(fields) => fields.contains(key)
            case None => getFlatField(key).isSome()
        }
    }

    /**
     * Put the Data to JsonObject.
     *
     * @param key Key position.
     * @param v JsonValue data.
     *
     * @since 0.17.4
     */
    public func put(key: String, v: JsonValue): Unit {
        putField(key, v)
        if (!isJsonObjectKeyHtmlSafe(key)) {
            allKeysHtmlSafe = false
        }
    }

    func putParsed(key: String, v: JsonValue, htmlSafe: Bool): Unit {
        putField(key, v)
        if (!htmlSafe) {
            allKeysHtmlSafe = false
        }
    }

    /**
     * Obtains the option version of JsonValue data of JsonObject at a specified location.
     *
     * @param key Key position.
     * @return get option version of data corresponding to the key.
     *
     * @since 0.17.4
     */
    public func get(key: String): Option<JsonValue> {
        return match (hashFields) {
            case Some(fields) => fields.get(key)
            case None => getFlatField(key)
        }
    }

    /**
     * Obtains JsonValue data of JsonObject at a specified location.
     *
     * @param key Key position.
     * @return get data corresponding to the key.
     *
     * @since 0.17.4
     *
     * @throws JsonException if key of JsonObject does not exist.
     */
    public operator func [](key: String): JsonValue {
        return match (get(key)) {
            case Some(v) => v
            case None => throw JsonException("The Value of JsonObject does not exist")
        }
    }

    /**
     * Get the fields data of JsonObject.
     *
     * @return the fields of JsonObject.
     *
     * @since 0.17.4
     */
    public func getFields(): HashMap<String, JsonValue> {
        // The returned map can be mutated without going through put(). Once it
        // escapes, keep serialization on the checking path.
        allKeysHtmlSafe = false
        return promoteToHashFields()
    }

    func isFlatStorage(): Bool {
        return match (hashFields) {
            case Some(_) => false
            case None => true
        }
    }

    func getFlatFieldsForRead(): Array<(String, JsonValue)> {
        return flatFields
    }

    func getFlatSizeForRead(): Int64 {
        return flatSize
    }

    func getHashFieldsForRead(): HashMap<String, JsonValue> {
        return match (hashFields) {
            case Some(fields) => fields
            case None => throw IllegalStateException("JsonObject is using flat storage.")
        }
    }

    func allKeysAreHtmlSafe(): Bool {
        return allKeysHtmlSafe
    }
}

extend String {
    func isContainOnlySpaceAndTab() {
        for (i in this) {
            if (i != b' ' && i != b'\t') {
                return false
            }
        }
        return true
    }
}
