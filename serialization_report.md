# Cangjie Serialization Module Security Audit Report

**Audit Scope**: `stdx.serialization.serialization`, `stdx.encoding.json`, `stdx.encoding.json.stream`
**Date**: 2026-03-24
**Reference**: Go `encoding/json` CVE history, Java deserialization attack patterns, OWASP Top 10

---

## HIGH Severity

### HIGH-01: JsonReader No Nesting Depth Limit (DoS)

**File**: `encoding/json/stream/json_token.cj:74-109` (`JsonStateStack`), `encoding/json/stream/json_reader.cj`

**Description**: The `JsonParser` (DOM parser in `native.cj:14`) enforces `MAX_JSON_PARSE_DEPTH = 100`, but the streaming `JsonReader` has **no depth limit**. `JsonStateStack.put()` dynamically doubles the stack array without any upper bound.

**Attack Vector**:
```json
[[[[[[[[[[... 10000 layers ...]]]]]]]]]
```
When deserializing nested collection types (e.g., `ArrayList<ArrayList<...>>`) via `JsonReader`, each layer triggers `startArray()` -> `T.fromJson(r)` recursive call chain, eventually exhausting the call stack or memory.

**Affected Code**:
```cangjie
// json_token.cj:84-92
func put(v: Int64) {
    if (stacksize >= stack.size) {
        var newstack = Array<Int64>(stack.size * 2, repeat: 0)  // unlimited growth
        stack.copyTo(newstack, 0, 0, stack.size)
        stack = newstack
    }
    stack[stacksize] = v
    stacksize++
}
```

**CVE Reference**: Go CVE-2022-30635 — fixed by adding a 10000 nesting depth hard limit in `encoding/json`.

**Recommendation**: Add a depth ceiling (e.g., 1024) in `JsonStateStack.put()`, throwing `IllegalStateException` when exceeded.

---

### HIGH-02: Integer Truncation Without Range Check in DataModel Deserialization

**File**: `serialization/serialization/serializable.cj` — lines 99-104 (Int32), 132-137 (Int16), 165-170 (Int8), 198-203 (UInt64), 231-236 (UInt32), 264-269 (UInt16), 297-302 (UInt8)

**Description**: All narrow integer type `deserialize()` implementations convert from `Int64` (the internal type of `DataModelInt`) without range checking. This silently truncates or reinterprets values.

**Attack Vector**:
```
Input:  DataModelInt(0x1_0000_0000)   // 4294967296, exceeds Int32 range
Result: Int32.deserialize(dm)         // silent truncation to 0
```

Most critically, `UInt64.deserialize` reinterprets negative Int64 values:
```cangjie
// serializable.cj:198-203
case dmi: DataModelInt => UInt64(dmi.getValue())
// Int64(-1) becomes UInt64(18446744073709551615) = UInt64.MAX
```

This enables **integer overflow bypasses** in permission checks, balance calculations, etc.

**Contrast**: The same codebase's `json_deserializable.cj:70-76` correctly validates ranges for `Int32.fromJson`:
```cangjie
if (overflow || res > Int64(MAXVAL_I32) || res < Int64(MINVAL_I32)) {
    throw OverflowException("The next number is out of range for Int32.")
}
```

This inconsistency between the two deserialization APIs is dangerous — users may assume equivalent safety.

**Affected Types**: Int32, Int16, Int8, UInt64, UInt32, UInt16, UInt8

**Recommendation**: Add range validation in every narrow type's `deserialize()`, throwing `DataModelException` on overflow. Mirror the logic already present in `json_deserializable.cj`.

---

### HIGH-03: JSON Parser Out-of-Bounds Read on Truncated Input

**File**: `encoding/json/native.cj` — lines 259-321 (`parseJsonNull`, `parseJsonTrue`, `parseJsonFalse`), lines 466-497 (`parseJsonString`)

**Description**: These parsing functions increment `parser.offset` and then access `parser.data[parser.offset]` **without checking** whether `offset < size`.

**Attack Vector (parseJsonNull)**:
```
Input: "nul" (truncated)

parseJsonNull():
  offset=0: check data[0]=='n' ✓, offset++
  offset=1: check data[1]=='u' ✓, offset++
  offset=2: check data[2]=='l' ✓, offset++
  offset=3: check data[3]=='l' ← OUT OF BOUNDS (data.size=3)
```

