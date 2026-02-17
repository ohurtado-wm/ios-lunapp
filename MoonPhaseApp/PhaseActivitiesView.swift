import SwiftUI

struct PhaseActivitiesView: View {
    let language: AppLanguage
    @State private var selectedPhase: AgriculturalMoonPhase

    init(language: AppLanguage, initialPhase: AgriculturalMoonPhase) {
        self.language = language
        _selectedPhase = State(initialValue: initialPhase)
    }

    private func localized(_ english: String, _ spanish: String) -> String {
        language == .spanish ? spanish : english
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(localized("Select a Moon Phase", "Selecciona una fase lunar"))
                    .font(.title2.bold())

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(AgriculturalMoonPhase.allCases, id: \.self) { phase in
                        Button {
                            selectedPhase = phase
                        } label: {
                            VStack(spacing: 8) {
                                Image(phase.assetName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 72, height: 72)
                                Text(phase.localizedName(language: language))
                                    .font(.subheadline.weight(.semibold))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(selectedPhase == phase ? Color.accentColor.opacity(0.2) : Color(.secondarySystemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(selectedPhase == phase ? Color.accentColor : Color.clear, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(phase.localizedName(language: language))
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(localized("Recommended Activities", "Actividades recomendadas"))
                        .font(.title3.bold())
                    Text(selectedPhase.localizedName(language: language))
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    ForEach(selectedPhase.activities(language: language), id: \.self) { activity in
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
        .navigationTitle(localized("Activities", "Actividades"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PhaseActivitiesView(language: .english, initialPhase: .newMoon)
    }
}
