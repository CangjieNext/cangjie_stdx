# Structures

## struct ExtKeyUsage

```cangjie
public struct ExtKeyUsage <: ToString {
    public static let AnyKey: UInt16 = 0
    public static let ServerAuth: UInt16 = 1
    public static let ClientAuth: UInt16 = 2
    public static let EmailProtection: UInt16 = 3
    public static let CodeSigning: UInt16 = 4
    public static let OCSPSigning: UInt16 = 5
    public static let TimeStamping: UInt16 = 6
    public init(keys: Array<UInt16>)
}
```

Functionality: Digital certificate extension fields typically contain extended key usage descriptions. Currently supported usages include: ServerAuth, ClientAuth, EmailProtection, CodeSigning, OCSPSigning, TimeStamping.

Parent Types:

- ToString

### static let AnyKey

```cangjie
public static let AnyKey: UInt16 = 0
```

Functionality: Indicates applicability for any purpose.

Type: UInt16

### static let ClientAuth

```cangjie
public static let ClientAuth: UInt16 = 2
```

Functionality: Indicates usage for SSL client authentication.

Type: UInt16

### static let CodeSigning

```cangjie
public static let CodeSigning: UInt16 = 4
```

Functionality: Indicates usage for code signing.

Type: UInt16

### static let EmailProtection

```cangjie
public static let EmailProtection: UInt16 = 3
```

Functionality: Indicates usage for email encryption/decryption, signing, etc.

Type: UInt16

### static let OCSPSigning

```cangjie
public static let OCSPSigning: UInt16 = 5
```

Functionality: Used for signing OCSP response packets.

Type: UInt16

### static let ServerAuth

```cangjie
public static let ServerAuth: UInt16 = 1
```

Functionality: Indicates usage for SSL server authentication.

Type: UInt16

### static let TimeStamping

```cangjie
public static let TimeStamping: UInt16 = 6
```

Functionality: Used for binding object digest values with timestamps.

Type: UInt16

### init(Array\<UInt16>)

```cangjie
public init(keys: Array<UInt16>)
```

Functionality: Constructs extended key usage with specified purposes. Note that the same key can have multiple usages.

Parameters:

- keys: Array\<UInt16> - Key(s).

### func toString()

```cangjie
public override func toString(): String
```

Functionality: Generates an extended key usage string.

Return Value:

- String - Certificate extended key usage string.

## struct KeyUsage

```cangjie
public struct KeyUsage <: ToString {
    public static let DigitalSignature: UInt16 = 0x0080
    public static let NonRepudiation: UInt16 = 0x0040
    public static let KeyEncipherment: UInt16 = 0x0020
    public static let DataEncipherment: UInt16 = 0x0010
    public static let KeyAgreement: UInt16 = 0x0008
    public static let CertSign: UInt16 = 0x0004
    public static let CRLSign: UInt16 = 0x0002
    public static let EncipherOnly: UInt16 = 0x0001
    public static let DecipherOnly: UInt16 = 0x0100
    public init(keys: UInt16)
}
```

Functionality: Digital certificate extension fields typically contain descriptions of public key usages. Currently supported usages include: DigitalSignature, NonRepudiation, KeyEncipherment, DataEncipherment, KeyAgreement, CertSign, CRLSign, EncipherOnly, DecipherOnly.

Parent Types:

- ToString

### static let CRLSign

```cangjie
public static let CRLSign: UInt16 = 0x0002
```

Functionality: Indicates the private key can be used to sign CRLs, while the public key can be used to verify CRL signatures.

Type: UInt16

### static let CertSign

```cangjie
public static let CertSign: UInt16 = 0x0004
```

Functionality: Indicates the private key is used for certificate signing, while the public key is used to verify certificate signatures. Specifically for CA certificates.

Type: UInt16

### static let DataEncipherment

```cangjie
public static let DataEncipherment: UInt16 = 0x0010
```

Functionality: Indicates the public key is used for direct data encryption.

Type: UInt16

### static let DecipherOnly

```cangjie
public static let DecipherOnly: UInt16 = 0x0100
```

Functionality: Indicates the public key in the certificate is only used for decryption calculations during key agreement. Meaningful only when used with keyAgreement.

Type: UInt16

### static let DigitalSignature

```cangjie
public static let DigitalSignature: UInt16 = 0x0080
```

Functionality: Indicates the private key can be used for various digital signature operations (except certificate signing, CRL signing, and non-repudiation services), while the public key is used to verify these signatures.

Type: UInt16

### static let EncipherOnly

```cangjie
public static let EncipherOnly: UInt16 = 0x0001
```

