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

require_pattern 'SMALL_JSON_ARRAY_CAPACITY[^=]*=[[:space:]]*8' "$OBJECT_SOURCE"
require_pattern 'flatItems:[[:space:]]*Array<JsonValue>' "$OBJECT_SOURCE"
require_pattern 'listItems:[[:space:]]*\?ArrayList<JsonValue>' "$OBJECT_SOURCE"
require_pattern 'promoteToListItems' "$OBJECT_SOURCE"
require_pattern 'isFlatStorage' "$OBJECT_SOURCE" "$WRITER_SOURCE" "$TO_JSON_SOURCE"
require_pattern 'getFlatItemsForRead' "$OBJECT_SOURCE" "$WRITER_SOURCE" "$TO_JSON_SOURCE"
require_pattern 'getListItemsForRead' "$OBJECT_SOURCE" "$WRITER_SOURCE" "$TO_JSON_SOURCE"

array_source="$(sed -n '/public class JsonArray/,/public class JsonObject/p' "$OBJECT_SOURCE")"
empty_init="$(sed -n '/public init() {/,/^    }/p' <<<"$array_source")"
if rg -q 'ArrayList<JsonValue>\(' <<<"$empty_init"; then
    echo "FAIL JsonArray() still allocates ArrayList eagerly" >&2
    exit 1
fi

echo "PASS dom_json_flat_array structure"
