import Foundation

/// 错误计数存储(每个 id 一个计数)
public final class MistakeCountStore {
    private let defaults: UserDefaults
    private let key = "MacTrainer.mistakeCount"
    private let errorLogKey = "MacTrainer.mistakeCountErrors"
    private(set) var counts: [String: Int]

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: key),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            self.counts = decoded
        } else {
            self.counts = [:]
        }
    }

    public func getCount(for id: String) -> Int {
        counts[id] ?? 0
    }

    public func setCount(_ count: Int, for id: String) {
        counts[id] = count
        writeWithErrorHandling()
    }

    public func increment(for id: String) -> Int {
        let new = (counts[id] ?? 0) + 1
        counts[id] = new
        writeWithErrorHandling()
        return new
    }

    public func reset(for id: String) {
        counts[id] = 0
        writeWithErrorHandling()
    }

    public func resetAll() {
        counts = [:]
        writeWithErrorHandling()
    }

    private func writeWithErrorHandling() {
        do {
            let data = try JSONEncoder().encode(counts)
            defaults.set(data, forKey: key)
        } catch {
            logError("Failed to write mistakeCount: \(error)")
        }
    }

    public func logError(_ message: String) {
        var errors = (defaults.array(forKey: errorLogKey) as? [String]) ?? []
        errors.append("\(Date()): \(message)")
        if errors.count > 50 { errors = Array(errors.suffix(50)) }
        defaults.set(errors, forKey: errorLogKey)
    }
}
