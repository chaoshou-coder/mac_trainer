import Testing
import Foundation
@testable import MacTrainer

final class AppModelEndToEndTests {
    private func makeShortcuts() -> [Shortcut] {
        [
            Shortcut(id: "1", category: .system, subcategory: "s",
                     displayKey: "⌘A", description: "1",
                     appScope: ["system"], verifiedAgainst: "v", verifiedDate: "v", aliases: []),
            Shortcut(id: "2", category: .system, subcategory: "s",
                     displayKey: "⌘B", description: "2",
                     appScope: ["system"], verifiedAgainst: "v", verifiedDate: "v", aliases: []),
            Shortcut(id: "3", category: .system, subcategory: "s",
                     displayKey: "⌘C", description: "3",
                     appScope: ["system"], verifiedAgainst: "v", verifiedDate: "v", aliases: []),
        ]
    }

    @Test func fullFlowCheckToQuizToMaster() {
        // 用临时 defaults 避免污染
        let suiteName = "test-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { UserDefaults().removePersistentDomain(forName: suiteName) }

        let progress = ProgressStore(defaults: defaults)
        let mistakes = MistakeCountStore(defaults: defaults)
        let model = AppModel(progressStore: progress, mistakeStore: mistakes)
        model.shortcuts = makeShortcuts()

        // 1. 勾选"已练过"
        model.togglePracticed("1")
        #expect(model.statuses["1"] == .practiced)

        // 2. 勾选第二条
        model.togglePracticed("2")
        #expect(model.statuses["2"] == .practiced)

        // 3. 答对 3 次 → mastered
        // 模拟 quizSession,但直接调底层
        for _ in 0..<3 {
            let t = StateMachine.transition(
                current: model.statuses["1"] ?? .practiced,
                event: .answerCorrect,
                consecutiveCorrect: model.consecutiveCorrect,
                mistakeCount: model.mistakeCounts["1"] ?? 0
            )
            model.applyTransition(id: "1", newStatus: t.newStatus, mistakeCount: t.newMistakeCount)
            model.consecutiveCorrect += 1
        }
        #expect(model.statuses["1"] == .mastered)

        // 4. 答错累计 2 次 → recentMistakes
        for _ in 0..<2 {
            let t = StateMachine.transition(
                current: model.statuses["2"] ?? .practiced,
                event: .answerWrong,
                consecutiveCorrect: 0,
                mistakeCount: model.mistakeCounts["2"] ?? 0
            )
            model.applyTransition(id: "2", newStatus: t.newStatus, mistakeCount: t.newMistakeCount)
        }
        #expect(model.statuses["2"] == .recentMistakes)
    }

    @Test func searchFiltersCorrectly() {
        let model = AppModel()
        model.shortcuts = makeShortcuts()
        model.searchQuery = "1"
        let r = model.visibleShortcuts
        #expect(r.count == 1)
        #expect(r[0].id == "1")
    }

    @Test func realBundleLoadsAndValidates() throws {
        // 真实 bundle JSON 在新 normalize 下必须能加载 + 通过 validate
        // 防止 Normalization 改动导致真实数据冲突但 fixture 测不到
        let model = AppModel()
        try model.loadBundledShortcuts()
        #expect(model.shortcuts.count > 0)
    }
}
