import Foundation
import Testing
@testable import SwiftPrompter

private let fixture = """
cat K AE1 T
their DH EH1 R
there DH EH1 R
read R EH1 D
read(2) R IY1 D
don't D OW1 N T
we'll W IY1 L
well W EH1 L
aalborg AO1 L B AO0 R G # place, danish

"""

private func phonemes(_ s: String) -> [String] {
    s.split(separator: " ").map(String.init)
}

@Test func lookupReturnsPhonemesWithoutStress() {
    let dict = CMUDict(text: fixture)
    #expect(dict.pronunciation(for: "cat") == phonemes("K AE T"))
    #expect(dict.pronunciation(for: "there") == dict.pronunciation(for: "their"))
}

@Test func firstPronunciationWins() {
    let dict = CMUDict(text: fixture)
    #expect(dict.pronunciation(for: "read") == phonemes("R EH D"))
}

@Test func trailingCommentsAreIgnored() {
    let dict = CMUDict(text: fixture)
    #expect(dict.pronunciation(for: "aalborg") == phonemes("AO L B AO R G"))
}

@Test func apostropheKeysAreKept() {
    let dict = CMUDict(text: fixture)
    #expect(dict.pronunciation(for: "don't") == phonemes("D OW N T"))
    #expect(dict.pronunciation(for: "we'll") == phonemes("W IY L"))
    #expect(dict.pronunciation(for: "well") == phonemes("W EH L"))
}

@Test func missesAndBlankInputReturnNil() {
    let dict = CMUDict(text: fixture)
    #expect(dict.pronunciation(for: "zzyzx") == nil)
    #expect(dict.pronunciation(for: "") == nil)
}

@Test func bundledDictionaryLoadsAndLooksUpWords() throws {
    let dict = try CMUDict.bundled()
    #expect(dict.count > 120_000)
    #expect(dict.pronunciation(for: "cat") == phonemes("K AE T"))
    #expect(dict.pronunciation(for: "there") == dict.pronunciation(for: "their"))
    #expect(dict.pronunciation(for: "don't") != nil)
    #expect(dict.pronunciation(for: "zzyzx") == nil)
}
