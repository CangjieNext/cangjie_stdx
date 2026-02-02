# stdx.crypto.common

## 功能介绍

crypto.common 包提供了加解密相关接口。

## API 列表

### 函数

| 函数名                                                                                                                       | 功能                         |
| ---------------------------------------------------------------------------------------------------------------------------- | ---------------------------- |
| [getGlobalCryptoKit()](./crypto_common_package_api/crypto_common_package_funcs.md#func-getglobalcryptokit)                   | 获取当前全局使用的加密套件。 |
| [setGlobalCryptoKit(CryptoKit)](./crypto_common_package_api/crypto_common_package_funcs.md#func-setglobalcryptokitcryptokit) | 设置全局使用的加密套件。     |

### 接口

| 接口名                                                                                                       | 功能                                                   |
| ------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------ |
| [Certificate](./crypto_common_package_api/crypto_common_package_interfaces.md#interface-certificate)         | 证书接口，用于适配不同的加密套件。                     |
| [CryptoKit](./crypto_common_package_api/crypto_common_package_interfaces.md#interface-cryptokit)             | 加密套件接口。提供随机数生成器及解码 DER、PEM 的能力。 |
| [DHParameters](./crypto_common_package_api/crypto_common_package_interfaces.md#interface-dhparameters)       | DH 密钥参数接口。                                      |
| [Key](./crypto_common_package_api/crypto_common_package_interfaces.md#interface-key)                         | 密钥接口。                                             |
| [PrivateKey](./crypto_common_package_api/crypto_common_package_interfaces.md#interface-privatekey)           | 私钥接口。                                             |
| [PublicKey](./crypto_common_package_api/crypto_common_package_interfaces.md#interface-publickey)             | 公钥接口。                                             |
| [RandomGenerator](./crypto_common_package_api/crypto_common_package_interfaces.md#interface-randomgenerator) | 安全随机数生成器接口。                                 |

### 结构体

| 结构体名                                                                                 | 功能                          |
| ---------------------------------------------------------------------------------------- | ----------------------------- |
| [DerBlob](./crypto_common_package_api/crypto_common_package_structs.md#struct-derblob)   | Crypto 支持配置二进制证书流。 |
| [Pem](./crypto_common_package_api/crypto_common_package_structs.md#struct-pem)           | Pem 结构体。                  |
| [PemEntry](./crypto_common_package_api/crypto_common_package_structs.md#struct-pementry) | PEM 文本格式。                |

### 异常类

| 异常类名                                                                                                 | 功能                               |
| -------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| [CryptoException](./crypto_common_package_api/crypto_common_package_exceptions.md#class-cryptoexception) | 此类为加解密出现错误时抛出的异常。 |
