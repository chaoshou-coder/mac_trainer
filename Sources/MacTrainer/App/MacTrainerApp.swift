import SwiftUI

@main
struct MacTrainerApp: App {
    @State private var model: AppModel

    init() {
        let m = AppModel()
        do {
            try m.loadBundledShortcuts()
        } catch {
            print("[MacTrainer] 加载失败: \(error.localizedDescription)")
            // 不抛,允许 app 启动(空状态)
        }
        _model = State(initialValue: m)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
        }
        .windowStyle(.titleBar)
        .commands {
            CommandGroup(after: .toolbar) {
                Button("开始复习") {
                    model.startQuiz()
                }
                .keyboardShortcut("r", modifiers: .command)
            }
        }
    }
}
