import AVFoundation
import Speech

/// Owns the capture session off the main actor; startRunning/stopRunning are blocking APIs.
actor MicrophoneCapture {
    private var provider: CaptureInputSequenceProvider?
    private var observers: [NSObjectProtocol] = []

    func start(analyzer: SpeechAnalyzer, transcriber: SpeechTranscriber,
               onError: @escaping @Sendable (String) -> Void) async throws {
        guard let device = AVCaptureDevice.default(for: .audio) else {
            throw SpeechService.Failure("No microphone is available. Connect an audio input and retry.")
        }
        let provider = try await CaptureInputSequenceProvider.providerWithSession(
            from: device, compatibleWith: [transcriber])
        self.provider = provider
        try Task.checkCancellation()
        let center = NotificationCenter.default
        for name in [AVCaptureSession.runtimeErrorNotification, AVCaptureSession.wasInterruptedNotification] {
            observers.append(center.addObserver(forName: name, object: provider.captureSession, queue: nil) { note in
                let detail = (note.userInfo?[AVCaptureSessionErrorKey] as? NSError)?.localizedDescription
                onError(detail ?? "Microphone capture was interrupted. Stop and retry when the input is available.")
            })
        }
        try await analyzer.start(inputSequence: provider.analyzerInputs)
        try Task.checkCancellation()
        provider.captureSession.startRunning()
        guard provider.captureSession.isRunning else {
            throw SpeechService.Failure("The microphone capture session could not start.")
        }
    }

    func stop() {
        for observer in observers { NotificationCenter.default.removeObserver(observer) }
        observers.removeAll()
        provider?.captureSession.stopRunning()
        provider = nil
    }
}
