/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.encoding.json.stream

import std.math.numeric.*

const MAX_JSON_BIGINT_LENGTH: Int64 = 16384

extend BigInt <: JsonSerializable {
    public func toJson(w: JsonWriter): Unit {
        w.jsonValue(this.toString())
    }
}

extend BigInt <: JsonDeserializable<BigInt> {
    public static func fromJson(r: JsonReader): BigInt {
        let value = r.readString()
        if (value.size > MAX_JSON_BIGINT_LENGTH) {
            throw IllegalStateException("BigInt length exceeds ${MAX_JSON_BIGINT_LENGTH}.")
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
        return Decimal.parse(r.readString())
    }
}