**Attack Vector (parseJsonString)**:
```
Input: {"key": "no_closing_quote

parseJsonString():
  while (next != b'"') {
      parser.offset++
      next = parser.data[parser.offset]  // No bounds check → OOB read
  }
```

The outer `catch (_: Exception)` block (`native.cj:164`) attempts error recovery, but its `unsafe` block also accesses `parser.data` and may itself trigger OOB access.

**Risk**: Crash (DoS). Depending on the runtime's array bounds enforcement, may leak adjacent memory contents.

**Recommendation**: Check `parser.offset < parser.size` before every `parser.data[parser.offset]` access. Alternatively, use a sentinel-based approach (append a terminator byte to the data array).

---

### HIGH-04: JSON Parser Cache Array Out-of-Bounds Write

**File**: `encoding/json/native.cj:214-217` (`parseJsonObject`), `native.cj:245-246` (`parseJsonArray`)

**Description**: The parser uses a shared `cache` array sized `max(inputSize >> 1, 16)`. Each object key-value pair writes 2 entries to the cache. For deeply nested structures sharing the same cache, `cacheSize` can exceed `cache.size`.

**Attack Vector**:
```json
{"a":1,"b":2,"c":3,"d":4,...}
```
Each key-value pair occupies ~5 bytes in input but consumes 2 cache slots. For an input of length N, cache size is N/2, but the number of key-value pairs can approach N/5. In nested scenarios, cumulative cache usage exceeds the allocation.

**Affected Code**:
```cangjie
// native.cj:214-217
parser.cache[parser.cacheSize] = key        // no bounds check
parser.cache[parser.cacheSize + 1] = value  // no bounds check
parser.cacheSize += 2
```

**Risk**: Array out-of-bounds write, leading to crash or potential memory corruption.

**Recommendation**: Check `parser.cacheSize + 1 < parser.cache.size` before writes, and dynamically expand or reject input.

---

### HIGH-05: Surrogate Pair Handling Produces Invalid UTF-8

**File**: `encoding/json/native.cj:518-551` (`handleEscape`), `encoding/json/stream/json_reader.cj:412-432`

**Description**: Both parsers handle `\uXXXX` escape sequences and attempt surrogate pair decoding, but **do not validate** that the first code unit is a high surrogate (U+D800-U+DBFF) and the second is a low surrogate (U+DC00-U+DFFF).

**Affected Code** (native.cj):
```cangjie
// Catch block entered when Rune() construction fails (any reason, not just surrogate)
let num1 = UInt16.parse(str1) & 0b0000001111111111  // takes low 10 bits blindly
let num2 = UInt16.parse(str2) & 0b0000001111111111
let str = Rune((((UInt32(num1)) << 10) | (UInt32(num2))) + 0x10000).toString()
unsafe { parser.strCache.add(all: str.rawData()) }
```

**Attack Vector**:
```json
"\uD800\uD800"  (two high surrogates, no low surrogate)
```
Both are masked to low 10 bits and combined: `(0x000 << 10 | 0x000) + 0x10000 = U+10000`. This produces a valid-looking but **semantically incorrect** code point. Other malformed pairs can produce arbitrary code points in the supplementary planes.

The result is passed through `String.fromUtf8Unchecked()`, producing strings that may:
- Bypass security filters relying on character comparisons
- Cause path traversal when used as filenames
- Enable XSS when embedded in HTML

**Recommendation**: Validate high/low surrogate ranges per RFC 2781 before combining. Reject invalid surrogate pairs with `JsonException`.

---

### HIGH-06: `charToByteArr` Allows 5-6 Byte UTF-8 Sequences

**File**: `encoding/json/stream/json_reader.cj:440-474`

**Description**: The `charToByteArr` function in `JsonReader` encodes Unicode code points to UTF-8. It includes branches for 5-byte and 6-byte encodings:

```cangjie
} else if (ch <= UTF8_5_MAX) {     // 5-byte: U+200000 to U+3FFFFFF
    stringBuffer.append(UInt8(((ch >> SHIFT_24) & LOW_2_MASK) | HIGH_5_MASK))
    // ... 4 more bytes
} else {                            // 6-byte: U+4000000+
    stringBuffer.append(UInt8(((ch >> SHIFT_30) & LOW_1_MASK) | HIGH_6_MASK))
    // ... 5 more bytes
}
```

