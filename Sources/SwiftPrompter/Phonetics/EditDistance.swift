/// Levenshtein edit distance over any sequence of equatable elements: characters, phonemes, words.
enum EditDistance {
    /// Minimum number of insertions, deletions and substitutions that turn `a` into `b`.
    static func levenshtein<Element: Equatable>(_ a: [Element], _ b: [Element]) -> Int {
        if a.isEmpty { return b.count }
        if b.isEmpty { return a.count }

        var previous = Array(0...b.count)
        for i in 1...a.count {
            var current = [i] + Array(repeating: 0, count: b.count)
            for j in 1...b.count {
                let substitution = previous[j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1)
                current[j] = min(substitution, previous[j] + 1, current[j - 1] + 1)
            }
            previous = current
        }
        return previous[b.count]
    }

    /// `levenshtein` divided by the longer length: 0 is identical, 1 is nothing in common.
    static func normalized<Element: Equatable>(_ a: [Element], _ b: [Element]) -> Double {
        let longer = max(a.count, b.count)
        return longer == 0 ? 0 : Double(levenshtein(a, b)) / Double(longer)
    }
}
