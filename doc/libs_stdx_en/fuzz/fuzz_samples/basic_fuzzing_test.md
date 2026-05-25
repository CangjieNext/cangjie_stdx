# Testing Character Guessing Functionality

- Implement the API under test to throw an exception only when the input array length is 8 and its content matches the ASCII values of "Cangjie!". Under purely random conditions, the worst-case scenario would require 2<sup>64</sup> guesses to trigger the exception.
- Create a Fuzzer and invoke the API under test to initiate the main process.

```cangjie
// Import required classes
import stdx.fuzz.Fuzzer

main() {
    // Create Fuzzer and start the fuzz process
    Fuzzer(api).startFuzz()
    return 0
}


// Function under test, throws an exception when specific conditions are met, which will be caught by the Fuzzer
public func api(data: Array<UInt8>): Int32 {
    if (data.size == 8 && data[0] == b'C' && data[1] == b'a' && data[2] == b'n' && data[3] == b'g' && data[4] == b'j' &&
        data[5] == b'i' && data[6] == b'e' && data[7] == b'!') {
        throw Exception("TRAP")
    }
    return 0
}
```

> In the commands below, CANGJIE_STDX_PATH points to the directory containing the stdx series, e.g., "./static/stdx"

Linux compilation command: `cjc fuzz_main.cj -L $CANGJIE_STDX_PATH -lstdx.fuzz --import-path $CANGJIE_STDX_PATH --link-options="--whole-archive $CANGJIE_HOME/lib/linux_x86_64_cjnative/libclang_rt.fuzzer_no_main.a -no-whole-archive -lstdc++" --sanitizer-coverage-inline-8bit-counters -lpthread`

macOS compilation command: `cjc fuzz_main.cj -L $CANGJIE_STDX_PATH -lstdx.fuzz --import-path $CANGJIE_STDX_PATH --link-options="$CANGJIE_HOME/lib/linux_x86_64_cjnative/libclang_rt.fuzzer_no_main.a -lc++" --sanitizer-coverage-inline-8bit-counters -lpthread`

Explanation:

- `link-options` are linker options. The fuzz library itself depends on the symbol `LLVMFuzzerRunDriver`, which developers need to resolve themselves.
    - The Cangjie language includes a **modified** version of libfuzzer at $CANGJIE_HOME/lib/linux_x86_64_cjnative/libclang_rt.fuzzer_no_main.a, which enhances the standard libfuzzer. See [Experimental Feature - Coverage Information Printing](./print_coverage.md).
    - You can use `find $(clang -print-runtime-dir) -name "libclang_rt.fuzzer_no_main*.a"` to locate the locally installed static library file.
- For Linux compilation, `whole-archive libfuzzer.a` is required because when cjc invokes the ld backend, the order from left to right is `libfuzzer.a`, `libcangjie-fuzz-fuzz.a`, and basic libraries like libc. This order may cause the `LLVMFuzzerRunDriver` symbol, which `libcangjie-fuzz-fuzz.a` depends on, to be unresolved. Solutions include:
    - Placing `libfuzzer.a` after `libcangjie-fuzz-fuzz.a`;
    - Using `whole-archive libfuzzer.a` to circumvent the unresolved symbol issue.
- `-lstdc++` (Linux) / `-lc++` (macOS) links the std library required by libfuzzer.
- `--sanitizer-coverage-inline-8bit-counters` is a compilation option for `cjc` that performs coverage feedback instrumentation for the current `package`. Refer to the cjc compiler manual for details.
    - Other advanced parameters include: `--sanitizer-coverage-trace-compares` (improves fuzz mutation efficiency) and `--sanitizer-coverage-pc-table` (prints coverage information after fuzzing).

> **Note:**
>
> If you are using an older Linux system version, you may encounter linker errors due to a low GLIBC version. Add `-lpthread` to the `link-options` parameter to resolve this issue.

