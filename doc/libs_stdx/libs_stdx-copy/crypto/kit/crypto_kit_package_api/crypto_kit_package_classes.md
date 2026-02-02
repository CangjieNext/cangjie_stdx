# 类

## class DefaultCryptoKit

```cangjie
public class DefaultCryptoKit <: CryptoKit
```

功能：[CryptoKit](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-cryptokit) 的默认实现。提供随机数生成器及解码 DER、PEM 的能力。

父类型：

- [CryptoKit](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-cryptokit)

> **说明：**
>
> PEM 是一种基于 Base64 的编码格式。

### func certificateFromDer(DerBlob)

```cangjie
func certificateFromDer(encoded: DerBlob): Certificate
```

功能：将证书从 DER 格式解码。

参数：

- encoded: [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - 待解码的 DerBlob 对象。

返回值：

- [Certificate](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-certificate) - 解码得到的证书。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 编码文件中无有效信息时抛出异常。
- [X509Exception](../../x509/x509_package_api/x509_package_exceptions.md#class-x509exception) - 解码失败时抛出异常。

### func certificateFromPem(String)

```cangjie
func certificateFromPem(text: String): Array<Certificate>
```

功能：将证书从 PEM 格式解码。

参数：

- text: String - 待解码的 PEM 格式字符串。

返回值：

- Array\<[Certificate](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-certificate)> - 解码得到的证书集合。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 编码文件中无有效信息时抛出异常。
- [X509Exception](../../x509/x509_package_api/x509_package_exceptions.md#class-x509exception) - 解码失败时抛出异常。

### func dhParametersFromDer(DerBlob)

```cangjie
func dhParametersFromDer(encoded: DerBlob): DHParameters
```

功能：将 DH 密钥参数从 DER 格式解码。

参数：

- encoded: [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - 待解码的 DerBlob 对象。

返回值：

- [DHParameters](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-dhparameters) - 解码得到的 DH 密钥参数。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 编码文件中无有效信息时抛出异常。
- [X509Exception](../../x509/x509_package_api/x509_package_exceptions.md#class-x509exception) - 解码失败时抛出异常。

### func dhParametersFromPem(String)

```cangjie
func dhParametersFromPem(text: String): DHParameters
```

功能：将 DH 密钥参数从 PEM 格式解码。

参数：

- text: String - 待解码的 PEM 格式字符串。

返回值：

- [DHParameters](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-dhparameters) - 解码得到的 DH 密钥参数。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 编码文件中无有效信息时抛出异常。
- [X509Exception](../../x509/x509_package_api/x509_package_exceptions.md#class-x509exception) - 解码失败时抛出异常。

### func getRandomGen()

```cangjie
func getRandomGen(): RandomGenerator
```

功能：获取随机数生成器。

返回值：

- [RandomGenerator](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-randomgenerator) - 随机数生成器。

### func privateKeyFromDer(DerBlob)

```cangjie
func privateKeyFromDer(encoded: DerBlob): PrivateKey
```

功能：将私钥从 DER 格式解码。

参数：

- encoded: [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - 待解码的 DerBlob 对象。

返回值：

- [PrivateKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-privatekey) - 解码得到的私钥。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 编码文件中无有效信息时抛出异常。
- [X509Exception](../../x509/x509_package_api/x509_package_exceptions.md#class-x509exception) - 解码失败时抛出异常。

### func privateKeyFromDer(DerBlob, ?String)

```cangjie
func privateKeyFromDer(encoded: DerBlob, password!: ?String): PrivateKey
```

功能：将私钥从 DER 格式解密解码。密码为 None 时则不解密。

参数：

- encoded: [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - 待解密解码的 DerBlob 对象。
- password!: ?String - 解密密码。

返回值：

- [PrivateKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-privatekey) - 解密解码得到的私钥。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 编码文件中无有效信息时抛出异常。
- [X509Exception](../../x509/x509_package_api/x509_package_exceptions.md#class-x509exception) - 解码失败时抛出异常。

### func privateKeyFromPem(String)

```cangjie
func privateKeyFromPem(text: String): PrivateKey
```

功能：将私钥从 PEM 格式解码。

参数：

- text: String - 待解码的 PEM 格式字符串。

返回值：

- [PrivateKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-privatekey) - 解码得到的私钥。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 编码文件中无有效信息时抛出异常。
- [X509Exception](../../x509/x509_package_api/x509_package_exceptions.md#class-x509exception) - 解码失败时抛出异常。

### func privateKeyFromPem(String, ?String)

```cangjie
func privateKeyFromPem(text: String, password!: ?String): PrivateKey
```

功能：将私钥从 PEM 格式解密解码。密码为 `None` 时则不解密。

参数：

- text: String - 待解密解码的 PEM 格式字符串。
- password!: ?String - 解密密码。

返回值：

- [PrivateKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-privatekey) - 解密解码得到的私钥。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 编码文件中无有效信息时抛出异常。
- [X509Exception](../../x509/x509_package_api/x509_package_exceptions.md#class-x509exception) - 解码失败时抛出异常。

### func publicKeyFromDer(DerBlob)

```cangjie
func publicKeyFromDer(encoded: DerBlob): PublicKey
```

功能：将公钥从 DER 格式解码。

参数：

- encoded: [DerBlob](../../common/crypto_common_package_api/crypto_common_package_structs.md#struct-derblob) - 待解码的 DerBlob 对象。

返回值：

- [PublicKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-publickey) - 解码得到的公钥。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 编码文件中无有效信息时抛出异常。
- [X509Exception](../../x509/x509_package_api/x509_package_exceptions.md#class-x509exception) - 解码失败时抛出异常。

### func publicKeyFromPem(String)

```cangjie
func publicKeyFromPem(text: String): PublicKey
```

功能：将公钥从 PEM 格式解码。

参数：

- text: String - 待解码的 PEM 格式字符串。

返回值：

- [PublicKey](../../common/crypto_common_package_api/crypto_common_package_interfaces.md#interface-publickey) - 解码得到的公钥。

异常：

- [CryptoException](../../common/crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) - 编码文件中无有效信息时抛出异常。
- [X509Exception](../../x509/x509_package_api/x509_package_exceptions.md#class-x509exception) - 解码失败时抛出异常。
