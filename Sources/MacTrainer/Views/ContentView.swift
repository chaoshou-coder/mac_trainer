import SwiftUI

/// 三栏容器:NavigationSplitView
public struct ContentView: View {
    @Bindable var model: AppModel

    public init(model: AppModel) {
        self.model = model
    }

    public var body: some View {
        NavigationSplitView {
            SidebarView(model: model)
        } content: {
            MiddleListView(model: model)
        } detail: {
            DetailView(model: model)
        }
        .navigationTitle("Mac 全键盘训练器")
        .toolbar {
            ToolbarItem(placement: .principal) {
                SearchField(model: model)
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    model.startQuiz()
                } label: {
                    Label("复习", systemImage: "play.circle")
                }
                .keyboardShortcut("r", modifiers: .command)
                .disabled(model.shortcuts.filter { StateMachine.isQuizCandidate(model.statuses[$0.id] ?? .unseen) }.isEmpty)
            }
        }
        .sheet(item: Binding(
            get: { model.currentQuestion.map { QuizSessionID(question: $0) } },
            set: { newValue in
                if newValue == nil { model.endQuiz() }
            }
        )) { sessionID in
            QuizPanelView(model: model, question: sessionID.question)
        }
        .frame(minWidth: 900, minHeight: 600)
    }
}

/// QuizSessionID 让 currentQuestion 变成 Identifiable
struct QuizSessionID: Identifiable {
    let question: QuizQuestion
    var id: String { question.correct.id }
}
