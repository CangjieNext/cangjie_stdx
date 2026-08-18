#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OBJECT_SOURCE="$ROOT_DIR/src/stdx/encoding/json/json_object.cj"
PARSER_SOURCE="$ROOT_DIR/src/stdx/encoding/json/native.cj"

require_pattern() {
    local pattern="$1"
    shift
    if ! rg -q "$pattern" "$@"; then
        echo "FAIL missing required pattern: $pattern" >&2
        exit 1
    fi
}

require_pattern 'func keyMayEqual\(' "$OBJECT_SOURCE"
require_pattern 'left\.size[[:space:]]*!=[[:space:]]*right\.size' "$OBJECT_SOURCE"
require_pattern 'leftRaw\[0\].*rightRaw\[0\]' "$OBJECT_SOURCE"
require_pattern 'leftRaw\[last\].*rightRaw\[last\]' "$OBJECT_SOURCE"

key_filter_uses="$(rg -c 'keyMayEqual\(' "$OBJECT_SOURCE")"
if (( key_filter_uses < 3 )); then
    echo "FAIL keyMayEqual must be defined once and used by put/get flat paths" >&2
    exit 1
fi

object_parser="$(sed -n '/^func parseJsonObject(/,/^func parseJsonArray(/p' "$PARSER_SOURCE")"
array_parser="$(sed -n '/^func parseJsonArray(/,/^func parseJsonNull(/p' "$PARSER_SOURCE")"

if rg -q 'var first|while \(requireCurrentByte\(parser\)' <<<"$object_parser"; then
    echo "FAIL parseJsonObject still uses the duplicate loop-head delimiter path" >&2
    exit 1
fi
if rg -q 'var first|while \(requireCurrentByte\(parser\)' <<<"$array_parser"; then
    echo "FAIL parseJsonArray still uses the duplicate loop-head delimiter path" >&2
    exit 1
fi
if [[ "$(rg -c 'let delimiter = requireCurrentByte\(parser\)' <<<"$object_parser")" -ne 1 ]]; then
    echo "FAIL parseJsonObject must consume one named post-value delimiter" >&2
    exit 1
fi
if [[ "$(rg -c 'let delimiter = requireCurrentByte\(parser\)' <<<"$array_parser")" -ne 1 ]]; then
    echo "FAIL parseJsonArray must consume one named post-value delimiter" >&2
    exit 1
fi

echo "PASS dom_json key and delimiter fast-path structure"
