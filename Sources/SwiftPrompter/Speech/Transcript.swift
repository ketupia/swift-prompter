import CoreMedia
import Foundation

/// Speech results replace overlapping time ranges, rather than appending every hypothesis.
struct Transcript {
    struct Segment {
        let range: CMTimeRange
        let text: String
        let isFinal: Bool
    }

    private(set) var segments: [Segment] = []

    mutating func accept(range: CMTimeRange, text: String, isFinal: Bool) {
        segments.removeAll { segment in
            CMTimeRangeGetIntersection(segment.range, otherRange: range).duration > .zero
                || segment.range == range
        }
        segments.append(Segment(range: range, text: text, isFinal: isFinal))
        segments.sort { $0.range.start < $1.range.start }
    }

    var finalText: String { text(final: true) }
    var provisionalText: String { text(final: false) }

    private func text(final: Bool) -> String {
        segments.filter { $0.isFinal == final }.map(\.text).joined(separator: " ")
    }
}
