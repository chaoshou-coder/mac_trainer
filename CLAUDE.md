# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

MacTrainer is a native macOS keyboard-shortcut practice tool. It catalogs 203 macOS shortcuts across six sections (system, Finder, Terminal, text editing, VSCode, Chrome), with a three-pane browsing UI, ⌘F cross-field search, ⌘R random quiz, and a four-state progress tracker. The app is a guide only — the user practices on their real Mac. All progress is stored locally in `UserDefaults`.

Stack: Swift 5.9, SwiftUI (`NavigationSplitView`), `@Observable` (Observation framework), Swift Testing (`import Testing`), Swift Package Manager, macOS 14+.

## Build & test

Build the package and run the app from the command line:

```bash
swift run              # build + launch
swift test             # run the full test suite
swift build            # build only
```

Open in Xcode for the standard ⌘R / ⌘U workflow:

```bash
open Package.swift
```

Run a single test file with Swift Testing's filter:

```bash
swift test --filter StateMachineTests
swift test --filter NormalizationTests
swift test --filter AppModelEndToEndTests
```

Tests are organized to mirror the source layout (`Tests/MacTrainerTests/{Model,Review,Integration}/` ↔ `Sources/MacTrainer/{Model,Review,}`). Test JSON fixtures live in `Tests/MacTrainerTests/Fixtures/`.

## Module layout

```
Sources/MacTrainer/
├── App/                      # @main entry, window + ⌘R menu command
│   └── MacTrainerApp.swift   #   loads shortcuts on init, swallows load errors
├── AppModel.swift            # central @Observable source of truth
├── Model/                    # data + validation
│   ├── Shortcut.swift        #   Codable, with custom init for empty-field rejection
│   ├── ShortcutCategory.swift#  6-case enum; values MUST match Shortcut.appScope set
│   ├── ShortcutStatus.swift  #   4 states: unseen / practiced / mastered / recent_mistakes
│   ├── ShortcutsBundle.swift #   loadBundled() + validate() (id/displayKey/alias uniqueness)
│   ├── Normalization.swift   #   "Cmd+Shift+A" → "⇧⌘A"; fixed order ⌃ ⌥ ⇧ ⌘
│   └── SearchIndex.swift     #   case-insensitive substring match across fields
├── Review/                   # quiz logic (pure functions, no UI)
│   ├── StateMachine.swift    #   4-state machine: rules in doc-comment
│   ├── DistractorGenerator.swift  # 4-choice distractor pool (subcategory → category → global)
│   ├── KeyMatcher.swift      #   typed-input grading via Normalization
│   └── QuizSession.swift     #   50/50 multiple-choice vs type-the-key
├── Persistence/              # UserDefaults wrappers
│   ├── ProgressStore.swift   #   per-id ShortcutStatus, error log
│   └── MistakeCountStore.swift
├── Views/                    # SwiftUI
│   ├── ContentView.swift     #   NavigationSplitView, ⌘R toolbar, quiz sheet
│   ├── SidebarView.swift     #   6 sections + filter chips (全部/已练/错题)
│   ├── MiddleListView.swift  #   filtered shortcut list, status icons
│   ├── DetailView.swift      #   toggle, mistake count, source disclosure
│   ├── SearchField.swift     #   toolbar search (binds to model.searchQuery)
│   └── QuizPanelView.swift   #   sheet: MC + type-key, verdict UI
└── Resources/data/
    └── shortcuts.json        # bundled shortcut data (the source of truth for content)
```

## Key design rules

