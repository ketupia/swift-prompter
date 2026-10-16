import AVFoundation
import Combine
import Foundation
import Speech

@MainActor
final class SpeechService: ObservableObject {
    struct Failure: LocalizedError {
        let message: String
        init(_ message: String) { self.message = message }
        var errorDescription: String? { message }
    }

    enum Phase { case idle, preparing, listening, stopping }
    @Published private(set) var phase: Phase = .idle
    @Published private(set) var status = "Ready. Start Listening requests microphone access."
    @Published private(set) var errorMessage: String?
    @Published private(set) var finalText = ""
    @Published private(set) var provisionalText = ""
    @Published private(set) var downloadProgress: Double?
    @Published private(set) var locales: [String] = []
    @Published var localeIdentifier = Locale.current.identifier

    private let microphone = MicrophoneCapture()
    private var analyzer: SpeechAnalyzer?
    private var setupTask: Task<Void, Never>?
    private var stopTask: Task<Void, Never>?
    private var resultsTask: Task<Void, Never>?
    private var progressTask: Task<Void, Never>?
    private var installation: AssetInstallationRequest?
    private var transcript = Transcript()

    func loadLocales() async {
        locales = await SpeechTranscriber.supportedLocales.map(\.identifier).sorted()
        if let equivalent = await SpeechTranscriber.supportedLocale(equivalentTo: Locale(identifier: localeIdentifier)) {
            localeIdentifier = equivalent.identifier
        } else if locales.contains("en-US") {
            localeIdentifier = "en-US"
        } else if let first = locales.first {
            localeIdentifier = first
        }
        if !SpeechTranscriber.isAvailable {
            errorMessage = "SpeechTranscriber is unavailable on this device."
        } else if locales.isEmpty {
            errorMessage = "No supported transcription locales were reported by the system."
        }
    }

    func start() {
        guard phase == .idle else { return }
        phase = .preparing
        errorMessage = nil
        transcript = Transcript()
        finalText = ""
        provisionalText = ""
        setupTask = Task { await prepareAndStart() }
    }

    private func prepareAndStart() async {
        do {
            guard SpeechTranscriber.isAvailable else { throw Failure("SpeechTranscriber is unavailable on this device.") }
            guard let locale = await SpeechTranscriber.supportedLocale(equivalentTo: Locale(identifier: localeIdentifier)) else {
                throw Failure("The selected locale is not supported by SpeechTranscriber.")
            }
            try Task.checkCancellation()
            status = "Requesting microphone permission…"
            switch AVCaptureDevice.authorizationStatus(for: .audio) {
            case .authorized: break
            case .notDetermined:
                guard await AVCaptureDevice.requestAccess(for: .audio) else { throw microphonePermissionError() }
            case .denied, .restricted: throw microphonePermissionError()
            @unknown default: throw microphonePermissionError()
            }
            try Task.checkCancellation()
            let transcriber = SpeechTranscriber(locale: locale, preset: .progressiveTranscription)
            status = "Checking local speech model for \(locale.identifier)…"
            // Keep at most one app reservation, so changing language cannot exhaust the quota.
            for reserved in await AssetInventory.reservedLocales where reserved != locale {
                await AssetInventory.release(reservedLocale: reserved)
            }
            try await AssetInventory.reserve(locale: locale)
            try Task.checkCancellation()
            guard await AssetInventory.status(forModules: [transcriber]) != .unsupported else {
                throw Failure("The speech model is not supported on this device for \(locale.identifier).")
            }
            if let request = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
                try Task.checkCancellation()
                installation = request
                status = "Downloading speech model for \(locale.identifier). Internet is needed for this step…"
                progressTask = Task {
                    while !Task.isCancelled {
                        downloadProgress = request.progress.fractionCompleted
                        try? await Task.sleep(for: .milliseconds(250))
                    }
                }
                try await request.downloadAndInstall()
                progressTask?.cancel()
                progressTask = nil
                installation = nil
                downloadProgress = nil
            }
            try Task.checkCancellation()
            let analyzer = SpeechAnalyzer(modules: [transcriber])
            self.analyzer = analyzer
            status = "Preparing local transcription…"
            guard let format = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [transcriber]) else {
                throw Failure("The installed speech model has no compatible audio format.")
            }
            try await analyzer.prepareToAnalyze(in: format)
            try Task.checkCancellation()
            resultsTask = Task {
                do {
                    for try await result in transcriber.results {
                        try Task.checkCancellation()
                        transcript.accept(range: result.range, text: String(result.text.characters), isFinal: result.isFinal)
                        finalText = transcript.finalText
                        provisionalText = transcript.provisionalText
                    }
                    if phase == .listening || phase == .preparing {
                        Task { await stop(error: "The transcription stream ended unexpectedly. Start Listening to retry.") }
                    }
                } catch {
                    if phase == .listening || phase == .preparing {
                        Task { await stop(error: "Transcription failed: \(error.localizedDescription)") }
                    }
                }
            }
            try await microphone.start(analyzer: analyzer, transcriber: transcriber) { [weak self] message in
                Task { @MainActor in await self?.stop(error: message) }
            }
            try Task.checkCancellation()
            phase = .listening
            status = "Listening on device · \(locale.identifier)"
        } catch {
            // Stop owns cleanup when the user cancels preparation.
            if phase != .stopping {
                errorMessage = error.localizedDescription
                await cleanUp(finalize: false)
                phase = .idle
                status = "Could not start listening."
            }
        }
    }

    func stop(error: String? = nil) async {
        if let stopTask { await stopTask.value; return }
        guard phase != .idle else { return }
        let wasListening = phase == .listening
        phase = .stopping
        status = "Stopping microphone and transcription…"
        if let error { errorMessage = error }
        setupTask?.cancel()
        installation?.progress.cancel()
        let task = Task {
            await setupTask?.value
            setupTask = nil
            await cleanUp(finalize: wasListening && error == nil)
            phase = .idle
            status = errorMessage == nil ? "Stopped. Microphone released." : "Stopped after an error."
        }
        stopTask = task
        await task.value
        stopTask = nil
    }

    private func cleanUp(finalize: Bool) async {
        progressTask?.cancel()
        progressTask = nil
        installation = nil
        downloadProgress = nil
        await microphone.stop()
        if let analyzer {
            if finalize {
                do { try await analyzer.finalize(through: nil) }
                catch { errorMessage = "Could not finalize the last speech: \(error.localizedDescription)" }
            }
            await analyzer.cancelAndFinishNow()
        }
        // Finishing closes the result stream. Drain final results before allowing another session.
        await resultsTask?.value
        resultsTask = nil
        analyzer = nil
    }

    private func microphonePermissionError() -> Failure {
        Failure("Microphone access is denied or restricted. Enable Swift Prompter in System Settings → Privacy & Security → Microphone, then retry.")
    }
}
