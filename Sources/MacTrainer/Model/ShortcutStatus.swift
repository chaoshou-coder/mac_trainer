import Foundation

/// 状态机 4 状态(对应设计文档 D6 修订)
public enum ShortcutStatus: String, Codable, Sendable, Equatable {
    case unseen
    case practiced
    case mastered
    case recentMistakes = "recent_mistakes"
}
