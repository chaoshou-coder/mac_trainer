# Mac Keyboard Trainer

> A keyboard-shortcut practice tool for macOS, built from Apple's official user guide.
>
> 中文文档: [README.zh.md](README.zh.md)

[![Swift](https://img.shields.io/badge/Swift-5.9-F05138.svg)](https://swift.org)
[![macOS](https://img.shields.io/badge/macOS-14%2B-000000.svg)](https://www.apple.com/macos)
[![Platform](https://img.shields.io/badge/Platform-macOS-blue.svg)](https://www.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](#license)
[![GitHub stars](https://img.shields.io/github/stars/chaoshou-coder/mac_trainer.svg)](https://github.com/chaoshou-coder/mac_trainer/stargazers)

---

Mac Keyboard Trainer catalogs 202 macOS shortcuts across six sections — system, Finder, Terminal, text editing, VSCode, and Chrome — with three-pane browsing, ⌘F cross-field search, ⌘R two-direction random quiz, and a four-state progress tracker. The app only guides; you practice on your real Mac. No simulated UI, no account, no cloud — all progress stays in local UserDefaults.

## Why MacTrainer

- **Built from Apple official docs** — every shortcut traces to a source, no crowd-sourced guesses
- **No fake UI to practice in** — you go practice on your real Mac, the app tracks what you actually learned
- **Two-direction quiz** — 50% multiple choice + 50% type the shortcut, proves you can both read and recall
- **Local-first** — no account, no cloud sync, all data in macOS UserDefaults
- **Native macOS** — SwiftUI, NavigationSplitView, dark mode auto-adapts

## Features

| Section | Shortcuts | Coverage |
|---------|-----------|----------|
| System | 55 | Spotlight, screenshots, Mission Control, accessibility, Dock, menubar |
| Finder | 39 | Navigation, file ops, view modes, tags, tabs, AirDrop |
| Terminal | 31 | Window/tab/split, navigation, edit, shell readline, search |
| Text editing | 28 | Cursor, selection, delete, format, clipboard, find |
| VSCode | 24 | Command palette, file ops, editor, search, debug, Git |
| Chrome | 25 | Tabs, windows, navigation, bookmarks, history, downloads, DevTools |

- `⌘F` search across displayKey, description, aliases, and category
- `⌘R` starts a quiz session, randomly sampled from your practiced shortcuts
- Four-state progress: `unseen` -> `practiced` -> `mastered`; mistakes go to `recent_mistakes`
- Mistake count auto-resets when you reach `mastered`
- Practice on your real Mac — the app never shows you a fake UI to learn in

## Quick Start

### Requirements

- macOS 14.0 or later
- Xcode 15 or later (Swift 5.9+)

### Build and Run

```bash
git clone https://github.com/chaoshou-coder/mac_trainer.git
cd mac_trainer
open Package.swift
```

Xcode treats the Swift Package as a project. Press `⌘U` to run tests, `⌘R` to launch.

### Command-Line

```bash
swift test     # run the full test suite (42 tests)
swift run      # build and launch the app
```

## Architecture

```
+------------------+     +-----------------+     +------------------+
|                  |     |                 |     |                  |
|     Sidebar      |---->|      Middle     |---->|      Detail      |
|  (6 categories)  |     |  (search +      |     |   (toggle +      |
|                  |     |   list view)    |     |    source)       |
|                  |     |                 |     |                  |
+------------------+     +-----------------+     +------------------+
                                                          |
                                                          |  ⌘R
                                                          v
                                                  +------------------+
                                                  |                  |
                                                  |    Quiz Panel    |
                                                  |  multiple choice |
                                                  |       +          |
                                                  |     type key     |
                                                  |                  |
                                                  +------------------+
```

| Module | Responsibility |
|--------|----------------|
| `Model/` | Shortcut data, normalization, search index |
| `Review/` | 4-state machine, distractor generation, key matcher |
| `Views/` | SwiftUI NavigationSplitView, dark-mode-ready |
| `Persistence/` | UserDefaults wrapper for progress + mistakes |
| `AppModel` | Single `@Observable` source of truth, coordinates layers |

## Tech Stack

- **Language**: Swift 5.9
- **UI**: SwiftUI + NavigationSplitView
- **State**: `@Observable` (Observation framework)
- **Tests**: Swift Testing (`import Testing`)
- **Build**: Swift Package Manager
- **Deployment Target**: macOS 14.0+

## Data Structure

Each shortcut is one entry in `Sources/MacTrainer/Resources/data/shortcuts.json`:

```json
{
  "id": "sys.spotlight.open",
  "category": "system",
  "subcategory": "spotlight",
  "displayKey": "⌘Space",
  "description": "Open Spotlight",
  "appScope": ["system"],
  "verifiedAgainst": "macOS 14 Apple User Guide",
  "verifiedDate": "2026-06-20",
  "aliases": ["Cmd+Space"]
}
```

At startup the app validates:

- unique `id`
- `appScope` values are in the known set
- `displayKey` and aliases are allowed to repeat across different apps — the same key combo (Cmd+N, Cmd+Backspace, ...) means different things in Finder, Terminal, text editing, etc., so global uniqueness would reject legitimate entries

Any violation fails startup and prints the offending field.

## Roadmap

- **v0.1 (this)** — 202 shortcuts, three-pane UI, two-direction quiz
- **v0.2** — Add Safari, Mail, Notes (only data changes, no code)
- **v0.3** — Customizable section ordering + per-section progress notes
- **v1.0** — macOS 13 support, sign + notarize for distribution

## Contributing

This is a personal learning tool, but forks are welcome. The data file is the single source of truth for what shortcuts the app knows — adding new shortcuts only requires editing `Sources/MacTrainer/Resources/data/shortcuts.json`.

To add a section: edit `Sources/MacTrainer/Model/ShortcutCategory.swift` first, then add entries to the JSON.

## Acknowledgments

Data sources:
- Apple User Guide for macOS — [support.apple.com/guide/macbook](https://support.apple.com/guide/macbook)
- VSCode Keybindings — [code.visualstudio.com/docs/getstarted/keybindings](https://code.visualstudio.com/docs/getstarted/keybindings)
- Chrome Keyboard Shortcuts — [support.google.com/chrome/answer/157179](https://support.google.com/chrome/answer/157179)

## License

MIT — see [LICENSE](LICENSE).

---

Built with care in Swift + SwiftUI. Made for personal use, shared so others can fork and adapt.