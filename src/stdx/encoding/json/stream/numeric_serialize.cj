/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.encoding.json.stream

import std.math.numeric.*

const MAX_JSON_BIG_NUMBER_LENGTH: Int64 = 16384

func readJsonNumberAsString(r: JsonReader): String {
    match (r.peek()) {
        case Some(JsonToken.JsonNumber) =>
            r.nextValue(r.stringBuffer)
            let value = unsafe { String.fromUtf8Unchecked(r.stringBuffer.data[0..r.stringBuffer.size]) }
            r.stringBuffer.clear()
            return value
        case Some(JsonToken.JsonString) => return r.readString()
        case _ => throw IllegalStateException("The next Token is not JSON Number.")
    }
}

extend BigInt <: JsonSerializable {
    public func toJson(w: JsonWriter): Unit {
        w.jsonValue(this.toString())
    }
}

extend BigInt <: JsonDeserializable<BigInt> {
    public static func fromJson(r: JsonReader): BigInt {
        let value = readJsonNumberAsString(r)
        if (value.size > MAX_JSON_BIG_NUMBER_LENGTH) {
            throw IllegalStateException("BigInt length '${value.size}' exceeds maximum '${MAX_JSON_BIG_NUMBER_LENGTH}'.")
        }
        return BigInt.parse(value, radix: 10)
    }
}

extend Decimal <: JsonSerializable {
    public func toJson(w: JsonWriter): Unit {
        w.jsonValue(this.toString())
    }
}

extend Decimal <: JsonDeserializable<Decimal> {
    public static func fromJson(r: JsonReader): Decimal {
        // Same length cap as BigInt.fromJson: Decimal.parse converts the
        // coefficient with quadratic schoolbook base conversion, so an
        // unbounded token burns CPU super-linearly on untrusted input.
        let value = readJsonNumberAsString(r)
        if (value.size > MAX_JSON_BIG_NUMBER_LENGTH) {
            throw IllegalStateException("Decimal length '${value.size}' exceeds maximum '${MAX_JSON_BIG_NUMBER_LENGTH}'.")
        }
        return Decimal.parse(value)
    }
}