RFC 3629 restricts UTF-8 to a maximum of **4 bytes** (code points U+0000 to U+10FFFF). 5-byte and 6-byte sequences were part of the original UTF-8 proposal but have been **prohibited since 2003**.

**Risk**: Produces illegal UTF-8 sequences that bypass validators in downstream components, potentially enabling filter evasion attacks.

**Recommendation**: Remove 5-byte and 6-byte branches. Reject code points > U+10FFFF.

---

### HIGH-07: `jsonValue()` Allows Raw JSON Injection

**File**: `encoding/json/stream/json_writer.cj:50-63`

**Description**: The `jsonValue()` method on `JsonWriter` is **public** and writes an arbitrary string directly to the output stream without any JSON validation or escaping.

```cangjie
public func jsonValue(value: String): JsonWriter {
    beforeValue()
    // Writes value verbatim — no escaping, no structural validation
    unsafe { out.write(value.rawData()) }
    // or: value.rawData().copyTo(buffer, 0, curPos, value.size)
    this
}
```

It is used internally by `BigInt.toJson()` and `Decimal.toJson()` which pass safe `toString()` output. But as a public API, it allows:

```cangjie
writer.jsonValue(userControlledInput)
// If userControlledInput = "1}, \"injected\": true, {\"x\": "
// → breaks JSON structure, injects arbitrary key-value pairs
```

**CVE Reference**: Similar to Go's `json.RawMessage` but without the re-validation that Go performs during `Marshal`.

**Recommendation**: Either restrict `jsonValue()` to `protected`/internal visibility, or validate that the input is well-formed JSON before writing.

---

### HIGH-08: `readStringUnquoted()` Accepts Non-Standard JSON (Parser Differential)

**File**: `encoding/json/stream/json_reader.cj:796-836`

**Description**: When `readString()` encounters a non-`"` character, it falls through to `readStringUnquoted()`, which reads arbitrary ASCII bytes until a delimiter is found.

```cangjie
func readStringUnquoted(): String {
    // Accepts: {name: unquoted_value, count: 123abc}
    while (true) {
        if (byte == b']' || byte == b',' || byte == b'}' || ...) {
            return sb.toString()
        }
    }
}
```

This accepts **non-RFC-8259-compliant** JSON input. In microservice architectures where multiple parsers process the same data, differing interpretations of the same input (**parser differential**) is a well-documented attack vector.

**Example**: An input like `{admin: true}` might be accepted by this parser but rejected by a Python/Go validator that checked the same payload earlier.

**CVE Reference**: Go `encoding/json` strictly rejects all non-standard JSON format.

**Recommendation**: Remove the `readStringUnquoted()` fallback or gate it behind an explicit opt-in `lenient` mode (default off).

---

### HIGH-09: HashMap Collision Amplification DoS

**File**: `encoding/json/stream/json_deserializable.cj:196-211`, `serialization/serialization/serializable.cj:696-709`, `encoding/json/to_json.cj:93-103`

**Description**: HashMap deserialization from JSON has **no limits** on:
- Maximum number of keys
- Initial capacity pre-sizing
- Duplicate key detection

```cangjie
// json_deserializable.cj:197-211
public static func fromJson(r: JsonReader): HashMap<String, T> {
    let result = HashMap<String, T>()  // default capacity, no size limit
    while (r.peek() != EndObject) {
        key = (r.readName() as String).getOrThrow()
        value = T.fromJson(r)
        result.add(key, value)  // unbounded insertion
    }
}
```

If Cangjie's `HashMap` does not use a randomized hash seed (similar to Go before 1.0), an attacker can pre-compute collision keys, degrading lookup to O(n) per insert and overall insertion to O(n^2).

Even with randomized hashing, the lack of size limits allows memory exhaustion via:
```json
{"k1":"v","k2":"v","k3":"v",... 10 million keys ...}
```

**CVE Reference**: Hashdos (2011), Go issue #13 — led to hash randomization in Go maps.

**Recommendation**:
1. Add a configurable maximum element count for deserialized maps/arrays.
2. Pre-size HashMap with a capacity hint from the JSON structure when available.
3. Verify that the runtime's HashMap uses randomized hash seeds.

---

### HIGH-10: Large Array/Object Memory Exhaustion

