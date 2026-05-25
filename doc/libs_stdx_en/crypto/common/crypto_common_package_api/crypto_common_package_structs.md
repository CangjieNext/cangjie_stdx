# Structs

## struct DerBlob

```cangjie
public struct DerBlob <: Equatable<DerBlob> & Hashable {
    public init(content: Array<Byte>)
}
```

Functionality: Crypto supports configuring binary certificate streams. After users read binary certificate data and create a [DerBlob](#struct-derblob) object, it can be parsed into [X509Certificate](../../x509/x509_package_api/x509_package_classes.md#class-x509certificate) / [X509CertificateRequest](../../x509/x509_package_api/x509_package_classes.md#class-x509certificaterequest) / [PublicKey](./crypto_common_package_interfaces.md#interface-publickey) / [PrivateKey](./crypto_common_package_interfaces.md#interface-privatekey) objects.

Parent Types:

- Equatable\<[DerBlob](#struct-derblob)>
- Hashable

### prop body

```cangjie
public prop body: Array<Byte>
```

Functionality: The byte sequence within the [DerBlob](#struct-derblob) object.

Type: Array\<Byte>

### prop size

```cangjie
public prop size: Int64
```

Functionality: The size of the byte sequence in the [DerBlob](#struct-derblob) object.

Type: Int64

### init(Array\<Byte>)

```cangjie
public init(content: Array<Byte>)
```

Functionality: Constructs a [DerBlob](#struct-derblob) object.

Parameters:

- content: Array\<Byte> - The binary byte sequence.

### func hashCode()

```cangjie
public override func hashCode(): Int64
```

Functionality: Returns the hash value of the [DerBlob](#struct-derblob) object.

Return Value:

- Int64 - The result obtained after hashing the [DerBlob](#struct-derblob) object.

### operator func !=(DerBlob)

```cangjie
public override operator func !=(other: DerBlob): Bool
```

Functionality: Inequality comparison.

Parameters:

- other: [DerBlob](#struct-derblob) - The [DerBlob](#struct-derblob) object to compare.

Return Value:

- Bool - Returns true if the objects are different; otherwise, returns false.

### operator func ==(DerBlob)

```cangjie
public override operator func ==(other: DerBlob): Bool
```

Functionality: Equality comparison.

Parameters:

- other: [DerBlob](#struct-derblob) - The [DerBlob](#struct-derblob) object to compare.

Return Value:

- Bool - Returns true if the objects are identical; otherwise, returns false.

## struct Pem

```cangjie
public struct Pem <: Collection<PemEntry> & ToString {
    public Pem(private let items: Array<PemEntry>)
}
```

Functionality: The struct [Pem](#struct-pem) is a sequence of entries that can contain multiple [PemEntry](#struct-pementry) objects.

Parent Types:

- Collection\<[PemEntry](#struct-pementry)>
- ToString

### prop size

```cangjie
public override prop size: Int64
```

Functionality: The number of entries in the sequence.

Type: Int64

### Pem(Array\<PemEntry>)

```cangjie
public Pem(private let items: Array<PemEntry>)
```

Functionality: Constructs a [Pem](#struct-pem) object.

Parameters:

- items: Array\<[PemEntry](#struct-pementry)> - Multiple [PemEntry](#struct-pementry) objects.

### static func decode(String)

```cangjie
public static func decode(text: String): Pem
```

Functionality: Decodes PEM text into a sequence of entries.

Parameters:

- text: String - The PEM string.

Return Value:

- [Pem](#struct-pem) - The sequence of PEM entries.

Exceptions:

- [X509Exception](./x509_package_exceptions.md#class-x509exception) - Throws an exception when data is empty or decoding fails.

### func encode()

```cangjie
public func encode(): String
```

Functionality: Returns a PEM-formatted string. Line endings are generated according to the current operating system.

Return Value:

- String - The PEM-formatted string.

### func isEmpty()

```cangjie
public override func isEmpty(): Bool
```

Functionality: Determines whether the decoded sequence of PEM entries is empty.

Return Value:

- Bool - Returns true if the decoded sequence of PEM entries is empty; otherwise, returns false.

### func iterator()

```cangjie
public override func iterator(): Iterator<PemEntry>
```

Functionality: Generates an iterator for the decoded sequence of PEM entries.

Return Value:

- Iterator\<[PemEntry](#struct-pementry)> - The iterator for the decoded sequence of PEM entries.

### func toString()

```cangjie
public override func toString(): String
```

Functionality: Returns a string containing the labels of each entry sequence.

Return Value:

- String - A string containing the labels of each entry sequence.

## struct PemEntry

```cangjie
public struct PemEntry <: ToString {
    public static let LABEL_CERTIFICATE = "CERTIFICATE"
    public static let LABEL_X509_CRL = "X509 CRL"
    public static let LABEL_CERTIFICATE_REQUEST = "CERTIFICATE REQUEST"
    public static let LABEL_PRIVATE_KEY = "PRIVATE KEY"
    public static let LABEL_EC_PRIVATE_KEY = "EC PRIVATE KEY"
    public static let LABEL_ENCRYPTED_PRIVATE_KEY = "ENCRYPTED PRIVATE KEY"
    public static let LABEL_RSA_PRIVATE_KEY = "RSA PRIVATE KEY"
    public static let LABEL_SM2_PRIVATE_KEY = "SM2 PRIVATE KEY"
    public static let LABEL_PUBLIC_KEY = "PUBLIC KEY"
    public static let LABEL_EC_PARAMETERS = "EC PARAMETERS"
    public static let LABEL_DH_PARAMETERS = "DH PARAMETERS"
    public PemEntry(
        public let label: String,
        public let headers: Array<(String, String)>,
        public let body: ?DerBlob
    )
    public init(label: String, body: DerBlob)
}
```

Functionality: The PEM text format is commonly used to store certificates and keys. The PEM encoding structure consists of the following parts:

The first line is a utf8-encoded string composed of "-----BEGIN", a label, and "-----";
The middle part is the body, which is a printable string obtained by base64 encoding the actual binary content. For detailed PEM encoding specifications, refer to [RFC 7468](https://www.rfc-editor.org/rfc/rfc7468.html);
The last line is a utf8-encoded string composed of "-----END", a label, and "-----", as specified in [RFC 1421](https://www.rfc-editor.org/rfc/rfc1421.html).
In older versions of the PEM encoding standard, entry headers were also included between the first line and the body.

To support different user scenarios, we provide the [PemEntry](#struct-pementry) and [Pem](#struct-pem) types. [PemEntry](#struct-pementry) is used to store a single PEM basic structure.

Parent Types:

- ToString

### static let LABEL_CERTIFICATE

```cangjie
public static let LABEL_CERTIFICATE = "CERTIFICATE"
```

Functionality: Indicates the entry type is a certificate.

Type: String

### static let LABEL_CERTIFICATE_REQUEST

```cangjie
public static let LABEL_CERTIFICATE_REQUEST = "CERTIFICATE REQUEST"
```

Functionality: Indicates the entry type is a certificate signing request.

Type: String

### static let LABEL_DH_PARAMETERS

```cangjie
public static let LABEL_DH_PARAMETERS = "DH PARAMETERS"
```

Functionality: Indicates the entry type is DH key parameters.

Type: String

### static let LABEL_EC_PARAMETERS

```cangjie
public static let LABEL_EC_PARAMETERS = "EC PARAMETERS"
```

Functionality: Indicates the entry type is elliptic curve parameters.

Type: String

### static let LABEL_EC_PRIVATE_KEY

```cangjie
public static let LABEL_EC_PRIVATE_KEY = "EC PRIVATE KEY"
```

Functionality: Indicates the entry type is an elliptic curve private key.

Type: String

### static let LABEL_ENCRYPTED_PRIVATE_KEY

```cangjie
public static let LABEL_ENCRYPTED_PRIVATE_KEY = "ENCRYPTED PRIVATE KEY"
```

Functionality: Indicates the entry type is a PKCS #8 standard encrypted private key.

Type: String

### static let LABEL_PRIVATE_KEY

```cangjie
public static let LABEL_PRIVATE_KEY = "PRIVATE KEY"
```

Functionality: Indicates the entry type is a PKCS #8 standard unencrypted private key.

Type: String

### static let LABEL_PUBLIC_KEY

```cangjie
public static let LABEL_PUBLIC_KEY = "PUBLIC KEY"
```

Functionality: Indicates the entry type is a public key.

Type: String

### static let LABEL_RSA_PRIVATE_KEY

```cangjie
public static let LABEL_RSA_PRIVATE_KEY = "RSA PRIVATE KEY"
```

Functionality: Indicates the entry type is an RSA private key.

Type: String

### static let LABEL_SM2_PRIVATE_KEY

```cangjie
public static let LABEL_SM2_PRIVATE_KEY = "SM2 PRIVATE KEY"
```

Functionality: Indicates the entry type is an SM2 private key.

Type: String

### static let LABEL_X509_CRL

```cangjie
public static let LABEL_X509_CRL = "X509 CRL"
```

Functionality: Indicates the entry type is a certificate revocation list.

Type: String

### PemEntry(String, Array\<(String, String)>, ?DerBlob)

```cangjie
public PemEntry(
    public let label: String,
    public let headers: Array<(String, String)>,
    public let body: ?DerBlob
)
```

Functionality: Constructs a [PemEntry](#struct-pementry) object.

Parameters:

- label: String - The label.
- headers: Array\<(String, String)> - The entry headers.
- body: ?[DerBlob](#struct-derblob) - The binary content.

### let body

```cangjie
public let body: ?DerBlob
```

Functionality: The binary content of the [PemEntry](#struct-pementry) instance.

Type: ?[DerBlob](#struct-derblob)

### let headers

```cangjie
public let headers: Array<(String, String)>
```

Functionality: The entry headers of the [PemEntry](#struct-pementry) instance.

Type: Array\<(String, String)>

### let label

```cangjie
public let label: String
```

Functionality: The label of the [PemEntry](#struct-pementry) instance.

Type: String

### init(String, DerBlob)

```cangjie
public init(label: String, body: DerBlob)
```

Functionality: Constructs a [PemEntry](#struct-pementry) object.

Parameters:

- label: String - The label.
- body: [DerBlob](#struct-derblob) - The binary content.

### func encode()

```cangjie
public func encode(): String
```

Function: Returns a string in PEM format. Line terminators will be generated according to the current operating system.

Return Value:

- String - A string in PEM format.

### func header(String)

```cangjie
public func header(name: String): Iterator<String>
```

Function: Finds the corresponding entry content by the entry header name.

Parameters:

- name: String - The name of the entry header.

Return Value:

- Iterator\<String> - An iterator of the content corresponding to the entry header name.

### func toString()

```cangjie
public override func toString(): String
```

Function: Returns the label of the PEM object and the length of its binary content.

Return Value:

- String - The label of the PEM object and the length of its binary content.
