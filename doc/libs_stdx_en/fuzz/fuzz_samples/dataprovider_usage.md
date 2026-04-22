# Testing with DataProvider Functionality

In addition to testing APIs using byte streams, the fuzz package provides the `FuzzDataProvider` class, which offers a more user-friendly way to generate standard Cangjie data types from mutated data sources, facilitating API testing.

```cangjie
public func api2(dp: FuzzDataProvider): Int32 {
    if(dp.consumeBool() && dp.consumeByte() == b'A' && dp.consumeUint32() == 0xdeadbeef){
        throw Exception("TRAP")
    }
    return 0
}
```

In this example, enabling `--sanitizer-coverage-trace-compares` can significantly improve fuzzing efficiency.

In DataProvider mode, it's not straightforward to determine the return values of various APIs. Therefore, `Fuzzer.enableDebugDataProvider()` and `DebugDataProvider` are provided. Calling `enableDebugDataProvider()` before `startFuzz` will enable logging for each `consumeXXX` call during the fuzzing session.

For instance, after the above code triggers an exception, recompiling with `enableDebugDataProvider` added produces the following effect:

```cangjie
import stdx.fuzz.*

main() {
    let fuzzer = Fuzzer(api2)
    fuzzer.enableDebugDataProvider()
    fuzzer.startFuzz()
    return 0
}
```

The execution results are as follows:

```text
./main crash-d7ece8e77ff25769a5d55eb8d3093d4bace78e1b
Running: crash-d7ece8e77ff25769a5d55eb8d3093d4bace78e1b
[DEBUG] consumeBool return true
[DEBUG] consumeByte return 65
[DEBUG] consumeUInt32 return 3735928559
[WARNING]: Detect uncatched exception, maybe caused by bugs, exit now
An exception has occurred:
Exception: TRAP
         at default.api2(fuzz/fuzz::FuzzDataProvider)(/tmp/test.cj:12)
         at _ZN7default4api2EC_ZN9fuzz$fuzz16FuzzDataProviderE_cc_wrapper(/tmp/test.cj:0)
         at libfuzzerCallback(fuzz/fuzz/callback.cj:0)
[INFO]: data is: [191, 65, 239, 190, 173, 222]
```