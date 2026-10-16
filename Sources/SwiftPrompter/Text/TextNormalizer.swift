import Foundation

/// Turns prose into lowercase matching tokens.
///
/// - Lowercase.
/// - Apostrophes (straight or curly) are removed without splitting: `don't` -> `dont`.
/// - Anything else that isn't a letter or digit separates tokens: `oil-change` -> `oil`, `change`.
enum TextNormalizer {
    static func tokens(from text: String) -> [String] {
        text.lowercased()
            .replacing("'", with: "")  // straight apostrophe
            .replacing("\u{2019}", with: "")  // ’ right single quote (curly apostrophe)
            .replacing("\u{2018}", with: "")  // ‘ left single quote
            .replacing("\u{02BC}", with: "")  // ʼ modifier letter apostrophe
            .split { !$0.isLetter && !$0.isNumber }
            .map(String.init)
    }
}
