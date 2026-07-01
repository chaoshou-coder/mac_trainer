import Foundation

/// 快捷键数据模型
/// 反序列化时做边界检查(D2 决策:放弃 formal schema,只 Codable + 自定义 init)
public struct Shortcut: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let category: ShortcutCategory
    public let subcategory: String
    public let displayKey: String
    public let description: String
    public let appScope: [String]
    public let verifiedAgainst: String
    public let verifiedDate: String
    public let aliases: [String]

    enum CodingKeys: String, CodingKey {
        case id, category, subcategory, displayKey, description
        case appScope, verifiedAgainst, verifiedDate, aliases
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decode(String.self, forKey: .id)
        guard !self.id.isEmpty else {
            throw DecodingError.dataCorruptedError(forKey: .id, in: c, debugDescription: "id 不能为空")
        }
        self.category = try c.decode(ShortcutCategory.self, forKey: .category)
        self.subcategory = try c.decode(String.self, forKey: .subcategory)
        guard !self.subcategory.isEmpty else {
            throw DecodingError.dataCorruptedError(forKey: .subcategory, in: c, debugDescription: "subcategory 不能为空")
        }
        self.displayKey = try c.decode(String.self, forKey: .displayKey)
        guard !self.displayKey.isEmpty else {
            throw DecodingError.dataCorruptedError(forKey: .displayKey, in: c, debugDescription: "displayKey 不能为空")
        }
        self.description = try c.decode(String.self, forKey: .description)
        guard !self.description.isEmpty else {
            throw DecodingError.dataCorruptedError(forKey: .description, in: c, debugDescription: "description 不能为空")
        }
        self.appScope = try c.decode([String].self, forKey: .appScope)
        guard !self.appScope.isEmpty else {
            throw DecodingError.dataCorruptedError(forKey: .appScope, in: c, debugDescription: "appScope 不能为空数组")
        }
        // 验证 appScope 值域
        // v0.2:用 ShortcutCategory.allValidAppScopes(包含语义 scope + distro 标签)
        // 不能用 allCases,否则 distro 标签(vanilla/doom/spacemacs)会被拒
        let validScopes = ShortcutCategory.allValidAppScopes
        for scope in self.appScope {
            guard validScopes.contains(scope) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .appScope, in: c,
                    debugDescription: "appScope 包含非法值: \(scope), 合法值域: \(validScopes.sorted())"
                )
            }
        }
        self.verifiedAgainst = try c.decode(String.self, forKey: .verifiedAgainst)
        self.verifiedDate = try c.decode(String.self, forKey: .verifiedDate)
        self.aliases = try c.decode([String].self, forKey: .aliases)
    }

    /// 显式 init(测试和程序构造时使用)
    public init(
        id: String,
        category: ShortcutCategory,
        subcategory: String,
        displayKey: String,
        description: String,
        appScope: [String],
        verifiedAgainst: String,
        verifiedDate: String,
        aliases: [String]
    ) {
        self.id = id
        self.category = category
        self.subcategory = subcategory
        self.displayKey = displayKey
        self.description = description
        self.appScope = appScope
        self.verifiedAgainst = verifiedAgainst
        self.verifiedDate = verifiedDate
        self.aliases = aliases
    }
}
