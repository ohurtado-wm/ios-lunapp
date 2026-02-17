import Foundation
import Combine
import UserNotifications

final class AppSettings: ObservableObject {
    @Published var notificationTime: Date

    private static let reminderHourKey = "reminder_hour"
    private static let reminderMinuteKey = "reminder_minute"

    init() {
        self.notificationTime = Self.loadNotificationTime()
        let values = Self.loadReminderHourMinute()
        ReminderNotificationManager.shared.scheduleIfAuthorized(
            hour: values.hour,
            minute: values.minute,
            language: AppLanguage.current
        )
    }

    func saveReminderTimeAndSchedule(language: AppLanguage) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
        let hour = components.hour ?? 9
        let minute = components.minute ?? 0

        UserDefaults.standard.set(hour, forKey: Self.reminderHourKey)
        UserDefaults.standard.set(minute, forKey: Self.reminderMinuteKey)

        ReminderNotificationManager.shared.requestAuthorizationIfNeeded { granted in
            guard granted else { return }
            ReminderNotificationManager.shared.scheduleDailyReminders(hour: hour, minute: minute, language: language)
        }
    }

    static func loadReminderHourMinute() -> (hour: Int, minute: Int) {
        let defaults = UserDefaults.standard
        let hour = defaults.object(forKey: reminderHourKey) as? Int ?? 9
        let minute = defaults.object(forKey: reminderMinuteKey) as? Int ?? 0
        return (hour, minute)
    }

    private static func loadNotificationTime() -> Date {
        let values = loadReminderHourMinute()
        let calendar = Calendar.current
        let today = Date()

        var components = calendar.dateComponents([.year, .month, .day], from: today)
        components.hour = values.hour
        components.minute = values.minute
        return calendar.date(from: components) ?? today
    }
}

final class ReminderNotificationManager {
    static let shared = ReminderNotificationManager()

    private let center = UNUserNotificationCenter.current()
    private let calculator = MoonPhaseCalculator()
    private let identifierPrefix = "moon_reminder_"

    private init() {}

    func requestAuthorizationIfNeeded(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func scheduleIfAuthorized(hour: Int, minute: Int, language: AppLanguage) {
        center.getNotificationSettings { [weak self] settings in
            guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else { return }
            self?.scheduleDailyReminders(hour: hour, minute: minute, language: language)
        }
    }

    func scheduleDailyReminders(hour: Int, minute: Int, language: AppLanguage) {
        center.getPendingNotificationRequests { [weak self] requests in
            guard let self else { return }
            let toRemove = requests
                .map(\.identifier)
                .filter { $0.hasPrefix(self.identifierPrefix) }

            self.center.removePendingNotificationRequests(withIdentifiers: toRemove)
            self.createUpcomingReminders(hour: hour, minute: minute, language: language)
        }
    }

    private func createUpcomingReminders(hour: Int, minute: Int, language: AppLanguage) {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())

        for offset in 0..<30 {
            guard let day = calendar.date(byAdding: .day, value: offset, to: startOfToday) else { continue }

            let phase = calculator.phase(for: day)
            let body = phase.reminderMessage(language: language, for: day, calendar: calendar)
            var components = calendar.dateComponents([.year, .month, .day], from: day)
            components.hour = hour
            components.minute = minute

            let content = UNMutableNotificationContent()
            content.title = language == .spanish ? "Recordatorio lunar" : "Moon reminder"
            content.body = body
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let idDate = calendar.dateComponents([.year, .month, .day], from: day)
            let identifier = "\(identifierPrefix)\(idDate.year ?? 0)-\(idDate.month ?? 0)-\(idDate.day ?? 0)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            center.add(request)
        }
    }
}
