import Testing
import Foundation
@testable import MacTrainer

final class DistractorGeneratorTests {
    private func makeShortcuts() -> [Shortcut] {
        // 同 category + subcategory 有 3 条
        [
            Shortcut(id: "1", category: .system, subcategory: "spotlight",
                     displayKey: "⌘Space", description: "Spotlight",
                     appScope: ["system"], verifiedAgainst: "v", verifiedDate: "v", aliases: []),
            Shortcut(id: "2", category: .system, subcategory: "spotlight",
                     displayKey: "⌘⇧Space", description: "Spotlight 别名",
                     appScope: ["system"], verifiedAgainst: "v", verifiedDate: "v", aliases: []),
            Shortcut(id: "3", category: .system, subcategory: "spotlight",
                     displayKey: "⌘⌥Space", description: "Spotlight 选项",
                     appScope: ["system"], verifiedAgainst: "v", verifiedDate: "v", aliases: []),
            // 同 category 但不同 subcategory
            Shortcut(id: "4", category: .system, subcategory: "screenshot",
                     displayKey: "⌘⇧3", description: "截全屏",
                     appScope: ["system"], verifiedAgainst: "v", verifiedDate: "v", aliases: []),
            // 不同 category
            Shortcut(id: "5", category: .finder, subcategory: "file",
                     displayKey: "⌘N", description: "新建",
                     appScope: ["finder"], verifiedAgainst: "v", verifiedDate: "v", aliases: [])
        ]
    }

    @Test func generateHas4Options() {
        let gen = DistractorGenerator(allShortcuts: makeShortcuts())
        let correct = makeShortcuts()[0]
        let opts = gen.generate(correct: correct)
        #expect(opts.count == 4)
    }

    @Test func generateIncludesCorrect() {
        let gen = DistractorGenerator(allShortcuts: makeShortcuts())
        let correct = makeShortcuts()[0]
        let opts = gen.generate(correct: correct)
        #expect(opts.contains { $0.isCorrect && $0.shortcut.id == "1" })
    }

    @Test func distractorsNotCorrect() {
        let gen = DistractorGenerator(allShortcuts: makeShortcuts())
        let correct = makeShortcuts()[0]
        let opts = gen.generate(correct: correct)
        let distractors = opts.filter { !$0.isCorrect }
        #expect(distractors.count == 3)
        for d in distractors {
            #expect(d.shortcut.id != "1")
        }
    }

    @Test func distractorsAreUnique() {
        let gen = DistractorGenerator(allShortcuts: makeShortcuts())
        let correct = makeShortcuts()[0]
        let opts = gen.generate(correct: correct)
        let ids = opts.map { $0.shortcut.id }
        #expect(Set(ids).count == ids.count)
    }

    @Test func fallbackToCategoryWhenSubcategoryEmpty() {
        // 正确答案来自只有 1 条的 subcategory
        let all = [
            Shortcut(id: "1", category: .finder, subcategory: "unique",
                     displayKey: "⌘Q", description: "唯一",
                     appScope: ["finder"], verifiedAgainst: "v", verifiedDate: "v", aliases: []),
            Shortcut(id: "2", category: .finder, subcategory: "file",
                     displayKey: "⌘N", description: "F1",
                     appScope: ["finder"], verifiedAgainst: "v", verifiedDate: "v", aliases: []),
            Shortcut(id: "3", category: .finder, subcategory: "file",
                     displayKey: "⌘O", description: "F2",
                     appScope: ["finder"], verifiedAgainst: "v", verifiedDate: "v", aliases: []),
            Shortcut(id: "4", category: .finder, subcategory: "file",
                     displayKey: "⌘S", description: "F3",
                     appScope: ["finder"], verifiedAgainst: "v", verifiedDate: "v", aliases: []),
        ]
        let gen = DistractorGenerator(allShortcuts: all)
        let correct = all[0]
        let opts = gen.generate(correct: correct)
        #expect(opts.count == 4)
    }

    @Test func fallbackToGlobalWhenCategoryEmpty() {
        let all = [
            Shortcut(id: "1", category: .vscode, subcategory: "editor",
                     displayKey: "⌘P", description: "VSCode 唯一",
                     appScope: ["vscode"], verifiedAgainst: "v", verifiedDate: "v", aliases: []),
            Shortcut(id: "2", category: .chrome, subcategory: "tab",
                     displayKey: "⌘T", description: "Chrome T",
                     appScope: ["chrome"], verifiedAgainst: "v", verifiedDate: "v", aliases: []),
            Shortcut(id: "3", category: .finder, subcategory: "file",
                     displayKey: "⌘N", description: "Finder N",
                     appScope: ["finder"], verifiedAgainst: "v", verifiedDate: "v", aliases: []),
            Shortcut(id: "4", category: .text, subcategory: "cursor",
                     displayKey: "⌘←", description: "Text ←",
                     appScope: ["system"], verifiedAgainst: "v", verifiedDate: "v", aliases: [])
        ]
        let gen = DistractorGenerator(allShortcuts: all)
        let correct = all[0]
        let opts = gen.generate(correct: correct)
        #expect(opts.count == 4)
    }
}
