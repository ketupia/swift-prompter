import Foundation

/// The CMU Pronouncing Dictionary, keyed the same way `TextNormalizer` tokens are
/// (lowercase, apostrophes kept). Immutable once built, so it can be shared freely.
///
/// Each word has one pronunciation: the first entry in the file. Stress digits are dropped.
/// If two entries normalize to the same key, the first one wins.
struct CMUDict: Sendable {
    enum LoadError: Error {
        case resourceMissing
    }

    private let entries: [String: [String]]

    var count: Int { entries.count }

    /// Parses dictionary text: `word PH1 PH2 …`, with optional `word(2)` variants and `# comment`s.
    init(text: String) {
        var entries: [String: [String]] = [:]
        for line in text.split(whereSeparator: \.isNewline) {
            let fields = line.prefix { $0 != "#" }.split(whereSeparator: \.isWhitespace)
            guard fields.count > 1 else { continue }

            let key = TextNormalizer.tokens(from: String(fields[0].prefix { $0 != "(" })).joined()
            guard !key.isEmpty, entries[key] == nil else { continue }

            entries[key] = fields.dropFirst().map { String($0.prefix { !$0.isNumber }) }
        }
        self.entries = entries
    }

    /// Loads the dictionary bundled with the app.
    static func bundled() throws -> CMUDict {
        guard let url = Bundle.module.url(forResource: "cmudict", withExtension: "dict", subdirectory: "cmudict") else {
            throw LoadError.resourceMissing
        }
        return CMUDict(text: try String(contentsOf: url, encoding: .utf8))
    }

    /// Phonemes for an already-normalized word, or `nil` if it isn't in the dictionary.
    func pronunciation(for word: String) -> [String]? {
        entries[word]
    }
}
