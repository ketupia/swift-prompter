#!/bin/bash
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"
source "$PROJECT_ROOT/scripts/build-environment.sh"
CONFIGURATION="${1:-debug}"
case "$CONFIGURATION" in debug|release) ;; *) echo "Usage: $0 [debug|release]" >&2; exit 2 ;; esac
BIN_DIR="$(swift build "${SWIFT_FLAGS[@]}" -c "$CONFIGURATION" --show-bin-path)"
APP="$PROJECT_ROOT/dist/Swift Prompter.app"
if [[ ! -x "$BIN_DIR/SwiftPrompter" ]]; then
    echo "Executable missing. Run swift build -c $CONFIGURATION first." >&2
    exit 1
fi
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN_DIR/SwiftPrompter" "$APP/Contents/MacOS/SwiftPrompter"
# SwiftPM puts package resources in a bundle beside the executable; Bundle.module looks for it in Contents/Resources.
rm -rf "$APP/Contents/Resources/SwiftPrompter_SwiftPrompter.bundle"
cp -R "$BIN_DIR/SwiftPrompter_SwiftPrompter.bundle" "$APP/Contents/Resources/"
cp Resources/Info.plist "$APP/Contents/Info.plist"
printf 'APPL????' > "$APP/Contents/PkgInfo"
plutil -lint "$APP/Contents/Info.plist"
# A stable designated requirement keeps the local TCC identity consistent across rebuilds.
# This is local ad hoc signing, without hardened runtime or a developer certificate.
codesign --force --sign - --identifier com.ketupia.swiftprompter \
    --requirements '=designated => identifier "com.ketupia.swiftprompter"' "$APP"
codesign --verify --strict --verbose=2 "$APP"
echo "$APP"
