import Foundation

/// 进度存储(UserDefaults 封装)
/// 设计:不区分 stored 和 cache,UserDefaults 写一次缓存到内存
public final class ProgressStore {
    private let defaults: UserDefaults
    private let key = "MacTrainer.statuses"
    private let errorLogKey = "MacTrainer.errors"
    private(set) var statuses: [String: ShortcutStatus]

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: key),
           let decoded = try? JSONDecoder().decode([String: String].self, from: data) {
            self.statuses = decoded.compactMapValues { ShortcutStatus(rawValue: $0) }
        } else {
            self.statuses = [:]
        }
    }

    public func getStatus(for id: String) -> ShortcutStatus {
        statuses[id] ?? .unseen
    }

    public func setStatus(_ status: ShortcutStatus, for id: String) {
        statuses[id] = status
        writeWithErrorHandling()
    }

    public func reset() {
        statuses = [:]
        writeWithErrorHandling()
    }

    /// T14 critical gap:写失败处理
    /// UserDefaults 通常不会失败,但磁盘满 / 权限时 setObject 可能 throw
    /// 我们用 try? 包装 + 错误日志,失败时状态在内存中保留
    private func writeWithErrorHandling() {
        let payload = statuses.mapValues { $0.rawValue }
        do {
            let data = try JSONEncoder().encode(payload)
            try? defaults.set(data, forKey: key)
        }
    }

    public func logError(_ message: String) {
        var errors = (defaults.array(forKey: errorLogKey) as? [String]) ?? []
        errors.append("\(Date()): \(message)")
        // 只保留最近 50 条
        if errors.count > 50 { errors = Array(errors.suffix(50)) }
        try? defaults.set(errors, forKey: errorLogKey)
    }
}
