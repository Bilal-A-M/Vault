import Foundation

/// One of the two people who share the vault. There are no accounts: the app
/// knows two `Person` values, and each phone remembers which one is holding it.
struct Person: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var color: PersonColor

    init(id: UUID = UUID(), name: String, color: PersonColor) {
        self.id = id
        self.name = name
        self.color = color
    }

    var initial: String {
        name.trimmingCharacters(in: .whitespaces).first.map { String($0).uppercased() } ?? "?"
    }
}

/// The colours a person can pick at setup. Sky and rose are the defaults.
/// Stored as a raw string so it survives sync; the actual colours live in
/// `VaultColor` (design system).
enum PersonColor: String, CaseIterable, Identifiable, Codable {
    case sky, rose, lavender, sage, coral, slate

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}
