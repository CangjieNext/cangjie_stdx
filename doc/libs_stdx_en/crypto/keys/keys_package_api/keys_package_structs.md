# Structs

## struct OAEPOption

```cangjie
public struct OAEPOption {
    public init(hash: Digest, mgfHash: Digest, label!: String = "")
}
```

Function: This struct represents the parameters required for [OAEP](./keys_package_enums.md#enum-padoption) padding mode.

### init(Digest, Digest, String)

```cangjie
public init(hash: Digest, mgfHash: Digest, label!: String = "")
```

Function: Initializes OAEP padding parameters.

Parameters:

- hash: Digest - The hash method used for digesting the label.
- mgfHash: Digest - The hash method used in the MGF1 function.
- label!: String - An optional parameter (defaults to empty string) that can be set to distinguish between different encryption operations.

## struct PSSOption

```cangjie
public struct PSSOption {
    public init(saltLen: Int32)
}
```

Function: This struct represents the parameters required for [PSS](./keys_package_enums.md#enum-padoption) padding mode.

### init(Int32)

```cangjie(Int32)
public init(saltLen: Int32)
```

Function: Initializes PSS padding parameters.

Parameters:

- saltLen: Int32 - The length of random salt (in bytes). Should be greater than or equal to 0 and less than or equal to (RSA length - digest length - 2). Excessive length may cause signature failure.

Exceptions:

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - Thrown when salt length is less than 0.
