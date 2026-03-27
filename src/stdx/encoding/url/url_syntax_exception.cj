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
        var result = input
        let atIdx = result.indexOf('@') ?? -1
        if (atIdx != -1) {
            let schemeEnd = result.indexOf("://") ?? -1
            if (schemeEnd != -1 && atIdx > schemeEnd) {
                let hostStart = atIdx + 1
                let userinfo = result[(schemeEnd + 3)..atIdx]
                let colonIdx = userinfo.indexOf(':') ?? -1
                var sanitizedUserinfo = ""
                if (colonIdx != -1) {
                    let username = userinfo[0..colonIdx]
                    let password = userinfo[(colonIdx + 1)..]
                    let maskedUsername = "*" * username.size
                    let maskedPassword = "*" * password.size
                    sanitizedUserinfo = "${maskedUsername}:${maskedPassword}"
                } else {
                    sanitizedUserinfo = "*" * userinfo.size
                }
                result = result[0..(schemeEnd + 3)] + sanitizedUserinfo + "@" + result[hostStart..]
            }
        }
        return result
    }

    protected override func getClassName(): String {
        return "UrlSyntaxException"
    }
}