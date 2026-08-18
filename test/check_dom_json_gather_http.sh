#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WRITER_SOURCE="$ROOT_DIR/src/stdx/encoding/json/write_buffer.cj"
VALUE_SOURCE="$ROOT_DIR/src/stdx/encoding/json/json_value.cj"
BODY_SOURCE="$ROOT_DIR/src/stdx/net/http/http_body.cj"
RESPONSE_SOURCE="$ROOT_DIR/src/stdx/net/http/http_response.cj"
REQUEST_SOURCE="$ROOT_DIR/src/stdx/net/http/http_request.cj"
SERVER_SOURCE="$ROOT_DIR/src/stdx/net/http/http_server1_1.cj"
CLIENT_SOURCE="$ROOT_DIR/src/stdx/net/http/http_client1_1.cj"
CONN_SOURCE="$ROOT_DIR/src/stdx/net/http/buffered_conn.cj"

require_pattern() {
    local pattern="$1"
    shift
    if ! rg -q "$pattern" "$@"; then
        echo "FAIL missing segmented JSON/HTTP contract: $pattern" >&2
        exit 1
    fi
}

require_pattern 'class[[:space:]]+SegmentedWriteBuffer' "$WRITER_SOURCE"
require_pattern 'class[[:space:]]+JsonByteSegments' "$WRITER_SOURCE"
require_pattern 'appendUnescapedNativeFastPath' "$WRITER_SOURCE"
require_pattern 'toSegmentedBytes' "$VALUE_SOURCE"
require_pattern 'class[[:space:]]+HttpSegmentedBody' "$BODY_SOURCE"
require_pattern 'body\(segments:[[:space:]]*Array<Array<UInt8>>' "$RESPONSE_SOURCE" "$REQUEST_SOURCE"
require_pattern 'case b:[[:space:]]*HttpSegmentedBody' "$SERVER_SOURCE" "$CLIENT_SOURCE"
require_pattern 'writeGathered' "$SERVER_SOURCE" "$CLIENT_SOURCE" "$CONN_SOURCE"

echo "PASS segmented JSON/HTTP structure"
