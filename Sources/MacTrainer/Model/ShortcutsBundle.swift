import Foundation

/// bundle JSON 顶层
public struct ShortcutsBundle: Codable, Sendable {
    public let version: Int
    public let lastUpdated: String
    public let shortcuts: [Shortcut]

    public init(version: Int, lastUpdated: String, shortcuts: [Shortcut]) {
        self.version = version
        self.lastUpdated = lastUpdated
        self.shortcuts = shortcuts
    }

    /// 从 bundle 资源加载(根据 Package.swift 中 process("Resources/data") 暴露)
    public static func loadBundled() throws -> ShortcutsBundle {
        guard let url = Bundle.module.url(forResource: "shortcuts", withExtension: "json") else {
            throw NSError(
                domain: "MacTrainer.Bundle", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "未找到 shortcuts.json"]
            )
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let bundle = try decoder.decode(ShortcutsBundle.self, from: data)
        try Self.validate(bundle)
        return bundle
    }

    /// 加载后做冲突检查(设计文档:aliases 归一后与多条 displayKey 冲突则拒启动)
    public static func validate(_ bundle: ShortcutsBundle) throws {
        // 1. aliases 归一结果与 displayKey 冲突检查
        var displayKeyNormSet: [String: String] = [:]  // normalized -> original id
        for s in bundle.shortcuts {
            let n = Normalization.normalize(s.displayKey)
            if let existing = displayKeyNormSet[n] {
                throw NSError(
                    domain: "MacTrainer.Validate", code: 1,
                    userInfo: [NSLocalizedDescriptionKey:
                        "displayKey 归一冲突: '\(s.id)' 与 '\(existing)' 都归一为 '\(n)'"]
                )
            }
            displayKeyNormSet[n] = s.id
        }
        // 2. aliases 归一后不能与任何 displayKey 冲突
        for s in bundle.shortcuts {
            for alias in s.aliases {
                let n = Normalization.normalize(alias)
                if let existing = displayKeyNormSet[n], existing != s.id {
                    throw NSError(
                        domain: "MacTrainer.Validate", code: 2,
                        userInfo: [NSLocalizedDescriptionKey:
                            "alias '\(alias)' 归一后 '\(n)' 与 displayKey '\(existing)' 冲突"]
                    )
                }
            }
        }
        // 3. id 唯一
        let ids = bundle.shortcuts.map { $0.id }
        if Set(ids).count != ids.count {
            throw NSError(
                domain: "MacTrainer.Validate", code: 3,
                userInfo: [NSLocalizedDescriptionKey: "id 不唯一"]
            )
        }
    }
}
