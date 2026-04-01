# Structures

## struct OperationMode

```cangjie
public struct OperationMode <: ToString & Equatable<OperationMode> {
    public static let ECB: OperationMode
    public static let CBC: OperationMode
    public static let OFB: OperationMode
    public static let CFB: OperationMode
    public static let CTR: OperationMode
    public static let GCM: OperationMode
    public let mode: String
}
```

Function: Working modes for symmetric encryption/decryption algorithms.

Parent types:

- ToString
- Equatable\<[OperationMode](#struct-operationmode)>

### static let ECB

```cangjie
public static let ECB: OperationMode
```

Function: Electronic CodeBook working mode. The initial value of ECB is [OperationMode](crypto_package_structs.md#struct-operationmode)("ECB").

> **Note:**
>
> For block ciphers, ECB is known to be insecure. Use with caution.

Type: [OperationMode](crypto_package_structs.md#struct-operationmode)

### static let CBC

```cangjie
public static let CBC: OperationMode
```

Function: Cipher Block Chaining working mode. The initial value of CBC is [OperationMode](crypto_package_structs.md#struct-operationmode)("CBC").

Type: [OperationMode](crypto_package_structs.md#struct-operationmode)

### static let OFB

```cangjie
public static let OFB: OperationMode
```

Function: Output FeedBack working mode. The initial value of OFB is [OperationMode](crypto_package_structs.md#struct-operationmode)("OFB").

Type: [OperationMode](crypto_package_structs.md#struct-operationmode)

### static let CFB

```cangjie
public static let CFB: OperationMode
```

Function: Cipher FeedBack working mode. The initial value of CFB is [OperationMode](crypto_package_structs.md#struct-operationmode)("CFB").

Type: [OperationMode](crypto_package_structs.md#struct-operationmode)

### static let CTR

```cangjie
public static let CTR: OperationMode
```

Function: CounTeR working mode. The initial value of CTR is [OperationMode](crypto_package_structs.md#struct-operationmode)("CTR").

Type: [OperationMode](crypto_package_structs.md#struct-operationmode)

### static let GCM

```cangjie
public static let GCM: OperationMode
```

Function: Galois Counter Mode working mode. The initial value of GCM is [OperationMode](crypto_package_structs.md#struct-operationmode)("GCM").

Type: [OperationMode](crypto_package_structs.md#struct-operationmode)

### let mode

```cangjie
public let mode: String
```

Function: Specifies the block cipher working mode, currently supporting ECB, CBC, CFB, OFB, CTR, and GCM.

Type: String

### func toString()

```cangjie
public override func toString(): String
```

Function: Gets the working mode string.

Return value:

- String - The working mode string.

### func ==(OperationMode)

```cangjie
public override operator func ==(other: OperationMode): Bool
```

Function: Compares if working modes are identical.

Parameters:

- other: [OperationMode](crypto_package_structs.md#struct-operationmode) - The working mode to compare.

Return value:

- Bool - true if identical, false otherwise.

### func !=(OperationMode)

```cangjie
public override operator func !=(other: OperationMode): Bool
```

Function: Compares if working modes are different.

Parameters:

- other: [OperationMode](crypto_package_structs.md#struct-operationmode) - The working mode to compare.

Return value:

- Bool - true if different, false otherwise.

## struct PaddingMode

```cangjie
public struct PaddingMode <: Equatable<PaddingMode> {
    public static let NoPadding: PaddingMode
    public static let PKCS7Padding: PaddingMode
    public let paddingType: Int64
}
```

Function: Padding modes for symmetric encryption/decryption algorithms.

Parent types:

- Equatable\<[PaddingMode](#struct-paddingmode)>

### static let NoPadding

```cangjie
public static let NoPadding: PaddingMode
```

Function: No padding. The initial value of NoPadding is [PaddingMode](crypto_package_structs.md#struct-paddingmode)(0).

Type: [PaddingMode](crypto_package_structs.md#struct-paddingmode)

### static let PKCS7Padding

```cangjie
public static let PKCS7Padding: PaddingMode
```

Function: PKCS7 protocol padding. The initial value of PKCS7Padding is [PaddingMode](crypto_package_structs.md#struct-paddingmode)(1).

Type: [PaddingMode](crypto_package_structs.md#struct-paddingmode)

### let paddingType

```cangjie
public let paddingType: Int64
```

Function: Specifies the block cipher padding method, currently supporting no padding and PKCS7 padding.

Type: Int64

### func ==(PaddingMode)

```cangjie
public override operator func ==(other: PaddingMode): Bool
```

Function: Compares if padding modes are identical.

Parameters:

- other: [PaddingMode](crypto_package_structs.md#struct-paddingmode) - The padding mode to compare.

Return value:

- Bool - true if identical, false otherwise.

### func !=(PaddingMode)

```cangjie
public override operator func !=(other: PaddingMode): Bool
```

Function: Compares if padding modes are different.

Parameters:

- other: [PaddingMode](crypto_package_structs.md#struct-paddingmode) - The padding mode to compare.

Return value:

- Bool - true if different, false otherwise.