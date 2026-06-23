import Foundation

/// 共享 normalization 函数
/// 在加载和判分时都被调用(必须只有一份,见 plan Code Quality P1)
public enum Normalization {
    private static let modifierMap: [String: String] = [
        "cmd": "⌘", "command": "⌘",
        "shift": "⇧",
        "ctrl": "⌃", "control": "⌃",
        "option": "⌥", "alt": "⌥",
        "tab": "⇥",
        "enter": "⏎", "return": "⏎",
        "backspace": "⌫", "delete": "⌫",
        "esc": "⎋", "escape": "⎋"
    ]

    private static let modifierOrder: [String] = ["⌃", "⌥", "⇧", "⌘"]

    /// 把 "Cmd+Shift+A" 归一为 "⇧⌘A"
    /// 规则:
    /// - 英文修饰键符号替换为 Unicode
    /// - 去空格
    /// - 去 "+"
    /// - 修饰键按 ⌃ ⌥ ⇧ ⌘ 顺序排序
    public static func normalize(_ raw: String) -> String {
        let lower = raw.lowercased()
        // 拆分 token: 按 + 或空格
        let tokens = lower
            .replacingOccurrences(of: " ", with: "")
            .split(separator: "+", omittingEmptySubsequences: true)
            .map(String.init)

        var modifiers: [String] = []
        var main = ""

        for token in tokens {
            if let mapped = modifierMap[token] {
                if !modifiers.contains(mapped) {
                    modifiers.append(mapped)
                }
            } else {
                // 非修饰键:取第一个字母(快捷键主键通常是一个字符)
                main = token.uppercased()
            }
        }

        // 按固定顺序排序
        modifiers.sort { a, b in
            let ai = modifierOrder.firstIndex(of: a) ?? Int.max
            let bi = modifierOrder.firstIndex(of: b) ?? Int.max
            return ai < bi
        }

        return modifiers.joined() + main
    }

    /// 归一 displayKey(用于初始化时)
    public static func normalizeDisplayKey(_ raw: String) -> String {
        normalize(raw)
    }
}
