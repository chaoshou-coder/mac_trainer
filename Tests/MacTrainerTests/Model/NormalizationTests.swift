import Testing
import Foundation
@testable import MacTrainer

final class NormalizationTests {
    @Test func basicCmd() {
        #expect(Normalization.normalize("Cmd+Space") == "⌘Space")
    }

    @Test func basicShift() {
        #expect(Normalization.normalize("Cmd+Shift+3") == "⇧⌘3")
    }

    @Test func basicCtrl() {
        #expect(Normalization.normalize("Ctrl+C") == "⌃C")
    }

    @Test func basicOption() {
        #expect(Normalization.normalize("Option+Left") == "⌥←")
    }

    @Test func caseInsensitive() {
        #expect(Normalization.normalize("cmd+space") == "⌘Space")
        #expect(Normalization.normalize("CMD+SPACE") == "⌘Space")
    }

    @Test func modifierOrder() {
        // 顺序固定为 ⌃ ⌥ ⇧ ⌘
        #expect(Normalization.normalize("Cmd+Ctrl+Shift") == "⌃⇧⌘")
        #expect(Normalization.normalize("Shift+Cmd+Ctrl") == "⌃⇧⌘")
        #expect(Normalization.normalize("Ctrl+Shift+Option+Cmd") == "⌃⌥⇧⌘")
    }

    @Test func stripsSpace() {
        #expect(Normalization.normalize(" Cmd + Space ") == "⌘Space")
    }

    @Test func noModifier() {
        #expect(Normalization.normalize("Space") == "Space")
        #expect(Normalization.normalize("F1") == "F1")
    }

    @Test func aliasMapping() {
        #expect(Normalization.normalize("Alt+Tab") == "⌥⇥")
        #expect(Normalization.normalize("Esc") == "⎋")
        #expect(Normalization.normalize("Enter") == "⏎")
        #expect(Normalization.normalize("Backspace") == "⌫")
    }
}
