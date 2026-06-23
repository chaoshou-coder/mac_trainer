import Foundation

/// 跨字段模糊匹配
/// 搜索:displayKey + description + aliases + category
public struct SearchIndex: Sendable {
    private let shortcuts: [Shortcut]

    public init(shortcuts: [Shortcut]) {
        self.shortcuts = shortcuts
    }

    public func filter(query: String) -> [Shortcut] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return shortcuts }
        return shortcuts.filter { s in
            // 任何一个字段包含 query 即匹配
            if s.displayKey.lowercased().contains(q) { return true }
            if s.description.lowercased().contains(q) { return true }
            if s.category.rawValue.lowercased().contains(q) { return true }
            if s.subcategory.lowercased().contains(q) { return true }
            if s.id.lowercased().contains(q) { return true }
            for alias in s.aliases {
                if alias.lowercased().contains(q) { return true }
            }
            return false
        }
    }
}
