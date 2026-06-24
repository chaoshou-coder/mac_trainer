import Foundation
import Observation

/// 集中 @Observable(D4)
/// 持有:所有数据 + 状态 + 复习会话
@Observable
public final class AppModel {
    // MARK: - 原始数据
    public internal(set) var shortcuts: [Shortcut] = []
    public private(set) var statuses: [String: ShortcutStatus] = [:]
    public private(set) var mistakeCounts: [String: Int] = [:]

    // MARK: - UI 状态
    public var selectedCategory: ShortcutCategory? = nil
    public var selectedShortcutId: String? = nil
    public var searchQuery: String = ""
    public var sidebarFilter: SidebarFilter = .all
    public var showAliases: Bool = false

    // MARK: - 复习
    public var currentQuestion: QuizQuestion? = nil
    public var consecutiveCorrect: Int = 0
    public var lastVerdict: KeyMatcher.Verdict? = nil

    // MARK: - Stores
    public let progressStore: ProgressStore
    public let mistakeStore: MistakeCountStore

    public enum SidebarFilter: String, CaseIterable, Sendable {
        case all, practiced, mistakes

        public var displayName: String {
            switch self {
            case .all: return "全部"
            case .practiced: return "已练"
            case .mistakes: return "错题"
            }
        }
    }

    /// 抽考生成器(在 loadBundledShortcuts 后才能正确构造)
    private var distractorGen: DistractorGenerator = DistractorGenerator(allShortcuts: [])

    public init(progressStore: ProgressStore = ProgressStore(), mistakeStore: MistakeCountStore = MistakeCountStore()) {
        self.progressStore = progressStore
        self.mistakeStore = mistakeStore
    }

    // MARK: - 加载
    public func loadBundledShortcuts() throws {
        let bundle = try ShortcutsBundle.loadBundled()
        self.shortcuts = bundle.shortcuts
        // 重新构造 distractorGen(它需要 allShortcuts)
        self.distractorGen = DistractorGenerator(allShortcuts: bundle.shortcuts)
        // 同步 statuses 和 mistakeCounts(已存在的)
        for s in bundle.shortcuts {
            self.statuses[s.id] = self.progressStore.getStatus(for: s.id)
            self.mistakeCounts[s.id] = self.mistakeStore.getCount(for: s.id)
        }
    }

    // MARK: - 计算属性
    public var visibleShortcuts: [Shortcut] {
        var pool = shortcuts
        if let cat = selectedCategory {
            pool = pool.filter { $0.category == cat }
        }
        switch sidebarFilter {
        case .all: break
        case .practiced:
            pool = pool.filter { (statuses[$0.id] ?? .unseen) == .practiced || (statuses[$0.id] ?? .unseen) == .mastered }
        case .mistakes:
            pool = pool.filter { (statuses[$0.id] ?? .unseen) == .recentMistakes }
        }
        if !searchQuery.isEmpty {
            let index = SearchIndex(shortcuts: pool)
            pool = index.filter(query: searchQuery)
        }
        return pool
    }

    public func categoryProgress(_ cat: ShortcutCategory) -> (practiced: Int, total: Int) {
        let total = shortcuts.filter { $0.category == cat }.count
        let practiced = shortcuts.filter { $0.category == cat && (statuses[$0.id] ?? .unseen) != .unseen }.count
        return (practiced, total)
    }

    // MARK: - 状态变更
    public func selectCategory(_ cat: ShortcutCategory?) {
        selectedCategory = cat
        selectedShortcutId = nil
    }

    public func selectShortcut(_ id: String?) {
        selectedShortcutId = id
    }

    public func togglePracticed(_ id: String) {
        let current = statuses[id] ?? .unseen
        let newStatus: ShortcutStatus = (current == .unseen) ? .practiced : .unseen
        applyTransition(id: id, newStatus: newStatus, mistakeCount: mistakeCounts[id] ?? 0)
    }

    // MARK: - 复习
    public func startQuiz() {
        let candidates = shortcuts.filter { StateMachine.isQuizCandidate(statuses[$0.id] ?? .unseen) }
        currentQuestion = QuizSession.nextQuestion(candidates: candidates, distractorGen: distractorGen)
        consecutiveCorrect = 0
        lastVerdict = nil
    }

    public func answerMultipleChoice(pickedId: String) {
        guard let q = currentQuestion else { return }
        let correct = QuizSession.gradeMultipleChoice(question: q, pickedId: pickedId)
        applyQuizAnswer(correct: correct)
    }

    public func answerTyped(_ input: String) {
        guard let q = currentQuestion else { return }
        let verdict = QuizSession.gradeTyped(question: q, input: input)
        lastVerdict = verdict
        applyQuizAnswer(correct: verdict == .correct)
    }

    public func endQuiz() {
        currentQuestion = nil
        lastVerdict = nil
        consecutiveCorrect = 0
    }

    public func nextQuestionAfterAnswer() {
        // 答完一题后,出下一题(或结束如果没候选了)
        let candidates = shortcuts.filter { StateMachine.isQuizCandidate(statuses[$0.id] ?? .unseen) }
        if let next = QuizSession.nextQuestion(candidates: candidates, distractorGen: distractorGen) {
            currentQuestion = next
            lastVerdict = nil
        } else {
            currentQuestion = nil
            lastVerdict = nil
        }
    }

    // MARK: - 状态转移(供 UI 和测试共用)
    public func applyTransition(id: String, newStatus: ShortcutStatus, mistakeCount: Int) {
        statuses[id] = newStatus
        mistakeCounts[id] = mistakeCount
        progressStore.setStatus(newStatus, for: id)
        mistakeStore.setCount(mistakeCount, for: id)
    }

    private func applyQuizAnswer(correct: Bool) {
        guard let q = currentQuestion else { return }
        let id = q.correct.id
        let current = statuses[id] ?? .unseen
        let mc = mistakeCounts[id] ?? 0

        if correct {
            consecutiveCorrect += 1
            let t = StateMachine.transition(
                current: current,
                event: .answerCorrect,
                consecutiveCorrect: consecutiveCorrect,
                mistakeCount: mc
            )
            applyTransition(id: id, newStatus: t.newStatus, mistakeCount: t.newMistakeCount)
            lastVerdict = .correct
        } else {
            consecutiveCorrect = 0
            let t = StateMachine.transition(
                current: current,
                event: .answerWrong,
                consecutiveCorrect: 0,
                mistakeCount: mc
            )
            applyTransition(id: id, newStatus: t.newStatus, mistakeCount: t.newMistakeCount)
            lastVerdict = .wrong(correctKey: q.correct.displayKey)
        }
    }
}
