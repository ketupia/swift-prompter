import CoreMedia
import Testing
@testable import SwiftPrompter

private func range(_ start: Int64, _ length: Int64) -> CMTimeRange {
    CMTimeRange(start: CMTime(value: start, timescale: 1), duration: CMTime(value: length, timescale: 1))
}

@Test func provisionalRevisionsAreReplacedAndFinalSegmentsStay() {
    var transcript = Transcript()
    transcript.accept(range: range(0, 2), text: "hello", isFinal: false)
    transcript.accept(range: range(0, 3), text: "hello world", isFinal: false)
    #expect(transcript.provisionalText == "hello world")
    transcript.accept(range: range(0, 3), text: "Hello world.", isFinal: true)
    transcript.accept(range: range(3, 2), text: "Next sentence", isFinal: false)
    #expect(transcript.finalText == "Hello world.")
    #expect(transcript.provisionalText == "Next sentence")
    transcript.accept(range: range(3, 2), text: "Next sentence.", isFinal: true)
    #expect(transcript.finalText == "Hello world. Next sentence.")
    #expect(transcript.provisionalText.isEmpty)
}

@Test @MainActor func overlayPreviewIsFixedAndHandlesBlankScripts() {
    #expect(AppModel.previewLines(from: " \n\n") == "Enter your script in the main window.")
    #expect(AppModel.previewLines(from: "one\n\ntwo\nthree\nfour\nfive") == "one\ntwo\nthree\nfour")
}
