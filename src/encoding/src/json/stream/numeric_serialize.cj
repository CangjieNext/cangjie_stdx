/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package cangjie_stdx::encoding.json.stream

import std.math.numeric.*


extend BigInt <: JsonSerializable {
    public func toJson(w: JsonWriter): Unit {
        w.jsonValue(this.toString())
    }
}

extend BigInt <: JsonDeserializable<BigInt> {
    public static func fromJson(r: JsonReader): BigInt {
        return BigInt.parse(r.readString(), radix: 10)
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
