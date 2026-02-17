import Foundation
import Combine
import NaturalLanguage

struct ActivityLog: Codable, Identifiable, Hashable {
    let id: UUID
    let text: String
    let createdAt: Date
    let tagIDs: [String]
}

struct ActivityTagDefinition {
    let id: String
    let english: String
    let spanish: String
    let keywords: [String]

    func localizedName(language: AppLanguage) -> String {
        language == .spanish ? spanish : english
    }
}

final class ActivityLogStore: ObservableObject {
    @Published private(set) var logs: [ActivityLog] = []

    private let storageKey = "activity_logs_v1"

    private let tagDefinitions: [ActivityTagDefinition] = [
        ActivityTagDefinition(id: "siembra", english: "Planting", spanish: "Siembra", keywords: ["siembra", "sembr", "plantar", "plante", "planto", "plantado", "seed", "sow", "sowing"]),
        ActivityTagDefinition(id: "cosecha", english: "Harvest", spanish: "Cosecha", keywords: ["cosecha", "cosechar", "recolect", "harvest", "collect"]),
        ActivityTagDefinition(id: "poda", english: "Pruning", spanish: "Poda", keywords: ["poda", "podar", "pode", "prune", "pruning"]),
        ActivityTagDefinition(id: "riego", english: "Irrigation", spanish: "Riego", keywords: ["riego", "regar", "agua", "irrigation", "water", "watering"]),
        ActivityTagDefinition(id: "abono", english: "Fertilizer", spanish: "Abono", keywords: ["abono", "abonar", "fertiliz", "compost", "fertilizer", "manure"]),
        ActivityTagDefinition(id: "trasplante", english: "Transplant", spanish: "Trasplante", keywords: ["trasplante", "trasplant", "transplant"]),
        ActivityTagDefinition(id: "plagas", english: "Pest Control", spanish: "Plagas", keywords: ["plaga", "plagas", "insecto", "insectos", "hormiga", "hormigas", "pest", "insect", "aphid", "ant"]),
        ActivityTagDefinition(id: "maleza", english: "Weeding", spanish: "Maleza", keywords: ["maleza", "malezas", "hierba", "hierbas", "deshierbe", "weed", "weeding"]),
        ActivityTagDefinition(id: "suelo", english: "Soil", spanish: "Suelo", keywords: ["suelo", "tierra", "terreno", "soil", "ground"]),
        ActivityTagDefinition(id: "semillas", english: "Seeds", spanish: "Semillas", keywords: ["semilla", "semillas", "seed", "seeds"]),
        ActivityTagDefinition(id: "injerto", english: "Grafting", spanish: "Injerto", keywords: ["injerto", "injert", "graft", "grafting"]),
        ActivityTagDefinition(id: "limpieza", english: "Cleaning", spanish: "Limpieza", keywords: ["limpieza", "limpiar", "cleanup", "cleaning"]),
        ActivityTagDefinition(id: "arbol", english: "Tree", spanish: "Arbol", keywords: ["arbol", "tree"]),
        ActivityTagDefinition(id: "frutal", english: "Fruit Tree", spanish: "Frutal", keywords: ["frutal", "fruit tree", "orchard"]),
        ActivityTagDefinition(id: "limon", english: "Lemon", spanish: "Limon", keywords: ["limon", "lemon", "citron"]),
        ActivityTagDefinition(id: "naranja", english: "Orange", spanish: "Naranja", keywords: ["naranja", "orange"]),
        ActivityTagDefinition(id: "manzana", english: "Apple", spanish: "Manzana", keywords: ["manzana", "apple"]),
        ActivityTagDefinition(id: "papa", english: "Potato", spanish: "Papa", keywords: ["papa", "patata", "potato"]),
        ActivityTagDefinition(id: "zanahoria", english: "Carrot", spanish: "Zanahoria", keywords: ["zanahoria", "carrot"]),
        ActivityTagDefinition(id: "cebolla", english: "Onion", spanish: "Cebolla", keywords: ["cebolla", "onion"]),
        ActivityTagDefinition(id: "ajo", english: "Garlic", spanish: "Ajo", keywords: ["ajo", "garlic"]),
        ActivityTagDefinition(id: "lechuga", english: "Lettuce", spanish: "Lechuga", keywords: ["lechuga", "lettuce"]),
        ActivityTagDefinition(id: "espinaca", english: "Spinach", spanish: "Espinaca", keywords: ["espinaca", "spinach"]),
        ActivityTagDefinition(id: "culantro", english: "Cilantro", spanish: "Culantro", keywords: ["culantro", "cilantro", "coriander"]),
        ActivityTagDefinition(id: "maiz", english: "Corn", spanish: "Maiz", keywords: ["maiz", "corn"]),
        ActivityTagDefinition(id: "frijol", english: "Beans", spanish: "Frijol", keywords: ["frijol", "frijoles", "bean", "beans"]),
        ActivityTagDefinition(id: "estanque", english: "Pond", spanish: "Estanque", keywords: ["estanque", "pond"]),
        ActivityTagDefinition(id: "raiz", english: "Root", spanish: "Raiz", keywords: ["raiz", "root", "tuberculo", "tubercle", "bulbo", "bulb"])
    ]

    init() {
        load()
    }