Similar to the `libfuzzer` experience, you can run it directly. Within seconds (depending on CPU performance), a crash will be triggered, and the input data will be "Cangjie!".

Execution results:

```text
$ ./main
INFO: Seed: 246468919
INFO: Loaded 1 modules   (15 inline 8-bit counters): 15 [0x55bb7c76dcb0, 0x55bb7c76dcbf),
INFO: -max_len is not provided; libFuzzer will not generate inputs larger than 4096 bytes
INFO: A corpus is not provided, starting from an empty corpus
#2      INITED ft: 4 corp: 1/1b exec/s: 0 rss: 28Mb
#420    NEW    ft: 5 corp: 2/9b lim: 8 exec/s: 0 rss: 28Mb L: 8/8 MS: 3 CrossOver-InsertByte-InsertRepeatedBytes-
#1323   NEW    ft: 6 corp: 3/17b lim: 14 exec/s: 0 rss: 28Mb L: 8/8 MS: 3 InsertByte-InsertByte-CrossOver-
#131072 pulse  ft: 6 corp: 3/17b lim: 1300 exec/s: 65536 rss: 35Mb
#262144 pulse  ft: 6 corp: 3/17b lim: 2600 exec/s: 65536 rss: 41Mb
#295225 NEW    ft: 7 corp: 4/25b lim: 2930 exec/s: 73806 rss: 43Mb L: 8/8 MS: 2 ShuffleBytes-ChangeByte-
#514006 NEW    ft: 8 corp: 5/33b lim: 4096 exec/s: 73429 rss: 53Mb L: 8/8 MS: 1 ChangeByte-
#524288 pulse  ft: 8 corp: 5/33b lim: 4096 exec/s: 74898 rss: 53Mb
#1048576        pulse  ft: 8 corp: 5/33b lim: 4096 exec/s: 61680 rss: 78Mb
#1064377        NEW    ft: 9 corp: 6/41b lim: 4096 exec/s: 62610 rss: 79Mb L: 8/8 MS: 1 ChangeByte-
#1287268        NEW    ft: 10 corp: 7/49b lim: 4096 exec/s: 61298 rss: 90Mb L: 8/8 MS: 1 ChangeByte-
#2097152        pulse  ft: 10 corp: 7/49b lim: 4096 exec/s: 59918 rss: 128Mb
#2875430        NEW    ft: 11 corp: 8/57b lim: 4096 exec/s: 61179 rss: 165Mb L: 8/8 MS: 2 ChangeBinInt-ChangeByte-
#4194304        pulse  ft: 11 corp: 8/57b lim: 4096 exec/s: 59918 rss: 227Mb
#4208258        NEW    ft: 12 corp: 9/65b lim: 4096 exec/s: 60117 rss: 228Mb L: 8/8 MS: 3 CrossOver-CrossOver-ChangeBit-
[WARNING]: Detect uncatched exception, maybe caused by bugs, exit now
An exception has occurred:
Exception: TRAP
         at default.api(std/core::Array<...>)(/data/Cangjie/fuzz_main.cj:14)
         at _ZN7default3apiER_ZN8std$core5ArrayIhE_cc_wrapper(/data/Cangjie/fuzz_main.cj:0)
         at libfuzzerCallback(fuzz/fuzz/callback.cj:20)
[INFO]: data is: [67, 97, 110, 103, 106, 105, 101, 33]
[INFO]: crash file will stored with libfuzzer
==899957== ERROR: libFuzzer: fuzz target exited
SUMMARY: libFuzzer: fuzz target exited
MS: 1 ChangeByte-; base unit: 7d8b0108ce76a937161065eafcde95bbf3d47dbf
0x43,0x61,0x6e,0x67,0x6a,0x69,0x65,0x21,
Cangjie!
artifact_prefix='./'; Test unit written to ./crash-555e7af32a2ceb585cdd9ce810c4804e65d41cea
Base64: Q2FuZ2ppZSE=
```