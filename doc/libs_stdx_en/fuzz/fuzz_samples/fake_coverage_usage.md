# Using FakeCoverage to Prevent Fuzz Abnormal Termination in DataProvider Mode

When linked with libfuzzer <= 14 and operating in DataProvider mode, you may encounter errors similar to the following, in which case this section should be consulted:

```text
ERROR: no interesting inputs were found. Is the code instrumented for coverage? Exiting.
```

Starting from [libfuzzer 15](https://github.com/llvm/llvm-project/commit/92fb310151d2b1e349695fc0f1c5d5d50afb3b52), this feature has been fixed - execution will not stop even if inputs are rejected during initialization.

**Note: Please verify that the tested library is indeed instrumented with coverage feedback, as this error can also occur without coverage instrumentation!**

The current fuzz backend interfaces with libfuzzer, which during startup first inputs an empty byte stream, followed by a byte stream containing only a `'\n'` to probe the target function. After these two rounds, it checks for new coverage. In DataProvider mode, if data is consumed before calling the target library's API, insufficient data length may cause early returns, leading libfuzzer to detect zero coverage information.

For example, the following code triggers this error:

Triggering code:

```cangjie
// main.cj
import stdx.fuzz.*

main() {
    let f = Fuzzer(api)
    f.disableFakeCoverage()
    f.startFuzz()
    return 0
}

// fuzz_target.cj, with sancov
public func api(dp: FuzzDataProvider): Int32 {
    if (dp.consumeBool() && dp.consumeBool()) {
        throw Exception("TRAP!")
    }
    return 0
}
```

Execution result:

```text
...
ERROR: no interesting inputs were found. Is the code instrumented for coverage? Exiting.
...
```

Therefore, Fake Coverage must be used to create artificial coverage information, making libfuzzer believe during initialization that the target module is indeed instrumented. Only after DataProvider collects sufficient data can effective fuzz testing proceed. This approach is called Fake Coverage mode.

Simply replace the `disableFakeCoverage()` in the above example with `enableFakeCoverage()` to continue execution and eventually trigger the TRAP.

Alternatively, besides using Fake Coverage mode, you can actively call certain non-critical APIs of the target function in test cases to pass coverage information to libfuzzer, which also helps sustain the fuzz process.

```cangjie
// main.cj
import stdx.fuzz.*

main() {
    let f = Fuzzer(api)
    f.enableFakeCoverage()
    f.startFuzz()
    return 0
}

// fuzz_target.cj, with sancov
public func api(dp: FuzzDataProvider): Int32 {
    if (dp.consumeBool() && dp.consumeBool()) {
        throw Exception("TRAP!")
    }
    return 0
}
```

Execution result:

```text
INFO: Running with entropic power schedule (0xFF, 100).
INFO: Seed: 3187548846
INFO: Loaded 2 modules   (8 inline 8-bit counters): 7 [0x55bf83ea8790, 0x55bf83ea8797), 1 [0x55bf83e97b00, 0x55bf83e97b01),
INFO: -max_len is not provided; libFuzzer will not generate inputs larger than 4096 bytes
INFO: A corpus is not provided, starting from an empty corpus
#2      INITED ft: 5 corp: 1/1b exec/s: 0 rss: 33Mb
#9      NEW    ft: 6 corp: 2/2b lim: 4 exec/s: 0 rss: 33Mb L: 1/1 MS: 2 CopyPart-ChangeByte-
[WARNING]: Detect uncatched exception, maybe caused by bugs, exit now
An exception has occurred:
Exception: TRAP!
...
...
```