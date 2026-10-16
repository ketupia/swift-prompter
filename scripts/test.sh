#!/bin/bash
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"
source "$PROJECT_ROOT/scripts/build-environment.sh"
# Swift 6.4's swiftbuild engine in the CLT install does not automatically find
# Swift Testing's macro plugin. Supply its installed toolchain path explicitly.
SWIFTC="$(xcrun --find swiftc)"
TESTING_PLUGINS="$(dirname "$SWIFTC")/../lib/swift/host/plugins/testing"
if [[ ! -f "$TESTING_PLUGINS/libTestingMacros.dylib" ]]; then
    echo "Swift Testing macro plugin missing at $TESTING_PLUGINS" >&2
    exit 1
fi
swift test "${SWIFT_FLAGS[@]}" -Xswiftc -plugin-path -Xswiftc "$TESTING_PLUGINS" "$@"