    func addLog(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let tags = extractTagIDs(from: trimmed)
        let newLog = ActivityLog(id: UUID(), text: trimmed, createdAt: Date(), tagIDs: tags)
        logs.append(newLog)
        save()
    }

    func log(withID id: UUID) -> ActivityLog? {
        logs.first(where: { $0.id == id })
    }

    func deleteLog(id: UUID) {
        logs.removeAll { $0.id == id }
        save()
    }

    func addTag(tagID: String, toLog id: UUID) {
        let normalizedTag = normalize(tagID)
        guard !normalizedTag.isEmpty else { return }
        guard let index = logs.firstIndex(where: { $0.id == id }) else { return }

        var updated = logs[index]
        if !updated.tagIDs.contains(normalizedTag) {
            updated = ActivityLog(
                id: updated.id,
                text: updated.text,
                createdAt: updated.createdAt,
                tagIDs: updated.tagIDs + [normalizedTag]
            )
            logs[index] = updated
            save()
        }
    }

    func removeTag(tagID: String, fromLog id: UUID) {
        guard let index = logs.firstIndex(where: { $0.id == id }) else { return }
        let normalizedTag = normalize(tagID)
        var updated = logs[index]
        updated = ActivityLog(
            id: updated.id,
            text: updated.text,
            createdAt: updated.createdAt,
            tagIDs: updated.tagIDs.filter { $0 != normalizedTag }
        )
        logs[index] = updated
        save()
    }

    func localizedTags(for log: ActivityLog, language: AppLanguage) -> [String] {
        log.tagIDs.compactMap { tagName(for: $0, language: language) }
    }

    func tagName(for id: String, language: AppLanguage) -> String? {
        tagDefinitions.first(where: { $0.id == id })?.localizedName(language: language)
    }

    func allSuggestedTagIDs(language: AppLanguage) -> [String] {
        tagDefinitions.map(\.id).sorted { left, right in
            let l = tagName(for: left, language: language) ?? left
            let r = tagName(for: right, language: language) ?? right
            return l.localizedCaseInsensitiveCompare(r) == .orderedAscending
        }
    }

    func availableTagIDs(language: AppLanguage) -> [String] {
        let ids = Set(logs.flatMap(\.tagIDs))
        return ids.sorted { (left, right) in
            let l = tagName(for: left, language: language) ?? left
            let r = tagName(for: right, language: language) ?? right
            return l.localizedCaseInsensitiveCompare(r) == .orderedAscending
        }
    }

    var sortedLogs: [ActivityLog] {
        logs.sorted { $0.createdAt > $1.createdAt }
    }

    private func extractTagIDs(from text: String) -> [String] {
        let normalized = normalize(text)
        let directTokens = normalized.split(separator: " ").map(String.init)
        let nlpTokens = nlpLemmas(from: text)
        let allTokens = Set(directTokens + nlpTokens)
        let paddedText = " \(normalized) "

        var detected: [String] = []
        for definition in tagDefinitions {
            let matched = definition.keywords.contains { keyword in
                let key = normalize(keyword)
                return matches(
                    normalizedKeyword: key,
                    tokens: allTokens,
                    normalizedText: normalized,
                    paddedText: paddedText
                )
            }
            if matched {
                detected.append(definition.id)
            }
        }

        return detected
    }

    private func normalize(_ text: String) -> String {
        let lowered = text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        let space = UnicodeScalar(32)!
        let scalars = lowered.unicodeScalars.map { scalar in
            CharacterSet.alphanumerics.contains(scalar) ? scalar : space
        }
        let sanitized = String(String.UnicodeScalarView(scalars))
        return sanitized.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func matches(normalizedKeyword: String, tokens: Set<String>, normalizedText: String, paddedText: String) -> Bool {
        guard !normalizedKeyword.isEmpty else { return false }

        if normalizedKeyword.contains(" ") {
            return normalizedText.contains(normalizedKeyword)
        }

        if tokens.contains(normalizedKeyword) {
            return true
        }

        if normalizedKeyword.count >= 5 && tokens.contains(where: { $0.hasPrefix(normalizedKeyword) }) {
            return true
        }

        return paddedText.contains(" \(normalizedKeyword) ")
    }

    private func nlpLemmas(from text: String) -> [String] {
        let tagger = NLTagger(tagSchemes: [.lemma, .lexicalClass])
        tagger.string = text

        var results: [String] = []
        let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames]
        let fullRange = text.startIndex..<text.endIndex

        tagger.enumerateTags(in: fullRange, unit: .word, scheme: .lexicalClass, options: options) { tag, range in
            let word = String(text[range])
            let normalizedWord = normalize(word)
            guard !normalizedWord.isEmpty else { return true }

            if tag == .noun || tag == .verb || tag == .adjective {
                let lemma = tagger.tag(at: range.lowerBound, unit: .word, scheme: .lemma).0?.rawValue ?? word
                let normalizedLemma = normalize(lemma)
                if !normalizedLemma.isEmpty {
                    results.append(normalizedLemma)
                }
                results.append(normalizedWord)
            }
            return true
        }

        return results
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(logs) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([ActivityLog].self, from: data) else {
            logs = []
            return
        }
        logs = decoded.map { log in
            ActivityLog(
                id: log.id,
                text: log.text,
                createdAt: log.createdAt,
                tagIDs: extractTagIDs(from: log.text)
            )
        }
        save()
    }
}
