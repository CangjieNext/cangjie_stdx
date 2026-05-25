# x509 Usage

## Reading and Parsing Certificates

> **Note:**
>
> Certificate files need to be prepared by the user.

Example:

<!-- compile -->
```cangjie
import std.fs.File
import stdx.crypto.x509.*

let readPath = "./files/root_rsa.cer"

main() {
    /* Read local certificate */
    let pem = String.fromUtf8(File.readFrom(readPath))
    let certificates = X509Certificate.decodeFromPem(pem)

    /* Parse mandatory fields in certificate */
    let cert = certificates[0]
    println(cert)
    println("Serial Number: ${cert.serialNumber}")
    println("Issuer: ${cert.issuer}")
    println("NotBefore: ${cert.notBefore}")
    println("NotAfter: ${cert.notAfter}")
    println(cert.signatureAlgorithm)
    let signature = cert.signature
    println(signature.hashCode())
    println(cert.publicKeyAlgorithm)
    let pubKey = cert.publicKey
    println(pubKey.encodeToPem().encode())

    /* Parse extended fields in certificate */
    println("DNSNames: ${cert.dnsNames}")
    println("EmailAddresses: ${cert.emailAddresses}")
    println("IPAddresses: ${cert.IPAddresses}")
    println("KeyUsage: ${cert.keyUsage}")
    println("ExtKeyUsage: ${cert.extKeyUsage}")

    /* Parse subject distinguished name */
    println("Subject: ${cert.subject}")

    return 0
}
```

## Reading and Verifying Certificates

> **Note:**
>
> Certificate files need to be prepared by the user.

Example:

<!-- compile -->
```cangjie
import std.fs.File
import stdx.crypto.x509.*
import std.time.DateTime

let prefixPath = "./files/"
let certFile = "servers.crt"
let rootFile = "roots.crt"
let middleFile = "middles.crt"

func getX509Cert(path: String) {
    let pem = String.fromUtf8(File.readFrom(path))
    X509Certificate.decodeFromPem(pem)
}

func testVerifyByTime(cert: X509Certificate, roots: Array<X509Certificate>, middles: Array<X509Certificate>) {
    var opt = VerifyOption()
    opt.roots = roots
    opt.intermediates = middles
    cert.verify(opt)
    println("Verify result: ${cert.verify(opt)}")
    opt.time = DateTime.of(year: 2023, month: 7, dayOfMonth: 1)
    println("Verify result:: ${cert.verify(opt)}")
}

func testVerifyByDNS(cert: X509Certificate) {
    var opt = VerifyOption()
    opt.dnsName = "www.example.com"
    println("cert DNS names: ${cert.dnsNames}")
    let res = cert.verify(opt)
    println("Verify result: ${res}")
}

/**
 * The relation of certs.
 *    root[0]         root[1]
 *    /      \            |
 *  mid[0]  mid[1]    mid[2]
 *   |                  |
 *  server[0]         server[1]
 */
func testVerify(cert: X509Certificate, roots: Array<X509Certificate>, middles: Array<X509Certificate>) {
    var opt = VerifyOption()
    opt.roots = roots
    opt.intermediates = middles
    let res = cert.verify(opt)
    println("Verify result: ${res}")
}

main() {
    /* Two server certificates */
    let certs = getX509Cert(prefixPath + certFile)
    /* Two root certificates */
    let roots = getX509Cert(prefixPath + rootFile)
    /* Three intermediate certificates */
    let middles = getX509Cert(prefixPath + middleFile)
    /* Verify validity period */
    testVerifyByTime(certs[0], [roots[0]], [middles[0]])
    /* Verify DNS name */
    testVerifyByDNS(certs[0])

    /* Verify validity based on root and intermediate certificates */
    /* cert0 <- root0: false */
    testVerify(certs[0], [roots[0]], [])
    /* cert0 <- middle0 <- root0: true */
    testVerify(certs[0], [roots[0]], [middles[0]])
    /* cert0 <- (middle0, middle1, middle2) <- (root0, root1) : true */
    testVerify(certs[0], roots, middles)
    /* cert1 <- middle0 <- root0: false */
    testVerify(certs[1], [roots[0]], [middles[0]])
    /* cert1 <- middle2 <- root1: true */
    testVerify(certs[1], [roots[1]], [middles[2]])
    /* cert1 <- (middle0, middle1, middle2) <- (root0, root1) : true */
    testVerify(certs[1], roots, middles)
    return 0
}
```