- **Single source of truth for content**: `Sources/MacTrainer/Resources/data/shortcuts.json`. Adding a shortcut only requires editing this file. Adding a new section requires editing `Sources/MacTrainer/Model/ShortcutCategory.swift` first, then the JSON.
- **Startup validation**: `ShortcutsBundle.validate()` enforces unique `id`, unique `displayKey` after Unicode normalization, and that no alias normalizes to a `displayKey` belonging to another entry. Any failure aborts app launch (or logs and continues with empty state — see `MacTrainerApp.init`).
- **Normalization is shared**: `Model/Normalization.swift` is the only place that converts `Cmd+Shift+A` ↔ `⇧⌘A`. Both `KeyMatcher` (grading) and `ShortcutsBundle.validate` (uniqueness) call it — keep it that way (do not duplicate modifier maps).
- **State machine is pure**: `StateMachine.transition()` takes `current + event + consecutiveCorrect + mistakeCount` and returns a `Transition`. All UI/store side effects live in `AppModel.applyTransition`. Rules (per the comment in `StateMachine.swift`):
  - `practiced` + 3 consecutive correct → `mastered` (resets mistakeCount)
  - `practiced` + 2 wrong → `recentMistakes`
  - `recentMistakes` + 1 correct → `practiced`; + 2 correct (from `recentMistakes` directly) → `mastered` (skips `practiced`)
  - `mastered` + wrong → `practiced` (mistakeCount increments)
  - Quiz candidates = `practiced ∪ recentMistakes` only (`StateMachine.isQuizCandidate`)
- **`AppModel` is the only place that writes to persistence**: `applyTransition` updates `statuses` + `mistakeCounts` and forwards to `ProgressStore` / `MistakeCountStore`. UI never calls the stores directly.
- **Distractor fallback chain**: same `(category, subcategory)` → same `category` → global pool. Always 4 options, never duplicates, never includes the correct answer.
- **Quiz is 50/50**: `QuizSession.nextQuestion` randomly picks between `multipleChoice` (uses `DistractorGenerator`) and `typeKey` (uses `KeyMatcher`).
- **The app never draws a fake Mac UI to practice in** — that's the product's whole point. Don't add simulators.

## Data file shape

`Sources/MacTrainer/Resources/data/shortcuts.json` schema (per the README + `docs/sources.md`):

```json
{
  "id": "sys.spotlight.open",      // unique, lowercase, dot-separated
  "category": "system",            // one of the 6 ShortcutCategory raw values
  "subcategory": "spotlight",      // free-form human label
  "displayKey": "⌘Space",          // Unicode modifier symbols in ⌃ ⌥ ⇧ ⌘ order
  "description": "Open Spotlight", // user-facing string
  "appScope": ["system"],          // non-empty; each value MUST be a valid category
  "verifiedAgainst": "macOS 14 Apple User Guide",
  "verifiedDate": "2026-06-20",    // YYYY-MM-DD; entries > 12 months old need re-verification
  "aliases": ["Cmd+Space"]         // English spellings, used for search + typed-key grading
```

Re-verify shortcuts annually (see `docs/sources.md`).

## Testing conventions

- Use Swift Testing (`import Testing`, `@Test`, `#expect`). Do not introduce XCTest unless adding a UI test target.
- Test files mirror the module path: `Tests/.../Model/NormalizationTests.swift` covers `Sources/.../Model/Normalization.swift`.
- Build `Shortcut` instances with the explicit memberwise init in tests — that's the supported test construction path. The `Codable` `init(from:)` exists for `shortcuts.json` decoding only.
- For end-to-end tests that touch `UserDefaults`, allocate a temp `UserDefaults(suiteName: "test-\(UUID())")` and `removePersistentDomain` in a `defer` (see `AppModelEndToEndTests.fullFlowCheckToQuizToMaster`).
- For tests needing many similar shortcuts, inline a private `makeShortcuts()` factory at the top of the test type (see `DistractorGeneratorTests`).
- Fixtures (`Tests/MacTrainerTests/Fixtures/*.json`) are loaded via `.process("Fixtures")` in `Package.swift`. They are *not* the bundled app data — that's a different JSON.

## Where to look first for a task

| Task type | Start here |
|-----------|-----------|
| Add a shortcut | `Resources/data/shortcuts.json` only |
| Add a section/category | `Model/ShortcutCategory.swift` first, then JSON |
| Tweak progress rules | `Review/StateMachine.swift` (pure), then `AppModel` callers |
| Change grading tolerance | `Model/Normalization.swift` (shared) |
| Change quiz UI | `Views/QuizPanelView.swift` + `Review/QuizSession.swift` |
| Change storage | `Persistence/*.swift` + `AppModel.applyTransition` (the only write path) |
| Change search | `Model/SearchIndex.swift` |
| Read design intent | `docs/design-doc.md` (zh), `README.md` / `README.zh.md` |
