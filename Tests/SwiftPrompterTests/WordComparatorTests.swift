import Testing
@testable import SwiftPrompter

private let comparator = WordComparator(dictionary: CMUDict(text: """
cat K AE1 T
coat K OW1 T
their DH EH1 R
there DH EH1 R
"""))

@Test func wordsInTheDictionaryAreComparedBySound() {
    #expect(comparator.distance("there", "their") == 0)
    #expect(comparator.distance("cat", "coat") == 1.0 / 3.0)
}

@Test func missingWordsAreComparedBySpelling() {
    #expect(comparator.distance("sarah", "sarah") == 0)
    #expect(comparator.distance("zzyzx", "zzyzy") == 0.2)
}

@Test func aMissingWordMakesBothCompareBySpelling() {
    #expect(comparator.distance("cat", "bat") == 1.0 / 3.0)
    #expect(comparator.distance("there", "their") == 0)
}
