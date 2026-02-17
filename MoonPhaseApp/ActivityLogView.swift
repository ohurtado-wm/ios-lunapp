import SwiftUI

struct ActivityLogView: View {
    @EnvironmentObject private var logStore: ActivityLogStore
    let language: AppLanguage

    @State private var entryText = ""
    @State private var selectedTagID: String? = nil
    @State private var pendingDeleteLog: ActivityLog? = nil
    @State private var selectedLogForEdit: ActivityLog? = nil

    private func localized(_ english: String, _ spanish: String) -> String {
        language == .spanish ? spanish : english
    }

    private func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: language == .spanish ? "es_ES" : "en_US")
        return formatter
    }

    private var visibleLogs: [ActivityLog] {
        guard let selectedTagID else { return logStore.sortedLogs }
        return logStore.sortedLogs.filter { $0.tagIDs.contains(selectedTagID) }
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Text(localized("Activity Log", "Bitacora de actividades"))
                        .font(.title2.bold())

                    Text(localized("What did you do today?", "Que hiciste hoy?"))
                        .font(.headline)

                    TextEditor(text: $entryText)
                        .frame(minHeight: 110)
                        .padding(8)
                        .scrollContentBackground(.hidden)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                    Button {
                        logStore.addLog(text: entryText)
                        entryText = ""
                    } label: {
                        Text(localized("Save log", "Guardar registro"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(entryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        tagChip(id: nil, label: localized("All", "Todas"))
                        ForEach(logStore.availableTagIDs(language: language), id: \.self) { tagID in
                            tagChip(id: tagID, label: logStore.tagName(for: tagID, language: language) ?? tagID)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .listRowSeparator(.hidden)
            } header: {
                Text(localized("Filter by tag", "Filtrar por etiqueta"))
            }

            Section(localized("Saved logs", "Registros guardados")) {
                if visibleLogs.isEmpty {
                    Text(localized("No logs yet.", "Aun no hay registros."))
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(visibleLogs) { log in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(dateFormatter().string(from: log.createdAt))
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(log.text)
                                .font(.body)

                            let tags = logStore.localizedTags(for: log, language: language)
                            if !tags.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 6) {
                                        ForEach(tags, id: \.self) { tag in
                                            Text(tag)
                                                .font(.caption.weight(.semibold))
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .background(Color.accentColor.opacity(0.15), in: Capsule())
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                pendingDeleteLog = log
                            } label: {
                                Label(localized("Delete", "Eliminar"), systemImage: "trash")
                            }
                            .tint(.red)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                selectedLogForEdit = log
                            } label: {
                                Label(localized("Edit tags", "Editar etiquetas"), systemImage: "tag")
                            }
                            .tint(.blue)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationTitle(localized("Logs", "Registros"))
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            localized("Delete this log?", "Eliminar este registro?"),
            isPresented: Binding(
                get: { pendingDeleteLog != nil },
                set: { if !$0 { pendingDeleteLog = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button(localized("Delete", "Eliminar"), role: .destructive) {
                if let log = pendingDeleteLog {
                    logStore.deleteLog(id: log.id)
                }
                pendingDeleteLog = nil
            }
            Button(localized("Cancel", "Cancelar"), role: .cancel) {
                pendingDeleteLog = nil
            }
        } message: {
            Text(localized("This action cannot be undone.", "Esta accion no se puede deshacer."))
        }
        .navigationDestination(item: $selectedLogForEdit) { log in
            ActivityLogTagsView(logID: log.id, language: language)
                .environmentObject(logStore)
        }
    }

    @ViewBuilder
    private func tagChip(id: String?, label: String) -> some View {
        let isSelected = selectedTagID == id
        Button {
            selectedTagID = id
        } label: {
            Text(label)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground), in: Capsule())
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ActivityLogView(language: .spanish)
            .environmentObject(ActivityLogStore())
    }
}
