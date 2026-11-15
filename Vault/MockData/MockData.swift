import Foundation

/// ALL mock data lives here. Screens never read this file directly: they go
/// through `VaultStore`, which loads a scenario via `InMemoryPersistence`.
/// When real storage arrives, this file stays only for previews and tests.
enum MockData {

    /// The states you can jump to from Settings → Preview & debug.
    enum Scenario: String, CaseIterable, Identifiable {
        case populated, nearMilestone, sparse, empty, firstLaunch
        var id: String { rawValue }
        var title: String {
            switch self {
            case .populated: "Populated (7 months)"
            case .nearMilestone: "Near a milestone"
            case .sparse: "Sparse (2 weeks)"
            case .empty: "Empty vault"
            case .firstLaunch: "First launch (setup)"
            }
        }
    }

    // MARK: People (fixed IDs so previews and widgets agree)

    static let bilal = Person(id: UUID(uuidString: "6B1E8B57-0000-4000-8000-000000000001")!, name: "Bilal", color: .sky)
    static let hiba = Person(id: UUID(uuidString: "6B1E8B57-0000-4000-8000-000000000002")!, name: "Hiba", color: .rose)
    static let people = [bilal, hiba]

    // MARK: Goals

    static let vacation = Goal(id: UUID(uuidString: "6B1E8B57-0000-4000-8000-000000000011")!,
                               name: "Vacation", icon: .plane, targetCents: 600_000,
                               targetDate: date(daysFromNow: 138), createdAt: date(daysFromNow: -200))
    static let house = Goal(id: UUID(uuidString: "6B1E8B57-0000-4000-8000-000000000012")!,
                            name: "House deposit", icon: .house, targetCents: 4_000_000,
                            targetDate: date(daysFromNow: 700), createdAt: date(daysFromNow: -210))
    static let emergency = Goal(id: UUID(uuidString: "6B1E8B57-0000-4000-8000-000000000013")!,
                                name: "Emergency fund", icon: .shield, targetCents: 1_000_000,
                                createdAt: date(daysFromNow: -220))
    static let car = Goal(id: UUID(uuidString: "6B1E8B57-0000-4000-8000-000000000014")!,
                          name: "New car", icon: .car, targetCents: 1_500_000,
                          targetDate: date(daysFromNow: 400), createdAt: date(daysFromNow: -60))
    static let goals = [vacation, house, emergency, car]

    // MARK: Entries
    //
    // ~7 months of history. Totals: Vacation $4,680 (78%; Hiba's $200 today
    // crossed 75%), House $19,400 (48.5%, $600 short of 50%), Emergency fund
    // $10,000 (reached), New car $1,200. Sum: $35,280.

    enum Who { case bilal, hiba }
    enum GoalKey { case vacation, house, emergency, car }

