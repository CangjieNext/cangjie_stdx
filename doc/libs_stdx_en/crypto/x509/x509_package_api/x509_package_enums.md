# Enumerations

## enum PublicKeyAlgorithm

```cangjie
public enum PublicKeyAlgorithm <: Equatable<PublicKeyAlgorithm> & ToString {
    RSA | DSA | ECDSA | UnknownPublicKeyAlgorithm
}
```

Function: Public key information contained in digital certificates, currently supported types include: RSA, DSA, ECDSA.

Parent types:

- Equatable\<[PublicKeyAlgorithm](#enum-publickeyalgorithm)>
- ToString

### DSA

```cangjie
DSA
```

Function: DSA public key algorithm.

### ECDSA

```cangjie
ECDSA
```

Function: ECDSA public key algorithm.

### RSA

```cangjie
RSA
```

Function: RSA public key algorithm.

### UnknownPublicKeyAlgorithm

```cangjie
UnknownPublicKeyAlgorithm
```

Function: Unknown public key algorithm.

### func toString()

```cangjie
public override func toString(): String
```

Function: Generates a string representation of the public key algorithm name carried by the certificate.

Return value:

- String - The public key algorithm name string carried by the certificate.

### operator func !=(PublicKeyAlgorithm)

```cangjie
public override operator func !=(other: PublicKeyAlgorithm): Bool
```

Function: Inequality comparison.

Parameters:

- other: [PublicKeyAlgorithm](x509_package_enums.md#enum-publickeyalgorithm) - The public key algorithm to compare with.

Return value:

- Bool - Returns true if the public key algorithms are different; otherwise, returns false.

### operator func ==(PublicKeyAlgorithm)

```cangjie
public override operator func ==(other: PublicKeyAlgorithm): Bool
```

Function: Equality comparison.

Parameters:

- other: [PublicKeyAlgorithm](x509_package_enums.md#enum-publickeyalgorithm) - The public key algorithm to compare with.

Return value:

- Bool - Returns true if the public key algorithms are identical; otherwise, returns false.

## enum SignatureAlgorithm

```cangjie
public enum SignatureAlgorithm <: Equatable<SignatureAlgorithm> & ToString {
    | MD2WithRSA | MD5WithRSA | SHA1WithRSA | SHA256WithRSA | SHA384WithRSA
    | SHA512WithRSA | DSAWithSHA1 | DSAWithSHA256 | ECDSAWithSHA1 | ECDSAWithSHA256
    | ECDSAWithSHA384 | ECDSAWithSHA512 | UnknownSignatureAlgorithm
}
```

Function: The certificate signature algorithm ([Signature](x509_package_structs.md#struct-signature) Algorithm) is used for digitally signing certificates. It encrypts the public key and other information in digital certificates to ensure their integrity and authenticity.

Currently supported signature algorithms include: MD2WithRSA, MD5WithRSA, SHA1WithRSA, SHA256WithRSA, SHA384WithRSA, SHA512WithRSA, DSAWithSHA1, DSAWithSHA256, ECDSAWithSHA1, ECDSAWithSHA256, ECDSAWithSHA384, and ECDSAWithSHA512.

> **Note:**
>
> MD5WithRSA, SHA1WithRSA have been proven to be insecure. Use with caution.

Parent types:

- Equatable\<[SignatureAlgorithm](#enum-signaturealgorithm)>
- ToString

### DSAWithSHA1

```cangjie
DSAWithSHA1
```

Function: DSAwithSHA1 signature algorithm.

### DSAWithSHA256

```cangjie
DSAWithSHA256
```

Function: DSAwithSHA256 signature algorithm.

### ECDSAWithSHA1

```cangjie
ECDSAWithSHA1
```

Function: ECDSAwithSHA1 signature algorithm.

### ECDSAWithSHA256

```cangjie
ECDSAWithSHA256
```

Function: ECDSAwithSHA256 signature algorithm.

### ECDSAWithSHA384

```cangjie
ECDSAWithSHA384
```

Function: ECDSAwithSHA384 signature algorithm.

### ECDSAWithSHA512

```cangjie
ECDSAWithSHA512
```

Function: ECDSAwithSHA512 signature algorithm.

### MD2WithRSA

```cangjie
MD2WithRSA
```

Function: MD2withRSA signature algorithm.

### MD5WithRSA

```cangjie
MD5WithRSA
```

Function: MD5withRSA signature algorithm.

### SHA1WithRSA

```cangjie
SHA1WithRSA
```

Function: SHA1withRSA signature algorithm.

### SHA256WithRSA

```cangjie
SHA256WithRSA
```

Function: SHA256withRSA signature algorithm.

### SHA384WithRSA

```cangjie
SHA384WithRSA
```

Function: SHA384withRSA signature algorithm.

### SHA512WithRSA

```cangjie
SHA512WithRSA
```

Function: SHA512withRSA signature algorithm.

### UnknownSignatureAlgorithm

```cangjie
UnknownSignatureAlgorithm
```

Function: Unknown signature algorithm.

### func toString()

```cangjie
public override func toString(): String
```

Function: Generates a string representation of the certificate signature algorithm name.

Return value:

- String - The certificate signature algorithm name string.

### operator func != (SignatureAlgorithm)

```cangjie
public override operator func !=(other: SignatureAlgorithm): Bool
```

Function: Inequality comparison.

Parameters:

- other: [SignatureAlgorithm](./x509_package_enums.md#enum-signaturealgorithm) - The signature algorithm to compare with.

Return value:

- Bool - Returns true if the signature algorithms are different; otherwise, returns false.

### operator func == (SignatureAlgorithm)

```cangjie
public override operator func ==(other: SignatureAlgorithm): Bool
```

Function: Equality comparison.

Parameters:

- other: [SignatureAlgorithm](./x509_package_enums.md#enum-signaturealgorithm) - The signature algorithm to compare with.

Return value:

- Bool - Returns true if the signature algorithms are identical; otherwise, returns false.