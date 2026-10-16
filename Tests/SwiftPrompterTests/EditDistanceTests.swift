import Testing
@testable import SwiftPrompter

@Test func levenshteinCountsInsertsDeletesAndSubstitutions() {
    #expect(EditDistance.levenshtein(Array("kitten"), Array("sitting")) == 3)
    #expect(EditDistance.levenshtein(Array("abc"), Array("abc")) == 0)
    #expect(EditDistance.levenshtein(Array("abc"), Array<Character>()) == 3)
    #expect(EditDistance.levenshtein(Array<Character>(), Array("abc")) == 3)
    #expect(EditDistance.levenshtein(Array<Character>(), Array<Character>()) == 0)
}

@Test func normalizedDistanceDividesByTheLongerLength() {
    #expect(EditDistance.normalized(Array("abc"), Array("abc")) == 0)
    #expect(EditDistance.normalized(Array("abc"), Array("xyz")) == 1)
    #expect(EditDistance.normalized(Array("ab"), Array("abcd")) == 0.5)
    #expect(EditDistance.normalized(Array<Character>(), Array<Character>()) == 0)
}

@Test func nearMissesCostAFraction() {
    #expect(EditDistance.normalized(["K", "AE", "T"], ["K", "OW", "T"]) == 1.0 / 3.0)
    #expect(EditDistance.normalized(["EH", "G"], ["EH", "G", "Z"]) == 1.0 / 3.0)
}
