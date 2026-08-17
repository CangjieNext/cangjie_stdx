/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.encoding.json

@FastNative
foreign func memcpy_s(dest: CPointer<UInt8>, destMax: UIntNative, src: CPointer<UInt8>, count: UIntNative): Int32

let BOOL_TRUE_STRING = "true".toArray()
let BOOL_FALSE_STRING = "false".toArray()
let NULL_STRING = "null".toArray()
let EMPTY_OBJECT_BYTES: Array<Byte> = [b'{', b'}']
let EMPTY_ARRAY_BYTES: Array<Byte> = [b'[', b']']
let KEY_VALUE_SEPARATOR_BYTES: Array<Byte> = [b'\"', b':']
let HEX_BYTES = "0123456789abcdef".toArray()
const MIN_CAPACITY = 16
const MAX_FLOAT64_JSON_SIZE = 32
const BLANK: Byte = ' '
const MAX_JSON_WRITE_DEPTH = 100

/*
 * This is a stringbuilder customized for json serialization.
 * Compared with stringbuilder, it has the following optimization points:
 *  1. Constructor with capacity, and func asumecapacity(jv: JsonVaule) is used to
 *     estimate the capacity in advance. Although this is not accurate,
 *     it can reduce a large amount of memory application and copy during
 *     long jsonvalue serialization.
 *  2. The cache(_buffer) is initialized with blank character. when adding blanks,
 *     only need to move the pointer.
 *  3. append(str: String), faster then StringBuilder.
 *  4. func removetail(), faster then StringBuilder.
 */
protected class WriteBuffer {
    private var _buffer: Array<Byte>
    private var _size: Int64 = 0

    /*
     * buff must be filled with blank
     */
    init(capacity: Int64) {
        let cap = if (capacity > MIN_CAPACITY) {
            capacity
        } else {
            MIN_CAPACITY
        }
        _buffer = Array<Byte>(cap, repeat: BLANK)
    }

    prop size: Int64 {
        get() {
            return _size
        }
    }

    /*
     * buff must be filled with blank
     */
    func expendSlow(addition: Int64): Unit {
        let minCapacity = _size + addition
        let oldCapacity: Int64 = _buffer.size
        var newCapacity: Int64 = oldCapacity + (oldCapacity >> 1)
        if (newCapacity < minCapacity) {
            newCapacity = minCapacity
        }
        let newArr: Array<Byte> = Array<Byte>(newCapacity, repeat: BLANK)
        _buffer.copyTo(newArr, 0, 0, _size)
        _buffer = newArr
    }

    func append(arr: Array<Byte>): WriteBuffer {
        if (_size + arr.size >= _buffer.size) {
            expendSlow(arr.size)
        }

        if (arr.size < 32) {
            for (index in 0..arr.size) {
                _buffer[_size] = arr[index]
                _size++
            }
        } else {
            arr.copyTo(_buffer, 0, _size, arr.size)
            _size += arr.size
        }
        return this
    }

    func append(arr: Array<Byte>, offset: Int64, length: Int64): WriteBuffer {
        if (_size + length >= _buffer.size) {
            expendSlow(length)
        }
        arr.copyTo(_buffer, offset, _size, length)
        _size += length
        return this
    }

    func append(str: String): WriteBuffer {
        append(unsafe { str.rawData() })
        return this
    }

    func append(byte: Byte): WriteBuffer {
        if (_size + 1 >= _buffer.size) {
            expendSlow(1)
        }
        _buffer[_size] = byte
        _size++
        return this
    }

    func append(n: Int64): WriteBuffer {
        if (_size + 22 >= _buffer.size) {
            expendSlow(22)
        }
        unsafe {
            let buff = acquireArrayRawData<Byte>(_buffer)
            let len = CJ_JSON_WriteBufferAppendInt(buff.pointer + _size, n)
            releaseArrayRawData(buff)
            _size += len
        }
        return this
    }

    func append(fl: Float64): WriteBuffer {
        if (_size + MAX_FLOAT64_JSON_SIZE >= _buffer.size) {
            expendSlow(MAX_FLOAT64_JSON_SIZE)
        }
        unsafe {
            let dest = acquireArrayRawData(_buffer)
            let printedLen = CJ_JSON_FloatPrint(fl, dest.pointer + _size, _buffer.size - _size)
            releaseArrayRawData(dest)
            if (printedLen <= 0) {
                throw IllegalStateException("Failed to serialize JSON float.")
            }
            _size += printedLen
        }
        return this
    }

    func append(b: Bool): WriteBuffer {
        if (b) {
            append(BOOL_TRUE_STRING)
        } else {
            append(BOOL_FALSE_STRING)
        }
    }

