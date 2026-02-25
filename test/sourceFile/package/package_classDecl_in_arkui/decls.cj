package testPackage

import std.binary.*
import std.collection.*

class CallbackResource {
    public var resourceId: Int32
    public var hold: pointer
    public var release: pointer
    init(resourceId: Int32, hold: pointer, release: pointer) {
        this.resourceId = resourceId
        this.hold = hold
        this.release = release
    }
}

class DeserializerBase {
    private var position: Int32 = 0
    public var length: Int32 = 96 // make private
    public var buffer: UInt64 // make private

    public init(buffer: UInt64, length: Int32) {
        this.buffer = buffer
        this.length = length
    }
    public init(buffer: Array<UInt8>, length: Int32) {
        this.buffer = InteropNativeModule._Malloc(length)
        for (i in 0..length) {
            DeserializerBase.writeu8(this.buffer, i, length, buffer[Int64(i)])
        }
        this.length = length
    }

    private static func writeu8(buffer: pointer, offset: Int32, length: Int32, value: UInt8): Unit {
        InteropNativeModule._WriteByte(buffer, Int64(offset), Int64(length), Int32(value))
    }
    private static func readu8(buffer: pointer, offset: Int32, length: Int32): Int32 {
        return InteropNativeModule._ReadByte(buffer, Int64(offset), Int64(length))
    }

    public func asBuffer(): UInt64 {
        return this.buffer
    }

    public func currentPosition(): Int32 {
        return this.position
    }

    public func resetCurrentPosition(): Unit {
        this.position = 0
    }

    private func checkCapacity(value: Int32) {
        if (value > this.length) {
            throw Exception("${value} is less than remaining buffer length")
        }
    }

    private func readInt8(): Int8 {
        this.checkCapacity(1)
        var res = DeserializerBase.readu8(this.buffer, this.position, this.length)
        this.position += 1
        return Int8(res)
    }

    public func readInt32(): Int32 {
        this.checkCapacity(4)
        let arr = Array<UInt8>(4, {i => UInt8(i+1)}) 
        //Array<UInt8>(4, {i => UInt8(DeserializerBase.readu8(this.buffer, this.position + Int32(i), this.length))})
        this.position += 4
        return Int32.readLittleEndian(arr)
    }

    public func readInt64(): Int64 {
        this.checkCapacity(8)
        let arr = Array<UInt8>(8, {i => UInt8(DeserializerBase.readu8(this.buffer, this.position + Int32(i), this.length))})
        this.position += 8
        return Int64.readLittleEndian(arr)
    }

    public func readPointer(): UInt64 {
        this.checkCapacity(8)
        let arr = Array<UInt8>(8, {i => UInt8(DeserializerBase.readu8(this.buffer, this.position + Int32(i), this.length))})
        this.position += 8
        return UInt64.readLittleEndian(arr)
    }

    public func readFloat32(): Float32 {
        this.checkCapacity(4)
        let arr = Array<UInt8>(4, {i => UInt8(DeserializerBase.readu8(this.buffer, this.position + Int32(i), this.length))})
        this.position += 4
        return Float32.readLittleEndian(arr)
    }
    public func readFloat64(): Float64 {
        this.checkCapacity(8)
        let arr = Array<UInt8>(8, {i => UInt8(DeserializerBase.readu8(this.buffer, this.position + Int32(i), this.length))})
        this.position += 8
        return Float64.readLittleEndian(arr)
    }

    public func readBoolean(): Bool {
        var byteVal = DeserializerBase.readu8(this.buffer, this.position, this.length)
        this.position += 1
        return byteVal == 1
    }

    public func readString(): String {
        let length = this.readInt32()
        this.checkCapacity(length)
        // read without null-terminated byte
        let value = InteropNativeModule._Utf8ToString(this.buffer, Int32(this.position), Int32(length))
        this.position += length
        return value
    }

    public func readCustomObject(kind: String): Object {
        throw Exception("readCustomObject")
    }

    public func readObject(): Any {
        let resource = this.readCallbackResource()
        return ResourceHolder.instance().get(resource.resourceId)
    }

    public func readBuffer(): Array<UInt8> {
        return Array<UInt8>()
    }

    public func readFunction(): Any {
        return { => }
    }

    public func readNumber(): Float64 {
        let tag = this.readInt8()
        if (tag == Tag.UNDEFINED.value) {
            throw Exception("Read number can't return undefined.")
        } else if (tag == Tag.INT32.value) {
            return Float64(this.readInt32())
        } else if (tag == Tag.FLOAT32.value) {
            return Float64(this.readFloat32())
        } else {
            throw Exception("Unknown number tag: ${tag}")
        }
    }

    public func readCallbackResource(): CallbackResource {
        return CallbackResource(this.readInt32(), this.readPointer(), this.readPointer())
    }
}

class pointer {
    public var x: Int64 = 10
    var y: String = "Hello" 

    init() {
    }
}

public open class Tag {
    public static var UNDEFINED: Tag = Tag(101)
    public static var INT32: Tag = Tag(102)
    public static var FLOAT32: Tag = Tag(103)
    public static var STRING: Tag = Tag(104)
    public static var LENGTH: Tag = Tag(105)
    public static var RESOURCE: Tag = Tag(106)
    public static var OBJECT: Tag = Tag(107)
    public var value: Int8
    Tag (arg0: Int8) {
        value = arg0
    }
}

func myFunc(): Unit {
    var a = 1
}

let arr = Array<Int64>(4, {i => i+1})

var res = DeserializerBase.readu8(pointer(), 0, 0)