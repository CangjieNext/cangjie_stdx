# Functions

## func getGlobalTlsKit()

```cangjie
public func getGlobalTlsKit(): TlsKit
```

Function: Gets the currently globally used TLS kit.

Return value:

- [TlsKit](./tls_common_package_interfaces.md#interface-tlskit) - The currently globally used TLS kit.

Exceptions:

- [TlsException](./tls_common_package_exceptions.md#class-tlsexception) - Throws an exception if no global TLS kit is set.

## func setGlobalTlsKit(TlsKit)

```cangjie
public func setGlobalTlsKit(kit: TlsKit): Unit
```

Function: Sets the globally used TLS kit.

Parameters:

- kit: [TlsKit](./tls_common_package_interfaces.md#interface-tlskit) - The global TLS kit.
