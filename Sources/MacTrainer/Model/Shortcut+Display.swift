import Foundation

/// `Shortcut` 扩展:UI 渲染 helper
///
/// v0.2 加 `displayKeyAnnotated`,渲染 "ASCII (Unicode)" 形式:
/// - `displayKey: "C-x"` → `"C-x (⌃X)"`
/// - `displayKey: "⌘A"` → `"⌘A"`(ASCII == Unicode,不显示括号)
/// - `displayKey: "M-x"` → `"M-x"`(meta normalize 后是 M,ASCII == Unicode)
/// - v0.3 扩展:有 `sequence` 时返回 `"C-x C-s (⌃X ⌃S)"`
public extension Shortcut {
    /// UI 渲染:ASCII 主体 + Unicode 符号在括号(如果两者不同)
    /// emacs 圈习惯 ASCII 形式("C-x" / "M-x"),但 Mac 用户看 ⌃X / ⌥X 更直观
    /// 两者都顾到
    var displayKeyAnnotated: String {
        let ascii = displayKey
        let unicode = Normalization.normalize(ascii)
        // 如果 ASCII == Unicode(或者只是大小写不同,避免冗余括号)
        if ascii == unicode || ascii == unicode.lowercased() {
            return ascii
        }
        return "\(ascii) (\(unicode))"
    }
}
