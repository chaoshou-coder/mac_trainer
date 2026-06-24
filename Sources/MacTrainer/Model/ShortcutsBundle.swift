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

    /// 加载后做冲突检查
    /// - displayKey **不**要求全局唯一:同组合键在不同 app 是不同快捷键(如 ⌘N 在 Finder/Terminal/Chrome、⌘⌫ 在 Finder/Text 各有不同语义)
    /// - alias **不**查重:同上,同 alias 可指向不同 app 的不同 displayKey
    /// - id 全局唯一(target macOS 14+,数据已人工核验,不再做交叉冲突检查)
    public static func validate(_ bundle: ShortcutsBundle) throws {
        let ids = bundle.shortcuts.map { $0.id }
        if Set(ids).count != ids.count {
            throw NSError(
                domain: "MacTrainer.Validate", code: 3,
                userInfo: [NSLocalizedDescriptionKey: "id 不唯一"]
            )
        }
    }
}
