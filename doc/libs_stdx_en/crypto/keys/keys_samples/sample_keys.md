# Keys Usage

## RSA Key Example

### Generate RSA public and private keys, encrypt using OAEP padding mode with the public key, and decrypt using OAEP padding mode with the private key

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::crypto.keys.*
import cangjie_stdx::crypto.digest.*
import std.io.*
import std.crypto.digest.*

main() {
    var rsaPri = RSAPrivateKey(2048)
    var rsaPub = RSAPublicKey(rsaPri)

    var str: String = "hello world, hello cangjie"
    var bas1 = ByteBuffer()
    var bas2 = ByteBuffer()
    var bas3 = ByteBuffer()
    bas1.write(str.toArray())

    var encOpt = OAEPOption(SHA1(), SHA256())
    rsaPub.encrypt(bas1, bas2, padType: OAEP(encOpt))
    var encOpt2 = OAEPOption(SHA1(), SHA256())
    rsaPri.decrypt(bas2, bas3, padType: OAEP(encOpt2))

    var buf = Array<Byte>(str.size, repeat: 0)
    bas3.read(buf)
    if (str.toArray() == buf) {
        println("success")
    } else {
        println("fail")
    }
}
```

Execution result:

```text
success
```

### Read RSA public and private keys from files, sign using PKCS1 padding mode with the private key, and verify the signature using PKCS1 padding mode with the public key

**Note:**
>
> - You need to prepare the public and private key files yourself.

Example:

<!-- compile -->
```cangjie
import cangjie_stdx::crypto.keys.*
import cangjie_stdx::crypto.digest.*
import std.crypto.digest.*
import std.fs.*
import std.io.*

main() {
    var pemPri = String.fromUtf8(readToEnd(File("./files/rsaPri.pem", Read)))
    var rsaPri = RSAPrivateKey.decodeFromPem(pemPri)

    var pemPub = String.fromUtf8(readToEnd(File("./files/rsaPub.pem", Read)))
    var rsaPub = RSAPublicKey.decodeFromPem(pemPub)

    var str: String = "helloworld"
    var sha512Instance = SHA512()
    sha512Instance.write(str.toArray())
    var md: Array<Byte> = sha512Instance.finish()

    var sig = rsaPri.sign(sha512Instance, md, padType: PKCS1)
    if (rsaPub.verify(sha512Instance, md, sig, padType: PKCS1)) {
        println("verify successful")
    }
}
```

Execution result:

```text
verify successful
```

## ECDSA Key Example

### Generate ECDSA public and private keys, sign using the private key, and verify the signature with the public key

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::crypto.keys.*
import cangjie_stdx::crypto.digest.*
import std.convert.*
import std.crypto.digest.*

main() {
    var ecPri = ECDSAPrivateKey(P224)
    var ecPub = ECDSAPublicKey(ecPri)

    var str: String = "helloworld"
    var sha512Instance = SHA512()
    sha512Instance.write(str.toArray())
    var md: Array<Byte> = sha512Instance.finish()

    var sig = ecPri.sign(md)
    if (ecPub.verify(md, sig)) {
        println("verify successful")
    }
}
```

Execution result:

```text
verify successful
```

## SM2 Key Example

### Generate SM2 public and private keys, sign using the private key, and verify the signature with the public key

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::crypto.keys.*
import cangjie_stdx::crypto.digest.*
import std.convert.*
import std.crypto.digest.*
import std.fs.*
import std.io.*

main(): Unit {
    /* Generate public and private keys without parameters */
    let sm2PrivateKey = SM2PrivateKey()
    let sm2PublicKey = SM2PublicKey(sm2PrivateKey)

    /* Export public and private keys */
    let priPem = sm2PrivateKey.encodeToPem()
    let file1: File = File("./sm2Pri.pem", Write)
    file1.write(priPem.encode().toArray())
    file1.close()

    let pubPem = sm2PublicKey.encodeToPem()
    let file2: File = File("./sm2Pub.pem", Write)
    file2.write(pubPem.encode().toArray())
    file2.close()

    /* Encrypt with public key, decrypt with private key */
    let str: String = "helloworld"
    let encresult = sm2PublicKey.encrypt(str.toArray())
    let decresult = sm2PrivateKey.decrypt(encresult)
    println(String.fromUtf8(decresult))

    /* Sign with private key, verify with public key */
    let strSig: String = "helloworld"
    let sigRe = sm2PrivateKey.sign(strSig.toArray())
    let verifyre = sm2PublicKey.verify(strSig.toArray(), sigRe)
    println(verifyre)

    /* Import private and public keys */
    let pemPri = String.fromUtf8(readToEnd(File("./sm2Pri.pem", Read)))
    let sm2PrivateKeyNew = SM2PrivateKey.decodeFromPem(pemPri)
    println(sm2PrivateKeyNew)
    let pemPub = String.fromUtf8(readToEnd(File("./sm2Pub.pem", Read)))
    let sm2PublicKeyNew = SM2PublicKey.decodeFromPem(pemPub)
    println(sm2PublicKeyNew)
}
```

Execution result:

```text
helloworld
true
SM2 PRIVATE KEY
SM2 PUBLIC KEY
```