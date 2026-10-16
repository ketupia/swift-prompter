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

@Test func apostrophesAreRemovedNotSplit() {
    #expect(TextNormalizer.tokens(from: "don't") == ["dont"])
    #expect(TextNormalizer.tokens(from: "don\u{2019}t") == ["dont"])
    #expect(TextNormalizer.tokens(from: "'quoted'") == ["quoted"])
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
