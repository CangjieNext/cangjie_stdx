# Usage of the URL Parsing Function `parse`

The `parse` function is used to parse a URL string and generate a URL object. The example demonstrates parsing an address to obtain a URL object and printing its various properties.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::encoding.url.*

main(): Int64 {
    /* Call the static function URL.parse to parse the web address and obtain an object named url */
    var url = URL.parse(
        "http://www.example.com:80/path%E4%BB%93%E9%A2%89?key=value%E4%BB%93%E9%A2%89#%E4%BD%A0%E5%A5%BD")

    /* Print the component properties of the url object */
    println("url.scheme = ${url.scheme}")
    println("url.opaque = ${url.opaque}")
    println("url.userInfo = ${url.userInfo}")
    println("url.rawUserInfo = ${url.rawUserInfo}")
    println("url.host = ${url.host}")
    println("url.hostName = ${url.hostName}")
    println("url.port = ${url.port}")
    println("url.path = ${url.path}")
    println("url.rawPath = ${url.rawPath}")
    println("url.query = ${url.query.getOrThrow()}")
    println("url.rawQuery = ${url.rawQuery.getOrThrow()}")
    println("url.fragment = ${url.fragment.getOrThrow()}")
    println("url.rawfragment = ${url.rawFragment.getOrThrow()}")
    println("url = ${url}")
    return 0
}
```

Execution Result:

```text
url.scheme = http
url.opaque =
url.userInfo =
url.rawUserInfo =
url.host = www.example.com:80
url.hostName = www.example.com
url.port = 80
url.path = /path仓颉
url.rawPath = /path%E4%BB%93%E9%A2%89
url.query = key=value仓颉
url.rawQuery = key=value%E4%BB%93%E9%A2%89
url.fragment = 你好
url.rawfragment = %E4%BD%A0%E5%A5%BD
url = http://www.example.com:80/path%E4%BB%93%E9%A2%89?key=value%E4%BB%93%E9%A2%89#%E4%BD%A0%E5%A5%BD
```