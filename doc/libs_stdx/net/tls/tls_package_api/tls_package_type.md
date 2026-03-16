# 类型别名

## type KeylessDecryptFunc

```cangjie
public type KeylessDecryptFunc = (cipherText: Array<Byte>) -> Array<Byte> 
```

功能：供无私钥握手使用的解密回调函数类型。

示例：
<!-- associated_example -->
参见 [static func server](./tls_package_classes.md#static-func-serverstreamingsocket-tlsserversession-keylesstlsserverconfig) 示例。

## type KeylessSignFunc

```cangjie
public type KeylessSignFunc = (hashValue: Array<Byte>) -> Array<Byte>
```

功能：供无私钥握手使用的签名回调函数类型。

示例：
<!-- associated_example -->
参见 [static func server](./tls_package_classes.md#static-func-serverstreamingsocket-tlsserversession-keylesstlsserverconfig) 示例。
