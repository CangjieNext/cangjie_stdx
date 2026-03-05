# Form Construction and Usage

## Form Construction and the `get` Function

Create a Form class and use the `get` function to retrieve the value mapped to a key. In this example, the `get` function of the Form class is used to obtain the value `2` corresponding to the key `1`.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::encoding.url.*

main(): Int64 {
    var s = Form("1=2&2=3&1=2&&")
    print(s.get("1").getOrThrow())
    return 0
}
```

Execution result:

```text
2
```

## Form Construction and `get` Function Usage with Duplicate Keys

Create a Form class and use the `get` function to retrieve the value mapped to a key. In this example, the `get` function of the Form class is used to obtain the first value `%6AD` corresponding to the key `1`. The `%6A` in the value is decoded as `j`, resulting in the value `jD`.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::encoding.url.*

main(): Int64 {
    var s = Form("2=3&1=%6AD&1=2")
    /* For %6A decoded as j, calling get with duplicate keys retrieves the first value jD */
    print(s.get("1").getOrThrow())
    return 0
}
```

Execution result:

```text
jD
```

## Form Construction and Other Function Usage

Demonstrate the usage of `add`, `set`, and `clone` functions, printing the changes before and after operations.

Example:

<!-- verify -->
```cangjie
import cangjie_stdx::encoding.url.*

main(): Int64 {
    var f = Form()

    /* Add values v1 and v2 to key k */
    f.add("k", "v1")
    f.add("k", "v2")

    /* When calling the get method, the first value is retrieved */
    println(f.get("k").getOrThrow())

    /* Set the value of key k to v */
    f.set("k", "v")
    println(f.get("k").getOrThrow())
    let clone_f = f.clone()

    /* Add a key-value pair to the cloned clone_f */
    clone_f.add("k1", "v1")

    /* Retrieve value v1 via get */
    println(clone_f.get("k1").getOrThrow())

    /* The original f does not have key k1, so the default value kkk is returned */
    println(f.get("k1") ?? "kkk")
    return 0
}
```

Execution result:

```text
v1
v
v1
kkk
```