# Enumerations

## enum SignatureAlgorithm

```cangjie
public enum SignatureAlgorithm <: ToString & Equatable<SignatureAlgorithm> {
    | SignatureAndHashAlgorithm(SignatureType, HashType)
    | SignatureScheme(SignatureSchemeType)
}
```

Function: Defines the signature algorithm type, which is used to ensure the authentication, integrity, and authenticity of transmitted data.

Parent Types:

- ToString
- Equatable\<[SignatureAlgorithm](../../../crypto/x509/x509_package_api/x509_package_enums.md#enum-signaturealgorithm)>

### SignatureAndHashAlgorithm(SignatureType, HashType)

```cangjie
SignatureAndHashAlgorithm(SignatureType, HashType)
```

Function: Indicates which signature and hash algorithm pair will be used for digital signatures. From TLS 1.2 onwards, it includes signature and hash algorithm types.

### SignatureScheme(SignatureSchemeType)

```cangjie
SignatureScheme(SignatureSchemeType)
```

Function: Signature scheme. From TLS 1.3 onwards, this is the industry-recommended way to specify signature algorithms.

### func toString()

```cangjie
public func toString():String
```

Function: Converts the signature algorithm to its string representation.

Return Value:

- String - The name of the signature algorithm.

### operator func !=(SignatureAlgorithm)

```cangjie
public operator func !=(other: SignatureAlgorithm) : Bool
```

Function: Determines whether the signature algorithm types are different.

Parameters:

- other: [SignatureAlgorithm](tls_package_enums.md#enum-signaturealgorithm) - The signature algorithm type to compare.

Return Value:

- Bool - Returns `true` if different; otherwise, returns `false`.

### operator func ==(SignatureAlgorithm)

```cangjie
public operator func ==(other: SignatureAlgorithm) : Bool
```

Function: Determines whether the signature algorithm types are the same.

Parameters:

- other: [SignatureAlgorithm](tls_package_enums.md#enum-signaturealgorithm) - The signature algorithm type to compare.

Return Value:

- Bool - Returns `true` if the same; otherwise, returns `false`.

## enum SignatureSchemeType

```cangjie
public enum SignatureSchemeType <: ToString & Equatable<SignatureSchemeType> {
    | RSA_PKCS1_SHA256
    | RSA_PKCS1_SHA384
    | RSA_PKCS1_SHA512
    | ECDSA_SECP256R1_SHA256
    | ECDSA_SECP384R1_SHA384
    | ECDSA_SECP521R1_SHA512
    | RSA_PSS_RSAE_SHA256
    | RSA_PSS_RSAE_SHA384
    | RSA_PSS_RSAE_SHA512
    | ED25519
    | ED448
    | RSA_PSS_PSS_SHA256
    | RSA_PSS_PSS_SHA384
    | RSA_PSS_PSS_SHA512
}
```

Function: Defines encryption algorithm types used to ensure the security and privacy of network communications.

Parent Types:

- ToString
- Equatable\<[SignatureSchemeType](#enum-signatureschemetype)>

### ECDSA_SECP256R1_SHA256

```cangjie
ECDSA_SECP256R1_SHA256
```

Function: Creates an enumeration instance of type `ECDSA_SECP256R1_SHA256`, indicating the use of the `ECDSA_SECP256R1_SHA256` encryption algorithm.

### ECDSA_SECP384R1_SHA384

```cangjie
ECDSA_SECP384R1_SHA384
```

Function: Creates an enumeration instance of type `ECDSA_SECP384R1_SHA384`, indicating the use of the `ECDSA_SECP384R1_SHA384` encryption algorithm.

### ECDSA_SECP521R1_SHA512

```cangjie
ECDSA_SECP521R1_SHA512
```

Function: Creates an enumeration instance of type `ECDSA_SECP521R1_SHA512`, indicating the use of the `ECDSA_SECP521R1_SHA512` encryption algorithm.

### ED25519

```cangjie
ED25519
```

Function: Creates an enumeration instance of type `ED25519`, indicating the use of the ED25519 encryption algorithm.

### ED448

```cangjie
ED448
```

Function: Creates an enumeration instance of type `ED448`, indicating the use of the ED448 encryption algorithm.

### RSA_PKCS1_SHA256

```cangjie
RSA_PKCS1_SHA256
```

Function: Creates an enumeration instance of type `RSA_PKCS1_SHA256`, indicating the use of the `RSA_PKCS1_SHA256` encryption algorithm.

### RSA_PKCS1_SHA384

```cangjie
RSA_PKCS1_SHA384
```

Function: Creates an enumeration instance of type `RSA_PKCS1_SHA384`, indicating the use of the `RSA_PKCS1_SHA384` encryption algorithm.

### RSA_PKCS1_SHA512

```cangjie
RSA_PKCS1_SHA512
```

Function: Creates an enumeration instance of type `RSA_PKCS1_SHA512`, indicating the use of the `RSA_PKCS1_SHA512` encryption algorithm.

### RSA_PSS_PSS_SHA256

```cangjie
RSA_PSS_PSS_SHA256
```

Function: Creates an enumeration instance of type `RSA_PSS_PSS_SHA256`, indicating the use of the `RSA_PSS_PSS_SHA256` encryption algorithm.

### RSA_PSS_PSS_SHA384

```cangjie
RSA_PSS_PSS_SHA384
```

Function: Creates an enumeration instance of type `RSA_PSS_PSS_SHA384`, indicating the use of the `RSA_PSS_PSS_SHA384` encryption algorithm.

### RSA_PSS_PSS_SHA512

```cangjie
RSA_PSS_PSS_SHA512
```

Function: Creates an enumeration instance of type `RSA_PSS_PSS_SHA512`, indicating the use of the `RSA_PSS_PSS_SHA512` encryption algorithm.

### RSA_PSS_RSAE_SHA256

```cangjie
RSA_PSS_RSAE_SHA256
```

Function: Creates an enumeration instance of type `RSA_PSS_RSAE_SHA256`, indicating the use of the `RSA_PSS_RSAE_SHA256` encryption algorithm.

### RSA_PSS_RSAE_SHA384

```cangjie
RSA_PSS_RSAE_SHA384
```

Function: Creates an enumeration instance of type `RSA_PSS_RSAE_SHA384`, indicating the use of the `RSA_PSS_RSAE_SHA384` encryption algorithm.

### RSA_PSS_RSAE_SHA512

```cangjie
RSA_PSS_RSAE_SHA512
```

Function: Creates an enumeration instance of type `RSA_PSS_RSAE_SHA512`, indicating the use of the `RSA_PSS_RSAE_SHA384` encryption algorithm.

### func toString()

```cangjie
public func toString(): String
```

Function: Returns the string representation of the encryption algorithm type.

For example, the string representation of `RSA_PKCS1_SHA256` is "rsa_pkcs1_sha256".

Return Value:

- String - The string representation of the encryption algorithm type.

### operator func !=(SignatureSchemeType)

```cangjie
public operator func !=(other: SignatureSchemeType): Bool
```

Function: Determines whether the two encryption algorithm types are different.

Parameters:

- other: [SignatureSchemeType](tls_package_enums.md#enum-signatureschemetype) - The encryption algorithm type to compare.

Return Value:

- Bool - Returns true if different; otherwise, returns false.

### operator func ==(SignatureSchemeType)

```cangjie
public operator func ==(other: SignatureSchemeType): Bool
```

Function: Determines whether the two encryption algorithm types are the same.

Parameters:

- other: [SignatureSchemeType](tls_package_enums.md#enum-signatureschemetype) - The type of cryptographic algorithm to compare.

Return Value:

- Bool - Returns `true` if identical; otherwise, returns `false`.

## enum SignatureType

```cangjie
public enum SignatureType <: ToString & Equatable<SignatureType> {
    | DSA
    | ECDSA
    | RSA
}
```

Function: Signature algorithm type for authenticity verification. Refer to [RFC5246 7.4.1.4.1](https://www.rfc-editor.org/rfc/rfc5246.html#section-7.4.1.4.1).

Parent Types:

- ToString
- Equatable\<[SignatureType](#enum-signaturetype)>

### DSA

```cangjie
DSA
```

Function: Creates a `DSA` enum instance, representing the Digital Signature Algorithm.

### ECDSA

```cangjie
ECDSA
```

Function: Creates an `ECDSA` enum instance, representing the Elliptic Curve Digital Signature Algorithm.

### RSA

```cangjie
RSA
```

Function: Creates an `RSA` enum instance, representing the RSA encryption algorithm.

### func toString()

```cangjie
public func toString(): String
```

Function: Converts to a string representation of the signature algorithm.

Return Value:

- String - The name of the signature algorithm.

### operator func !=(SignatureType)

```cangjie
public operator func !=(other: SignatureType) : Bool
```

Function: Determines whether two signature algorithms are different.

Parameters:

- other: [SignatureType](tls_package_enums.md#enum-signaturetype) - The type of signature algorithm to compare.

Return Value:

- Bool - Returns `true` if different; otherwise, returns `false`.

### operator func ==(SignatureType)

```cangjie
public operator func ==(other: SignatureType) : Bool
```

Function: Determines whether two signature algorithms are identical.

Parameters:

- other: [SignatureType](tls_package_enums.md#enum-signaturetype) - The type of signature algorithm to compare.

Return Value:

- Bool - Returns `true` if identical; otherwise, returns `false`.

## enum TlsClientIdentificationMode

```cangjie
public enum TlsClientIdentificationMode {
    | Disabled
    | Optional
    | Required
}
```

Function: Server-side authentication mode for client certificates.

### Disabled

```cangjie
Disabled
```

Function: Indicates that the server does not validate client certificates. Clients may omit sending certificates and public keys (unidirectional authentication).

### Optional

```cangjie
Optional
```

Function: Indicates that the server validates client certificates, but clients may choose not to provide certificates and public keys (unidirectional authentication if omitted, bidirectional if provided).

### Required

```cangjie
Required
```

Function: Indicates that the server validates client certificates and mandates clients to provide certificates and public keys (bidirectional authentication).
