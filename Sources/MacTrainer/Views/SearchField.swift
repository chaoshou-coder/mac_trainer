import SwiftUI

/// 搜索框(⌘F 聚焦)
public struct SearchField: View {
    @Bindable var model: AppModel
    @FocusState private var isFocused: Bool

    public init(model: AppModel) {
        self.model = model
    }

    public var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("搜索快捷键、描述、aliases...", text: $model.searchQuery)
                .textFieldStyle(.plain)
                .focused($isFocused)
                .frame(minWidth: 240)
            if !model.searchQuery.isEmpty {
                Button {
                    model.searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(6)
        .onAppear {
            // 等待 view 出现后绑定 ⌘F
            DispatchQueue.main.async {
                // 简化:不绑定全局快捷键,用户点击框即可
            }
        }
    }
}
