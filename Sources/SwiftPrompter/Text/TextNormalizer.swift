import Foundation

/// Turns prose into lowercase matching tokens.
///
/// - Lowercase.
/// - Letters, digits and the straight apostrophe make up tokens: `don't` stays `don't`.
/// - Anything else separates tokens, including curly quotes: `oil-change` -> `oil`, `change`.
/// - Apostrophes at the start or end of a token are trimmed: `'quoted'` -> `quoted`.
enum TextNormalizer {
    static func tokens(from text: String) -> [String] {
        text.lowercased()
            .split { !$0.isLetter && !$0.isNumber && $0 != "'" }
            .map { $0.trimmingCharacters(in: ["'"]) }
            .filter { !$0.isEmpty }
    }
}