**File**: `encoding/json/native.cj:230-257` (`parseJsonArray`), `encoding/json/stream/json_deserializable.cj:183-194`

**Description**: Neither the DOM parser nor the stream parser limits the number of elements in arrays or objects.

**Attack Vector**:
```json
[1,1,1,1,...] // 10 million elements, ~20MB input → hundreds of MB in memory
```

In `parseJsonArray`, all parsed elements are stored in `parser.cache` before being copied to `ArrayList`. The cache is allocated as `max(inputSize >> 1, 16)` — for a 20MB input, this is a 10M-element `JsonValue` array pre-allocation.

For the stream parser, `ArrayList<T>.fromJson` grows the list without limit:
```cangjie
while (r.peek() != EndArray) {
    result.add(T.fromJson(r))  // no limit
}
```

**CVE Reference**: Go CVE-2022-30630 — excessive memory allocation via deeply nested or large JSON structures.

**Recommendation**: Add configurable limits for maximum array size, maximum object key count, and maximum total input size.

---

## MEDIUM Severity

### MED-01: Float64 Implicit Precision Loss from DataModelInt

**File**: `serialization/serialization/serializable.cj:330-336`

**Description**: `Float64.deserialize` silently accepts `DataModelInt` and converts:

```cangjie
case dmi: DataModelInt => Float64(dmi.getValue())
```

`Float64` can only exactly represent integers up to 2^53. Values above this threshold lose precision silently. For example, `9007199254740993` (2^53+1) becomes `9007199254740992.0`.

This can cause ID collisions, signature verification failures, or financial calculation errors.

Note: `Float32.deserialize` and `Float16.deserialize` do **not** accept DataModelInt, making this behavior inconsistent.

**Recommendation**: Either remove the implicit conversion or document it prominently and add a precision check that throws when the integer exceeds 2^53.

---

### MED-02: `DataModelStruct.get()` Returns Null for Missing Keys

**File**: `serialization/serialization/data_model.cj:283-290`

**Description**: When a key is not found, `get()` returns `DataModelNull()` instead of throwing an exception or returning `Option`.

```cangjie
public func get(key: String): DataModel {
    for (fie in fields) {
        if (fie.getName() == key) { return fie.getData() }
    }
    return DataModelNull()  // silently returns null for missing key
}
```

This makes it impossible to distinguish between "field exists with null value" and "field does not exist". When the result is passed to `Option<T>.deserialize`, the missing field is silently treated as `None`, bypassing required-field validation.

**Recommendation**: Change return type to `Option<DataModel>` or throw `DataModelException` for missing keys.

---

### MED-03: `htmlSafe` Defaults to `false` — XSS Risk

**File**: `encoding/json/stream/json_writer.cj:315-329`

**Description**: Both `WriteConfig.compact` and `WriteConfig.pretty` set `htmlSafe` to `false` by default. When serializing strings containing `<script>alert(1)</script>`, the characters `<`, `>`, `&` are **not escaped**.

```cangjie
public static let compact: WriteConfig = WriteConfig(
    _htmlSafe: false,  // <, >, & not escaped
    ...
)
```

If the JSON output is embedded in HTML (extremely common in web development), this directly enables XSS.

**CVE Reference**: Go `encoding/json.Marshal` escapes `<`, `>`, `&` **by default** since Go 1.7. Developers must explicitly call `SetEscapeHTML(false)` to disable it.

**Recommendation**: Change default to `htmlSafe: true`. This is a breaking change but significantly improves security posture for web use cases.

---

### MED-04: `DataModelSeq` / `DataModelStruct` Unbounded Size

**File**: `serialization/serialization/data_model.cj:164-212` (DataModelSeq), `data_model.cj:217-291` (DataModelStruct)

**Description**: `DataModelSeq.add()` and `DataModelStruct.add()` impose no element count limits. Combined with `DataModel.fromJson()` (`to_json.cj:78-103`) which recursively builds the DataModel tree from `JsonValue`, an attacker can cause unbounded memory allocation.

**Recommendation**: Provide configurable size limits or document the need for input validation.

---

### MED-05: `toJson()`/`toJsonString()` Recursive Serialization Without Depth Protection

**File**: `encoding/json/write_buffer.cj:226-293` (`jsonWriteObject`, `jsonWriteArray`)

