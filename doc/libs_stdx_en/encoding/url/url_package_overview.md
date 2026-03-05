# cangjie_stdx::encoding.url

## Feature Description

The url package provides URL-related capabilities, including parsing various components of a URL, encoding/decoding URLs, merging URLs or paths, etc.

URL (Uniform Resource Locator) is an abbreviation for Uniform Resource Locator, which is an address used to identify the location of resources on the internet. It typically includes information such as the protocol, hostname, path, and query parameters. The protocol refers to the protocol used to access the resource (e.g., HTTP, FTP), the hostname refers to the domain name or IP address of the server where the resource is located, the path refers to the specific location of the resource, and the query parameters refer to the string used to pass parameters. The URL is the unique way to identify resources on the internet, through which various types of resources such as web pages, images, and videos can be accessed.

A URL generally follows this format:

```text
scheme://host[:port]/path[?query][#fragment]
```

Where:

- `scheme`: Protocol, such as `http`, `https`, `ftp`, etc.;
- `host`: Hostname or IP address;
- `port`: Port number, optional, defaults to the protocol's default port;
- `path`: Resource path, such as `/index.html`, `/blog/post/123`, etc.;
- `query`: Query parameters, such as `?page=2&sort=desc`, optional;
- `fragment`: Document fragment identifier, such as `#section-1`, optional.

For example, the URL format of the web address `https://www.example.com/blog/post/123?page=2&sort=desc#section-1` is:

- scheme: https
- host: `www.example.com`
- path: /blog/post/123
- query: ?page=2&sort=desc
- fragment: #section-1

Reasons and basic process for URL encoding:

URL encoding is the process of converting non-ASCII characters in a URL into a more readable ASCII character format. This is because URLs are only allowed to contain ASCII characters, and non-ASCII characters may cause URL parsing errors or transmission failures.

The basic process of URL encoding is as follows:

1. Convert the URL string into a byte array.
2. For each non-ASCII character, convert it into a UTF-8 encoded byte sequence.
3. For each byte, convert it into two hexadecimal digits.
4. Add a percent sign (%) before each hexadecimal digit.
5. Concatenate all encoded characters to form the encoded URL string.

For example, URL encoding the string "你好，世界！" results in "%E4%BD%A0%E5%A5%BD%EF%BC%8C%E4%B8%96%E7%95%8C%EF%BC%81".

## API List

### Classes

|                 Class Name                |                Function                |
| ---------------------------------------- | ------------------------------------- |
| [Form](./url_package_api/url_package_classes.md#class-form) | Form stores HTTP request parameters in key-value pairs, where the same key can correspond to multiple values, and values are stored as arrays. |
| [URL](./url_package_api/url_package_classes.md#class-url) | This class provides functions for parsing URLs and other related functions. |
| [UserInfo](./url_package_api/url_package_classes.md#class-userinfo) | UserInfo represents the username and password information in a URL. |

### Exception Classes

|               Exception Class Name              |                Function                |
| ---------------------------------------------- | ------------------------------------- |
| [UrlSyntaxException](./url_package_api/url_package_exceptions.md#class-urlsyntaxexception) | URL parsing exception class. |