import SwiftUI

struct ActivityLogTagsView: View {
    @EnvironmentObject private var logStore: ActivityLogStore
    let logID: UUID
    let language: AppLanguage

    @State private var newTagText = ""
    @State private var editableDate = Date()

    private func localized(_ english: String, _ spanish: String) -> String {
        language == .spanish ? spanish : english
    }

    private var log: ActivityLog? {
        logStore.log(withID: logID)
    }

    private func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: language == .spanish ? "es_ES" : "en_US")
        return formatter
    }

    private var suggestedToAdd: [String] {
        guard let log else { return [] }
        let current = Set(log.tagIDs)
        return logStore.allSuggestedTagIDs(language: language).filter { !current.contains($0) }
    }

    var body: some View {
        Group {
            if let log {
                List {
                    Section(localized("Log", "Registro")) {
                        DatePicker(
                            localized("Date and time", "Fecha y hora"),
                            selection: $editableDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .onChange(of: editableDate) { _, value in
                            logStore.updateLogDate(id: logID, newDate: value)
                        }

                        Text(dateFormatter().string(from: log.createdAt))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(log.text)
                            .font(.body)
                    }

                    Section(localized("Current Tags", "Etiquetas actuales")) {
                        if log.tagIDs.isEmpty {
                            Text(localized("No tags yet.", "Aun no hay etiquetas."))
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(log.tagIDs, id: \.self) { tagID in
                                HStack {
                                    Text(logStore.tagName(for: tagID, language: language) ?? tagID.capitalized)
                                    Spacer()
                                    Button(role: .destructive) {
                                        logStore.removeTag(tagID: tagID, fromLog: logID)
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .buttonStyle(.borderless)
                                }
                            }
                        }
                    }

                    Section(localized("Add Suggested Tags", "Agregar etiquetas sugeridas")) {
                        if suggestedToAdd.isEmpty {
                            Text(localized("No more suggestions.", "No hay mas sugerencias."))
                                .foregroundStyle(.secondary)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(suggestedToAdd, id: \.self) { tagID in
                                        Button {
                                            logStore.addTag(tagID: tagID, toLog: logID)
                                        } label: {
                                            Text(logStore.tagName(for: tagID, language: language) ?? tagID)
                                                .font(.caption.weight(.semibold))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(Color.accentColor.opacity(0.15), in: Capsule())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }

                    Section(localized("Add Custom Tag", "Agregar etiqueta personalizada")) {
                        TextField(localized("Tag name", "Nombre de la etiqueta"), text: $newTagText)
                        Button(localized("Add tag", "Agregar etiqueta")) {
                            logStore.addTag(tagID: newTagText, toLog: logID)
                            newTagText = ""
                        }
                        .disabled(newTagText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .listStyle(.insetGrouped)
            } else {
                Text(localized("Log not found.", "Registro no encontrado."))
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(localized("Edit Tags", "Editar etiquetas"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let current = log {
                editableDate = current.createdAt
            }
        }
        .onChange(of: log?.createdAt) { _, value in
            if let value {
                editableDate = value
            }
        }
    }
}

#Preview {
    NavigationStack {
        ActivityLogTagsView(logID: UUID(), language: .spanish)
            .environmentObject(ActivityLogStore())
    }
}
