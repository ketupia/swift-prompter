# Sourced by the build/run scripts. Keep compiler and manifest caches in the project.
export CLANG_MODULE_CACHE_PATH="$PROJECT_ROOT/.build/clang-module-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="$PROJECT_ROOT/.build/swift-module-cache"
SWIFT_FLAGS=(--cache-path "$PROJECT_ROOT/.build/cache")
# Some confined agent environments cannot create a nested manifest sandbox.
# Normal Terminal / VS Code builds retain SwiftPM's default sandbox.
if [[ "${SWIFT_PROMPTER_DISABLE_BUILD_SANDBOX:-0}" == 1 ]]; then
    SWIFT_FLAGS+=(--disable-sandbox)
fi