    func appendBlank(n: Int64): WriteBuffer {
        if (_size + n >= _buffer.size) {
            expendSlow(n)
        }
        _size += n
        return this
    }

    func removetail(): WriteBuffer {
        if (_size > 0) {
            _size--
        }
        return this
    }

    func appendEscapeSmall(data: Array<Byte>, htmlSafe: Bool): WriteBuffer {
        // Reserve the common no-escape result once. If an escaped byte is
        // found, reserve only its expansion plus the unprocessed suffix.
        if (_size + data.size >= _buffer.size) {
            expendSlow(data.size)
        }

        var i: Int64 = 0
        var normalStart: Int64 = 0
        while (i < data.size) {
            let b = data[i]
            if (b >= 32 && b != 127 && b != b'\"' && b != b'\\' && (!htmlSafe || b != b'&')) {
                i++
                continue
            }

            // Copy a maximal ordinary run once. This keeps the existing
            // Array backing and does not add a String/descriptor allocation.
            if (i > normalStart) {
                data.copyTo(_buffer, normalStart, _size, i - normalStart)
                _size += i - normalStart
            }
            let extra = match (b) {
                case '\b' | '\f' | '\n' | '\r' | '\t' | '\\' | '\"' => 1
                case _ => 5
            }
            let addition = data.size - i + extra
            if (_size + addition >= _buffer.size) {
                expendSlow(addition)
            }
            _buffer[_size] = b'\\'
            _size++
            match (b) {
                case '\b' => _buffer[_size] = b'b'
                case '\f' => _buffer[_size] = b'f'
                case '\n' => _buffer[_size] = b'n'
                case '\r' => _buffer[_size] = b'r'
                case '\t' => _buffer[_size] = b't'
                case '\\' => _buffer[_size] = b'\\'
                case '\"' => _buffer[_size] = b'\"'
                case _ =>
                    _buffer[_size] = b'u'
                    _buffer[_size + 1] = b'0'
                    _buffer[_size + 2] = b'0'
                    _buffer[_size + 3] = HEX_BYTES[Int64(b >> 4)]
                    _buffer[_size + 4] = HEX_BYTES[Int64(b & 0x0f)]
                    _size += 4
            }
            _size++
            i++
            normalStart = i
        }
        if (normalStart < data.size) {
            data.copyTo(_buffer, normalStart, _size, data.size - normalStart)
            _size += data.size - normalStart
        }
        return this
    }

    func appendEscapeNative(str: String, htmlSafe: Bool): WriteBuffer {
        var escapenum = 0

        unsafe {
            let input = acquireArrayRawData(str.rawData())
            escapenum = CJ_JSON_StringEscapeCharNumGet(input.pointer, str.size, htmlSafe)
            releaseArrayRawData(input)
        }

        if (escapenum == 0) {
            append(str)
            return this
        } else {
            let addition = str.size + escapenum
            if (_size + addition >= _buffer.size) {
                expendSlow(addition)
            }
            unsafe {
                let input = acquireArrayRawData(str.rawData())
                let buff = acquireArrayRawData<Byte>(_buffer)
                let len = CJ_JSON_ReplaceEscapeChar(input.pointer, str.size, buff.pointer + _size, htmlSafe)
                releaseArrayRawData(input)
                releaseArrayRawData(buff)
                _size += len
                return this
            }
        }
    }

    func appendEscape(str: String, htmlSafe!: Bool = true): WriteBuffer {
        let data = unsafe { str.rawData() }
        if (data.size < 32) {
            return appendEscapeSmall(data, htmlSafe)
        }
        return appendEscapeNative(str, htmlSafe)
    }

    func getAndClear(): Array<Byte> {
        let ret = _buffer[0.._size]
        _buffer = Array<Byte>(0, repeat: BLANK)
        _size = 0
        return ret
    }
}

func checkJsonWriteDepth(depth: Int64): Unit {
    if (depth > MAX_JSON_WRITE_DEPTH) {
        throw JsonException("Json nested depth exceeds ${MAX_JSON_WRITE_DEPTH}.")
    }
}

func jsonWriteWithoutFormat(json: JsonValue, buff: WriteBuffer, htmlSafe!: Bool = true): Unit {
    jsonWriteWithoutFormat(json, buff, 0, htmlSafe: htmlSafe)
}

func jsonWriteWithoutFormat(json: JsonValue, buff: WriteBuffer, depth: Int64, htmlSafe!: Bool = true): Unit {
    json.writeCompactTo(buff, depth, htmlSafe)
}

