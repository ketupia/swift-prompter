#!/bin/bash
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"
source "$PROJECT_ROOT/scripts/build-environment.sh"
CONFIGURATION="${1:-debug}"
case "$CONFIGURATION" in debug|release) ;; *) echo "Usage: $0 [debug|release]" >&2; exit 2 ;; esac
swift build "${SWIFT_FLAGS[@]}" -c "$CONFIGURATION"
./scripts/package.sh "$CONFIGURATION"
open "$PROJECT_ROOT/dist/Swift Prompter.app"