**Description**: `jsonWriteObject` and `jsonWriteArray` call each other recursively without depth tracking. Since `JsonObject`/`JsonArray` use reference semantics, circular references are possible:

```cangjie
let a = JsonArray()
let b = JsonArray()
a.add(b)
b.add(a)  // circular reference
a.toJsonString()  // → stack overflow
```

**Recommendation**: Add depth tracking with a configurable maximum (e.g., 1000).

---

### MED-06: `Field.data` Is Public Mutable — Encapsulation Breach

**File**: `serialization/serialization/data_model.cj:302`

**Description**: The `Field` class exposes `data` as a public mutable field:

```cangjie
public class Field {
    private var name: String
    var data: DataModel  // NOT private — externally mutable
}
```

Any code holding a reference to a `Field` (e.g., via `DataModelStruct.getFields()`) can modify the data after validation, creating a TOCTOU (time-of-check-time-of-use) vulnerability.

**Recommendation**: Make `data` private and provide only a getter, or make it `let` (immutable).

---

### MED-07: `getItems()` / `getFields()` Return Mutable Internal References

**File**: `serialization/serialization/data_model.cj:198-200`, `data_model.cj:251-253`

**Description**: These methods return the internal `ArrayList` directly:

```cangjie
public func getItems(): ArrayList<DataModel> {
    return items  // caller can freely add/remove elements
}
```

Callers can bypass `DataModelStruct.add()`'s deduplication logic by directly calling `list.add()`. The `to_json.cj:80,95` code already exploits this pattern:

```cangjie
let list: ArrayList<Field> = dms.getFields()
list.add(field)  // bypasses DataModelStruct.add() deduplication
```

**Recommendation**: Return a read-only view or defensive copy.

---

### MED-08: NaN / Infinity Not Handled in Float Serialization

**File**: `encoding/json/write_buffer.cj:111-135`, `encoding/json/json_object.cj:242-331`

**Description**: `DataModelFloat` and `JsonFloat` accept `NaN`, `+Infinity`, `-Infinity` without validation. These values are **not valid JSON** per RFC 8259.

When serialized, the output (e.g., `NaN`, `Infinity`) will be rejected by standards-compliant JSON parsers in other languages (Python `json.loads`, Go `json.Unmarshal`).

**CVE Reference**: Go `encoding/json.Marshal` returns an error for NaN/Infinity values.

**Recommendation**: Throw an exception when constructing `DataModelFloat`/`JsonFloat` with NaN or Infinity, or provide a configuration option for handling.

---

### MED-09: Overly Broad Exception Catch in JSON Parser

**File**: `encoding/json/native.cj:164`

**Description**: The `parseJson` function catches all `Exception` types:

```cangjie
} catch (_: Exception) {
    unsafe {
        // Error recovery code that itself accesses parser.data
    }
}
```

This swallows critical system exceptions (OutOfMemoryError, StackOverflowError) and re-wraps them as `JsonException`, masking the root cause. The error recovery code runs in an `unsafe` block using potentially invalid parser state.

**Recommendation**: Catch only `JsonException` or add specific exception types. Re-throw system-critical exceptions.

---

### MED-10: Native Function TOCTOU in WriteBuffer

**File**: `encoding/json/write_buffer.cj:158-181`

**Description**: `appendEscape()` calls two native functions sequentially:
1. `CJ_JSON_StringEscapeCharNumGet()` — calculates the extra bytes needed
2. `CJ_JSON_ReplaceEscapeChar()` — performs the actual escape

The buffer is sized based on step 1, but if step 2 writes more bytes than predicted (due to a native code bug or a race condition on the input string), a **buffer overflow** occurs.

We cannot audit the native (C/C++) implementations from this codebase, but this "calculate-size-then-write" pattern is a classic TOCTOU attack surface.

**Recommendation**: Audit the corresponding native code. Consider a single native function that both calculates and writes, or add a bounds check after the write.

---

### MED-11: Duplicate Key Parser Differential Risk

**File**: `serialization/serialization/data_model.cj:263-273`, `encoding/json/to_json.cj:93-103`

**Description**: `DataModelStruct.add()` deduplicates keys (overwrites existing), but `buildDMStruct` in `to_json.cj` bypasses this by directly operating on the internal list:

```cangjie
let list: ArrayList<Field> = dms.getFields()  // internal reference
list.add(field)  // direct add, no dedup check
```

