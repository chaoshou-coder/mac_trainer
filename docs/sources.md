# 数据来源与核验

## 来源清单

| 来源 | 用途 | 链接 |
|------|------|------|
| Apple User Guide (macOS 14.x) | 系统 / Finder / Terminal / 文本编辑快捷键 | https://support.apple.com/guide/macbook/welcome/mac |
| VSCode Keybindings | VSCode 快捷键 | https://code.visualstudio.com/docs/getstarted/keybindings |
| Chrome Keyboard Shortcuts | Chrome 快捷键 | https://support.google.com/chrome/answer/157179 |

## 核验节奏

- **初次录入**:2026-06-24,基于 macOS 14 / VSCode 1.89 / 当前 Chrome
- **每年复核**:macOS 大版本发布后 2 周内做一次全量复核
- **字段 `verifiedDate` 超过 12 个月**的条目须人工再核验

## 字段说明

每条快捷键有:
- `id`:唯一,小写 + 点分隔
- `category`:6 个枚举值之一
- `subcategory`:人工分类(如 `spotlight`、`screenshot`)
- `displayKey`:Unicode 符号(⌘ ⇧ ⌥ ⌃),按 ⌃ ⌥ ⇧ ⌘ 顺序
- `description`:中文描述
- `appScope`:生效的 app,数组(可在多个 app 用)
- `verifiedAgainst`:核验来源(Apple User Guide / VSCode 1.89 / Chrome ...)
- `verifiedDate`:核验日期 YYYY-MM-DD
- `aliases`:同义英文写法(搜索和判分容错用)

## 录入顺序建议

1. 系统级(macOS 通用,影响所有 app)
2. Finder / Terminal(Apple 内置)
3. 文本编辑(全 app 通用)
4. VSCode
5. Chrome

## 待补(200 条目标)

目前 80+ 条,差 120+ 条。建议:
- 系统级再补 30 条(辅助功能、快捷键自定义)
- 文本编辑补 20 条(更多光标移动、选择操作)
- Terminal 补 20 条(更多 shell 操作)
- VSCode 补 30 条
- Chrome 补 20 条
