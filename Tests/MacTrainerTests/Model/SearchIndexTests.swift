import Testing
import Foundation
@testable import MacTrainer

final class SearchIndexTests {
    private func makeShortcuts() -> [Shortcut] {
        [
            Shortcut(id: "1", category: .system, subcategory: "spotlight",
                     displayKey: "⌘Space", description: "打开 Spotlight 搜索",
                     appScope: ["system"], verifiedAgainst: "v", verifiedDate: "v", aliases: []),
            Shortcut(id: "2", category: .finder, subcategory: "file",
                     displayKey: "⌘N", description: "新建 Finder 窗口",
                     appScope: ["finder"], verifiedAgainst: "v", verifiedDate: "v", aliases: []),
            Shortcut(id: "3", category: .text, subcategory: "cursor",
                     displayKey: "⌘←", description: "光标到行首",
                     appScope: ["system"], verifiedAgainst: "v", verifiedDate: "v", aliases: [])
        ]
    }

    @Test func emptyQueryReturnsAll() {
        let idx = SearchIndex(shortcuts: makeShortcuts())
        #expect(idx.filter(query: "").count == 3)
    }

    @Test func matchByDescription() {
        let idx = SearchIndex(shortcuts: makeShortcuts())
        let r = idx.filter(query: "spotlight")
        #expect(r.count == 1 && r[0].id == "1")
    }

    @Test func matchByDisplayKey() {
        let idx = SearchIndex(shortcuts: makeShortcuts())
        let r = idx.filter(query: "⌘N")
        #expect(r.count == 1 && r[0].id == "2")
    }

    @Test func matchByCategory() {
        let idx = SearchIndex(shortcuts: makeShortcuts())
        let r = idx.filter(query: "finder")
        #expect(r.count == 1)
    }

    @Test func noMatchReturnsEmpty() {
        let idx = SearchIndex(shortcuts: makeShortcuts())
        let r = idx.filter(query: "nonexistent")
        #expect(r.isEmpty)
    }
}
