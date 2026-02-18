import SwiftUI

private struct MoonCycleDay: Identifiable {
    let date: Date
    let phase: MoonPhase
    let isToday: Bool

    var id: TimeInterval { date.timeIntervalSince1970 }
}

private struct MoonCyclePage {
    let titleEn: String
    let titleEs: String
    let start: Date
    let end: Date
    let days: [MoonCycleDay]
}

private struct MoonCycleBuilder {
    private let calculator = MoonPhaseCalculator()
    private let calendar = Calendar.current

    func pages(around today: Date = Date()) -> [MoonCyclePage] {
        let cycleSeconds = calculator.cycleLengthDays() * 86_400
        let currentStart = calculator.cycleStart(for: today)
        let previousStart = currentStart.addingTimeInterval(-cycleSeconds)
        let nextStart = currentStart.addingTimeInterval(cycleSeconds)

        return [
            makePage(titleEn: "Previous", titleEs: "Anterior", start: previousStart, cycleSeconds: cycleSeconds, today: today),
            makePage(titleEn: "Current", titleEs: "Actual", start: currentStart, cycleSeconds: cycleSeconds, today: today),
            makePage(titleEn: "Next", titleEs: "Siguiente", start: nextStart, cycleSeconds: cycleSeconds, today: today)
        ]
    }

    private func makePage(titleEn: String, titleEs: String, start: Date, cycleSeconds: Double, today: Date) -> MoonCyclePage {
        let end = start.addingTimeInterval(cycleSeconds)

        var days: [MoonCycleDay] = []
        var cursor = calendar.startOfDay(for: start)
        let todayStart = calendar.startOfDay(for: today)

        while cursor < end {
            days.append(
                MoonCycleDay(
                    date: cursor,
                    phase: calculator.phase(for: cursor),
                    isToday: calendar.isDate(cursor, inSameDayAs: todayStart)
                )
            )
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }

        return MoonCyclePage(titleEn: titleEn, titleEs: titleEs, start: start, end: end, days: days)
    }
}

struct MoonCalendarView: View {
    let language: AppLanguage
    private let builder = MoonCycleBuilder()
    @State private var selectedPageIndex = 1

    private var pages: [MoonCyclePage] {
        builder.pages(around: Date())
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    private func localized(_ english: String, _ spanish: String) -> String {
        language == .spanish ? spanish : english
    }

    private func title(for page: MoonCyclePage) -> String {
        language == .spanish ? page.titleEs : page.titleEn
    }

    private func weekdaySymbols() -> [String] {
        var symbols = language == .spanish ? Calendar.current.shortWeekdaySymbols : Calendar.current.shortWeekdaySymbols
        let first = Calendar.current.firstWeekday - 1
        if first > 0 {
            symbols = Array(symbols[first...]) + Array(symbols[..<first])
        }
        return symbols
    }

    private func dayFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        formatter.locale = Locale(identifier: language == .spanish ? "es_ES" : "en_US")
        return formatter
    }

    private func rangeFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: language == .spanish ? "es_ES" : "en_US")
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localized("Moon Calendar", "Calendario lunar"))
                .font(.title2.bold())
                .padding(.horizontal, 20)
                .padding(.top, 12)

            TabView(selection: $selectedPageIndex) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(title(for: page))
                                .font(.headline)
                            Spacer()
                            Text("\(rangeFormatter().string(from: page.start)) - \(rangeFormatter().string(from: page.end))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(weekdaySymbols(), id: \.self) { symbol in
                                Text(symbol)
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity)
                            }

                            ForEach(page.days) { day in
                                VStack(spacing: 4) {
                                    Text(dayFormatter().string(from: day.date))
                                        .font(.caption.weight(.semibold))
                                    Image(day.phase.assetName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                }
                                .frame(maxWidth: .infinity, minHeight: 42)
                                .padding(.vertical, 4)
                                .background(
                                    day.isToday
                                    ? Color.accentColor.opacity(0.18)
                                    : Color.clear,
                                    in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                                )
                                .accessibilityLabel("\(day.phase.localizedName(language: language))")
                            }
                        }
                    }
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 26)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
        }
        .navigationTitle(localized("Moon Calendar", "Calendario lunar"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        MoonCalendarView(language: .english)
    }
}