func jsonWriteObject(json: JsonObject, buff: WriteBuffer, depth: Int64, bracketInNewLine: Bool, indent: String, htmlSafe!: Bool = true): Unit {
    checkJsonWriteDepth(depth)
    if (bracketInNewLine) {
        for (_ in 0..depth) {
            buff.append(indent)
        }
    }

    if (json.size() == 0) {
        buff.append(EMPTY_OBJECT_BYTES)
        return
    }

    buff.append(b'{')
    let new_depth = depth + 1
    let allKeysHtmlSafe = json.allKeysAreHtmlSafe()
    if (json.isFlatStorage()) {
        let fields = json.getFlatFieldsForRead()
        for (i in 0..json.getFlatSizeForRead()) {
            let field = fields[i]
            jsonWriteObjectField(
                field[0], field[1], buff, new_depth, indent, allKeysHtmlSafe, htmlSafe
            )
        }
    } else {
        for ((key, value) in json.getHashFieldsForRead()) {
            jsonWriteObjectField(key, value, buff, new_depth, indent, allKeysHtmlSafe, htmlSafe)
        }
    }
    buff.removetail()
    buff.append(b'\n')
    for (_ in 0..depth) {
        buff.append(indent)
    }
    buff.append(b'}')
}

func jsonWriteObjectField(
    key: String,
    value: JsonValue,
    buff: WriteBuffer,
    depth: Int64,
    indent: String,
    allKeysHtmlSafe: Bool,
    htmlSafe: Bool
): Unit {
    buff.append(b'\n')
    for (_ in 0..depth) {
        buff.append(indent)
    }
    buff.append(b'\"')
    if (allKeysHtmlSafe) {
        buff.append(key)
    } else {
        buff.appendEscape(key)
    }
    buff.append(b'\"').append(b':').appendBlank(1)
    match (value) {
        case jo: JsonObject => jsonWriteObject(jo, buff, depth, false, indent, htmlSafe: htmlSafe)
        case ja: JsonArray => jsonWriteArray(ja, buff, depth, false, indent, htmlSafe: htmlSafe)
        case _ => jsonWriteWithoutFormat(value, buff, depth, htmlSafe: htmlSafe)
    }
    buff.append(b',')
}

func jsonWriteArray(json: JsonArray, buff: WriteBuffer, depth: Int64, bracketInNewLine: Bool, indent: String, htmlSafe!: Bool = true): Unit {
    checkJsonWriteDepth(depth)
    if (bracketInNewLine) {
        for (_ in 0..depth) {
            buff.append(indent)
        }
    }

    if (json.size() == 0) {
        buff.append(EMPTY_ARRAY_BYTES)
        return
    }

    buff.append(b'[')
    let new_depth = depth + 1
    for (v in json.getItems()) {
        buff.append(b'\n')
        for (_ in 0..new_depth) {
            buff.append(indent)
        }
        match (v) {
            case jo: JsonObject => jsonWriteObject(jo, buff, new_depth, false, indent, htmlSafe: htmlSafe)
            case ja: JsonArray => jsonWriteArray(ja, buff, new_depth, false, indent, htmlSafe: htmlSafe)
            case _ => jsonWriteWithoutFormat(v, buff, new_depth, htmlSafe: htmlSafe)
        }
        buff.append(b',')
    }
    buff.removetail()
    buff.append(b'\n')
    for (_ in 0..depth) {
        buff.append(indent)
    }
    buff.append(b']')
}

// Keep container capacity estimation recomputed on each serialization. JsonArray and JsonObject expose
// mutable backing collections, so a persistent cached capacity could become stale after external mutation.
func asumecapacity(json: JsonValue, depth: Int64): Int64 {
    checkJsonWriteDepth(depth)
    match (json) {
        case jo: JsonObject =>
            var sum = 2
            if (jo.isFlatStorage()) {
                let fields = jo.getFlatFieldsForRead()
                for (i in 0..jo.getFlatSizeForRead()) {
                    let field = fields[i]
                    sum += asumeObjectFieldCapacity(field[0], field[1], depth)
                }
            } else {
                for ((key, value) in jo.getHashFieldsForRead()) {
                    sum += asumeObjectFieldCapacity(key, value, depth)
                }
            }
            return sum
        case ja: JsonArray =>
            var sum: Int64 = 2  // []
            for (v in ja.getItems()) {
                sum += asumecapacity(v, depth + 1) + 1  // value + comma
            }
            return sum
        case js: JsonString => return js.value.size + 2 // "value"
        case _: JsonBool => return 5 // max of "false" and "true" 
        case _: JsonInt => return 22 // max len is 22
        case jf: JsonFloat => return jf.writeCapacity()
        case _ => return 4 // len of "null" is 4
    }
}

func asumeObjectFieldCapacity(key: String, value: JsonValue, depth: Int64): Int64 {
    return key.size + 4 + asumecapacity(value, depth + 1)
}
