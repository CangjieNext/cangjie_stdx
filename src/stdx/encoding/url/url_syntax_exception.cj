/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

/**
 * @file The file declares  the UrlSyntaxException.
 */

package stdx.encoding.url

/**
 * The UrlSyntaxException.
 */
public class UrlSyntaxException <: Exception {
    var pos: String = ""
    public init(reason: String) {
        super(reason)
    }
    /**
     * Initializes a UrlSyntaxException object.
     *
     * @param input : Native URL
     * @param reason : Reasons for parsing errors
     *
     */
    public init(input: String, reason: String) {
        super(reason + " Input = ${sanitizeUrl(input)}.")
    }

    public init(input: String, reason: String, pos: String) {
        super(reason + " Input = ${sanitizeUrl(input)} (at '${pos}').")
    }

    private static func sanitizeUrl(input: String): String {
        let maxLen = 200
        var result = input
        let atIdx = result.indexOf('@') ?? -1
        if (atIdx != -1) {
            let schemeEnd = result.indexOf("://") ?? -1
            if (schemeEnd != -1 && atIdx > schemeEnd) {
                let hostStart = atIdx + 1
                result = result[0..(schemeEnd + 3)] + "***:***@" + result[hostStart..]
            }
        }
        if (result.size > maxLen) {
            result = result[0..maxLen] + "..."
        }
        return result
    }

    protected override func getClassName(): String {
        return "UrlSyntaxException"
    }
}