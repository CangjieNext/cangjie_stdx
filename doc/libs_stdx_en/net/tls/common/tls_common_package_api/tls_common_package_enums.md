# Enumerations

## enum CertificateVerifyMode

```cangjie
public enum CertificateVerifyMode {
    | Default
    | TrustAll
    | CustomCA(Array<Certificate>)
    | CustomVerify((Array<Certificate>) -> Bool)
}
```

Function: Specifies the certificate verification handling mode.

> **Note:**
>
> The CustomCA mode allows using user-configured certificate paths, suitable for scenarios where user certificates cannot be set as system certificates.
>
> In certificate authentication mode, after a TCP connection is established, the client and server can exchange certificates. The Default mode uses system certificates.
>
> During development and testing phases, the TrustAll mode can be used. This mode indicates that the local end does not verify peer certificates. In this mode, the local end trusts any connected entity and should only be used during development and testing.

### CustomCA(Array\<Certificate>)

```cangjie
CustomCA(Array<Certificate>)
```

Function: Indicates verification against both the provided CA list and system CAs.

### CustomVerify((Array\<Certificate>) -> Bool)

```cangjie
CustomVerify((Array<Certificate>) -> Bool)
```

Function: Indicates custom verification rules. Requires providing a certificate verification function that returns whether verification passes based on the input certificates.

### Default

```cangjie
Default
```

Function: Indicates the default verification mode, which verifies certificates against system CAs.

### TrustAll

```cangjie
TrustAll
```

Function: Indicates trusting all certificates.

## enum TlsVersion

```cangjie
@Derive[ToString, Hashable, Equatable]
public enum TlsVersion {
    V1_2 | V1_3 | TLCP | ...
}
```

Function: TLS protocol versions.

Parent Types:

- ToString
- Hashable
- Equatable\<[TlsVersion](#enum-tlsversion)>

### V1_2

```cangjie
V1_2
```

Function: Indicates TLS 1.2 version.

### V1_3

```cangjie
V1_3
```

Function: Indicates TLS 1.3 version.

### TLCP

```cangjie
TLCP
```

Function: Indicates TLCP version.

### func hashCode()

```cangjie
public func hashCode(): Int64
```

Function: Returns the hash value of the current [TlsVersion](#enum-tlsversion).

Return Value:

- Int64 - The hash value of the current [TlsVersion](#enum-tlsversion).

### func toString()

```cangjie
public override func toString(): String
```

Function: Returns the string representation of the current [TlsVersion](#enum-tlsversion).

Return Value:

- String - The string representation of the current [TlsVersion](#enum-tlsversion).

### operator func ==(TlsVersion)

```cangjie
public operator func ==(that: TlsVersion): Bool
```

Function: Compares whether two [TlsVersion](#enum-tlsversion) instances are identical.

Parameters:

- that: [TlsVersion](#enum-tlsversion) - The TLS version to compare.

Return Value:

- Bool - Returns `true` if identical, otherwise returns `false`.
