// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// Licensed under Apache-2.0 with Runtime Library Exception.
package aspect_v4_external_source
import stdx.aspect_cj.*
import aspect_v4_support.*
@PointcutRule[packageName: "aspect_v4_external_app", className: "", methodName: "business",
    funcTypeStr: "(Int64)->Unit", targetKind: "global", recursive: false, annotationName: ""]
class Business {}
@InsertAtEntryByRule[rule: "aspect_v4_external_source.Business"]
public func before(args: Array<Any>): Unit { record((args[0] as Int64).getOrThrow()) }
