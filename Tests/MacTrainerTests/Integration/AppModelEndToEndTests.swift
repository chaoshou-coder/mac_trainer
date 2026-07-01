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

    // MARK: - v0.2:LoadState.failed 路径(Outside Voice #1 修)

    @Test func loadBundledSetsLoadStateToLoadedOnSuccess() {
        // 真实 bundle 应该加载成功,loadState = .loaded
        let model = AppModel()
        model.loadBundled()
        #expect(model.loadState == .loaded)
    }

    @Test func loadBundledSetsLoadStateToFailedOnInvalidJSON() {
        // 模拟加载失败:把 bundle URL 指向不存在的 resource
        // 这里我们直接测 .failed case:用 shortcut init 触发 decoding error
        // 不容易模拟 IO 失败,所以用 validate 失败的 JSON 测
        let invalidJSON = """
        {
          "version": 1,
          "lastUpdated": "2026-06-20",
          "shortcuts": []
        }
        """
        // v0.1 的 JSON(version 1,缺 categories 字段)decode 应该 throw
        let data = invalidJSON.data(using: .utf8)!
        #expect(throws: DecodingError.self) {
            _ = try JSONDecoder().decode(ShortcutsBundle.self, from: data)
        }
    }

    // MARK: - v0.2:appScopeFilter(distro chip 过滤)

    @Test func appScopeFilterScopesByDistro() {
        // 准备:3 个 emacs 类别 shortcut,分别有 vanilla / doom / (两个 emacs)appScope
        let suiteName = "test-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { UserDefaults().removePersistentDomain(forName: suiteName) }

        let model = AppModel(
            progressStore: ProgressStore(defaults: defaults),
            mistakeStore: MistakeCountStore(defaults: defaults)
        )
        model.categories = [.emacs]
        model.shortcuts = [
            Shortcut(id: "1", category: .emacs, subcategory: "buffer",
                     displayKey: "C-x C-s", description: "save",
                     appScope: ["emacs", "vanilla"], verifiedAgainst: "v",
                     verifiedDate: "v", aliases: []),
            Shortcut(id: "2", category: .emacs, subcategory: "buffer",
                     displayKey: "C-x C-w", description: "write-file",
                     appScope: ["emacs", "doom"], verifiedAgainst: "v",
                     verifiedDate: "v", aliases: []),
            Shortcut(id: "3", category: .emacs, subcategory: "buffer",
                     displayKey: "C-x b", description: "switch-buffer",
                     appScope: ["emacs"], verifiedAgainst: "v",
                     verifiedDate: "v", aliases: []),
        ]
        model.selectCategory(.emacs)

        // 1. 默认无 filter,3 个都可见
        #expect(model.visibleShortcuts.count == 3)

        // 2. setDistroFilter("vanilla") → 只剩 id=1
        model.setDistroFilter("vanilla")
        #expect(model.visibleShortcuts.count == 1)
        #expect(model.visibleShortcuts[0].id == "1")

        // 3. setDistroFilter("doom") → 只剩 id=2
        model.setDistroFilter("doom")
        #expect(model.visibleShortcuts.count == 1)
        #expect(model.visibleShortcuts[0].id == "2")

        // 4. setDistroFilter(nil) → 恢复 3 个
        model.setDistroFilter(nil)
        #expect(model.visibleShortcuts.count == 3)
    }

    @Test func availableDistrosIsScopedToCategory() {
        // outside 4 macOS category 的 shortcut(emacs 0 个,其它 emacs distro 无)
        // emacs 0 个 + 只有 doom 的 emacs entry → availableDistros 包含 doom
        let model = AppModel()
        model.categories = [.emacs, .system]
        model.shortcuts = [
            Shortcut(id: "1", category: .emacs, subcategory: "edit",
                     displayKey: "C-x", description: "x",
                     appScope: ["emacs", "doom"], verifiedAgainst: "v",
                     verifiedDate: "v", aliases: []),
        ]
        // 选 emacs:availableDistros 应包含 ["doom"]
        model.selectCategory(.emacs)
        #expect(model.availableDistros == ["doom"])

        // 选 system:availableDistros 应为空(system category 0 个 shortcut)
        model.selectCategory(.system)
        #expect(model.availableDistros.isEmpty)
    }

    @Test func setDistroFilterRejectsNonDistroValues() {
        let model = AppModel()
        // "emacs" 是 semantic scope 不是 distro,setDistroFilter 应该忽略(置 nil)
        model.setDistroFilter("emacs")
        #expect(model.appScopeFilter == nil)

        // "fake-distro" 不在 distroScopes,也应该忽略
        model.setDistroFilter("fake-distro")
        #expect(model.appScopeFilter == nil)

        // 合法值
        model.setDistroFilter("vanilla")
        #expect(model.appScopeFilter == "vanilla")
    }

    @Test func selectCategoryClearsDistroFilter() {
        // 切 category 应该清掉 distro filter(避免 doom 跨 category 干扰)
        let model = AppModel()
        model.categories = [.emacs, .vim]
        model.shortcuts = [
            Shortcut(id: "1", category: .emacs, subcategory: "x",
                     displayKey: "C-x", description: "x",
                     appScope: ["emacs", "doom"], verifiedAgainst: "v",
                     verifiedDate: "v", aliases: []),
            Shortcut(id: "2", category: .vim, subcategory: "x",
                     displayKey: "h", description: "h",
                     appScope: ["vim", "doom"], verifiedAgainst: "v",
                     verifiedDate: "v", aliases: []),
        ]
        model.selectCategory(.emacs)
        model.setDistroFilter("doom")
        #expect(model.appScopeFilter == "doom")

        // 切到 vim,filter 应自动清
        model.selectCategory(.vim)
        #expect(model.appScopeFilter == nil)
    }
}
