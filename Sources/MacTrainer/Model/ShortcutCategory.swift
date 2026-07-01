import Foundation

/// 板块枚举:对应 Sidebar 板块
/// 注意:值域必须在 `Shortcut.appScope` 中一致,否则边界检查拒绝
/// 加新 case 时,记得:`allValidAppScopes` 加对应 rawValue + `displayName`/`iconSystemName` 加 switch 分支
public enum ShortcutCategory: String, Codable, CaseIterable, Sendable {
    case system
    case finder
    case terminal
    case text
    case vscode
    case chrome
    case emacs    // v0.2 新加
    case vim      // v0.2 新加

    public var displayName: String {
        switch self {
        case .system: return "系统"
        case .finder: return "Finder"
        case .terminal: return "Terminal"
        case .text: return "文本编辑"
        case .vscode: return "VSCode"
        case .chrome: return "Chrome"
        case .emacs: return "Emacs"
        case .vim: return "Vim"
        }
    }

    public var iconSystemName: String {
        switch self {
        case .system: return "macwindow"
        case .finder: return "folder"
        case .terminal: return "terminal"
        case .text: return "text.alignleft"
        case .vscode: return "chevron.left.forwardslash.chevron.right"
        case .chrome: return "globe"
        case .emacs: return "terminal"
        case .vim: return "text.cursor"
        }
    }
}
