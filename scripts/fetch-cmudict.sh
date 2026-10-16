#!/bin/bash
# Downloads cmudict.dict and its LICENSE from the CMU Sphinx repo into Sources/SwiftPrompter/Resources/cmudict/.
# Pass a commit SHA to pin a version; defaults to master. The downloaded files are data only.
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REF="${1:-master}"
DEST="$PROJECT_ROOT/Sources/SwiftPrompter/Resources/cmudict"
BASE="https://raw.githubusercontent.com/cmusphinx/cmudict/$REF"
mkdir -p "$DEST"
curl -fsSL -o "$DEST/cmudict.dict" "$BASE/cmudict.dict"
curl -fsSL -o "$DEST/LICENSE" "$BASE/LICENSE"
printf 'Source: https://github.com/cmusphinx/cmudict\nRef: %s\nFetched: %s with scripts/fetch-cmudict.sh\n' \
    "$REF" "$(date +%F)" > "$DEST/SOURCE.txt"
wc -l "$DEST/cmudict.dict"