## Creating and Parsing Certificates

> **Note:**
>
> Root certificate files need to be prepared by the user.

Example:

<!-- compile -->
```cangjie
import std.fs.*
import stdx.crypto.x509.*
import stdx.crypto.keys.*
import std.time.*
import std.io.*

main() {
    let x509Name = X509Name(
        countryName: "CN",
        provinceName: "beijing",
        localityName: "haidian",
        organizationName: "organization",
        organizationalUnitName: "organization unit",
        commonName: "x509",
        email: "test@email.com"
    )
    let serialNumber = SerialNumber(length: 20)
    let startTime: DateTime = DateTime.now()
    let endTime: DateTime = startTime.addYears(1)
    let ip1: IP = [8, 8, 8, 8]
    let ip2: IP = [0, 1, 0, 1, 0, 1, 0, 1, 0, 8, 0, 8, 0, 8, 0, 8]
    let parentCertPem = String.fromUtf8(readToEnd(File("./certificate.pem", Read)))
    let parentCert = X509Certificate.decodeFromPem(parentCertPem)[0]
    let parentKeyPem = String.fromUtf8(readToEnd(File("./rsa_private_key.pem", Read)))
    let parentPrivateKey = GeneralPrivateKey.decodeFromPem(parentKeyPem)
    let usrKeyPem = String.fromUtf8(readToEnd(File("./ecdsa_public_key.pem", Read)))
    let usrPublicKey = GeneralPublicKey.decodeFromPem(usrKeyPem)

    let certInfo = X509CertificateInfo(serialNumber: serialNumber, notBefore: startTime, notAfter: endTime,
        subject: x509Name, dnsNames: ["b.com"], IPAddresses: [ip1, ip2]);
    let cert = X509Certificate(certInfo, parent: parentCert, publicKey: usrPublicKey, privateKey: parentPrivateKey)

    println(cert)
    println("Serial Number: ${cert.serialNumber}")
    println("Issuer: ${cert.issuer}")
    println("Subject: ${cert.subject}")
    println("NotBefore: ${cert.notBefore}")
    println("NotAfter: ${cert.notAfter}")
    println(cert.signatureAlgorithm)
    println("DNSNames: ${cert.dnsNames}")
    println("IPAddresses: ${cert.IPAddresses}")

    return 0
}
```

## Creating and Parsing Certificate Signing Requests

> **Note:**
>
> Private key files need to be prepared by the user.

Example:

<!-- compile -->
```cangjie
import std.fs.*
import std.io.*
import stdx.crypto.x509.*
import stdx.crypto.keys.GeneralPrivateKey

main() {
    let x509Name = X509Name(
        countryName: "CN",
        provinceName: "beijing",
        localityName: "haidian",
        organizationName: "organization",
        organizationalUnitName: "organization unit",
        commonName: "x509",
        email: "test@email.com"
    )
    let ip1: IP = [8, 8, 8, 8]
    let ip2: IP = [0, 1, 0, 1, 0, 1, 0, 1, 0, 8, 0, 8, 0, 8, 0, 8]
    let rsaPem = String.fromUtf8(readToEnd(File("./rsa_private_key.pem", Read)))
    let rsa = GeneralPrivateKey.decodeFromPem(rsaPem)

    let csrInfo = X509CertificateRequestInfo(subject: x509Name, dnsNames: ["b.com"], IPAddresses: [ip1, ip2]);
    let csr = X509CertificateRequest(rsa, certificateRequestInfo: csrInfo, signatureAlgorithm: SHA256WithRSA)

    println("Subject: ${csr.subject.toString()}")
    println("IPAddresses: ${csr.IPAddresses}")
    println("dnsNames: ${csr.dnsNames}")

    return 0
}
```
