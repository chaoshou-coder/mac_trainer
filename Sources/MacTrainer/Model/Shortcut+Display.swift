import Foundation

/// `Shortcut` 扩展:UI 渲染 helper
///
/// v0.2 加 `displayKeyAnnotated`,渲染 "ASCII (Unicode)" 形式:
/// - `displayKey: "C-x"` → `"C-x (⌃X)"` ← C 变 ⌃(不同 symbol)
/// - `displayKey: "M-x"` → `"M-x"` ← M 是 key letter,normalize 后跟 ASCII 同字符(只是 case)
/// - `displayKey: "⌘A"` → `"⌘A"` ← ⌘ 不变
/// - `displayKey: "h"` → `"h"` ← 单字母,normalize 后 uppercase 但只是 case
///
/// 规则:
/// 1. normalize 拿到 unicode 形式(全小写)
/// 2. 如果 ascii 首字母大写,unicode 整段大写(保留 case 信息)
/// 3. 过滤掉分隔符(`-`、空格),字母 lowercase 后比较
/// 4. 完全一致(只是大小写)→ 不显示括号;有 symbol 差异 → 显示
public extension Shortcut {
    var displayKeyAnnotated: String {
        let ascii = displayKey
        let normalized = Normalization.normalize(ascii)
        // 保留 ascii 首字母大小写
        let firstIsUpper = ascii.first.map { $0.isUppercase } ?? false
        let unicode = firstIsUpper ? normalized.uppercased() : normalized
        // 过滤掉 - 和空格,只比 alphanumeric(忽略 normalize 抹掉的 dash)
        let alphanum: (String) -> String = { s in
            s.filter { $0.isLetter || $0.isNumber }.lowercased()
        }
        if alphanum(ascii) == alphanum(unicode) {
            return ascii
        }
        return "\(ascii) (\(unicode))"
    }
}
