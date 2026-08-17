#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
JSON_DIR="$ROOT_DIR/src/stdx/encoding/json"

require_pattern() {
    local pattern="$1"
    shift
    if ! rg -q "$pattern" "$@"; then
        echo "FAIL missing required pattern: $pattern" >&2
        exit 1
    fi
}

require_pattern 'isJsonObjectKeyHtmlSafe' "$JSON_DIR/json_object.cj"
require_pattern 'lastStringHtmlSafe' "$JSON_DIR/native.cj"
require_pattern 'putParsed' "$JSON_DIR/native.cj" "$JSON_DIR/json_object.cj"
require_pattern 'allKeysHtmlSafe' "$JSON_DIR/json_object.cj"
require_pattern 'getFlatFieldsForRead' "$JSON_DIR/json_object.cj" "$JSON_DIR/write_buffer.cj"
require_pattern 'getHashFieldsForRead' "$JSON_DIR/json_object.cj" "$JSON_DIR/write_buffer.cj"

if rg -q 'private var escapeClass|appendEscapeClassified|lastStringEscapeClass' \
    "$JSON_DIR/json_object.cj" "$JSON_DIR/write_buffer.cj" "$JSON_DIR/native.cj"; then
    echo "FAIL JsonString still carries per-value escape classification" >&2
    exit 1
fi

echo "PASS object_key_escape_cache structure"
