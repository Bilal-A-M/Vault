import Foundation

/// A deposit or withdrawal the couple logged. Vault never moves money; it
/// records what you already did at the bank.
struct Entry: Identifiable, Hashable, Codable {
    enum Kind: String, Codable, CaseIterable, Identifiable {
        case deposit, withdrawal
        var id: String { rawValue }
        var title: String { self == .deposit ? "Deposit" : "Withdrawal" }
    }

    let id: UUID
    /// Always positive, in cents. Use `signedCents` for maths.
    var amountCents: Int
    var kind: Kind
    var date: Date
    var note: String
    var goalID: Goal.ID?
    var personID: Person.ID
    /// When the entry was logged (drives "New" tags on the partner's phone).
    var createdAt: Date

    init(id: UUID = UUID(), amountCents: Int, kind: Kind = .deposit, date: Date,
         note: String = "", goalID: Goal.ID? = nil, personID: Person.ID, createdAt: Date? = nil) {
        self.id = id
        self.amountCents = amountCents
        self.kind = kind
        self.date = date
        self.note = note
        self.goalID = goalID
        self.personID = personID
        self.createdAt = createdAt ?? date
    }

    var isWithdrawal: Bool { kind == .withdrawal }
    var signedCents: Int { isWithdrawal ? -amountCents : amountCents }
}

/// One person's share of some total (split bars, contributor lists).
struct ContributionShare: Identifiable, Hashable {
    let person: Person
    let cents: Int
    var id: Person.ID { person.id }
}

/// What gets synced. Device-only preferences live in `DevicePreferences`.
struct VaultSnapshot: Codable, Hashable {
    var people: [Person]
    var goals: [Goal]
    var entries: [Entry]
}

/// Settings that belong to one phone and are never synced.
struct DevicePreferences: Codable, Hashable {
    var phoneOwnerID: Person.ID?
    var hasCompletedSetup: Bool
    var hideAmounts = false
    var depositAlerts = true
    var milestoneAlerts = true
    var appearance: Appearance = .system
    /// Entries the partner logged after this moment show a "New" tag.
    var lastSeen: Date = .now
    /// Milestones already celebrated on this phone ("goalID:percent").
    var seenMilestones: Set<String> = []
}

enum Appearance: String, Codable, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

/// iCloud sync status. Mocked during the design phase.
enum SyncStatus: Hashable {
    case synced(Date)
    case syncing
    case offline(lastSynced: Date)
}
