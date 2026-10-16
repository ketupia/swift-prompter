import Combine
import Foundation

@MainActor
final class AppModel: ObservableObject {
    static let shared = AppModel()
    let speech = SpeechService()
    @Published var script = "Welcome to Swift Prompter.\n\nPlace this window near your webcam.\nSpeak naturally while demonstrating your app.\n\nThis first milestone tests the overlay and live transcription independently."
    @Published var fontSize: Double = 28
    @Published var backgroundOpacity: Double = 0.65
    @Published var overlayVisible = false
    @Published var clickThrough = false

    lazy var overlay = OverlayController(model: self)

    static func previewLines(from script: String) -> String {
        let lines = script.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        return lines.isEmpty ? "Enter your script in the main window." : lines.prefix(4).joined(separator: "\n")
    }

    func updateOverlay() { overlay.update() }
}
