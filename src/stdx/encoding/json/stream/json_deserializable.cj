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
 * This file defines interface JsonDeserializable
 */

package stdx.encoding.json.stream

import std.collection.*
import std.collection.concurrent.ConcurrentHashMap

public interface JsonDeserializable<T> {
    static func fromJson(r: JsonReader): T
}

extend Bool <: JsonDeserializable<Bool> {
    public static func fromJson(r: JsonReader): Bool {
        if (r.peeked == PEEK_STATE_TRUE) {
            return r.readTrue()
        } else if (r.peeked == PEEK_STATE_FALSE) {
            return r.readFalse()
        }
        return r.readBool()
    }
}

extend<T> Option<T> <: JsonDeserializable<Option<T>> where T <: JsonDeserializable<T> {
    public static func fromJson(r: JsonReader): Option<T> {
        if (r.peeked == PEEK_STATE_NULL || r.nextNonJsonWhitespace() == b'n') { // cjlint-ignore !G.EXP.03
            r.readNull()
            return None
        }
        return T.fromJson(r)
    }
}

const MAXVAL_I64: UInt64 = 0x7FFF_FFFF_FFFF_FFFF
const MAXVAL_UI64: UInt64 = 0xFFFF_FFFF_FFFF_FFFF
const MAXABSVAL_I64: UInt64 = MAXVAL_I64 + 1
const MAXVAL_I32: Int32 = 0x7FFF_FFFF
const MINVAL_I32: Int32 = -0x8000_0000
const MAXVAL_I16: Int16 = 0x7FFF
const MINVAL_I16: Int16 = -0x8000
const MAXVAL_I8: Int8 = 0x7F
const MINVAL_I8: Int8 = -0x80
const MAXVAL_UI32: UInt32 = 0xFFFF_FFFF
const MAXVAL_UI16: UInt16 = 0xFFFF
const MAXVAL_UI8: UInt8 = 0xFF
let isNative64 = UInt64(!UIntNative(0)) == MAXVAL_UI64

extend Int64 <: JsonDeserializable<Int64> {
    public static func fromJson(r: JsonReader): Int64 {
        let (res, overflow) = r.readInt()
        if (overflow) {
            throw OverflowException("The next number is out of range for Int64.")
        }
        return res
    }
}

extend Int32 <: JsonDeserializable<Int32> {
    public static func fromJson(r: JsonReader): Int32 {
        let (res, overflow) = r.readInt()
        if (overflow || res > Int64(MAXVAL_I32) || res < Int64(MINVAL_I32)) {
            throw OverflowException("The next number is out of range for Int32.")
        }
        return Int32(res)
    }
}

extend Int16 <: JsonDeserializable<Int16> {
    public static func fromJson(r: JsonReader): Int16 {
        let (res, overflow) = r.readInt()
        if (overflow || res > Int64(MAXVAL_I16) || res < Int64(MINVAL_I16)) {
            throw OverflowException("The next number is out of range for Int16.")
        }
        return Int16(res)
    }
}

extend Int8 <: JsonDeserializable<Int8> {
    public static func fromJson(r: JsonReader): Int8 {
        let (res, overflow) = r.readInt()
        if (overflow || res > Int64(MAXVAL_I8) || res < Int64(MINVAL_I8)) {
            throw OverflowException("The next number is out of range for Int8.")
        }
        return Int8(res)
    }
}

extend IntNative <: JsonDeserializable<IntNative> {
    public static func fromJson(r: JsonReader): IntNative {
        let (res, overflow) = r.readInt()
        if (overflow || (!isNative64 && (res > Int64(MAXVAL_I32) || res < Int64(MINVAL_I32)))) {
            throw OverflowException("The next number is out of range for IntNative.")
        }
        return IntNative(res)
    }
}

extend UInt64 <: JsonDeserializable<UInt64> {
    public static func fromJson(r: JsonReader): UInt64 {
        let (res, overflow) = r.readUInt()
        if (overflow) {
            throw OverflowException("The next number is out of range for UInt64.")
        }
        return res
    }
}

extend UInt32 <: JsonDeserializable<UInt32> {
    public static func fromJson(r: JsonReader): UInt32 {
        let (res, overflow) = r.readUInt()
        if (overflow || res > UInt64(MAXVAL_UI32)) {
            throw OverflowException("The next number is out of range for UInt32.")
        }
        return UInt32(res)
    }
}

extend UInt16 <: JsonDeserializable<UInt16> {
    public static func fromJson(r: JsonReader): UInt16 {
        let (res, overflow) = r.readUInt()
        if (overflow || res > UInt64(MAXVAL_UI16)) {
            throw OverflowException("The next number is out of range for UInt16.")
        }
        return UInt16(res)
    }
}

extend UInt8 <: JsonDeserializable<UInt8> {
    public static func fromJson(r: JsonReader): UInt8 {
        let (res, overflow) = r.readUInt()
        if (overflow || res > UInt64(MAXVAL_UI8)) {
            throw OverflowException("The next number is out of range for UInt8.")
        }
        return UInt8(res)
    }
}

extend UIntNative <: JsonDeserializable<UIntNative> {
    public static func fromJson(r: JsonReader): UIntNative {
        let (res, overflow) = r.readUInt()
        if (overflow || (!isNative64 && (res > UInt64(MAXVAL_UI32)))) {
            throw OverflowException("The next number is out of range for UIntNative.")
        }
        return UIntNative(res)
    }
}

extend Float64 <: JsonDeserializable<Float64> {
    public static func fromJson(r: JsonReader): Float64 {
        r.readFloat()
    }
}

extend Float32 <: JsonDeserializable<Float32> {
    public static func fromJson(r: JsonReader): Float32 {
        return Float32(r.readFloat())
    }
}

