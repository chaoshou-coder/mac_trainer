import SwiftUI

/// Sidebar:板块列表 + 进度
public struct SidebarView: View {
    @Bindable var model: AppModel

    public init(model: AppModel) {
        self.model = model
    }

    public var body: some View {
        List(selection: Binding(
            get: { model.selectedCategory },
            set: { model.selectCategory($0) }
        )) {
            Section("过滤") {
                ForEach(AppModel.SidebarFilter.allCases, id: \.self) { filter in
                    HStack {
                        Text(filter.displayName)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        model.sidebarFilter = filter
                    }
                    .background(model.sidebarFilter == filter ? Color.accentColor.opacity(0.2) : Color.clear)
                }
            }
            Section("板块") {
                ForEach(ShortcutCategory.allCases, id: \.self) { cat in
                    HStack {
                        Image(systemName: cat.iconSystemName)
                            .frame(width: 20)
                        Text(cat.displayName)
                        Spacer()
                        let progress = model.categoryProgress(cat)
                        Text("(\(progress.practiced)/\(progress.total))")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                    .tag(ShortcutCategory?.some(cat))
                }
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 180, idealWidth: 220, maxWidth: 280)
    }
}