While `JsonObject` uses `HashMap` (no dup keys at source), the inconsistency means future code paths could produce `DataModelStruct` with duplicate keys. When serialized back to JSON, duplicate keys cause different behavior in different parsers ("first wins" vs. "last wins"), enabling **parser differential attacks** in multi-service architectures.

**Recommendation**: Enforce deduplication at the `DataModelStruct` level regardless of the entry point.

---

### MED-12: No `DisallowUnknownFields` Mechanism

**File**: Framework design, documentation examples

**Description**: The framework's documented deserialization pattern silently ignores unknown fields:

```cangjie
// From official documentation sample
while (r.peek() != EndObject) {
    let n = r.readName()
    match (n) {
        case "key1" => res.key1 = r.readValue<Option<String>>()
        case "key2" => res.key2 = r.readValue<Bool>()
        case _ => ()  // unknown fields silently ignored
    }
}
```

This allows attackers to inject arbitrary extra fields without detection. In security-sensitive contexts (e.g., access control tokens, configuration files), unknown fields should be rejected.

**CVE Reference**: Go added `json.Decoder.DisallowUnknownFields()` as a strict mode.

**Recommendation**: Provide a framework-level strict mode or document the security implications. Ensure examples show `r.skip()` for unknown fields at minimum.

---

### MED-13: Serialize/Deserialize Asymmetry Not Enforced

**File**: Framework design (`serializable.cj`, `json_serializable.cj`, `json_deserializable.cj`)

**Description**: The `Serializable<T>` interface requires both `serialize()` and `deserialize()`, but there is no compile-time or runtime mechanism to verify that they are **symmetric** — i.e., that `deserialize(serialize(obj)) == obj`.

Users must manually maintain consistency between the field sets read during deserialization and written during serialization. In distributed systems with rolling upgrades, version skew can silently cause data loss when:
- A new field is added to `serialize()` but not yet to `deserialize()` on old nodes
- A field is renamed in one direction but not the other

**Recommendation**: Document this risk prominently. Consider providing a test utility that verifies round-trip consistency.

---

## LOW Severity

### LOW-01: Non-Standard JSON Number Systems (Binary/Octal/Hex)

**File**: `encoding/json/native.cj:351-372` (`parseNumberSystem`), `encoding/json/stream/json_reader.cj:1051-1076`

**Description**: Both parsers accept `0b` (binary), `0o` (octal), `0x` (hex), `0d` (explicit decimal) number prefixes, which are **not part of JSON** (RFC 8259 only allows decimal numbers).

```cangjie
// native.cj:358-369
case 'b' | 'B' => return Binary
case 'o' | 'O' => return Octal
case 'x' | 'X' => return Hex
```

Accepting non-standard input increases the attack surface and can cause interoperability issues where different parsers produce different values for the same input.

**Recommendation**: Remove non-standard number system support or gate it behind an explicit opt-in flag.

---

### LOW-02: `Array<T>.deserialize` Deserializes First Element Twice

**File**: `serialization/serialization/serializable.cj:577`

**Description**:

```cangjie
let arr: Array<T> = Array<T>(dataSize, repeat: T.deserialize(data[0]))
for (i in 1..dataSize) {
    arr[i] = T.deserialize(data[i])
}
```

`data[0]` is deserialized once as the `repeat` parameter (filling the entire array) and the result is then overwritten for indices 1..N. If `T.deserialize` has side effects (resource allocation, counter increment, external state mutation), the first element's side effects fire **twice**.

**Recommendation**: Use a different array initialization pattern that does not require deserializing the first element as a fill value.

---

### LOW-03: `WriteBuffer` Capacity Estimation Imprecise

**File**: `encoding/json/write_buffer.cj:295-316` (`asumecapacity`)

**Description**: The capacity estimation for `JsonFloat` is hardcoded to 200 bytes (with a comment "not precision"). For JSON with many floats, this over-allocates; for few floats in large structures, it under-allocates causing frequent resizing.

```cangjie
case _: JsonFloat => return 200 // not precision
```

**Risk**: Performance degradation (not a security issue per se, but repeated reallocation under attacker-controlled input can contribute to DoS).

**Recommendation**: Use a more realistic estimate (e.g., 25 bytes) or measure actual output sizes.

---

