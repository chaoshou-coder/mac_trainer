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
}
