import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: MoonPhaseViewModel
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var logStore: ActivityLogStore
    private let language = AppLanguage.current

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

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(localized("Today's Moon Phase", "Fase lunar de hoy"))
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text(dateFormatter(for: language).string(from: viewModel.today))
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text(viewModel.phase.reminderMessage(language: language, for: viewModel.today))
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                Image(viewModel.phase.assetName)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .accessibilityLabel(viewModel.phase.localizedName(language: language))

                Text(viewModel.phase.localizedName(language: language))
                    .font(.title2.weight(.semibold))

                VStack(alignment: .leading, spacing: 10) {
                    Text(localized("Today's Activities", "Actividades de hoy"))
                        .font(.title3.bold())
                    ForEach(viewModel.todayAgriculturalPhase.activities(language: language), id: \.self) { activity in
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
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
                PhaseActivitiesView(language: language, initialPhase: viewModel.todayAgriculturalPhase)
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
