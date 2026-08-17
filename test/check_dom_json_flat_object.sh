#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OBJECT_SOURCE="$ROOT_DIR/src/stdx/encoding/json/json_object.cj"
WRITER_SOURCE="$ROOT_DIR/src/stdx/encoding/json/write_buffer.cj"
TO_JSON_SOURCE="$ROOT_DIR/src/stdx/encoding/json/to_json.cj"

require_pattern() {
    local pattern="$1"
    shift
    if ! rg -q "$pattern" "$@"; then
        echo "FAIL missing required pattern: $pattern" >&2
        exit 1
    fi
}

require_pattern 'SMALL_JSON_OBJECT_CAPACITY[^=]*=[[:space:]]*8' "$OBJECT_SOURCE"
require_pattern 'flatFields:[[:space:]]*Array<\(String,[[:space:]]*JsonValue\)>' "$OBJECT_SOURCE"
require_pattern 'hashFields:[[:space:]]*\?HashMap<String,[[:space:]]*JsonValue>' "$OBJECT_SOURCE"
require_pattern 'promoteToHashFields' "$OBJECT_SOURCE"
require_pattern 'isFlatStorage' "$OBJECT_SOURCE" "$WRITER_SOURCE" "$TO_JSON_SOURCE"
require_pattern 'getFlatFieldsForRead' "$OBJECT_SOURCE" "$WRITER_SOURCE" "$TO_JSON_SOURCE"
require_pattern 'getHashFieldsForRead' "$OBJECT_SOURCE" "$WRITER_SOURCE" "$TO_JSON_SOURCE"

empty_init="$(sed -n '/public init() {/,/^    }/p' "$OBJECT_SOURCE")"
if rg -q 'HashMap<String,[[:space:]]*JsonValue>\(' <<<"$empty_init"; then
    echo "FAIL JsonObject() still allocates HashMap eagerly" >&2
    exit 1
fi

echo "PASS dom_json_flat_object structure"