Functionality: Indicates the public key in the certificate is only used for encryption calculations during key agreement. Meaningful only when used with keyAgreement.

Type: UInt16

### static let KeyAgreement

```cangjie
public static let KeyAgreement: UInt16 = 0x0008
```

Functionality: Indicates the key is used for key agreement.

Type: UInt16

### static let KeyEncipherment

```cangjie
public static let KeyEncipherment: UInt16 = 0x0020
```

Function: Indicates that the key is used to encrypt other keys for transmission.

Type: UInt16

### static let NonRepudiation

```cangjie
public static let NonRepudiation: UInt16 = 0x0040
```

Function: Indicates that the private key can be used for signing in non-repudiation services, while the public key is used to verify signatures.

Type: UInt16

### init(UInt16)

```cangjie
public init(keys: UInt16)
```

Function: Constructs an extended key usage with specified purposes. Note that a single key can have multiple usages.

Parameters:

- keys: UInt16 - The key usage. It is recommended to use the key usage variables provided in this structure and pass parameters via bitwise OR operations.

### func toString()

```cangjie
public override func toString(): String
```

Function: Generates a key usage string.

Return Value:

- String - The certificate key usage string.

## struct SerialNumber

```cangjie
public struct SerialNumber <: Equatable<SerialNumber> & Hashable & ToString {
    public init(length!: UInt8 = 16)
}
```

