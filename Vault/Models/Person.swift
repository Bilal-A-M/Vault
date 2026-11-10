import Foundation

/// One of the two people who share the vault. There are no accounts:
/// the app simply knows two `Person` values and which one owns this phone.
struct Person: Identifiable, Hashable {
    let id: UUID
    var name: String
    var color: PersonColor
    /// An emoji shown in the avatar. When empty, the first initial is used.
    var avatar: String

    init(id: UUID = UUID(), name: String, color: PersonColor, avatar: String = "") {
        self.id = id
        self.name = name
        self.color = color
        self.avatar = avatar
    }

    var initial: String {
        name.first.map { String($0).uppercased() } ?? "?"
    }
}

/// The palette a person can pick from. Stored as a raw string so it can be
/// persisted later; the actual colors live in the design system (`PersonColor.color`).
enum PersonColor: String, CaseIterable, Identifiable, Hashable {
    case teal, coral, lavender, sky, rose, sage

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}
