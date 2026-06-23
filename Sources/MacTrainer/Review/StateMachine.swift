import Foundation

/// 状态机(D6 修订后)
/// 所有函数是纯函数:输入当前 status + 事件,输出新 status + 副作用(对 mistakeCount 的修改建议)
public enum StateMachine {

    /// 转移结果:新 status + 新的 mistakeCount(可能重置)
    public struct Transition: Equatable {
        public let newStatus: ShortcutStatus
        public let newMistakeCount: Int
    }

    /// 事件:用户对一条快捷键的"动作"
    public enum Event: Equatable {
        case checkPracticed           // 勾选"我练过了"
        case answerCorrect
        case answerWrong
    }

    /// 状态转移
    /// - 规则:
    ///   - unseen --checkPracticed--> practiced
    ///   - unseen --answerWrong--> practiced (防御性)
    ///   - practiced + 累计答对 3 次 --> mastered
    ///   - practiced + 错误次数累计 ≥ 2 --> recentMistakes
    ///   - mastered --answerWrong--> practiced
    ///   - recentMistakes + 答对 1 次 --> practiced
    ///   - recentMistakes + 答对 2 次 --> mastered (跳过 practiced)
    /// - 进入 mastered 时 mistakeCount 重置为 0
    public static func transition(
        current: ShortcutStatus,
        event: Event,
        consecutiveCorrect: Int,
        mistakeCount: Int
    ) -> Transition {
        switch (current, event) {
        case (.unseen, .checkPracticed):
            return Transition(newStatus: .practiced, newMistakeCount: mistakeCount)
        case (.unseen, .answerWrong):
            return Transition(newStatus: .practiced, newMistakeCount: mistakeCount + 1)
        case (.unseen, .answerCorrect):
            return Transition(newStatus: .practiced, newMistakeCount: 0)

        case (.practiced, .checkPracticed):
            return Transition(newStatus: .practiced, newMistakeCount: mistakeCount)
        case (.practiced, .answerCorrect):
            if consecutiveCorrect + 1 >= 3 {
                return Transition(newStatus: .mastered, newMistakeCount: 0)
            }
            return Transition(newStatus: .practiced, newMistakeCount: 0)
        case (.practiced, .answerWrong):
            let newCount = mistakeCount + 1
            if newCount >= 2 {
                return Transition(newStatus: .recentMistakes, newMistakeCount: newCount)
            }
            return Transition(newStatus: .practiced, newMistakeCount: newCount)

        case (.mastered, .answerCorrect):
            return Transition(newStatus: .mastered, newMistakeCount: mistakeCount)
        case (.mastered, .answerWrong):
            return Transition(newStatus: .practiced, newMistakeCount: mistakeCount + 1)
        case (.mastered, .checkPracticed):
            return Transition(newStatus: .mastered, newMistakeCount: mistakeCount)

        case (.recentMistakes, .answerCorrect):
            if consecutiveCorrect + 1 >= 2 {
                return Transition(newStatus: .mastered, newMistakeCount: 0)
            }
            return Transition(newStatus: .practiced, newMistakeCount: 0)
        case (.recentMistakes, .answerWrong):
            return Transition(newStatus: .recentMistakes, newMistakeCount: mistakeCount + 1)
        case (.recentMistakes, .checkPracticed):
            return Transition(newStatus: .recentMistakes, newMistakeCount: mistakeCount)
        }
    }

    /// 抽考候选:`practiced ∪ recentMistakes`
    public static func isQuizCandidate(_ status: ShortcutStatus) -> Bool {
        status == .practiced || status == .recentMistakes
    }
}
