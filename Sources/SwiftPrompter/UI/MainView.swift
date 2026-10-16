import AppKit
import SwiftUI

struct MainView: View {
    @ObservedObject var model: AppModel
    @ObservedObject var speech: SpeechService

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Swift Prompter").font(.largeTitle.bold())
            Text("Overlay and local transcription · milestone 1").foregroundStyle(.secondary)
            HSplitView {
                VStack(alignment: .leading) {
                    Text("Script").font(.headline)
                    TextEditor(text: $model.script)
                        .font(.system(size: 16))
                        .padding(4)
                        .border(.secondary.opacity(0.3))
                    Text("Overlay previews the first four nonempty lines. It does not advance.")
                        .font(.caption).foregroundStyle(.secondary)
                }.frame(minWidth: 300)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Live recognized text").font(.headline)
                    ScrollView {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("FINAL").font(.caption).foregroundStyle(.secondary)
                            Text(speech.finalText.isEmpty ? "Finalized words appear here." : speech.finalText)
                                .textSelection(.enabled)
                            Divider()
                            Text("PROVISIONAL · may change").font(.caption).foregroundStyle(.secondary)
                            Text(speech.provisionalText.isEmpty ? "Waiting for speech…" : speech.provisionalText)
                                .foregroundStyle(.secondary).textSelection(.enabled)
                        }.frame(maxWidth: .infinity, alignment: .leading).padding(10)
                    }.border(.secondary.opacity(0.3))
                }.frame(minWidth: 300)
            }.frame(minHeight: 240)

            HStack {
                Picker("Speech language", selection: $speech.localeIdentifier) {
                    if speech.locales.isEmpty { Text(speech.localeIdentifier).tag(speech.localeIdentifier) }
                    ForEach(speech.locales, id: \.self) { identifier in
                        Text(Locale.current.localizedString(forIdentifier: identifier) ?? identifier).tag(identifier)
                    }
                }.frame(maxWidth: 300).disabled(speech.phase != .idle)
                Button("Start Listening") { speech.start() }
                    .disabled(speech.phase != .idle || speech.locales.isEmpty)
                Button(speech.phase == .stopping ? "Stopping…" : "Stop Listening") {
                    Task { await speech.stop() }
                }.disabled(speech.phase == .idle || speech.phase == .stopping)
            }
            Text(speech.status).accessibilityIdentifier("speechStatus")
            if let progress = speech.downloadProgress {
                ProgressView(value: progress) { Text("Model download: \(Int(progress * 100))%") }
            }
            if let error = speech.errorMessage {
                Text(error).foregroundStyle(.red).textSelection(.enabled)
            }
            Divider()
            HStack(spacing: 20) {
                Toggle("Show overlay", isOn: $model.overlayVisible)
                Toggle("Click-through", isOn: $model.clickThrough)
                Button("Make overlay interactive") { model.clickThrough = false }
                    .disabled(!model.clickThrough)
                Button("Place near webcam") { model.overlay.centerNearWebcam() }
                    .disabled(!model.overlayVisible)
            }
            HStack(spacing: 24) {
                HStack {
                    Text("Font \(Int(model.fontSize)) pt").frame(width: 90, alignment: .leading)
                    Slider(value: $model.fontSize, in: 18...52, step: 1)
                }
                HStack {
                    Text("Background \(Int(model.backgroundOpacity * 100))%").frame(width: 135, alignment: .leading)
                    Slider(value: $model.backgroundOpacity, in: 0...1)
                }
            }
            Text("Click-through sends pointer input to the app underneath. Disable it here to move the overlay again.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(minWidth: 860, minHeight: 660)
        .task { await speech.loadLocales() }
        .onChange(of: model.overlayVisible) { model.updateOverlay() }
        .onChange(of: model.clickThrough) { model.updateOverlay() }
    }
}
