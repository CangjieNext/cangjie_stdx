/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package stdx.net.tls

import stdx.crypto.x509.*
import stdx.net.tls.common.*

public enum TlsVersion <: ToString {
    | V1_2 // TLS 1.2
    | V1_3 // TLS 1.3
    | Unknown

    public override func toString(): String {
        match (this) {
            case V1_2 => "TlsVersion.V1_2"
            case V1_3 => "TlsVersion.V1_3"
            case Unknown => "TlsVersion.Unknown"
        }
    }
}

/**
 * X509 verification mode. A TLS client, once connected, received a server certificate and
 * should verify it to ensure that the connection has been established to the right peer.
 * The default behavior is to use the system trust store. However there are cases when it's required
 * to trust all certificates (in testing and development, usually) or we have a custom CA server whose
 * certificates couldn't be installed into the system trust store for some reason.
*/
public enum CertificateVerifyMode {
    | Default // default verification mode: validate certificates against system CAs
    | TrustAll // trust all certificates
    | CustomCA(Array<X509Certificate>) // validate against the provided list of CAs
}

/**
 * Whether client need to identify (send certificate).
 */
public enum TlsClientIdentificationMode {
    | Disabled
    | Optional
    | Required
}

extend TlsRawSocket {
    func setRequestedHostName(hostname: String): Unit {
        otherNonIO<Unit> {
            nativeStream, exception => setRequestedHostName(nativeStream, hostname, exception)
        }
    }

    private func setRequestedHostName(
        stream: CPointer<Ssl>,
        name: String,
        exception: CPointer<ExceptionData>
    ): Unit {
        unsafe {
            var result: Int32 = 0
            try (cstring = LibC.mallocCString(name).asResource()) {
                result = CJ_TLS_SetHostName(stream, cstring.value, exception)
            }
            if (result == 0) {
                exception.read().throwException(fallback: "Cannot set hostname on client.")
            }
        }
    }

    func setHostNameForVerify(hostname: String): Unit {
        otherNonIO<Unit> {
            nativeStream, _ => setHostNameForVerify(nativeStream, hostname)
        }
    }

    private func setHostNameForVerify(stream: CPointer<Ssl>, name: String): Unit {
        unsafe {
            var result: Int32 = 0
            try (cstring = LibC.mallocCString(name).asResource()) {
                result = CJ_TLS_SetHostNameForVerify(stream, cstring.value)
            }
            if (result == 0) {
                throw TlsException("Cannot set hostname for verification.")
            }
        }
    }
}
