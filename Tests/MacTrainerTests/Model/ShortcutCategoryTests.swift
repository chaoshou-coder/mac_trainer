import Testing
import Foundation
@testable import MacTrainer

final class ShortcutCategoryTests {
    // MARK: - enum cases(v0.2 加 .emacs 和 .vim,共 8 case)

    @Test func allCasesCountIs8() {
        #expect(ShortcutCategory.allCases.count == 8)
    }

    @Test func allCasesIncludesEmacs() {
        #expect(ShortcutCategory.allCases.contains(.emacs))
    }

    @Test func allCasesIncludesVim() {
        #expect(ShortcutCategory.allCases.contains(.vim))
    }

    // MARK: - displayName 全 8 case 不空

    @Test func displayNameNonEmptyForAllCases() {
        for cat in ShortcutCategory.allCases {
            #expect(!cat.displayName.isEmpty, "displayName empty for \(cat)")
        }
    }

    @Test func displayNameForEmacs() {
        #expect(ShortcutCategory.emacs.displayName == "Emacs")
    }

    @Test func displayNameForVim() {
        #expect(ShortcutCategory.vim.displayName == "Vim")
    }

    // MARK: - iconSystemName 全 8 case 不空(v0.2:T1 防止漏 switch 分支)

    @Test func iconSystemNameNonEmptyForAllCases() {
        for cat in ShortcutCategory.allCases {
            #expect(!cat.iconSystemName.isEmpty, "iconSystemName empty for \(cat)")
        }
    }

    // MARK: - allValidAppScopes constant

    @Test func allValidAppScopesIncludesAllEnumRawValues() {
        let scopeSet = ShortcutCategory.allValidAppScopes
        for cat in ShortcutCategory.allCases {
            #expect(scopeSet.contains(cat.rawValue), "missing \(cat.rawValue) in allValidAppScopes")
        }
    }

    @Test func allValidAppScopesIncludesDistroLabels() {
        #expect(ShortcutCategory.allValidAppScopes.contains("vanilla"))
        #expect(ShortcutCategory.allValidAppScopes.contains("doom"))
        #expect(ShortcutCategory.allValidAppScopes.contains("spacemacs"))
    }

    // MARK: - distroScopes constant(只装 distro 标签,不混 semantic scope)

    @Test func distroScopesContainsOnlyDistros() {
        #expect(ShortcutCategory.distroScopes == Set(["vanilla", "doom", "spacemacs"]))
    }

    @Test func distroScopesDoesNotContainSemanticScopes() {
        // Outside Voice #2 修:distro chip 不能混 semantic scope
        #expect(!ShortcutCategory.distroScopes.contains("emacs"))
        #expect(!ShortcutCategory.distroScopes.contains("vim"))
        #expect(!ShortcutCategory.distroScopes.contains("system"))
    }
}
