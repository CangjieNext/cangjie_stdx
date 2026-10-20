// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package replacement
import stdx.aspect_cj.*

public interface Calculator { func calculate(x: Int64): Int64 }

public class ClassCalculator <: Calculator {
    let offset = 10
    @ReplaceFuncBody[packageName: "replacement", className: "ClassCalculator",
        methodName: "calculate", isStatic: false, recursive: false]
    public func advice(x: Int64, original: (Int64) -> Int64): Int64 { original(x + 1) + 100 }
    public func calculate(x: Int64): Int64 { offset + x }
    public func externalCalculate(x: Int64): Int64 { offset + x }
    public func zeroCalculate(): Int64 { offset }

    @ReplaceFuncBody[packageName: "replacement", className: "ClassCalculator",
        methodName: "staticCalculate", isStatic: true, recursive: false]
    public static func staticAdvice(original: (Int64) -> Int64): Int64 { original(1) + 100 }
    public static func staticCalculate(x: Int64): Int64 { 10 + x }
}

public struct StructCalculator {
    let offset = 20
    @ReplaceFuncBody[packageName: "replacement", className: "StructCalculator",
        methodName: "calculate", isStatic: false, recursive: false]
    public func advice(x: Int64, original: (Int64) -> Int64): Int64 { original(x + 1) + 100 }
    public func calculate(x: Int64): Int64 { offset + x }
    public func externalCalculate(x: Int64): Int64 { offset + x }

    @ReplaceFuncBody[packageName: "replacement", className: "StructCalculator",
        methodName: "staticCalculate", isStatic: true, recursive: false]
    public static func staticAdvice(original: (Int64) -> Int64): Int64 { original(1) + 100 }
    public static func staticCalculate(x: Int64): Int64 { 20 + x }
}

public enum EnumCalculator {
    | Value
    @ReplaceFuncBody[packageName: "replacement", className: "EnumCalculator",
        methodName: "calculate", isStatic: false, recursive: false]
    public func advice(x: Int64, original: (Int64) -> Int64): Int64 { original(x + 1) + 100 }
    public func calculate(x: Int64): Int64 { 30 + x }
    public func externalCalculate(x: Int64): Int64 { 30 + x }

    @ReplaceFuncBody[packageName: "replacement", className: "EnumCalculator",
        methodName: "staticCalculate", isStatic: true, recursive: false]
    public static func staticAdvice(original: (Int64) -> Int64): Int64 { original(1) + 100 }
    public static func staticCalculate(x: Int64): Int64 { 30 + x }
}

@ReplaceFuncBody[packageName: "replacement", className: "ClassCalculator",
    methodName: "externalCalculate", isStatic: false, recursive: false]
public func globalClassAdvice(self: ClassCalculator, x: Int64, original: (Int64) -> Int64): Int64 {
    original(x + 2) + 200
}

@ReplaceFuncBody[packageName: "replacement", className: "StructCalculator",
    methodName: "externalCalculate", isStatic: false, recursive: false]
public func globalStructAdvice(self: StructCalculator, x: Int64, original: (Int64) -> Int64): Int64 {
    original(x + 2) + 200
}

@ReplaceFuncBody[packageName: "replacement", className: "ClassCalculator",
    methodName: "zeroCalculate", isStatic: false, recursive: false]
public func globalZeroAdvice(self: ClassCalculator, original: () -> Int64): Int64 {
    original() + 100
}

public class StaticReplacementAdvice {
    @ReplaceFuncBody[packageName: "replacement", className: "EnumCalculator",
        methodName: "externalCalculate", isStatic: false, recursive: false]
    public static func advice(self: EnumCalculator, x: Int64, original: (Int64) -> Int64): Int64 {
        original(x + 2) + 200
    }
}

public open class BaseCalculator {
    @ReplaceFuncBody[packageName: "replacement", className: "BaseCalculator",
        methodName: "calculate", isStatic: false, recursive: true]
    public func advice(x: Int64, original: (Int64) -> Int64): Int64 { original(x + 1) + 100 }
    public open func calculate(x: Int64): Int64 { 50 + x }
}

public class DerivedCalculator <: BaseCalculator {
    public func calculate(x: Int64): Int64 { 60 + x }
}

main() {
    let throughInterface: Calculator = ClassCalculator()
    println(throughInterface.calculate(0))
    println(ClassCalculator.staticCalculate(0))
    println(StructCalculator().calculate(0))
    println(StructCalculator.staticCalculate(0))
    println(EnumCalculator.Value.calculate(0))
    println(EnumCalculator.staticCalculate(0))
    println(ClassCalculator().externalCalculate(0))
    println(StructCalculator().externalCalculate(0))
    println(EnumCalculator.Value.externalCalculate(0))
    println(ClassCalculator().zeroCalculate())
    println(BaseCalculator().calculate(0))
    let throughParent: BaseCalculator = DerivedCalculator()
    println(throughParent.calculate(0))
    0
}