    static let entries: [Entry] = [
        e(0, 20000, .hiba, .vacation, note: "Payday top-up"),
        e(2, 12550, .hiba, .emergency, note: "Top-up after repair"),
        e(3, 20000, .hiba, .vacation),
        e(3, 45000, .bilal, .house),
        e(5, 40000, .bilal, .vacation),
        e(6, 12550, .bilal, .emergency, note: "Car repair", withdrawal: true),
        e(8, 30000, .hiba, .car),
        e(12, 35000, .bilal, .vacation, note: "Flights fund"),
        e(19, 100000, .hiba, .house, note: "Bonus"),
        e(20, 30000, .bilal, .car),
        e(25, 18000, .hiba, .vacation, note: "Sold old bike"),
        e(30, 105000, .hiba, .house),
        e(40, 100000, .bilal, .house),
        e(45, 30000, .hiba, .car),
        e(51, 130000, .bilal, .house),
        e(55, 30000, .bilal, .car),
        e(60, 30000, .hiba, .vacation),
        e(66, 50000, .bilal, .vacation),
        e(68, 50000, .hiba, .emergency),
        e(70, 70000, .bilal, .emergency),
        e(75, 110000, .hiba, .house),
        e(82, 140000, .bilal, .house),
        e(90, 25000, .hiba, .vacation),
        e(97, 40000, .bilal, .vacation),
        e(106, 95000, .hiba, .house),
        e(113, 125000, .bilal, .house),
        e(121, 30000, .hiba, .vacation),
        e(128, 35000, .bilal, .vacation),
        e(137, 100000, .hiba, .house),
        e(144, 130000, .bilal, .house),
        e(147, 90000, .hiba, .emergency),
        e(150, 100000, .bilal, .emergency),
        e(152, 30000, .hiba, .vacation),
        e(160, 40000, .bilal, .vacation),
        e(168, 90000, .hiba, .house),
        e(175, 120000, .bilal, .house),
        e(179, 110000, .hiba, .emergency),
        e(182, 130000, .bilal, .emergency),
        e(186, 25000, .hiba, .vacation),
        e(190, 30000, .bilal, .vacation),
        e(200, 250000, .hiba, .house, note: "Starting balance"),
        e(205, 300000, .bilal, .house, note: "Starting balance"),
        e(212, 200000, .hiba, .emergency),
        e(215, 250000, .bilal, .emergency)
    ]

    // MARK: Scenarios

    static func snapshot(_ scenario: Scenario) -> VaultSnapshot {
        switch scenario {
        case .populated:
            return VaultSnapshot(people: people, goals: goals, entries: entries)
        case .nearMilestone:
            // Without Hiba's latest $200, Vacation sits at 74.7%: logging $20+
            // to Vacation crosses 75% and shows the celebration.
            let latest = entries.filter { $0.goalID == vacation.id }.max { $0.date < $1.date }
            return VaultSnapshot(people: people, goals: goals, entries: entries.filter { $0.id != latest?.id })
        case .sparse:
            let few = [
                e(12, 25_000, .bilal, .vacation, note: "First deposit"),
                e(4, 15_000, .hiba, .vacation),
            ]
            return VaultSnapshot(people: people, goals: [vacation, house], entries: few)
        case .empty:
            return VaultSnapshot(people: people, goals: [], entries: [])
        case .firstLaunch:
            return VaultSnapshot(people: [], goals: [], entries: [])
        }
    }

    static func preferences(_ scenario: Scenario) -> DevicePreferences {
        var prefs = DevicePreferences(phoneOwnerID: bilal.id, hasCompletedSetup: scenario != .firstLaunch)
        if scenario == .firstLaunch { prefs.phoneOwnerID = nil }
        // Anything Hiba logged in the last day shows as "New" on Bilal's phone.
        prefs.lastSeen = date(daysFromNow: -1)
        // The Vacation 75% badge stays "new" until it has been seen.
        prefs.seenMilestones = ["\(vacation.id):25", "\(vacation.id):50", "\(house.id):25",
                                "\(emergency.id):25", "\(emergency.id):50", "\(emergency.id):75", "\(emergency.id):100"]
        return prefs
    }

    // MARK: Helpers

    static func date(daysFromNow days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: .now) ?? .now
    }

    /// Builds one entry `daysAgo` days back (today's entries sit two hours ago).
    static func e(_ daysAgo: Int, _ cents: Int, _ who: Who, _ goal: GoalKey,
                  note: String = "", withdrawal: Bool = false) -> Entry {
        let when = date(daysFromNow: -daysAgo).addingTimeInterval(-2 * 3600)
        let goalID: Goal.ID = switch goal {
        case .vacation: vacation.id
        case .house: house.id
        case .emergency: emergency.id
        case .car: car.id
        }
        return Entry(amountCents: cents, kind: withdrawal ? .withdrawal : .deposit, date: when,
                     note: note, goalID: goalID, personID: who == .bilal ? bilal.id : hiba.id)
    }
}