Purpose: The [SerialNumber](x509_package_structs.md#struct-serialnumber) struct represents the serial number of a digital certificate, serving as a unique identifier for the certificate. According to specifications, the length of the serial number should not exceed 20 bytes. See [rfc5280](https://www.rfc-editor.org/rfc/rfc5280) for details.

Parent types:

- Equatable<[SerialNumber](#struct-serialnumber)>
- Hashable
- ToString

### init(UInt8)

```cangjie
public init(length!: UInt8 = 16)
```

Purpose: Generates a random serial number of the specified length.

Parameters:

- length!: UInt8 - The length of the serial number in bytes, of type UInt8, with a default value of 16.

Exceptions:

- [X509Exception](./x509_package_exceptions.md#class-x509exception) - Throws an exception if length is 0 or greater than 20.

### func hashCode()

```cangjie
public override func hashCode(): Int64
```

Purpose: Returns the hash value of the certificate serial number.

Return value:

- Int64 - The result of the hash computation on the certificate serial number object.

### func toString()

```cangjie
public override func toString(): String
```

Purpose: Generates a hexadecimal string representation of the certificate serial number.

Return value:

- String - The hexadecimal string of the certificate serial number.

### operator func !=(SerialNumber)

```cangjie
public override operator func !=(other: SerialNumber): Bool
```

Purpose: Inequality comparison.

Parameters:

- other: [SerialNumber](x509_package_structs.md#struct-serialnumber) - The certificate serial number object to compare.

Return value:

- Bool - Returns true if the serial numbers are different; otherwise, returns false.

### operator func ==(SerialNumber)

```cangjie
public override operator func ==(other: SerialNumber): Bool
```

Purpose: Equality comparison.

Parameters:

- other: [SerialNumber](x509_package_structs.md#struct-serialnumber) - The certificate serial number object to compare.

Return value:

- Bool - Returns true if the serial numbers are the same; otherwise, returns false.

## struct Signature

```cangjie
public struct Signature <: Equatable<Signature> & Hashable {
}
```

Purpose: The digital certificate signature, used to verify the correctness of identity.

Parent types:

- Equatable<[Signature](#struct-signature)>
- Hashable

### prop signatureValue

```cangjie
public prop signatureValue: DerBlob
```

Purpose: Returns the binary data of the certificate signature.

Type: [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob)

### func hashCode()

```cangjie
public override func hashCode(): Int64
```

Purpose: Returns the hash value of the certificate signature.

Return value:

- Int64 - The result of the hash computation on the certificate signature object.

### operator func !=(Signature)

```cangjie
public override operator func !=(other: Signature): Bool
```

Purpose: Inequality comparison.

Parameters:

- other: [Signature](x509_package_structs.md#struct-signature) - The certificate signature to compare.

Return value:

- Bool - Returns true if the signatures are different; otherwise, returns false.

### operator func ==(Signature)

```cangjie
public override operator func ==(other: Signature): Bool
```

Purpose: Equality comparison.

Parameters:

- other: [Signature](x509_package_structs.md#struct-signature) - The certificate signature to compare.

Return value:

- Bool - Returns true if the signatures are the same; otherwise, returns false.

## struct VerifyOption

```cangjie
public struct VerifyOption {
    public var time: DateTime = DateTime.now()
    public var dnsName: String = ""
    public var roots: Array<X509Certificate> = X509Certificate.systemRootCerts()
    public var intermediates: Array<X509Certificate> = Array<X509Certificate>()
}
```

Purpose: Provides configuration options for the `x509` certificate verification function [verify](./x509_package_classes.md#func-verifyverifyoption).

### var dnsName

```cangjie
public var dnsName: String = ""
```

Purpose: The domain name to verify, empty by default. Domain verification is only performed when this is set.

Type: String

### var intermediates

```cangjie
public var intermediates: Array<X509Certificate> = Array<X509Certificate>()
```

Purpose: The intermediate certificate chain, empty by default.

Type: Array<[X509Certificate](x509_package_classes.md#class-x509certificate)>

### var roots

```cangjie
public var roots: Array<X509Certificate> = X509Certificate.systemRootCerts()
```

Purpose: The root certificate chain, defaults to the system root certificate chain.

Type: Array<[X509Certificate](x509_package_classes.md#class-x509certificate)>

### var time

```cangjie
public var time: DateTime = DateTime.now()
```

Function: Validates time, defaults to the time when the option is created.

Type: DateTime

## struct X509CertificateInfo

```cangjie
public struct X509CertificateInfo {
    public var serialNumber: SerialNumber
    public var notBefore: DateTime
    public var notAfter: DateTime
    public var subject: ?X509Name
    public var dnsNames: Array<String>
    public var emailAddresses: Array<String>
    public var IPAddresses: Array<IP>
    public var keyUsage: ?KeyUsage
    public var extKeyUsage: ?ExtKeyUsage

    public init(
        serialNumber!: ?SerialNumber = None,
        notBefore!: ?DateTime = None,
        notAfter!: ?DateTime = None,
        subject!: ?X509Name = None,
        dnsNames!: Array<String> = Array<String>(),
        emailAddresses!: Array<String> = Array<String>(),
        IPAddresses!: Array<IP> = Array<IP>(),
        keyUsage!: ?KeyUsage = None,
        extKeyUsage!: ?ExtKeyUsage = None
    )
}
```

Function: The [X509CertificateInfo](x509_package_structs.md#struct-x509certificateinfo) structure contains certificate information, including serial number, validity period, subject distinguished name, domain names, email addresses, [IP](x509_package_type.md#type-ip) addresses, key usage, and extended key usage.

### var IPAddresses

```cangjie
public var IPAddresses: Array<IP>
```

Function: Records the [IP](x509_package_type.md#type-ip) addresses of the certificate.

Type: Array\<[IP](./x509_package_type.md#type-ip)>

### var dnsNames

```cangjie
public var dnsNames: Array<String>
```

Function: Records the DNS domain names of the certificate.

Type: Array\<String>

### var emailAddresses

```cangjie
public var emailAddresses: Array<String>
```

Function: Records the email addresses of the certificate.

Type: Array\<String>

### var extKeyUsage

```cangjie
public var extKeyUsage: ?ExtKeyUsage
```

Function: Records the extended key usage of the certificate.

Type: ?[ExtKeyUsage](./x509_package_structs.md#struct-extkeyusage)

### var keyUsage

```cangjie
public var keyUsage: ?KeyUsage
```

Function: Records the key usage of the certificate.

Type: ?[KeyUsage](./x509_package_structs.md#struct-keyusage)

### var notAfter

```cangjie
public var notAfter: DateTime
```

Function: Records the expiration date of the certificate's validity period.

Type: DateTime

### var notBefore

```cangjie
public var notBefore: DateTime
```

Function: Records the start date of the certificate's validity period.

Type: DateTime

### var serialNumber

```cangjie
public var serialNumber: SerialNumber
```

Function: Records the serial number of the certificate.

Type: [SerialNumber](x509_package_structs.md#struct-serialnumber)

### var subject

```cangjie
public var subject: ?X509Name
```

Function: Records the subject distinguished name of the certificate.

Type: ?[X509Name](x509_package_classes.md#class-x509name)

### init(?SerialNumber, ?DateTime, ?DateTime, ?X509Name, Array\<String>, Array\<String>, Array\<IP>, ?KeyUsage, ?ExtKeyUsage)

```cangjie
public init(
    serialNumber!: ?SerialNumber = None,
    notBefore!: ?DateTime = None,
    notAfter!: ?DateTime = None,
    subject!: ?X509Name = None,
    dnsNames!: Array<String> = Array<String>(),
    emailAddresses!: Array<String> = Array<String>(),
    IPAddresses!: Array<IP> = Array<IP>(),
    keyUsage!: ?KeyUsage = None,
    extKeyUsage!: ?ExtKeyUsage = None
)
```

Function: Constructs an [X509CertificateInfo](x509_package_structs.md#struct-x509certificateinfo) object.

Parameters:

- serialNumber!: ?[SerialNumber](x509_package_structs.md#struct-serialnumber) - The serial number of the digital certificate. Default is None. When using the default value, the default serial number length is 128 bits.
- notBefore!: ?DateTime - The start time of the digital certificate's validity period. Default is None. When using the default value, the time defaults to the creation time of [X509CertificateInfo](x509_package_structs.md#struct-x509certificateinfo).
- notAfter!: ?DateTime - The expiration time of the digital certificate's validity period. Default is None. When using the default value, the time defaults to 1 year after notBefore.
- subject!: ?[X509Name](x509_package_classes.md#class-x509name) - The subject information of the digital certificate. Default is None.
- dnsNames!: Array\<String> - A list of domain names. Users must ensure the validity of input domain names. Default is an empty string array.
- emailAddresses!: Array\<String> - A list of email addresses. Users must ensure the validity of input emails. Default is an empty string array.
- IPAddresses!: Array\<[IP](x509_package_type.md#type-ip)> - A list of [IP](x509_package_type.md#type-ip) addresses. Default is an empty [IP](x509_package_type.md#type-ip) array.
- keyUsage!: ?[KeyUsage](x509_package_structs.md#struct-keyusage) - The key usage. Default is None.
- extKeyUsage!: ?[ExtKeyUsage](x509_package_structs.md#struct-extkeyusage) - The extended key usage. Default is None.

Exceptions:

- [X509Exception](./x509_package_exceptions.md#class-x509exception) - Thrown if the input [IP](x509_package_type.md#type-ip) address list contains invalid [IP](x509_package_type.md#type-ip) addresses.

## struct X509CertificateRequestInfo

```cangjie
public struct X509CertificateRequestInfo {
    public var subject: ?X509Name
    public var dnsNames: Array<String>
    public var emailAddresses: Array<String>
    public var IPAddresses: Array<IP>
 
    public init(
        subject!: ?X509Name = None,
        dnsNames!: Array<String> = Array<String>(),
        emailAddresses!: Array<String> = Array<String>(),
        IPAddresses!: Array<IP> = Array<IP>()
    )
}
```

Function: The [X509CertificateRequestInfo](x509_package_structs.md#struct-x509certificaterequestinfo) structure contains certificate request information, including subject distinguished name, domain names, email addresses, and [IP](x509_package_type.md#type-ip) addresses.

### var IPAddresses

```cangjie
public var IPAddresses: Array<IP>
```

Function: Records the [IP](x509_package_type.md#type-ip) addresses in the certificate signing request.

Type: Array\<[IP](./x509_package_type.md#type-ip)>

### var dnsNames

```cangjie
public var dnsNames: Array<String>
```

Function: Records the DNS domain names in the certificate signing request.

Type: Array\<String>

### var emailAddresses

```cangjie
public var emailAddresses: Array<String>
```

Function: Records the email addresses in the certificate signing request.

Type: Array\<String>

### var subject

```cangjie
public var subject: ?X509Name
```

Function: Records the subject distinguished name in the certificate signing request.

### init(?X509Name, Array\<String>, Array\<String>, Array\<IP>)

```cangjie
public init(
    subject!: ?X509Name = None,
    dnsNames!: Array<String> = Array<String>(),
    emailAddresses!: Array<String> = Array<String>(),
    IPAddresses!: Array<IP> = Array<IP>()
)
```

Function: Constructs an [X509CertificateRequestInfo](x509_package_structs.md#struct-x509certificaterequestinfo) object.

Parameters:

- subject!: ?[X509Name](x509_package_classes.md#class-x509name) - The subject information of the digital certificate. Default is None.
- dnsNames!: Array\<String> - A list of domain names. Users must ensure the validity of input domain names. Default is an empty string array.
- emailAddresses!: Array\<String> - A list of email addresses. Users must ensure the validity of input emails. Default is an empty string array.
- IPAddresses!: Array\<[IP](x509_package_type.md#type-ip)> - A list of [IP](x509_package_type.md#type-ip) addresses. Default is an empty [IP](x509_package_type.md#type-ip) array.

Exceptions:

- [X509Exception](./x509_package_exceptions.md#class-x509exception) - Thrown if the input [IP](x509_package_type.md#type-ip) address list contains invalid [IP](x509_package_type.md#type-ip) addresses.
