import SwiftUI

/// 抽考面板(sheet)
public struct QuizPanelView: View {
    @Bindable var model: AppModel
    let question: QuizQuestion
    @State private var typedInput: String = ""

    public init(model: AppModel, question: QuizQuestion) {
        self.model = model
        self.question = question
    }

    public var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("抽考")
                    .font(.headline)
                Spacer()
                Button {
                    model.endQuiz()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(.plain)
            }

            switch question.kind {
            case .multipleChoice(_, let options):
                multipleChoiceView(options: options)
            case .typeKey:
                typeKeyView()
            }

            if let verdict = model.lastVerdict {
                verdictView(verdict)
            }

            HStack {
                Spacer()
                Button("下一题") {
                    model.nextQuestionAfterAnswer()
                    typedInput = ""
                }
                .keyboardShortcut(.return, modifiers: [])
                .disabled(model.lastVerdict == nil)
            }
        }
        .padding(24)
        .frame(width: 500, height: 400)
    }

    @ViewBuilder
    private func multipleChoiceView(options: [DistractorGenerator.Option]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("这个快捷键是做什么的?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(question.correct.displayKey)
                .font(.system(size: 36, weight: .bold, design: .monospaced))
                .padding(.bottom, 8)
            ForEach(options, id: \.shortcut.id) { option in
                Button {
                    model.answerMultipleChoice(pickedId: option.shortcut.id)
                } label: {
                    HStack {
                        Text(option.shortcut.description)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if let verdict = model.lastVerdict, verdict == .correct, option.isCorrect {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                    .padding(8)
                    .background(buttonBackground(isCorrect: option.isCorrect))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .disabled(model.lastVerdict != nil)
            }
        }
    }

    @ViewBuilder
    private func typeKeyView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("按这个动作写出快捷键:")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(question.correct.description)
                .font(.title3)
                .padding(.bottom, 8)
            TextField("按快捷键...", text: $typedInput)
                .textFieldStyle(.roundedBorder)
                .font(.system(.title3, design: .monospaced))
                .onSubmit {
                    model.answerTyped(typedInput)
                }
            Button("提交") {
                model.answerTyped(typedInput)
            }
            .disabled(typedInput.isEmpty || model.lastVerdict != nil)
        }
    }

    @ViewBuilder
    private func verdictView(_ verdict: KeyMatcher.Verdict) -> some View {
        switch verdict {
        case .correct:
            Label("答对了!", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case .wrong(let correctKey):
            VStack(alignment: .leading) {
                Label("答错了", systemImage: "xmark.circle.fill")
                    .foregroundStyle(.red)
                Text("正确答案: \(correctKey)")
                    .font(.system(.body, design: .monospaced))
            }
        }
    }

    private func buttonBackground(isCorrect: Bool) -> Color {
        guard let verdict = model.lastVerdict else { return Color.gray.opacity(0.1) }
        if case .correct = verdict, isCorrect {
            return Color.green.opacity(0.2)
        }
        if case .wrong = verdict, isCorrect {
            return Color.orange.opacity(0.2)
        }
        return Color.gray.opacity(0.1)
    }
}
