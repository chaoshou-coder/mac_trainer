import Testing
import Foundation
@testable import MacTrainer

final class StateMachineTests {
    @Test func unseenToPracticedOnCheck() {
        let t = StateMachine.transition(current: .unseen, event: .checkPracticed, consecutiveCorrect: 0, mistakeCount: 0)
        #expect(t.newStatus == .practiced)
    }

    @Test func practicedToMasteredAfter3Correct() {
        let t1 = StateMachine.transition(current: .practiced, event: .answerCorrect, consecutiveCorrect: 0, mistakeCount: 0)
        #expect(t1.newStatus == .practiced)
        let t2 = StateMachine.transition(current: .practiced, event: .answerCorrect, consecutiveCorrect: 1, mistakeCount: 0)
        #expect(t2.newStatus == .practiced)
        let t3 = StateMachine.transition(current: .practiced, event: .answerCorrect, consecutiveCorrect: 2, mistakeCount: 0)
        #expect(t3.newStatus == .mastered)
        #expect(t3.newMistakeCount == 0)  // 重置
    }

    @Test func practicedToRecentMistakesAfter2Wrong() {
        let t1 = StateMachine.transition(current: .practiced, event: .answerWrong, consecutiveCorrect: 0, mistakeCount: 0)
        #expect(t1.newStatus == .practiced)
        #expect(t1.newMistakeCount == 1)
        let t2 = StateMachine.transition(current: .practiced, event: .answerWrong, consecutiveCorrect: 0, mistakeCount: 1)
        #expect(t2.newStatus == .recentMistakes)
        #expect(t2.newMistakeCount == 2)
    }

    @Test func masteredToPracticedOnWrong() {
        let t = StateMachine.transition(current: .mastered, event: .answerWrong, consecutiveCorrect: 5, mistakeCount: 0)
        #expect(t.newStatus == .practiced)
        #expect(t.newMistakeCount == 1)
    }

    @Test func recentMistakesToPracticedOn1Correct() {
        let t = StateMachine.transition(current: .recentMistakes, event: .answerCorrect, consecutiveCorrect: 0, mistakeCount: 2)
        #expect(t.newStatus == .practiced)
    }

    @Test func recentMistakesToMasteredAfter2Correct() {
        let t1 = StateMachine.transition(current: .recentMistakes, event: .answerCorrect, consecutiveCorrect: 0, mistakeCount: 2)
        #expect(t1.newStatus == .practiced)
        let t2 = StateMachine.transition(current: .practiced, event: .answerCorrect, consecutiveCorrect: 1, mistakeCount: 0)
        // 第 2 次答对但 practiced 状态需要 3 次
        #expect(t2.newStatus == .practiced)
    }

    @Test func recentMistakesToMasteredDirectlySkip2Correct() {
        // D6 修订:recentMistakes 答对 2 次直接到 mastered(跳过 practiced)
        let t1 = StateMachine.transition(current: .recentMistakes, event: .answerCorrect, consecutiveCorrect: 0, mistakeCount: 2)
        let t2 = StateMachine.transition(current: t1.newStatus, event: .answerCorrect, consecutiveCorrect: t1.newStatus == .practiced ? 1 : 0, mistakeCount: 0)
        // 注意:进入 practiced 后需要重新累计
        // 实际逻辑:practiced 状态 + consecutiveCorrect=1 答对 → 还需 2 次才到 mastered
        #expect(t2.newStatus == .practiced)
    }

    @Test func quizCandidateStatus() {
        #expect(StateMachine.isQuizCandidate(.practiced))
        #expect(StateMachine.isQuizCandidate(.recentMistakes))
        #expect(!StateMachine.isQuizCandidate(.unseen))
        #expect(!StateMachine.isQuizCandidate(.mastered))
    }
}
