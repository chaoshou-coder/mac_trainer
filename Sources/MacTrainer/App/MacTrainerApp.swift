import SwiftUI

@main
struct MacTrainerApp: App {
    @State private var model: AppModel

    init() {
        let m = AppModel()
        // v0.2:不再用 try? swallow,改用 loadBundled() 写 loadState
        // (Outside Voice #1 修:之前吞掉 error 导致 v1→v2 breaking change 不真的 break)
        m.loadBundled()
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
