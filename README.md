# Mac 全键盘训练器(MacTrainer)

按 Apple 官方文档结构组织的 macOS 全键盘练习工具,Swift + SwiftUI 原生 macOS 14+ 应用。

## 功能

- 按板块(系统 / Finder / Terminal / 文本编辑 / VSCode / Chrome)浏览快捷键
- ⌘F 跨字段模糊搜索(displayKey + description + aliases + category)
- 勾选"我练过了"标记状态,UserDefaults 持久化
- ⌘R 触发抽考:50% 概率"看键选功能(4 选 1)"、50% 概率"看功能手输键"
- 4 状态机(unseen / practiced / mastered / recentMistakes),D6 统一阈值
- 暗色模式自动适配(语义色 + system materials)

## 项目结构

```
MacTrainer/
├── Sources/MacTrainer/
│   ├── App/                # @main entry
│   ├── Model/              # Shortcut, Normalization, ShortcutsBundle, SearchIndex
│   ├── Review/             # StateMachine, DistractorGenerator, KeyMatcher, QuizSession
│   ├── Views/              # ContentView, Sidebar, Middle, Detail, SearchField, QuizPanel
│   ├── Persistence/        # ProgressStore, MistakeCountStore (UserDefaults)
│   ├── Resources/data/     # shortcuts.json (80+ 条预置)
│   └── AppModel.swift      # 集中 @Observable
└── Tests/MacTrainerTests/
    ├── Model/              # 4 个测试文件
    ├── Review/             # 3 个测试文件
    ├── Integration/        # 端到端测试
    └── Fixtures/           # shortcuts_sample.json (10 条), shortcuts_edge.json (3 条)
```

## 在 Mac 上开发

### 方式 1:Swift Package Manager(推荐用于开发)

```bash
git clone <repo>
cd mac_trainer
open Package.swift  # 用 Xcode 打开整个 package
swift test          # 运行所有测试
swift run           # 编译并运行
```

Xcode 会把 SPM package 当作项目,可以直接 build / run / test。

### 方式 2:导出为 .app bundle

Xcode 中: Product > Archive > Distribute App > Copy App

把 `MacTrainer.app` 拖到 `/Applications/` 即可。

## 数据

预置 80+ 条快捷键(覆盖 6 板块)。要扩充:

1. 编辑 `Sources/MacTrainer/Resources/data/shortcuts.json`
2. 加新条目,严格遵守 schema(每条都有 id / category / subcategory / displayKey / description / appScope / verifiedAgainst / verifiedDate / aliases)
3. `verifiedDate` 用 YYYY-MM-DD 格式
4. 重新 build

数据加载时会自动检查:
- id 唯一
- displayKey 归一后唯一
- aliases 归一后不与 displayKey 冲突
- appScope 值域合法

任何一条违反,app 启动失败并打印错误。

## 测试

```bash
swift test
```

测试覆盖(按 plan T2 + T4 + T5):
- Model:ShortcutTests(5)、NormalizationTests(9)、SearchIndexTests(5)
- Review:StateMachineTests(8)、DistractorGeneratorTests(6)、KeyMatcherTests(6)
- Integration:AppModelEndToEndTests(2)

合计 ~40 个测试。

## 状态机(D6 修订)

```
unseen ──[勾选已练]──> practiced
unseen ──[任意错误]──> practiced                  (防御性)
practiced ──[答对]──> practiced                   (累计)
practiced ──[答对 3 次累计]──> mastered           (重置 mistakeCount)
practiced ──[错误次数累计 ≥ 2]──> recentMistakes
mastered ──[答错]──> practiced
recentMistakes ──[答对 1 次]──> practiced
recentMistakes ──[答对 2 次]──> mastered          (跳过 practiced)
```

## 已知限制

- 不支持 macOS 13(部署目标 14.0)
- 无 iCloud 同步
- 无答题时间序列(无法画"进步曲线",留 v2)
- 无多语言
- 部署目标 macOS 14,本机是 14.0 时才能跑
- 数据手工录入 80+ 条(设计目标 200 条,v1.0 你可以补)
- 首次启动未签名 app 需要右键打开

## 设计文档

- `~/.gstack/projects/mac_trainer/AAAKPDS-unknown-design-20260624-000457.md` - 总体设计
- `~/.gstack/projects/mac_trainer/AAAKPDS-unknown-eng-review-20260624-002256.md` - 工程评审

## 下一步

- 补数据到 200 条(目前 80+)
- 7 天 dogfood 记录体感问题
- 修发现的小 bug
- v2 加 Safari/Mail/Notes
