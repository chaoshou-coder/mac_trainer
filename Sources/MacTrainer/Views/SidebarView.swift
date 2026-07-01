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
            // v0.2:distro chip 行(只在当前 category 有 distro-tagged shortcut 时显示)
            if !model.availableDistros.isEmpty {
                Section("Distro") {
                    // "全部"chip(总在,清 filter)
                    distroChip(label: "全部", isSelected: model.appScopeFilter == nil) {
                        model.setDistroFilter(nil)
                    }
                    ForEach(model.availableDistros, id: \.self) { distro in
                        distroChip(label: distro, isSelected: model.appScopeFilter == distro) {
                            model.setDistroFilter(distro)
                        }
                    }
                }
            }
            // v0.2:数据驱动,从 model.categories 读(不再用 ShortcutCategory.allCases)
            // 跟 enum 同步,但新增 enum case 自动出现(下次 ShortcutCategory 加 case 时不用改 UI)
            Section("板块") {
                ForEach(model.categories, id: \.self) { cat in
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

    /// v0.2:distro chip 单元(复用样式)
    @ViewBuilder
    private func distroChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        HStack {
            Text(label)
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
        .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
    }
}
