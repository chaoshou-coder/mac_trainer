import Foundation

/// 4 选 1 干扰项生成(设计文档 Review Logic)
/// 规则:
/// 1. 优先从同 category + subcategory 全集抽 3 个 description
/// 2. 不足 → 同 category
/// 3. 仍不足 → 全库
/// 4. 选项顺序随机 shuffle
/// 5. 排除正确答案,3 个选项不重复
public struct DistractorGenerator {
    public struct Option: Equatable, Sendable {
        public let shortcut: Shortcut
        public let isCorrect: Bool
    }

    private let allShortcuts: [Shortcut]

    public init(allShortcuts: [Shortcut]) {
        self.allShortcuts = allShortcuts
    }

    /// 生成 4 选 1 选项(包含正确答案 + 3 个干扰项)
    public func generate(correct: Shortcut, rng: () -> UInt64 = { UInt64.random(in: 0...UInt64.max) }) -> [Option] {
        var pool: [Shortcut] = []
        let sameCatSubcat = allShortcuts.filter {
            $0.category == correct.category && $0.subcategory == correct.subcategory && $0.id != correct.id
        }
        pool.append(contentsOf: sameCatSubcat)

        if pool.count < 3 {
            let sameCat = allShortcuts.filter {
                $0.category == correct.category && $0.id != correct.id && !pool.contains($0)
            }
            pool.append(contentsOf: sameCat)
        }

        if pool.count < 3 {
            let others = allShortcuts.filter { $0.id != correct.id && !pool.contains($0) }
            pool.append(contentsOf: others)
        }

        // 取前 3 个(已经过滤 + 排除正确答案)
        let distractors = Array(pool.prefix(3))
        var options = distractors.map { Option(shortcut: $0, isCorrect: false) }
        options.append(Option(shortcut: correct, isCorrect: true))
        // 随机 shuffle
        var rng = SeededRNG(seed: rng())
        options.shuffle(using: &rng)
        return options
    }
}

/// 简单可重现 RNG(用 seedable LCG)
private struct SeededRNG: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { self.state = seed == 0 ? 1 : seed }
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}
