# Mac 全键盘训练器 (MacTrainer)

> 基于 Apple 官方用户指南的 macOS 全键盘练习工具。
>
> English: [README.md](README.md)

[![Swift](https://img.shields.io/badge/Swift-5.9-F05138.svg)](https://swift.org)
[![macOS](https://img.shields.io/badge/macOS-14%2B-000000.svg)](https://www.apple.com/macos)
[![Platform](https://img.shields.io/badge/Platform-macOS-blue.svg)](https://www.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](#license)
[![GitHub stars](https://img.shields.io/github/stars/chaoshou-coder/mac_trainer.svg)](https://github.com/chaoshou-coder/mac_trainer/stargazers)

---

Mac 全键盘训练器按 Apple 官方用户指南的章节结构,整理 macOS 系统、Finder、Terminal、文本编辑、VSCode、Chrome 六大板块共 203 条快捷键,提供三栏浏览、⌘F 跨字段搜索、⌘R 双向随机抽考和四状态进度跟踪。app 只做引导,真练回到你的 Mac;不画假 UI、不注册账号、不上传数据,所有进度保存在本机 UserDefaults。

## 为什么做这个

- **完全基于 Apple 官方文档** — 每条快捷键都能追到出处,没有民间猜测
- **不画假 UI 让你练** — 你直接回真实 Mac 里练,app 只负责记录你真学到了什么
- **双向随机抽考** — 50% 四选一 + 50% 手写快捷键,既考认读也考回忆
- **本地优先** — 不要账号,不要云同步,所有数据都在 macOS UserDefaults
- **原生 macOS** — SwiftUI、NavigationSplitView、暗色模式自动适配

## 功能一览

| 板块 | 快捷键数 | 覆盖范围 |
|------|----------|----------|
| 系统 | 55 | Spotlight、截屏、Mission Control、辅助功能、Dock、菜单栏 |
| Finder | 35 | 导航、文件操作、视图模式、标签、标签页、AirDrop |
| Terminal | 31 | 窗口/标签页/拆分、导航、编辑、shell readline、搜索 |
| 文本编辑 | 28 | 光标、选择、删除、格式、剪贴板、查找 |
| VSCode | 27 | 命令面板、文件操作、编辑器、搜索、调试、Git |
| Chrome | 27 | 标签页、窗口、导航、书签、历史、下载、开发者工具 |

- `⌘F` 跨字段搜索:displayKey、描述、aliases、category 一把搜
- `⌘R` 启动抽考:从你已练过的快捷键里随机抽样
- 四状态进度:`unseen` → `practiced` → `mastered`,答错的进 `recent_mistakes`
- 到达 `mastered` 时自动重置错误计数
- 真练永远在你的 Mac 上,app 从不显示假 UI

## 快速开始

### 环境要求

- macOS 14.0 或更高
- Xcode 15 或更高(Swift 5.9+)

### 构建与运行

```bash
git clone https://github.com/chaoshou-coder/mac_trainer.git
cd mac_trainer
open Package.swift
```

Xcode 把 Swift Package 当作项目,直接 `⌘U` 跑测试、`⌘R` 启动 app。

### 命令行

```bash
swift test     # 跑全部测试(约 40 个)
swift run      # 编译并启动
```

## 架构

```
+------------------+     +-----------------+     +------------------+
|                  |     |                 |     |                  |
|     Sidebar      |---->|      Middle     |---->|      Detail      |
|   (6 大板块)     |     |  (搜索 +        |     |   (勾选 +        |
|                  |     |   列表)         |     |    来源)         |
|                  |     |                 |     |                  |
+------------------+     +-----------------+     +------------------+
                                                          |
                                                          |  ⌘R
                                                          v
                                                  +------------------+
                                                  |                  |
                                                  |    抽考面板      |
                                                  |   四选一 +       |
                                                  |   手输快捷键     |
                                                  |                  |
                                                  +------------------+
```

| 模块 | 职责 |
|------|------|
| `Model/` | 快捷键数据、Normalization 归一化、SearchIndex |
| `Review/` | 四状态机、4 选 1 干扰项生成、手输判分 |
| `Views/` | SwiftUI NavigationSplitView、暗色模式适配 |
| `Persistence/` | UserDefaults 封装(进度 + 错题计数) |
| `AppModel` | 集中 `@Observable`,协调各层 |

## 技术栈

- **语言**:Swift 5.9
- **UI**:SwiftUI + NavigationSplitView
- **状态管理**:`@Observable`(Observation 框架)
- **测试**:Swift Testing(`import Testing`)
- **构建**:Swift Package Manager
- **部署目标**:macOS 14.0+

## 数据结构

每条快捷键是 `Sources/MacTrainer/Resources/data/shortcuts.json` 里的一条:

```json
{
  "id": "sys.spotlight.open",
  "category": "system",
  "subcategory": "spotlight",
  "displayKey": "⌘Space",
  "description": "打开 Spotlight 搜索",
  "appScope": ["system"],
  "verifiedAgainst": "macOS 14 Apple User Guide",
  "verifiedDate": "2026-06-20",
  "aliases": ["Cmd+Space"]
}
```

启动时 app 校验:

- `id` 唯一
- `displayKey` 归一后唯一
- aliases 归一后与任何 displayKey 不冲突
- `appScope` 值在已知集合内

任何一条违反,app 拒启动并打印错误。

## 路线图

- **v0.1(当前)** — 203 条快捷键、三栏 UI、双向抽考
- **v0.2** — 新增 Safari、Mail、Notes(只改 JSON)
- **v0.3** — 板块顺序可自定义 + 各板块进度笔记
- **v1.0** — 支持 macOS 13,签名 + 公证分发

## 参与贡献

这是一个个人学习工具,但欢迎 fork。数据文件是 app "知道哪些快捷键"的唯一来源——加新快捷键只需编辑 `Sources/MacTrainer/Resources/data/shortcuts.json`。

要加新板块:先改 `Sources/MacTrainer/Model/ShortcutCategory.swift`,再加 JSON 条目。

## 致谢

数据来源:
- Apple macOS User Guide — [support.apple.com/guide/macbook](https://support.apple.com/guide/macbook)
- VSCode Keybindings — [code.visualstudio.com/docs/getstarted/keybindings](https://code.visualstudio.com/docs/getstarted/keybindings)
- Chrome Keyboard Shortcuts — [support.google.com/chrome/answer/157179](https://support.google.com/chrome/answer/157179)

## 许可证

MIT — 见 [LICENSE](LICENSE)。

---

用 Swift + SwiftUI 认真写的。为个人使用而做,分享出来方便别人 fork 改造。