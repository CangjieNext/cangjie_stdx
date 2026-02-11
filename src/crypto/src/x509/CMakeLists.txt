# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

set(X509_SRCS
    certificate_info.cj
    certificate.cj
    der_cert.cj
    der_parser.cj
    der_principal.cj
    der_type.cj
    der.cj
    keys.cj
    native.cj
    oid_principal.cj
    oid.cj
    serial_number.cj
    signature.cj
    utils.cj
    csr_blob.cj
    csr.cj
    CACHE INTERNAL "")

    add_subdirectory(native)