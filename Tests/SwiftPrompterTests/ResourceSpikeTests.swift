import Foundation
import Testing
@testable import SwiftPrompter

@Test func dictionaryResourceIsFindable() throws {
    let url = try #require(Bundle.module.url(forResource: "cmudict", withExtension: "dict", subdirectory: "cmudict"))
    #expect(FileManager.default.fileExists(atPath: url.path))
}
