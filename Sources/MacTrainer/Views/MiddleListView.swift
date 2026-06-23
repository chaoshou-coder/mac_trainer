import SwiftUI

/// Middle:当前板块的快捷键列表
public struct MiddleListView: View {
    @Bindable var model: AppModel

    public init(model: AppModel) {
        self.model = model
    }

    public var body: some View {
        let items = model.visibleShortcuts
        if items.isEmpty {
            ContentUnavailableView(
                "无快捷键",
                systemImage: "magnifyingglass",
                description: Text("试试切换板块或清空搜索")
            )
        } else {
            List(selection: Binding(
                get: { model.selectedShortcutId },
                set: { model.selectShortcut($0) }
            )) {
                ForEach(items) { shortcut in
                    HStack {
                        Text(shortcut.displayKey)
                            .font(.system(.body, design: .monospaced))
                            .frame(minWidth: 80, alignment: .leading)
                        Text(shortcut.description)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Spacer()
                        if model.statuses[shortcut.id] == .mastered {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                        } else if model.statuses[shortcut.id] == .recentMistakes {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                        } else if model.statuses[shortcut.id] == .practiced {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                    .tag(Optional(shortcut.id))
                }
            }
            .frame(minWidth: 280, idealWidth: 340)
        }
    }
}
