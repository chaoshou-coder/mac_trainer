import Testing
import Foundation
@testable import MacTrainer

final class ShortcutTests {
    @Test func decodeValidShortcut() throws {
        let json = """
        {
          "id": "x", "category": "system", "subcategory": "spotlight",
          "displayKey": "⌘Space", "description": "test", "appScope": ["system"],
          "verifiedAgainst": "v1", "verifiedDate": "2026-06-24", "aliases": ["Cmd+Space"]
        }
        """
        let data = json.data(using: .utf8)!
        let s = try JSONDecoder().decode(Shortcut.self, from: data)
        #expect(s.id == "x")
        #expect(s.category == .system)
        #expect(s.displayKey == "⌘Space")
    }

    @Test func rejectEmptyId() {
        let json = """
        {
          "id": "", "category": "system", "subcategory": "spotlight",
          "displayKey": "⌘Space", "description": "test", "appScope": ["system"],
          "verifiedAgainst": "v1", "verifiedDate": "2026-06-24", "aliases": []
        }
        """
        let data = json.data(using: .utf8)!
        #expect(throws: DecodingError.self) {
            _ = try JSONDecoder().decode(Shortcut.self, from: data)
        }
    }

    @Test func rejectInvalidAppScope() {
        let json = """
        {
          "id": "x", "category": "system", "subcategory": "spotlight",
          "displayKey": "⌘Space", "description": "test", "appScope": ["photoshop"],
          "verifiedAgainst": "v1", "verifiedDate": "2026-06-24", "aliases": []
        }
        """
        let data = json.data(using: .utf8)!
        #expect(throws: DecodingError.self) {
            _ = try JSONDecoder().decode(Shortcut.self, from: data)
        }
    }

    @Test func rejectEmptyAppScope() {
        let json = """
        {
          "id": "x", "category": "system", "subcategory": "spotlight",
          "displayKey": "⌘Space", "description": "test", "appScope": [],
          "verifiedAgainst": "v1", "verifiedDate": "2026-06-24", "aliases": []
        }
        """
        let data = json.data(using: .utf8)!
        #expect(throws: DecodingError.self) {
            _ = try JSONDecoder().decode(Shortcut.self, from: data)
        }
    }

    @Test func acceptMultipleAppScope() throws {
        let json = """
        {
          "id": "x", "category": "finder", "subcategory": "file",
          "displayKey": "⌘N", "description": "test", "appScope": ["finder", "system"],
          "verifiedAgainst": "v1", "verifiedDate": "2026-06-24", "aliases": []
        }
        """
        let data = json.data(using: .utf8)!
        let s = try JSONDecoder().decode(Shortcut.self, from: data)
        #expect(s.appScope.count == 2)
    }

    // MARK: - v0.2:displayKeyAnnotated 渲染(D3 决定:ASCII 主体 + Unicode 括号)

    @Test func displayKeyAnnotatedEmacsCtrlX() {
        // C-x 归一后是 ⌃X,显示 "C-x (⌃X)"
        let s = Shortcut(id: "x", category: .emacs, subcategory: "edit",
                         displayKey: "C-x", description: "test",
                         appScope: ["emacs"], verifiedAgainst: "v",
                         verifiedDate: "v", aliases: [])
        #expect(s.displayKeyAnnotated == "C-x (⌃X)")
    }

    @Test func displayKeyAnnotatedEmacsMx() {
        // M-x 归一后 meta→M,所以还是 "M-x"("M" normalize 形式跟 ASCII 一样)
        let s = Shortcut(id: "x", category: .emacs, subcategory: "edit",
                         displayKey: "M-x", description: "test",
                         appScope: ["emacs"], verifiedAgainst: "v",
                         verifiedDate: "v", aliases: [])
        #expect(s.displayKeyAnnotated == "M-x")
    }

    @Test func displayKeyAnnotatedMacSystemCmdA() {
        // ⌘A 归一后还是 ⌘A(Unicode 形式就是 final form,无 ASCII 别名)
        let s = Shortcut(id: "x", category: .system, subcategory: "spotlight",
                         displayKey: "⌘A", description: "test",
                         appScope: ["system"], verifiedAgainst: "v",
                         verifiedDate: "v", aliases: [])
        #expect(s.displayKeyAnnotated == "⌘A")
    }

    @Test func displayKeyAnnotatedVimH() {
        // 单字母 h,normalize 后还是 h
        let s = Shortcut(id: "x", category: .vim, subcategory: "normal",
                         displayKey: "h", description: "test",
                         appScope: ["vim"], verifiedAgainst: "v",
                         verifiedDate: "v", aliases: [])
        #expect(s.displayKeyAnnotated == "h")
    }

    // MARK: - v0.2:Shortcut.init(from:) 接受 distro scope 标签(vanilla/doom/spacemacs)

    @Test func acceptDistroAppScope() throws {
        let json = """
        {
          "id": "x", "category": "emacs", "subcategory": "edit",
          "displayKey": "C-x", "description": "test", "appScope": ["emacs", "vanilla"],
          "verifiedAgainst": "v1", "verifiedDate": "2026-06-24", "aliases": []
        }
        """
        let data = json.data(using: .utf8)!
        let s = try JSONDecoder().decode(Shortcut.self, from: data)
        #expect(s.appScope.contains("vanilla"))
    }
}
