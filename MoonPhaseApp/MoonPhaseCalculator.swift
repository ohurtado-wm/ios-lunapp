import Foundation

enum AppLanguage {
    case english
    case spanish

    static var current: AppLanguage {
        if let preferred = Bundle.main.preferredLocalizations.first?.lowercased(),
           preferred.hasPrefix("es") {
            return .spanish
        }

        if let preferredLanguage = Locale.preferredLanguages.first?.lowercased(),
           preferredLanguage.hasPrefix("es") {
            return .spanish
        }

        let code = Locale.autoupdatingCurrent.language.languageCode?.identifier.lowercased() ?? "en"
        return code.hasPrefix("es") ? .spanish : .english
    }
}

enum MoonPhase: CaseIterable {
    case newMoon
    case waxingCrescent
    case firstQuarter
    case waxingGibbous
    case fullMoon
    case waningGibbous
    case lastQuarter
    case waningCrescent

    var assetName: String {
        switch self {
        case .newMoon: return "new_moon"
        case .waxingCrescent: return "waxing_crescent"
        case .firstQuarter: return "first_quarter"
        case .waxingGibbous: return "waxing_gibbous"
        case .fullMoon: return "full_moon"
        case .waningGibbous: return "waning_gibbous"
        case .lastQuarter: return "last_quarter"
        case .waningCrescent: return "waning_crescent"
        }
    }

    func localizedName(language: AppLanguage) -> String {
        switch (self, language) {
        case (.newMoon, .english): return "New Moon"
        case (.newMoon, .spanish): return "Luna nueva"
        case (.waxingCrescent, .english): return "Waxing Crescent"
        case (.waxingCrescent, .spanish): return "Luna creciente"
        case (.firstQuarter, .english): return "First Quarter"
        case (.firstQuarter, .spanish): return "Cuarto creciente"
        case (.waxingGibbous, .english): return "Waxing Gibbous"
        case (.waxingGibbous, .spanish): return "Gibosa creciente"
        case (.fullMoon, .english): return "Full Moon"
        case (.fullMoon, .spanish): return "Luna llena"
        case (.waningGibbous, .english): return "Waning Gibbous"
        case (.waningGibbous, .spanish): return "Gibosa menguante"
        case (.lastQuarter, .english): return "Last Quarter"
        case (.lastQuarter, .spanish): return "Cuarto menguante"
        case (.waningCrescent, .english): return "Waning Crescent"
        case (.waningCrescent, .spanish): return "Luna menguante"
        }
    }

