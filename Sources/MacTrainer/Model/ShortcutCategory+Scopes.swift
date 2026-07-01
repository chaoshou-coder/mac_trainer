import Foundation

/// `ShortcutCategory` 扩展:集中管理 appScope 值域和 distro filter 标签
///
/// 加新 enum case 时,记得:
/// 1. `ShortcutCategory` 的 `displayName` / `iconSystemName` switch 加分支
/// 2. `allValidAppScopes` 加对应 rawValue(如果新 case 的 shortcut 会用 `appScope: ["<newCase>"]`)
/// 3. JSON `categories` 数组加对应 rawValue(`validate()` 强制对齐)
public extension ShortcutCategory {
    /// 所有合法的 `appScope` 值
    /// - 语义 scope:6 个 macOS category rawValue + v0.2 加的 emacs + vim
    /// - distro filter 标签:vanilla / doom / spacemacs(用于按 emacs disto 过滤)
    static let allValidAppScopes: Set<String> = Set([
        "system", "finder", "terminal", "text", "vscode", "chrome",
        "emacs", "vim",
        "vanilla", "doom", "spacemacs"
    ])

    /// 仅 distro filter 用的标签
    /// UI 渲染 appScopeFilter chip 行时用(只从当前 category 的 shortcut 聚合 distro 标签)
    /// 不混入语义 scope(否则 "emacs" 也会变成一个 distro chip,见 Outside Voice #2)
    static let distroScopes: Set<String> = ["vanilla", "doom", "spacemacs"]
}
