import Foundation

/// 抽考会话(单题)
/// 出题策略:50% 看 displayKey 选 description,50% 看 description 手输 displayKey
public struct QuizQuestion: Equatable, Sendable {
    public enum Kind: Equatable, Sendable {
        case multipleChoice(correct: Shortcut, options: [DistractorGenerator.Option])
        case typeKey(correct: Shortcut)
    }
    public let kind: Kind
    public let correct: Shortcut

    public init(kind: Kind, correct: Shortcut) {
        self.kind = kind
        self.correct = correct
    }
}

public enum QuizSession {
    /// 从候选集合中随机抽一题
    public static func nextQuestion(
        candidates: [Shortcut],
        distractorGen: DistractorGenerator,
        rng: () -> UInt64 = { UInt64.random(in: 0...UInt64.max) }
    ) -> QuizQuestion? {
        guard !candidates.isEmpty else { return nil }
        let seed = rng()
        var localRng = XorShift(seed: seed)
        let pick = candidates[Int(localRng.next() % UInt64(candidates.count))]

        // 50/50 出题类型
        let isMultipleChoice = (localRng.next() % 2) == 0
        if isMultipleChoice {
            let options = distractorGen.generate(correct: pick, rng: rng)
            return QuizQuestion(
                kind: .multipleChoice(correct: pick, options: options),
                correct: pick
            )
        } else {
            return QuizQuestion(kind: .typeKey(correct: pick), correct: pick)
        }
    }

    /// 4 选 1 判分
    public static func gradeMultipleChoice(question: QuizQuestion, pickedId: String) -> Bool {
        guard case .multipleChoice = question.kind else { return false }
        return pickedId == question.correct.id
    }

    /// 手输判分
    public static func gradeTyped(question: QuizQuestion, input: String) -> KeyMatcher.Verdict {
        guard case .typeKey = question.kind else {
            return .wrong(correctKey: question.correct.displayKey)
        }
        return KeyMatcher.match(input: input, against: question.correct)
    }
}

/// LCG-based 简单 PRNG(避免 RandomNumberGenerator 协议开销)
private struct XorShift {
    private var state: UInt64
    init(seed: UInt64) { self.state = seed == 0 ? 1 : seed }
    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
