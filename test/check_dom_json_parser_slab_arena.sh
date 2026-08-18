#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PARSER_SOURCE="$ROOT_DIR/src/stdx/encoding/json/native.cj"
OBJECT_SOURCE="$ROOT_DIR/src/stdx/encoding/json/json_object.cj"

require_pattern() {
    local pattern="$1"
    shift
    if ! rg -q "$pattern" "$@"; then
        echo "FAIL missing required pattern: $pattern" >&2
        exit 1
    fi
}

require_pattern 'class ParsedFlatStorageArena' "$PARSER_SOURCE"
require_pattern 'PARSED_FLAT_STORAGE_SLAB_CONTAINERS[^=]*=[[:space:]]*32' "$PARSER_SOURCE"
require_pattern 'func allocateObjectFields\(' "$PARSER_SOURCE"
require_pattern 'func allocateArrayItems\(' "$PARSER_SOURCE"
require_pattern '\.slice\(' "$PARSER_SOURCE"
require_pattern 'flatStorageArena.*ParsedFlatStorageArena' "$PARSER_SOURCE"
require_pattern 'JsonObject\(parser\.flatStorageArena\.allocateObjectFields\(\),[[:space:]]*0\)' "$PARSER_SOURCE"
require_pattern 'JsonArray\(parser\.flatStorageArena\.allocateArrayItems\(\),[[:space:]]*0\)' "$PARSER_SOURCE"
require_pattern 'init\(parsedFlatFields:[[:space:]]*Array<\(String,[[:space:]]*JsonValue\)>,' "$OBJECT_SOURCE"
require_pattern 'init\(parsedFlatItems:[[:space:]]*Array<JsonValue>,' "$OBJECT_SOURCE"

object_parser="$(sed -n '/^func parseJsonObject(/,/^func parseJsonArray(/p' "$PARSER_SOURCE")"
array_parser="$(sed -n '/^func parseJsonArray(/,/^func parseJsonNull(/p' "$PARSER_SOURCE")"
if rg -q 'JsonObject\(INITIAL_JSON_OBJECT_CAPACITY\)' <<<"$object_parser"; then
    echo "FAIL parsed JsonObject still allocates an independent eight-slot array" >&2
    exit 1
fi
if rg -q 'JsonArray\(INITIAL_JSON_ARRAY_CAPACITY\)' <<<"$array_parser"; then
    echo "FAIL parsed JsonArray still allocates an independent eight-slot array" >&2
    exit 1
fi

echo "PASS dom_json parser slab arena structure"