    func reminders(language: AppLanguage) -> [String] {
        switch (self, language) {
        case (.newMoon, .english):
            return [
                "The soil is quiet and resting. Take this time to plan your next sowing.",
                "It is the ideal time to remove weeds that drain energy from your garden.",
                "Cleaning day: remove diseased plants so they do not affect the rest of the crop.",
                "Sap is concentrated in the roots. Apply organic fertilizer to strengthen your plants.",
                "Use the lunar darkness for maintenance pruning in your fruit trees."
            ]
        case (.newMoon, .spanish):
            return [
                "La tierra esta en silencio y descanso. Aprovecha para planificar tus proximas siembras.",
                "Es el momento ideal para eliminar esa maleza que le quita energia a tu huerta.",
                "Dia de limpieza: quita las plantas enfermas para que no afecten al resto del cultivo.",
                "La savia esta en las raices. Aplica abonos organicos para fortalecer la base de tus plantas.",
                "Aprovecha la oscuridad lunar para realizar podas de mantenimiento en tus frutales."
            ]
        case (.waxingCrescent, .english):
            return [
                "Energy is rising. It is a good moment to prepare your seedbeds.",
                "Start balancing the soil; the land is waking up and ready for nutrients.",
                "Growth is becoming visible. Check that your shoots have the support they need.",
                "A good day for light fertilization; plants are starting to ask for more strength.",
                "Observe sap rising. This is a hopeful moment in the field."
            ]
        case (.waxingCrescent, .spanish):
            return [
                "La energia empieza a subir. Es un buen momento para preparar tus semilleros.",
                "Empieza a equilibrar el suelo; la tierra esta despertando y lista para recibir nutrientes.",
                "El crecimiento se nota. Revisa que tus brotes tengan el soporte necesario.",
                "Buen dia para abonar ligeramente; las plantas estan empezando a pedir mas fuerza.",
                "Observa como la savia sube. Es un momento de mucha esperanza en el campo."
            ]
        case (.firstQuarter, .english):
            return [
                "Time to sow lettuce, spinach, and cilantro. Sap is moving toward the leaves.",
                "Perfect day for transplanting. Your seedlings will adapt quickly to their new home.",
                "Thinking about grafting? Today is when unions take best thanks to sap flow.",
                "Fertilize foliage today; your plants will look greener and brighter.",
                "Sow anything that grows above ground and gives quick fruits."
            ]
        case (.firstQuarter, .spanish):
            return [
                "Hora de sembrar lechugas, espinacas y culantro. La savia va hacia las hojas.",
                "Dia perfecto para los trasplantes. Tus plantitas se adaptaran rapido a su nuevo hogar.",
                "Pensando en hacer un injerto? Hoy es cuando mejor pegan gracias al flujo de savia.",
                "Fertiliza el follaje hoy; veras como tus plantas se ponen mas verdes y brillantes.",
                "Siembra hoy todo lo que crezca por encima del suelo y de frutos rapidos."
            ]
        case (.waxingGibbous, .english):
            return [
                "Plants are absorbing nutrients at full speed. Do not skip fertilizer.",
                "We are close to Full Moon; get your baskets ready for the coming harvest.",
                "Check irrigation; your crops are in a period of high activity and thirst.",
                "Great moment for training prunes and guiding growth.",
                "Garden vitality is incredible today. Enjoy your plants' vigor."
            ]
        case (.waxingGibbous, .spanish):
            return [
                "Las plantas estan absorbiendo nutrientes al maximo. No les faltes con el abono.",
                "Estamos cerca de la Luna Llena; prepara tus canastos para la cosecha que viene.",
                "Revisa el riego; tus cultivos estan en un periodo de mucha actividad y sed.",
                "Es un gran momento para realizar podas de formacion y guiar el crecimiento.",
                "La vitalidad en la huerta es increible hoy. Disfruta del vigor de tus plantas."
            ]
        case (.fullMoon, .english):
            return [
                "Harvest today. Fruits are juicier, more nutritious, and full of flavor.",
                "Leafy vegetable harvest day. They will be fresh and crisp for the table.",
                "Light is at its peak; this is the best time to collect seeds from your best plants.",
                "Make sure to water well. During Full Moon plants transpire more and need water.",
                "What a beautiful garden. Energy is at its highest point, ideal to enjoy results."
            ]
        case (.fullMoon, .spanish):
            return [
                "Cosecha hoy mismo. Los frutos estan mas jugosos, nutritivos y llenos de sabor.",
                "Dia de recoleccion de hortalizas de hoja. Estaran frescas y crujientes para la mesa.",
                "La luz esta al maximo; es el mejor momento para recoger semillas de tus mejores ejemplares.",
                "Asegurate de regar bien. En Luna Llena las plantas transpiran mas y necesitan agua.",
                "Que belleza de huerta. La energia esta en el punto mas alto, ideal para disfrutar los resultados."
            ]
        case (.waningGibbous, .english):
            return [
                "Energy starts to go down. Good moment for deep cleaning prunes.",
                "Take time to aerate the soil; this helps roots breathe better.",
                "Ideal day to collect medicinal plants; their properties concentrate now.",
                "Start reducing irrigation a bit, the plant enters a calmer stage.",
                "This is a good period to transplant more delicate species."
            ]
        case (.waningGibbous, .spanish):
            return [
                "La energia empieza a bajar. Buen momento para realizar podas de limpieza profunda.",
                "Aprovecha para airear el suelo; esto ayudara a que las raices respiren mejor.",
                "Dia ideal para recolectar plantas medicinales; sus propiedades se concentran ahora.",
                "Empieza a reducir un poco el riego, la planta entra en una etapa de mayor calma.",
                "Es un buen periodo para trasplantar especies que son un poco mas delicadas."
            ]
        case (.lastQuarter, .english):
            return [
                "Time to sow below ground. Potatoes, carrots, onions, and garlic are up next.",
                "If you need timber for construction, cut it today so it is more resistant to woodworm.",
                "Perfect day to control pests naturally; plant resistance is stronger now.",
                "Sow tubers and roots today so they grow strong and large underground.",
                "Harvest grains (corn or beans) now so they store better in your pantry."
            ]
        case (.lastQuarter, .spanish):
            return [
                "A sembrar bajo tierra. Es el turno de las papas, zanahorias, cebollas y ajos.",
                "Si ocupas madera para construccion, cortala hoy para que sea resistente a la polilla.",
                "Dia perfecto para combatir plagas de forma natural; la resistencia de las plantas es mayor.",
                "Siembra tuberculos y raices hoy para que crezcan fuertes y grandes bajo el suelo.",
                "Cosecha los granos (maiz o frijol) ahora para que se conserven mejor en la alacena."
            ]
        case (.waningCrescent, .english):
            return [
                "Sap has returned to the roots. Take this chance to give the soil one last boost.",
                "General maintenance day. Organize your tools and prepare the soil for the new cycle.",
                "This is the stage of highest resistance. Ideal for controlling ants or persistent insects.",
                "Clean your garden of dry leaves and residues; prepare space for the next New Moon.",
                "The cycle is ending. Thank the earth for its fruits and prepare the resting stage."
            ]
        case (.waningCrescent, .spanish):
            return [
                "La savia ha vuelto a las raices. Aprovecha para dar un ultimo refuerzo al suelo.",
                "Dia de mantenimiento general. Ordena tus herramientas y prepara el terreno para el nuevo ciclo.",
                "Es el momento de mayor resistencia. Ideal para controlar hormigas o insectos persistentes.",
                "Limpia tu jardin de hojas secas y rastrojos; prepara el espacio para la proxima Luna Nueva.",
                "El ciclo esta terminando. Agradece a la tierra por los frutos y prepara el descanso."
            ]
        }
    }

