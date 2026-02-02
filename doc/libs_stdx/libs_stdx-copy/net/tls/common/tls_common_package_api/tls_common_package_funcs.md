# 函数

## func getGlobalTlsKit()

```cangjie
public func getGlobalTlsKit(): TlsKit
```

功能：获取当前全局使用的 TLS 套件。

返回值：

- [TlsKit](./tls_common_package_interfaces.md#interface-tlskit) - 当前全局使用的 TLS 套件。

异常：

- [TlsException](./tls_common_package_exceptions.md#class-tlsexception) - 若未设置全局 TLS 套件，则会抛出异常。

## func setGlobalTlsKit(TlsKit)

```cangjie
public func setGlobalTlsKit(kit: TlsKit): Unit
```

功能：设置全局使用的 TLS 套件。

参数：

- kit: [TlsKit](./tls_common_package_interfaces.md#interface-tlskit) - 全局 TLS 套件。
