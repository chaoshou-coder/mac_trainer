import Foundation

/// bundle JSON 顶层
/// v0.2 升级:加 `categories: [ShortcutCategory]` 字段(从 enum 自动发现,UI 消费)
/// 加 `version` 从 1 → 2(breaking:老 v0.1 JSON 缺 categories 字段,decode 失败 → "请升级 app")
public struct ShortcutsBundle: Codable, Sendable {
    public let version: Int
    public let lastUpdated: String
    /// v0.2 新加:跟 `ShortcutCategory.allCases` 内容必须一致(validate 强制)
    /// 用途:UI 直接消费这个数组(不调 `.allCases`),data-driven 数据源
    public let categories: [ShortcutCategory]
    public let shortcuts: [Shortcut]

    public init(version: Int, lastUpdated: String, categories: [ShortcutCategory], shortcuts: [Shortcut]) {
        self.version = version
        self.lastUpdated = lastUpdated
        self.categories = categories
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

    /// 加载后做校验
    /// - version 必须 ≥ 2(老 v0.1 bundle 缺 categories 字段,decode 已失败;这里是 belt-and-suspenders)
    /// - categories 数组必须跟 `ShortcutCategory.allCases` 内容一致(防止 JSON 跟 Swift 漂移)
    /// - id 全局唯一
    /// - displayKey **不**要求全局唯一(同组合键在不同 app 是不同快捷键)
    /// - alias **不**查重
    public static func validate(_ bundle: ShortcutsBundle) throws {
        // v0.2:version 强制 ≥ 2(老 v0.1 bundle 缺 categories 字段,理论上 decode 已失败)
        guard bundle.version >= 2 else {
            throw NSError(
                domain: "MacTrainer.Validate", code: 4,
                userInfo: [NSLocalizedDescriptionKey:
                    "数据格式太旧(version \(bundle.version)),请升级 app 到 v0.2+"]
            )
        }

        // v0.2:categories 数组必须跟 enum allCases 完全一致(顺序可以不同)
        let jsonIds = Set(bundle.categories.map { $0.rawValue })
        let enumIds = Set(ShortcutCategory.allCases.map { $0.rawValue })
        guard jsonIds == enumIds else {
            throw NSError(
                domain: "MacTrainer.Validate", code: 5,
                userInfo: [NSLocalizedDescriptionKey:
                    "JSON categories 跟代码 enum 漂移:JSON=\(jsonIds.sorted()) code=\(enumIds.sorted())"]
            )
        }

        // 每个 shortcut 的 category 必须在 categories 里(v0.2:用 rawValue 比,因为 enum case 跟 bundle.categories rawValue 必一致)
        let validCategoryIds = jsonIds
        for s in bundle.shortcuts {
            guard validCategoryIds.contains(s.category.rawValue) else {
                throw NSError(
                    domain: "MacTrainer.Validate", code: 6,
                    userInfo: [NSLocalizedDescriptionKey:
                        "shortcut '\(s.id)' 的 category '\(s.category.rawValue)' 不在 categories 列表"]
                )
            }
        }

        // id 全局唯一
        let ids = bundle.shortcuts.map { $0.id }
        if Set(ids).count != ids.count {
            throw NSError(
                domain: "MacTrainer.Validate", code: 3,
                userInfo: [NSLocalizedDescriptionKey: "id 不唯一"]
            )
        }
    }
}