extend Float16 <: JsonDeserializable<Float16> {
    public static func fromJson(r: JsonReader): Float16 {
        return Float16(r.readFloat())
    }
}

extend<T> Array<T> <: JsonDeserializable<Array<T>> where T <: JsonDeserializable<T> {
    public static func fromJson(r: JsonReader): Array<T> {
        return ArrayList<T>.fromJson(r).toArray()
    }
}

func readArrayContainer<T, C>(r: JsonReader, result: C, addValue: (C, T) -> Unit): C where T <: JsonDeserializable<T> {
    r.startArray()
    if (r.peek() == EndArray) {
        r.endArray()
        return result
    }
    while (true) {
        addValue(result, r.readValue<T>())
        if (r.peeked == PEEK_STATE_ARRAY_END) {
            break
        }
    }
    r.endArray()
    return result
}

func readObjectContainer<T, C>(
    r: JsonReader,
    result: C,
    addValue: (C, String, T) -> Unit
): C where T <: JsonDeserializable<T> {
    r.startObject()
    if (r.peek() == EndObject) {
        r.endObject()
        return result
    }
    while (true) {
        let key = (r.readName() as String).getOrThrow()
        let value = r.readValue<T>()
        addValue(result, key, value)
        if (r.peeked == PEEK_STATE_OBJECT_END) {
            break
        }
    }
    r.endObject()
    return result
}

extend<T> ArrayList<T> <: JsonDeserializable<ArrayList<T>> where T <: JsonDeserializable<T> {
    public static func fromJson(r: JsonReader): ArrayList<T> {
        return readArrayContainer<T, ArrayList<T>>(r, ArrayList<T>(), {result, value => result.add(value)})
    }
}

extend<T> HashMap<String, T> <: JsonDeserializable<HashMap<String, T>> where T <: JsonDeserializable<T> {
    public static func fromJson(r: JsonReader): HashMap<String, T> {
        return readObjectContainer<T, HashMap<String, T>>(r, HashMap<String, T>(),
            {result, key, value => result.add(key, value)})
    }
}

extend<T> HashSet<T> <: JsonDeserializable<HashSet<T>> where T <: JsonDeserializable<T> {
    public static func fromJson(r: JsonReader): HashSet<T> {
        return readArrayContainer<T, HashSet<T>>(r, HashSet<T>(), {result, value => result.add(value)})
    }
}

extend<T> LinkedList<T> <: JsonDeserializable<LinkedList<T>> where T <: JsonDeserializable<T> {
    public static func fromJson(r: JsonReader): LinkedList<T> {
        return readArrayContainer<T, LinkedList<T>>(r, LinkedList<T>(), {result, value => result.addLast(value)})
    }
}

extend<T> ArrayQueue<T> <: JsonDeserializable<ArrayQueue<T>> where T <: JsonDeserializable<T> {
    public static func fromJson(r: JsonReader): ArrayQueue<T> {
        return readArrayContainer<T, ArrayQueue<T>>(r, ArrayQueue<T>(), {result, value => result.add(value)})
    }
}

extend<T> ArrayDeque<T> <: JsonDeserializable<ArrayDeque<T>> where T <: JsonDeserializable<T> {
    public static func fromJson(r: JsonReader): ArrayDeque<T> {
        return readArrayContainer<T, ArrayDeque<T>>(r, ArrayDeque<T>(), {result, value => result.addLast(value)})
    }
}

extend<T> ArrayStack<T> <: JsonDeserializable<ArrayStack<T>> where T <: JsonDeserializable<T> {
    public static func fromJson(r: JsonReader): ArrayStack<T> {
        return readArrayContainer<T, ArrayStack<T>>(r, ArrayStack<T>(), {result, value => result.add(value)})
    }
}

extend<T> TreeSet<T> <: JsonDeserializable<TreeSet<T>> where T <: JsonDeserializable<T> {
    public static func fromJson(r: JsonReader): TreeSet<T> {
        return readArrayContainer<T, TreeSet<T>>(r, TreeSet<T>(), {result, value => result.add(value)})
    }
}

extend<T> TreeMap<String, T> <: JsonDeserializable<TreeMap<String, T>> where T <: JsonDeserializable<T> {
    public static func fromJson(r: JsonReader): TreeMap<String, T> {
        return readObjectContainer<T, TreeMap<String, T>>(r, TreeMap<String, T>(),
            {result, key, value => result.add(key, value)})
    }
}

extend<T> ConcurrentHashMap<String, T> <: JsonDeserializable<ConcurrentHashMap<String, T>> where T <: JsonDeserializable<T> {
    public static func fromJson(r: JsonReader): ConcurrentHashMap<String, T> {
        return readObjectContainer<T, ConcurrentHashMap<String, T>>(r, ConcurrentHashMap<String, T>(),
            {result, key, value => result.add(key, value)})
    }
}

let DIGITS_UI64: Array<UInt64> = [100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
    100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
    100, 100, 100, 100, 100, 100, 100, 100, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 100, 100, 100, 100, 100, 100, 100, 10, 11, 12,
    13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 100, 100, 100, 100, 100,
    100, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 100,
    100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
    100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
    100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
    100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
    100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100,
    100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100, 100]
const HEXADECIMAL_OVERFLOW_LIMIT_UI64 = MAXVAL_UI64 / 16
const OCTAL_OVERFLOW_LIMIT_UI64 = MAXVAL_UI64 / 8
const BINARY_OVERFLOW_LIMIT_UI64 = MAXVAL_UI64 / 2
const DECIMAL_OVERFLOW_LIMIT_UI64 = MAXVAL_UI64 / 10

func isDecimalDigit(byte: Byte): Bool {
    return byte >= b'0' && byte <= b'9'
}
