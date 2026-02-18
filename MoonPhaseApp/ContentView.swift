import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: MoonPhaseViewModel
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var logStore: ActivityLogStore
    @State private var showMoonCalendar = false
    @State private var dayOffset = 0
    @State private var dragOffset: CGFloat = 0
    private let language = AppLanguage.current
    private let calculator = MoonPhaseCalculator()
    private let moonSize: CGFloat = 220
    private let moonSpacing: CGFloat = 24

    private func dateFormatter(for language: AppLanguage) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: language == .spanish ? "es_ES" : "en_US")
        return formatter
    }

    private func localized(_ english: String, _ spanish: String) -> String {
        language == .spanish ? spanish : english
    }

    private var displayedDate: Date {
        Calendar.current.date(byAdding: .day, value: dayOffset, to: viewModel.today) ?? viewModel.today
    }

    private var displayedPhase: MoonPhase {
        calculator.phase(for: displayedDate)
    }

    private var displayedAgriculturalPhase: AgriculturalMoonPhase {
        displayedPhase.agriculturalPhase
    }

    private func shiftDay(by delta: Int) {
        let next = dayOffset + delta
        dayOffset = min(29, max(-29, next))
    }

    private func phase(at offset: Int) -> MoonPhase {
        let date = Calendar.current.date(byAdding: .day, value: offset, to: viewModel.today) ?? viewModel.today
        return calculator.phase(for: date)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(localized("Today's Moon Phase", "Fase lunar de hoy"))
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text(dateFormatter(for: language).string(from: displayedDate))
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text(displayedPhase.reminderMessage(language: language, for: displayedDate))
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                HStack(spacing: moonSpacing) {
                    Image(phase(at: dayOffset - 1).assetName)
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                        .frame(width: moonSize, height: moonSize)
                        .opacity(0.45)
                        .scaleEffect(0.88)

                    Image(displayedPhase.assetName)
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                        .frame(width: moonSize, height: moonSize)
                        .accessibilityLabel(displayedPhase.localizedName(language: language))

                    Image(phase(at: dayOffset + 1).assetName)
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                        .frame(width: moonSize, height: moonSize)
                        .opacity(0.45)
                        .scaleEffect(0.88)
                }
                .offset(x: -(moonSize + moonSpacing) + dragOffset)
                .frame(width: moonSize, height: moonSize)
                .clipped()
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 12)
                        .onChanged { value in
                            dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            let threshold: CGFloat = 55
                            if value.translation.width <= -threshold {
                                withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                                    shiftDay(by: 1)
                                    dragOffset = 0
                                }
                            } else if value.translation.width >= threshold {
                                withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                                    shiftDay(by: -1)
                                    dragOffset = 0
                                }
                            } else {
                                withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
                                    dragOffset = 0
                                }
                            }
                        }
                )
                .onTapGesture(count: 2) {
                    showMoonCalendar = true
                }

                Text(displayedPhase.localizedName(language: language))
                    .font(.title2.weight(.semibold))

                VStack(alignment: .leading, spacing: 10) {
                    Text(localized("Today's Activities", "Actividades de hoy"))
                        .font(.title3.bold())
                    ForEach(displayedAgriculturalPhase.activities(language: language), id: \.self) { activity in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                            Text(activity)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(24)
        }
        .navigationTitle(localized("Moon & Agriculture", "Luna y agricultura"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showMoonCalendar) {
            MoonCalendarView(language: language)
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsView(language: language)
                        .environmentObject(settings)
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel(localized("Settings", "Ajustes"))
            }
        }
        .overlay(alignment: .bottomTrailing) {
            NavigationLink {
                PhaseActivitiesView(language: language, initialPhase: displayedAgriculturalPhase)
            } label: {
                Image(systemName: "moon.stars.fill")
                    .font(.title2.weight(.semibold))
                    .frame(width: 58, height: 58)
                    .background(Color.accentColor, in: Circle())
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
            }
            .accessibilityLabel(localized("View activities by phase", "Ver actividades por fase"))
            .padding(.trailing, 20)
            .padding(.bottom, 24)
        }
        .overlay(alignment: .bottomLeading) {
            NavigationLink {
                ActivityLogView(language: language)
                    .environmentObject(logStore)
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.bold))
                    .frame(width: 58, height: 58)
                    .background(Color.green, in: Circle())
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
            }
            .accessibilityLabel(localized("Add activity log", "Agregar registro de actividad"))
            .padding(.leading, 20)
            .padding(.bottom, 24)
        }
        .overlay(alignment: .bottom) {
            NavigationLink {
                LogAssistantView(language: language)
                    .environmentObject(logStore)
            } label: {
                Image(systemName: "sparkles")
                    .font(.title2.weight(.bold))
                    .frame(width: 58, height: 58)
                    .background(Color.blue, in: Circle())
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
            }
            .accessibilityLabel(localized("Ask AI about logs", "Preguntar a la IA sobre registros"))
            .padding(.bottom, 24)
        }
    }
}

#Preview {
    ContentView(viewModel: MoonPhaseViewModel())
        .environmentObject(AppSettings())
        .environmentObject(ActivityLogStore())
}
