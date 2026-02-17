import SwiftUI

struct LogAssistantMessage: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let date: Date
}

struct LogAssistantView: View {
    @EnvironmentObject private var logStore: ActivityLogStore
    let language: AppLanguage

    @State private var input = ""
    @State private var messages: [LogAssistantMessage] = []

    private func localized(_ english: String, _ spanish: String) -> String {
        language == .spanish ? spanish : english
    }

    var body: some View {
        VStack(spacing: 0) {
            if messages.isEmpty {
                VStack(spacing: 10) {
                    Text(localized("Ask about your activity logs", "Pregunta sobre tus registros de actividad"))
                        .font(.headline)
                    Text(localized(
                        "Example: When was the last time I transplanted the lemon tree?",
                        "Ejemplo: Cuando fue la última vez que trasplanté el arbol de limon?"
                    ))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                HStack {
                                    if message.isUser { Spacer() }
                                    Text(message.text)
                                        .padding(12)
                                        .background(
                                            message.isUser
                                            ? Color.accentColor.opacity(0.9)
                                            : Color(.secondarySystemBackground)
                                        )
                                        .foregroundStyle(message.isUser ? .white : .primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        .frame(maxWidth: 300, alignment: message.isUser ? .trailing : .leading)
                                    if !message.isUser { Spacer() }
                                }
                                .id(message.id)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                    .onChange(of: messages.count) { _, _ in
                        if let last = messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }

            Divider()

            HStack(spacing: 10) {
                TextField(localized("Ask the AI", "Pregunta a la IA"), text: $input)
                    .textFieldStyle(.roundedBorder)

                Button {
                    submit()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.borderedProminent)
                .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(12)
            .background(Color(.systemBackground))
        }
        .navigationTitle(localized("AI Logs", "IA Registros"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func submit() {
        let question = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty else { return }

        messages.append(LogAssistantMessage(text: question, isUser: true, date: Date()))
        input = ""

        let answer = logStore.answer(question: question, language: language)
        messages.append(LogAssistantMessage(text: answer, isUser: false, date: Date()))
    }
}

#Preview {
    NavigationStack {
        LogAssistantView(language: .english)
            .environmentObject(ActivityLogStore())
    }
}
