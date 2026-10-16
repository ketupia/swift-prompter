/// How close two normalized words are, from 0 (identical) to 1 (nothing in common).
///
/// Compares by sound when both words are in the dictionary. If either one is missing, both are
/// compared by spelling, so every score is on the same 0–1 scale.
struct WordComparator: Sendable {
    let dictionary: CMUDict

    func distance(_ a: String, _ b: String) -> Double {
        if let x = dictionary.pronunciation(for: a), let y = dictionary.pronunciation(for: b) {
            return EditDistance.normalized(x, y)
        }
        return EditDistance.normalized(Array(a), Array(b))
    }
}
