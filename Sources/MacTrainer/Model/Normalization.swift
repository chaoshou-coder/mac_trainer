import Foundation

/// 共享 normalization 函数
/// 在加载和判分时都被调用(必须只有一份,见 plan Code Quality P1)
public enum Normalization {
    /// 键名 → canonical 形式
    /// - 修饰键 → 符号
    /// - 特殊键(Tab/Esc/Enter/Backspace)→ 符号
    /// - 方向键 → 箭头符号
    /// - "space"/"f1"..."f12" → 保留 canonical 大小写
    private static let keyMap: [String: String] = [
        // Modifiers
        "cmd": "⌘", "command": "⌘",
        "shift": "⇧",
        "ctrl": "⌃", "control": "⌃",
        "option": "⌥", "alt": "⌥",
        "meta": "M",  // v0.2:emacs Meta key(完整形式,emacs 简写走 expandEmacsNotation)
        // Special keys
        "tab": "⇥",
        "enter": "⏎", "return": "⏎",
        "backspace": "⌫", "delete": "⌫",
        "esc": "⎋", "escape": "⎋",
        // Arrows
        "left": "←", "right": "→", "up": "↑", "down": "↓",
        // Canonical-case forms
        "space": "Space",
        "f1": "F1", "f2": "F2", "f3": "F3", "f4": "F4",
        "f5": "F5", "f6": "F6", "f7": "F7", "f8": "F8",
        "f9": "F9", "f10": "F10", "f11": "F11", "f12": "F12",
    ]

    private static let modifierSymbols: Set<String> = ["⌘", "⇧", "⌃", "⌥", "M"]  // v0.2:M 是 emacs Meta
    private static let modifierOrder: [String] = ["⌃", "⌥", "M", "⇧", "⌘"]  // M 排 ⌥ 后 ⇧ 前

    /// v0.2:emacs 简写展开
    /// "C-x" → "Ctrl+x"(前缀 C 是 Ctrl)
    /// "M-x" → "Meta+x"(前缀 M 是 Meta)
    /// "S-x" → "Shift+x"(前缀 S 是 Shift)
    /// 规则:不含 "+" 且第 1 字符是 C/M/S 且含 "-" 且长度 ≥ 3
    /// 避免 "c" 在 keyMap 里同时是 modifier 又可能是 main key 的冲突
    private static func expandEmacsNotation(_ raw: String) -> String {
        guard raw.count >= 3, !raw.contains("+") else { return raw }
        let first = raw.first!
        let prefix: String
        switch first {
        case "C": prefix = "Ctrl"
        case "M": prefix = "Meta"
        case "S": prefix = "Shift"
        default: return raw
        }
        // 找 "-" 分隔符,确保 "-" 后面有内容
        guard let dashIdx = raw.firstIndex(of: "-"),
              raw.index(after: dashIdx) < raw.endIndex else { return raw }
        let rest = String(raw[raw.index(after: dashIdx)...])
        return "\(prefix)+\(rest)"
    }

    /// 把 "Cmd+Shift+A" 归一为 "⇧⌘A"
    /// 规则:
    /// - 英文修饰键符号替换为 Unicode
    /// - 去空格和 "+"
    /// - 修饰键按 ⌃ ⌥ ⇧ ⌘ 顺序排序
    /// - 主键保留 canonical 形式(单字母 uppercase,其它按 keyMap)
    public static func normalize(_ raw: String) -> String {
        // v0.2:emacs 简写预处理("C-x" → "Ctrl+x", "M-x" → "Meta+x", "S-x" → "Shift+x")
        // 避免 keyMap 同时含 "c" → ⌃(让 emacs "C-x" 工作)跟 "Ctrl+C" 里 "c" 是 main key 的冲突
        // 规则:input 不含 "+" 且 第 1 字符是 C/M/S 且 含 "-" 且 长度 ≥ 3
        let input = expandEmacsNotation(raw)
        let lower = input.lowercased()
        let tokens = lower
            .replacingOccurrences(of: " ", with: "")
            .split(separator: "+", omittingEmptySubsequences: true)
            .map(String.init)

        var modifiers: [String] = []
        var main = ""

        for token in tokens {
            if let mapped = keyMap[token] {
                if modifierSymbols.contains(mapped) {
                    if !modifiers.contains(mapped) {
                        modifiers.append(mapped)
                    }
                } else {
                    // 特殊键符号(Tab→⇥、Esc→⎋、←→等)或 canonical 形式("Space"、"F1")
                    main = mapped
                }
            } else {
                // 未知 token:单字母 uppercase,其它原样保留
                if token.count == 1, let c = token.first, c.isLetter {
                    main = String(c).uppercased()
                } else {
                    main = token
                }
            }
        }

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
