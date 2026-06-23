import SwiftUI

/// Detail:快捷键详情 + 勾选
public struct DetailView: View {
    @Bindable var model: AppModel

    public init(model: AppModel) {
        self.model = model
    }

    public var body: some View {
        if let id = model.selectedShortcutId,
           let shortcut = model.shortcuts.first(where: { $0.id == id }) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(shortcut.displayKey)
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .textSelection(.enabled)
                    Text(shortcut.description)
                        .font(.title3)
                    HStack {
                        Image(systemName: shortcut.category.iconSystemName)
                        Text(shortcut.category.displayName)
                            + Text(" / ").foregroundStyle(.secondary)
                            + Text(shortcut.subcategory).foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    Divider()

                    HStack {
                        Toggle(isOn: Binding(
                            get: { (model.statuses[shortcut.id] ?? .unseen) != .unseen },
                            set: { _ in model.togglePracticed(shortcut.id) }
                        )) {
                            Text("我练过了")
                        }
                        .toggleStyle(.checkbox)
                    }

                    if let mc = model.mistakeCounts[shortcut.id], mc > 0 {
                        Text("累计错 \(mc) 次")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }

                    Text("状态: \(statusDisplay(model.statuses[shortcut.id] ?? .unseen))")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Divider()

                    DisclosureGroup("核验来源") {
                        VStack(alignment: .leading) {
                            Text(shortcut.verifiedAgainst)
                            Text("核验日期: \(shortcut.verifiedDate)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .font(.caption)

                    DisclosureGroup(isExpanded: $model.showAliases) {
                        VStack(alignment: .leading) {
                            ForEach(shortcut.aliases, id: \.self) { alias in
                                Text(alias)
                                    .font(.system(.caption, design: .monospaced))
                            }
                        }
                    } label: {
                        Text("aliases")
                    }
                    .font(.caption)
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minWidth: 300)
        } else {
            ContentUnavailableView(
                "选择一条快捷键",
                systemImage: "keyboard",
                description: Text("从中间列表选一条查看详情")
            )
        }
    }

    private func statusDisplay(_ status: ShortcutStatus) -> String {
        switch status {
        case .unseen: return "未练过"
        case .practiced: return "已练过"
        case .mastered: return "已掌握"
        case .recentMistakes: return "近期错过"
        }
    }
}