    func reminderMessage(language: AppLanguage, for date: Date, calendar: Calendar = .current) -> String {
        let options = reminders(language: language)
        guard !options.isEmpty else { return "" }
        let phaseIndex = MoonPhase.allCases.firstIndex(of: self) ?? 0
        let dayInEra = calendar.ordinality(of: .day, in: .era, for: date) ?? 0
        let index = abs(dayInEra + (phaseIndex * 17)) % options.count
        return options[index]
    }
}

enum AgriculturalMoonPhase: CaseIterable, Hashable {
    case newMoon
    case firstQuarter
    case fullMoon
    case lastQuarter

    var assetName: String {
        switch self {
        case .newMoon: return "new_moon"
        case .firstQuarter: return "first_quarter"
        case .fullMoon: return "full_moon"
        case .lastQuarter: return "last_quarter"
        }
    }

    func localizedName(language: AppLanguage) -> String {
        switch (self, language) {
        case (.newMoon, .english): return "New Moon"
        case (.newMoon, .spanish): return "Luna nueva"
        case (.firstQuarter, .english): return "First Quarter"
        case (.firstQuarter, .spanish): return "Cuarto creciente"
        case (.fullMoon, .english): return "Full Moon"
        case (.fullMoon, .spanish): return "Luna llena"
        case (.lastQuarter, .english): return "Last Quarter"
        case (.lastQuarter, .spanish): return "Cuarto menguante"
        }
    }

    func activities(language: AppLanguage) -> [String] {
        switch (self, language) {
        case (.newMoon, .english):
            return [
                "Weed control.",
                "Cleaning prunes.",
                "Root fertilization.",
                "Soil preparation.",
                "Removal of diseased plants."
            ]
        case (.newMoon, .spanish):
            return [
                "Control de malezas.",
                "Podas de limpieza.",
                "Abonado de raices.",
                "Preparacion de terreno.",
                "Eliminacion de plantas enfermas."
            ]
        case (.firstQuarter, .english):
            return [
                "Sow leafy vegetables (lettuce, spinach).",
                "Sow grains and cereals.",
                "Transplanting.",
                "Grafting.",
                "Apply foliar fertilizers."
            ]
        case (.firstQuarter, .spanish):
            return [
                "Siembra de hortalizas de hoja (lechuga, espinaca).",
                "Siembra de granos y cereales.",
                "Trasplantes.",
                "Injertos.",
                "Aplicacion de fertilizantes foliares."
            ]
        case (.fullMoon, .english):
            return [
                "Harvest fruits (better flavor and juiciness).",
                "Harvest leafy vegetables.",
                "Sow root vegetables (potato, radish).",
                "Abundant watering.",
                "Seed collection."
            ]
        case (.fullMoon, .spanish):
            return [
                "Cosecha de frutos (mejor sabor y jugosidad).",
                "Cosecha de hortalizas de hoja.",
                "Siembra de hortalizas de raiz (papa, rabano).",
                "Riego abundante.",
                "Recoleccion de semillas."
            ]
        case (.lastQuarter, .english):
            return [
                "Sow tubers and bulbs (onion, carrot).",
                "Prune timber for construction (to prevent woodworm).",
                "Harvest grains for storage.",
                "Transplant delicate plants.",
                "Pest control."
            ]
        case (.lastQuarter, .spanish):
            return [
                "Siembra de tuberculos y bulbos (cebolla, zanahoria).",
                "Poda de madera para construccion (para que no se apolille).",
                "Cosecha de granos para almacenamiento.",
                "Trasplante de plantas delicadas.",
                "Control de plagas."
            ]
        }
    }
}

extension MoonPhase {
    var agriculturalPhase: AgriculturalMoonPhase {
        switch self {
        case .newMoon, .waxingCrescent:
            return .newMoon
        case .firstQuarter, .waxingGibbous:
            return .firstQuarter
        case .fullMoon, .waningGibbous:
            return .fullMoon
        case .lastQuarter, .waningCrescent:
            return .lastQuarter
        }
    }
}

struct MoonPhaseCalculator {
    private let synodicMonth = 29.530588853
    private let referenceNewMoon = Date(timeIntervalSince1970: 947182440) // Jan 6, 2000 18:14 UTC

    func phase(for date: Date = Date()) -> MoonPhase {
        let daysSinceReference = date.timeIntervalSince(referenceNewMoon) / 86_400
        var normalized = daysSinceReference.truncatingRemainder(dividingBy: synodicMonth) / synodicMonth
        if normalized < 0 { normalized += 1 }

        let index = Int((normalized * 8).rounded()) % 8
        return MoonPhase.allCases[index]
    }
}

final class MoonPhaseViewModel: ObservableObject {
    @Published var today: Date
    @Published var phase: MoonPhase

    private let calculator = MoonPhaseCalculator()

    init(today: Date = Date()) {
        self.today = today
        self.phase = calculator.phase(for: today)
    }

    var todayAgriculturalPhase: AgriculturalMoonPhase {
        phase.agriculturalPhase
    }
}
