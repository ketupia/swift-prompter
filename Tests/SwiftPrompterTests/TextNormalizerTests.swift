import Testing
@testable import SwiftPrompter

@Test func lowercasesAndStripsSentencePunctuation() {
    #expect(TextNormalizer.tokens(from: "Perform an oil change, today!") == ["perform", "an", "oil", "change", "today"])
}

@Test func hyphensAndUnderscoresSplit() {
    #expect(TextNormalizer.tokens(from: "oil-change") == ["oil", "change"])
    #expect(TextNormalizer.tokens(from: "oil_change") == ["oil", "change"])
    #expect(TextNormalizer.tokens(from: "oil\u{2014}change") == ["oil", "change"])
}

@Test func apostrophesInsideWordsAreKept() {
    #expect(TextNormalizer.tokens(from: "Don't") == ["don't"])
    #expect(TextNormalizer.tokens(from: "we'll go") == ["we'll", "go"])
}

@Test func apostrophesAtTheEdgesAreTrimmed() {
    #expect(TextNormalizer.tokens(from: "'quoted'") == ["quoted"])
    #expect(TextNormalizer.tokens(from: "the dogs' bowls") == ["the", "dogs", "bowls"])
    #expect(TextNormalizer.tokens(from: "rock 'n' roll") == ["rock", "n", "roll"])
    #expect(TextNormalizer.tokens(from: "'' '") == [])
}

@Test func curlyApostrophesSeparateLikeOtherPunctuation() {
    #expect(TextNormalizer.tokens(from: "don\u{2019}t") == ["don", "t"])
}

@Test func periodsSplit() {
    #expect(TextNormalizer.tokens(from: "end.Next") == ["end", "next"])
    #expect(TextNormalizer.tokens(from: "3.14") == ["3", "14"])
}

@Test func ellipsesAndEmptyInput() {
    #expect(TextNormalizer.tokens(from: "wait...what") == ["wait", "what"])
    #expect(TextNormalizer.tokens(from: "").isEmpty)
    #expect(TextNormalizer.tokens(from: " \n -- ... ").isEmpty)
}

@Test func lineBreaksSeparate() {
    #expect(TextNormalizer.tokens(from: "one\ntwo\r\nthree") == ["one", "two", "three"])
}
