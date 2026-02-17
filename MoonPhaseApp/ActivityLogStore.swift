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
    private let treeSpeciesTagIDs: Set<String> = ["limon", "naranja", "manzana", "guanacaste"]

    private let tagDefinitions: [ActivityTagDefinition] = [
        ActivityTagDefinition(id: "siembra", english: "Planting", spanish: "Siembra", keywords: ["siembra", "sembr", "plantar", "plante", "planto", "plantado", "seed", "sow", "sowing"]),
        ActivityTagDefinition(id: "cosecha", english: "Harvest", spanish: "Cosecha", keywords: ["cosecha", "cosechar", "recolect", "harvest", "collect"]),
        ActivityTagDefinition(id: "poda", english: "Pruning", spanish: "Poda", keywords: ["poda", "podar", "pode", "prune", "pruning"]),
        ActivityTagDefinition(id: "riego", english: "Irrigation", spanish: "Riego", keywords: ["riego", "regar", "agua", "irrigation", "water", "watering"]),
        ActivityTagDefinition(id: "abono", english: "Fertilizer", spanish: "Abono", keywords: ["abono", "abonar", "fertiliz", "compost", "fertilizer", "manure"]),
        ActivityTagDefinition(id: "trasplante", english: "Transplant", spanish: "Trasplante", keywords: ["trasplante", "trasplant", "transplant"]),
        ActivityTagDefinition(id: "plagas", english: "Pest Control", spanish: "Plagas", keywords: ["plaga", "plagas", "insecto", "insectos", "hormiga", "hormigas", "pest", "insect", "aphid", "ant"]),
        ActivityTagDefinition(id: "maleza", english: "Weeding", spanish: "Maleza", keywords: ["maleza", "malezas", "hierba", "hierbas", "deshierbe", "weed", "weeding", "monte"]),
        ActivityTagDefinition(id: "suelo", english: "Soil", spanish: "Suelo", keywords: ["suelo", "tierra", "terreno", "soil", "ground"]),
        ActivityTagDefinition(id: "semillas", english: "Seeds", spanish: "Semillas", keywords: ["semilla", "semillas", "seed", "seeds"]),
        ActivityTagDefinition(id: "injerto", english: "Grafting", spanish: "Injerto", keywords: ["injerto", "injert", "graft", "grafting"]),
        ActivityTagDefinition(id: "limpieza", english: "Cleaning", spanish: "Limpieza", keywords: ["limpieza", "limpiar", "cleanup", "cleaning"]),
        ActivityTagDefinition(id: "arbol", english: "Tree", spanish: "Arbol", keywords: ["arbol", "tree", "guanacaste", "palo"]),
        ActivityTagDefinition(id: "frutal", english: "Fruit Tree", spanish: "Frutal", keywords: ["frutal", "fruit tree", "orchard"]),
        ActivityTagDefinition(id: "limon", english: "Lemon", spanish: "Limon", keywords: ["limon", "lemon", "citron"]),
        ActivityTagDefinition(id: "guanacaste", english: "Guanacaste", spanish: "Guanacaste", keywords: ["guanacaste"]),
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
        ActivityTagDefinition(id: "raiz", english: "Root", spanish: "Raiz", keywords: ["raiz", "root", "tuberculo", "tubercle", "bulbo", "bulb"]),
        ActivityTagDefinition(id: "planta", english: "Plant", spanish: "Planta", keywords: ["planta", "plant", "plants", "matas", "mata"])
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

    func updateLogDate(id: UUID, newDate: Date) {
        guard let index = logs.firstIndex(where: { $0.id == id }) else { return }
        let current = logs[index]
        logs[index] = ActivityLog(
            id: current.id,
            text: current.text,
            createdAt: newDate,
            tagIDs: current.tagIDs
        )
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

    func answer(question: String, language: AppLanguage) -> String {
        let trimmed = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return language == .spanish
                ? "Escribe una pregunta sobre tus registros."
                : "Type a question about your logs."
        }

        guard !logs.isEmpty else {
            return language == .spanish
                ? "Aun no tienes registros guardados para responder esa pregunta."
                : "You do not have saved logs yet to answer that question."
        }

        let q = normalize(trimmed)
        let queryTags = extractTagIDs(from: trimmed)
        let yearFilter = requestedYearFilter(from: q)
        let dateRange = requestedDateRange(from: q, yearFilter: yearFilter)
        let asksTreesList = containsAny(q, [
            "cuales son los arboles", "que arboles", "which trees", "what trees"
        ])
        let asksTreesCount = containsAny(q, ["arboles", "arbol", "trees", "tree"]) && containsAny(q, ["cuantos", "cuantas", "how many"])
        let asksPlantsCount = containsAny(q, ["plantas", "planta", "plants", "plant", "matas", "mata"]) && containsAny(q, ["cuantos", "cuantas", "how many"])
        let isLastTime = containsAny(q, [
            "ultima vez", "last time", "when was the last", "latest", "most recent", "reciente"
        ])
        let isCountQuestion = containsAny(q, [
            "cuantas veces", "cuántas veces", "how many times", "how many"
        ])
        let isYesNoQuestion = trimmed.contains("?") && !isCountQuestion

        let periodLogs = sortedLogs.filter { log in
            guard let dateRange else { return true }
            return dateRange.contains(log.createdAt)
        }

        guard !periodLogs.isEmpty else {
            if language == .spanish {
                if let yearFilter {
                    return "No encontre registros para el año \(yearFilter)."
                }
                return "No encontre registros para ese periodo."
            } else {
                if let yearFilter {
                    return "I could not find logs for year \(yearFilter)."
                }
                return "I could not find logs for that period."
            }
        }

        let strictMatches = periodLogs.filter { log in queryTags.allSatisfy { log.tagIDs.contains($0) } }
        let softMatches = periodLogs.filter { log in !Set(log.tagIDs).intersection(queryTags).isEmpty }

        let candidates: [ActivityLog]
        if queryTags.isEmpty {
            candidates = periodLogs
        } else if !strictMatches.isEmpty {
            candidates = strictMatches
        } else if !softMatches.isEmpty {
            candidates = softMatches
        } else {
            candidates = []
        }

        if asksTreesList {
            let treeLogs = candidates.filter { isTreeLog($0) }
            let treeNames = uniqueTreeNames(from: treeLogs, language: language)
            if language == .spanish {
                if treeNames.isEmpty {
                    return "No encontre arboles sembrados en ese periodo."
                }
                return "Arboles sembrados: " + treeNames.joined(separator: ", ") + "."
            } else {
                if treeNames.isEmpty {
                    return "I could not find planted trees in that period."
                }
                return "Planted trees: " + treeNames.joined(separator: ", ") + "."
            }
        }

        if asksTreesCount {
            let total = countUnits(in: candidates.filter { isTreeLog($0) }, nounKind: .tree)
            if language == .spanish {
                return total == 0
                    ? "No encontre arboles sembrados en ese periodo."
                    : "En ese periodo se sembraron \(total) arbol\(total == 1 ? "" : "es")."
            } else {
                return total == 0
                    ? "I could not find planted trees in that period."
                    : "\(total) tree\(total == 1 ? "" : "s") were planted in that period."
            }
        }

        if asksPlantsCount {
            let total = countUnits(in: candidates, nounKind: .plant)
            if language == .spanish {
                return total == 0
                    ? "No encontre plantas para esa actividad en ese periodo."
                    : "En ese periodo se trabajaron \(total) planta\(total == 1 ? "" : "s")."
            } else {
                return total == 0
                    ? "I could not find plants for that activity in that period."
                    : "\(total) plant\(total == 1 ? "" : "s") were handled in that period."
            }
        }

        if isCountQuestion {
            let count = strictMatches.isEmpty ? softMatches.count : strictMatches.count
            if language == .spanish {
                return count == 0
                    ? "No encontre registros que coincidan con esa actividad."
                    : "Encontre \(count) registro\(count == 1 ? "" : "s") que coinciden."
            } else {
                return count == 0
                    ? "I could not find matching activity logs."
                    : "I found \(count) matching log\(count == 1 ? "" : "s")."
            }
        }

        if isYesNoQuestion && !isLastTime && !isCountQuestion {
            let count = candidates.count
            if language == .spanish {
                if count == 0 {
                    return "No encontre registros que coincidan con esa pregunta."
                }
                guard let latest = candidates.first else {
                    return "Encontre \(count) registro\(count == 1 ? "" : "s"), pero no pude mostrar el detalle."
                }
                let dateText = format(date: latest.createdAt, language: language)
                return "Si, encontre \(count) registro\(count == 1 ? "" : "s"). El mas reciente fue el \(dateText): \"\(latest.text)\"."
            } else {
                if count == 0 {
                    return "I could not find logs matching that question."
                }
                guard let latest = candidates.first else {
                    return "I found \(count) log\(count == 1 ? "" : "s"), but could not show details."
                }
                let dateText = format(date: latest.createdAt, language: language)
                return "Yes, I found \(count) log\(count == 1 ? "" : "s"). The most recent was on \(dateText): \"\(latest.text)\"."
            }
        }

        guard let best = candidates.first else {
            return language == .spanish
                ? "No encontre un registro que coincida con tu pregunta."
                : "I could not find a log that matches your question."
        }

        let dateText = format(date: best.createdAt, language: language)
        let tagNames = localizedTags(for: best, language: language)
        let tagText = tagNames.isEmpty ? "" : (language == .spanish ? " Etiquetas: " : " Tags: ") + tagNames.joined(separator: ", ")

        if language == .spanish {
            if isLastTime || !queryTags.isEmpty {
                return "La ultima vez fue el \(dateText): \"\(best.text)\".\(tagText)"
            }
            return "Registro mas reciente: \(dateText): \"\(best.text)\".\(tagText)"
        } else {
            if isLastTime || !queryTags.isEmpty {
                return "The last time was on \(dateText): \"\(best.text)\".\(tagText)"
            }
            return "Most recent log: \(dateText): \"\(best.text)\".\(tagText)"
        }
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

    private func format(date: Date, language: AppLanguage) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: language == .spanish ? "es_ES" : "en_US")
        return formatter.string(from: date)
    }

    private func containsAny(_ normalizedText: String, _ patterns: [String]) -> Bool {
        patterns.contains { pattern in
            normalizedText.contains(normalize(pattern))
        }
    }

    private func requestedDateRange(from normalizedQuestion: String, yearFilter: Int?) -> ClosedRange<Date>? {
        let calendar = Calendar.current
        let now = Date()

        if let weeks = extractLastWeeks(from: normalizedQuestion) {
            guard let start = calendar.date(byAdding: .day, value: -(weeks * 7), to: now) else { return nil }
            return start...now
        }

        if containsAny(normalizedQuestion, ["este mes", "this month"]) {
            let components = calendar.dateComponents([.year, .month], from: now)
            guard let start = calendar.date(from: components),
                  let nextMonth = calendar.date(byAdding: .month, value: 1, to: start),
                  let end = calendar.date(byAdding: .second, value: -1, to: nextMonth) else { return nil }
            return start...end
        }

        if let yearFilter {
            var startComponents = DateComponents()
            startComponents.year = yearFilter
            startComponents.month = 1
            startComponents.day = 1
            guard let start = calendar.date(from: startComponents),
                  let endStart = calendar.date(byAdding: .year, value: 1, to: start),
                  let end = calendar.date(byAdding: .second, value: -1, to: endStart) else { return nil }
            return start...end
        }

        return nil
    }

    private func extractLastWeeks(from normalizedText: String) -> Int? {
        guard containsAny(normalizedText, ["ultima", "ultimas", "last"]) &&
                containsAny(normalizedText, ["semana", "semanas", "week", "weeks"]) else {
            return nil
        }
        let words = normalizedText.split(separator: " ")
        for word in words {
            if let number = Int(word), number > 0 {
                return number
            }
        }
        if containsAny(normalizedText, ["ultima semana", "last week"]) {
            return 1
        }
        return nil
    }

    private func requestedYearFilter(from normalizedQuestion: String) -> Int? {
        let now = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: now)

        if containsAny(normalizedQuestion, ["año pasado", "ano pasado", "last year"]) {
            return currentYear - 1
        }
        if containsAny(normalizedQuestion, ["este año", "este ano", "this year"]) {
            return currentYear
        }

        if let explicit = extractExplicitYear(from: normalizedQuestion) {
            return explicit
        }
        return nil
    }

    private func extractExplicitYear(from normalizedText: String) -> Int? {
        let words = normalizedText.split(separator: " ")
        for word in words {
            let s = String(word)
            if s.count == 4, let year = Int(s), year >= 1900, year <= 2100 {
                return year
            }
        }
        return nil
    }

    private enum NounKind {
        case tree
        case plant
    }

    private func countUnits(in logs: [ActivityLog], nounKind: NounKind) -> Int {
        var total = 0
        for log in logs {
            let explicit = countUnits(in: log.text, nounKind: nounKind)
            total += max(explicit, 1)
        }
        return total
    }

    private func countUnits(in text: String, nounKind: NounKind) -> Int {
        let normalized = normalize(text)
        let words = normalized.split(separator: " ").map(String.init)
        let targets: Set<String> = nounKind == .tree ? ["arbol", "arboles", "tree", "trees", "palo", "palos"] : ["planta", "plantas", "plant", "plants", "mata", "matas"]

        var foundTarget = false
        var explicitCount = 0
        for (index, word) in words.enumerated() {
            guard targets.contains(word) else { continue }
            foundTarget = true
            if index > 0, let number = Int(words[index - 1]), number > 0 {
                explicitCount += number
            } else {
                explicitCount += 1
            }
        }

        if foundTarget {
            return explicitCount
        }
        return 0
    }

    private func isTreeLog(_ log: ActivityLog) -> Bool {
        if log.tagIDs.contains("arbol") || !Set(log.tagIDs).intersection(treeSpeciesTagIDs).isEmpty {
            return true
        }
        let normalized = normalize(log.text)
        return containsAny(normalized, ["arbol", "arboles", "tree", "trees", "guanacaste"])
    }

    private func uniqueTreeNames(from logs: [ActivityLog], language: AppLanguage) -> [String] {
        var names: [String] = []
        for log in logs {
            for tag in log.tagIDs where treeSpeciesTagIDs.contains(tag) {
                if let name = tagName(for: tag, language: language), !names.contains(name) {
                    names.append(name)
                }
            }
            for parsed in parseTreeNames(from: log.text, language: language) where !names.contains(parsed) {
                names.append(parsed)
            }
        }
        return names
    }

    private func parseTreeNames(from text: String, language: AppLanguage) -> [String] {
        let normalized = normalize(text)
        let words = normalized.split(separator: " ").map(String.init)
        guard !words.isEmpty else { return [] }

        var results: [String] = []
        for index in 0..<words.count {
            let word = words[index]
            guard word == "arbol" || word == "arboles" || word == "tree" || word == "trees" else { continue }

            if index + 2 < words.count && words[index + 1] == "de" {
                let candidateID = words[index + 2]
                if treeSpeciesTagIDs.contains(candidateID), let localized = tagName(for: candidateID, language: language) {
                    if !results.contains(localized) {
                        results.append(localized)
                    }
                }
            }
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
