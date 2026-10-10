// Copyright (c) Huawei Technologies Co., Ltd. 2026. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
// See https://cangjie-lang.cn/pages/LICENSE for license information.

package aspect_v4_anno_right

@Annotation[target: [GlobalFunction]]
public class Mark {
    let code: Int64
    let values: VArray<Int64, $2>
    public const init(code!: Int64, values!: VArray<Int64, $2>) {
        this.code = code
        this.values = values
    }
}
