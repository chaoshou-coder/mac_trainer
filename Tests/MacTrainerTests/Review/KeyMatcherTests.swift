import Testing
import Foundation
@testable import MacTrainer

final class KeyMatcherTests {
    private func makeShortcut(_ key: String, aliases: [String] = []) -> Shortcut {
        Shortcut(id: "x", category: .system, subcategory: "test",
                 displayKey: key, description: "test",
                 appScope: ["system"], verifiedAgainst: "v", verifiedDate: "v", aliases: aliases)
    }

    @Test func exactMatch() {
        let s = makeShortcut("⌘Space")
        #expect(KeyMatcher.match(input: "⌘Space", against: s) == .correct)
    }

    @Test func caseInsensitive() {
        let s = makeShortcut("⌘S")
        #expect(KeyMatcher.match(input: "⌘s", against: s) == .correct)
    }

    @Test func aliasMatch() {
        let s = makeShortcut("⌘Space", aliases: ["Cmd+Space"])
        #expect(KeyMatcher.match(input: "Cmd+Space", against: s) == .correct)
    }

    @Test func wrongReturnsCorrectKey() {
        let s = makeShortcut("⌘Space")
        if case .wrong(let correct) = KeyMatcher.match(input: "⌘Q", against: s) {
            #expect(correct == "⌘Space")
        } else {
            Issue.record("Expected wrong verdict")
        }
    }

    @Test func modifierOrderMismatchWrong() {
        let s = makeShortcut("⌘⇧3")  // ⌘ 后面
        // ⇧⌘3 顺序不对
        if case .wrong = KeyMatcher.match(input: "⇧⌘3", against: s) {
            // OK
        } else {
            Issue.record("Expected wrong")
        }
    }

    @Test func englishNameMatch() {
        let s = makeShortcut("⌘Space", aliases: ["Cmd+Space"])
        #expect(KeyMatcher.match(input: "Cmd + Space", against: s) == .correct)
    }
}
