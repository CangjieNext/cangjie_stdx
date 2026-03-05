# Conversion Between JsonValue and String

Below is an example demonstrating the mutual conversion between JsonValue and String. The example uses JsonValue.fromStr to convert a JSON string into a JsonValue, then prints the JsonValue object in two different formats.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::encoding.json.*

main() {
    var str = ##"[true,"kjjjke\"eed",{"sdfd":"ggggg","eeeee":[341,false,{"nnnn":55.87}]},3422,22.341,false,[22,22.22,true,"ddd"],43]"##
    var jv: JsonValue = JsonValue.fromStr(str)
    var res = jv.toString()
    var prettyres = jv.toJsonString()
    println(res)
    println(prettyres)
}
```

Execution Result:

```text
[true,"kjjjke\"eed",{"sdfd":"ggggg","eeeee":[341,false,{"nnnn":55.87}]},3422,22.341,false,[22,22.22,true,"ddd"],43]
[
  true,
  "kjjjke\"eed",
  {
    "sdfd": "ggggg",
    "eeeee": [
      341,
      false,
      {
        "nnnn": 55.87
      }
    ]
  },
  3422,
  22.341,
  false,
  [
    22,
    22.22,
    true,
    "ddd"
  ],
  43
]
```