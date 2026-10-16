# Swift Prompter

A native macOS teleprompter scaffold using SwiftUI, AppKit, and Apple's on-device
`SpeechAnalyzer` / `SpeechTranscriber`. Requires macOS 27 and Swift 6.4 Command Line
Tools; no full Xcode, simulator, third-party packages, or API key.

## Build and run

```sh
swift build
./scripts/package.sh
open "dist/Swift Prompter.app"
# Or build, package, ad hoc sign, verify, and open in one command:
./scripts/run.sh
# Optional optimized build:
./scripts/run.sh release
./scripts/test.sh
```

The bundle identifier is `com.ketupia.swiftprompter`. The app stays at
`dist/Swift Prompter.app`. Quit the running app before rebuilding its bundle.
The scripts use project-local caches. In a confined Codex environment that blocks
SwiftPM's nested manifest sandbox, use:

```sh
SWIFT_PROMPTER_DISABLE_BUILD_SANDBOX=1 ./scripts/run.sh
SWIFT_PROMPTER_DISABLE_BUILD_SANDBOX=1 ./scripts/test.sh
```

This only disables SwiftPM's build-time manifest sandbox, not macOS privacy controls.
The test helper supplies the installed Swift Testing macro plugin explicitly: this
CLT Swift 6.4 build's default `swift test` reported `plugin for module 'TestingMacros'
not found`. The helper requires no additional installation.

## Use and permissions

Edit the script, enable **Show overlay**, and adjust font size and background opacity.
Drag the overlay background to move it; resize at its edges. **Place near webcam**
centers it at the top of the current screen's usable area. The floating panel joins
Spaces and is configured as a full-screen auxiliary window. White text has black
shadows to retain contrast over a transparent background.

**Click-through** passes mouse events to the app underneath. Turn it off in the main
window or use **Make overlay interactive** there. The Window menu also offers
Command-Shift-I while this app is active; it is not a global shortcut.

Select a supported speech language, then press **Start Listening**. Only this action
requests microphone permission. If denied, enable **Swift Prompter** in System
Settings → Privacy & Security → Microphone. Start reports unavailable hardware,
unsupported locales/models, capture interruptions, and download/transcription errors.
Required speech models download from Apple with progress shown; this may need an
internet connection and time. Recognition subsequently runs on device. One locale
reservation is retained; changing language releases the previous app reservation.

Launch the `.app`, rather than `swift run` or the executable, for microphone testing:
TCC privacy permission belongs to the signed app identity. The bundle supplies
`NSMicrophoneUsageDescription` and `NSSpeechRecognitionUsageDescription`. Apple's
local SpeechAnalyzer path does **not** require the legacy SFSpeechRecognizer
authorization prompt, so the app does not request it. If a local permission record
becomes stale, quit the app and optionally reset only this app's microphone decision:

```sh
tccutil reset Microphone com.ketupia.swiftprompter
```

Local ad hoc signing uses a stable designated requirement to help preserve identity
across rebuilds. This is a development bundle, without notarization or distribution
signing; no paid membership is needed. Re-signing, moving the app, or OS privacy
changes can still cause permission to be requested again.

**Stop Listening** stops capture, finalizes audio already consumed by the analyzer,
finishes analysis, and drains the result stream. A small amount of queued capture
audio at the instant of stopping may not be transcribed. Stop also cancels preparation
and model installation; an open macOS permission dialog must still be answered.
Quitting or closing the main window waits for service cleanup.

## Structure

- `Sources/SwiftPrompter/UI`: SwiftUI editor, controls, transcription, and status.
- `Sources/SwiftPrompter/Overlay`: AppKit panel behavior and SwiftUI overlay content.
- `Sources/SwiftPrompter/Speech`: service lifecycle, background microphone capture,
  and time-range-based provisional/final transcript replacement.
- `Sources/SwiftPrompter/Model`: script and overlay settings.
- `Resources/Info.plist`: bundle metadata and privacy descriptions.
- `scripts`: build environment, bundle packaging/signing, and launch.
- `Tests`: transcript revision and fixed script preview checks.

## Milestone limitations and interactive checks

The overlay shows the first four nonempty script lines, clipped to five visual lines.
There is no script matching, confidence gate, automatic scrolling, or advancement.
Speech never changes the script position. Script, settings, and transcripts are kept
in memory only; there is no file persistence or audio recording. The default audio
input is selected at Start; after changing audio devices, stop and start again.

Build/tests validate compilation and pure transcript/preview behavior. Live recognition
needs interactive testing: allow microphone access, wait for any model download,
speak several sentences, check provisional words become final, then stop/restart and
quit while listening. Check drag/resize, font/opacity, click-through over another app,
and recovery using the main window. Test full-screen/Spaces behavior in your actual
presentation app; other apps with higher-level windows may cover a floating panel.
Compilation alone does not verify microphone transcription or visual behavior.

Verification in the restricted development session (2026-10-13): debug compilation,
two unit tests, shell syntax, plist validation, and ad hoc signature verification
passed. App launch could not be verified: `open` returned `-10827
(kLSNoExecutableErr: The executable is missing)` despite the executable being present
and signed. A direct launch aborted in macOS `_RegisterApplication` before app UI
initialization. The cause is unconfirmed; retry the run script from your own Terminal
or VS Code session. Desktop access was unavailable. Microphone permission, model
download, live transcription, and overlay behavior have not been tested interactively.

API references checked against Apple's current documentation and the installed SDK:
[SpeechAnalyzer](https://developer.apple.com/documentation/speech/speechanalyzer),
[microphone input provider](https://developer.apple.com/documentation/speech/captureinputsequenceprovider/providerwithsession(from:compatiblewith:priority:)),
[model installation](https://developer.apple.com/documentation/speech/assetinventory/assetinstallationrequest(supporting:)),
[result finality](https://developer.apple.com/documentation/speech/speechmoduleresult/isfinal),
[speech permissions](https://developer.apple.com/documentation/speech/asking-permission-to-use-speech-recognition).
