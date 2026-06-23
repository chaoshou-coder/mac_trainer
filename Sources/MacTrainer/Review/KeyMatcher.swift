import Foundation

/// 手输键判分(设计文档 Review Logic)
/// - 大小写不敏感
/// - 修饰键符号归一(用 Model/Normalization 共享函数)
/// - aliases 归一也算对
/// - 键位顺序必须完全一致
public enum KeyMatcher {
    public enum Verdict: Equatable {
        case correct
        case wrong(correctKey: String)
    }

    /// 判分
    /// - Parameters:
    ///   - input: 用户输入
    ///   - target: 目标快捷键
    /// - Returns: correct / wrong(正确答案)
    public static func match(input: String, against target: Shortcut) -> Verdict {
        let normalizedInput = Normalization.normalize(input)
        let normalizedTarget = Normalization.normalize(target.displayKey)
        if normalizedInput == normalizedTarget {
            return .correct
        }
        // aliases 也要判
        for alias in target.aliases {
            if normalizedInput == Normalization.normalize(alias) {
                return .correct
            }
        }
        return .wrong(correctKey: target.displayKey)
    }
}
