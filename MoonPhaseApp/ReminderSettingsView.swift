import SwiftUI

struct ReminderSettingsView: View {
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

            if !savedMessage.isEmpty {
                Section {
                    Text(savedMessage)
                        .font(.footnote)
                }
            }
        }
        .navigationTitle(localized("Reminder Settings", "Ajustes de recordatorio"))
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
        ReminderSettingsView(language: .english)
            .environmentObject(AppSettings())
    }
}
