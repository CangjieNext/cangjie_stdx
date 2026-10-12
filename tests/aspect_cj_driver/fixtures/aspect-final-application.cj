// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// Licensed under Apache-2.0 with Runtime Library Exception.
package aspect_v4_linked_app
import aspect_v4_linked_library.*
public func callLibrary(value: Int64): Unit { business(value) }
main() { callLibrary(7); 0 }
