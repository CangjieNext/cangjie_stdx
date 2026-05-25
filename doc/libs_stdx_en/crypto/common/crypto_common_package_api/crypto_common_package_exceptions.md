# Exception Classes

## class CryptoException

```cangjie
public class CryptoException <: Exception {
    public init()
    public init(message: String)
}
```

Function: This class represents exceptions thrown when encryption/decryption errors occur.

Parent Type:

- Exception

### init()

```cangjie
public init()
```

Function: Parameterless constructor for creating a [CryptoException](#class-cryptoexception) instance.

### init(String)

```cangjie
public init(message: String)
```

Function: Constructs a [CryptoException](#class-cryptoexception) object with the specified error message.

Parameters:

- message: String - The exception message.