### LOW-04: HashMap Serialization Runtime Type Check Instead of Compile-Time

**File**: `serialization/serialization/serializable.cj:664-710`

**Description**: `HashMap<K, V>.serialize()` checks at **runtime** whether `K` is `String`:

```cangjie
match (k) {
    case k: String => dms.add(field<V>(k, v))
    case _ => throw DataModelException("This data is not String.")
}
```

The generic constraint only requires `K <: Serializable<K> & Hashable & Equatable<K>`, so `HashMap<Int64, String>` compiles successfully but always throws at runtime.

**Contrast**: `JsonDeserializable` correctly constrains `HashMap<String, T>` at the type level.

**Recommendation**: Change the `extend` to `HashMap<String, V>` to catch the error at compile time.

---

### LOW-05: Widespread Use of `String.fromUtf8Unchecked`

**File**: `native.cj:338,490,493`, `json_reader.cj:822,828,883,887`, `json_object.cj:384,397,533,560,739,766` — approximately 20+ locations

**Description**: `String.fromUtf8Unchecked` is used extensively across the JSON parsing and serialization pipeline. Each usage assumes that prior validation guarantees valid UTF-8. If any upstream validation has a bug (e.g., the surrogate pair issue in HIGH-05 or the 5-6 byte UTF-8 issue in HIGH-06), the resulting invalid string propagates through the entire application.

**Recommendation**: At minimum, add debug-mode assertions that validate UTF-8 at `fromUtf8Unchecked` call sites. Consider using checked `fromUtf8` at parser boundaries (where data first enters from external sources) and only using `Unchecked` for internal transformations where validity is structurally guaranteed.

---

### LOW-06: Documentation Examples Encourage Unsafe Patterns

**File**: Official documentation samples (`sample_json_reader.md`)

**Description**: The documented deserialization pattern uses `case _ => ()` for unknown fields without calling `r.skip()`. When the unknown field's value is a nested object or array, not calling `skip()` leaves it unconsumed, corrupting the `JsonReader` state machine. The next `readName()` call will read the value data instead of the next key name.

```cangjie
// From documentation — problematic pattern:
case _ => ()  // should be: case _ => r.skip()
```

**Recommendation**: Update documentation to always use `r.skip()` for unknown fields, and add a warning about state corruption.

---

### LOW-07: Error Messages May Leak Sensitive Input Data

**File**: `encoding/json/native.cj:144,174`

**Description**: Parse error messages include fragments of the input data:

```cangjie
let errMsg = "Parse Error: [Line]: ${errRowAndCol[0]}, [Pos]: ${errRowAndCol[1]}, " +
    "[Error]: Unexpected character: '${errStr}'."
```

If the JSON input contains sensitive data (tokens, passwords, PII), the error message may leak these values through logging or error responses.

**Recommendation**: Limit error messages to position information without echoing input content, or truncate/redact the echoed character.

---

## Summary

| Severity | Count | Key Themes |
|----------|-------|------------|
| **HIGH** | 10 | Parser OOB, integer overflow, DoS, injection, invalid UTF-8 |
| **MEDIUM** | 13 | Precision loss, XSS, encapsulation breach, NaN, TOCTOU |
| **LOW** | 7 | Non-standard input, side effects, documentation issues |
| **Total** | **30** | |

### Priority Fix Order

**P0 — Immediate** (memory safety, data integrity):
- HIGH-03: Parser OOB reads on truncated input
- HIGH-04: Parser cache OOB writes
- HIGH-02: Integer truncation without range check
- HIGH-05: Surrogate pair validation
- HIGH-06: Remove 5-6 byte UTF-8 encoding

**P1 — Current Release** (DoS, injection):
- HIGH-01: Add depth limit to JsonReader
- HIGH-07: Restrict `jsonValue()` visibility/validation
- HIGH-08: Remove or gate `readStringUnquoted()`
- HIGH-09: Add HashMap size limits
- HIGH-10: Add array/object element limits
- MED-03: Change htmlSafe default to true

**P2 — Next Release** (design improvements):
- MED-02, MED-06, MED-07: Improve DataModel encapsulation
- MED-08: Handle NaN/Infinity
- MED-12: Add strict mode for unknown fields
- LOW-01: Remove non-standard number systems
- LOW-05: Reduce unsafe UTF-8 usage at boundaries
