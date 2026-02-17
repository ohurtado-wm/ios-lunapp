import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: AppSettings
    let language: AppLanguage

    @State private var selectedTime: Date
    @State private var savedMessage = ""

    init(language: AppLanguage) {
        self.language = language
        _selectedTime = State(initialValue: AppSettings.loadNotificationTimeForView())
    }

    private func localized(_ english: String, _ spanish: String) -> String {
        language == .spanish ? spanish : english
    }

    var body: some View {
        Form {
            Section {
                DatePicker(
                    localized("Daily notification", "Notificacion diaria"),
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                Text(localized(
                    "The app will send one daily reminder with today's moon message.",
                    "La app enviara un recordatorio diario con el mensaje lunar del dia."
                ))
                .font(.footnote)
                .foregroundStyle(.secondary)
            } header: {
                Text(localized("Reminder Time", "Hora del recordatorio"))
            }

            Section {
                Button(localized("Save and enable reminders", "Guardar y activar recordatorios")) {
                    settings.notificationTime = selectedTime
                    settings.saveReminderTimeAndSchedule(language: language)
                    savedMessage = localized("Saved. Daily notifications were scheduled.", "Guardado. Las notificaciones diarias fueron programadas.")
                }
            }

            Section {
                Picker(localized("AI mode", "Modo de IA"), selection: $settings.aiMode) {
                    ForEach(AIMode.allCases, id: \.rawValue) { mode in
                        Text(mode.localizedTitle(language: language)).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                Text(localized(
                    "LLM mode is shown for configuration, but not implemented yet.",
                    "El modo LLM esta disponible en configuracion, pero aun no esta implementado."
                ))
                .font(.footnote)
                .foregroundStyle(.secondary)
            } header: {
                Text(localized("AI Settings", "Ajustes de IA"))
            }

            if !savedMessage.isEmpty {
                Section {
                    Text(savedMessage)
                        .font(.footnote)
                }
            }
        }
        .navigationTitle(localized("Settings", "Ajustes"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension AppSettings {
    static func loadNotificationTimeForView() -> Date {
        let values = loadReminderHourMinute()
        let calendar = Calendar.current
        let today = Date()

        var components = calendar.dateComponents([.year, .month, .day], from: today)
        components.hour = values.hour
        components.minute = values.minute
        return calendar.date(from: components) ?? today
    }
}

#Preview {
    NavigationStack {
        SettingsView(language: .english)
            .environmentObject(AppSettings())
    }
}
