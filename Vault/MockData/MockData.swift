import Foundation

/// ALL mock data lives in this folder. Screens and previews read from here;
/// when the real data layer arrives, this is the only thing to replace.
/// (The full 6+ month deposit history is added with the Dashboard screens.)
enum MockData {
    // MARK: People

    static let me = Person(name: "Bilal", color: .teal, avatar: "🦊")
    static let wife = Person(name: "Sara", color: .coral, avatar: "🌸")
    static let people = [me, wife]

    // MARK: Goals (different progress levels; `house` sits just under 50%)

    static let vacation = Goal(name: "Vacation", emoji: "🏝️", targetCents: 600_000,
                               targetDate: date(daysFromNow: 140), createdAt: date(daysFromNow: -200))
    static let house = Goal(name: "House deposit", emoji: "🏡", targetCents: 4_000_000,
                            targetDate: date(daysFromNow: 700), createdAt: date(daysFromNow: -210))
    static let emergency = Goal(name: "Emergency fund", emoji: "🛟", targetCents: 1_000_000,
                                createdAt: date(daysFromNow: -220))
    static let car = Goal(name: "New car", emoji: "🚗", targetCents: 1_500_000,
                          targetDate: date(daysFromNow: 400), createdAt: date(daysFromNow: -60))
    static let goals = [vacation, house, emergency, car]

    /// Saved-so-far per goal, in cents.
    static let savedByGoal: [Goal.ID: Int] = [
        vacation.id: 468_000,     // 78%
        house.id: 1_940_000,      // 48.5%, near the 50% milestone
        emergency.id: 1_000_000,  // 100%
        car.id: 120_000,          // 8%
    ]

    // MARK: Deposits (a small sample for component previews)

    static let sampleDeposits: [Deposit] = [
        Deposit(amountCents: 20_000, date: date(daysFromNow: -1), note: "Payday top-up",
                goalID: vacation.id, personID: wife.id),
        Deposit(amountCents: 45_000, date: date(daysFromNow: -3), note: "",
                goalID: house.id, personID: me.id),
        Deposit(amountCents: 12_550, isWithdrawal: true, date: date(daysFromNow: -6),
                note: "Car repair", goalID: emergency.id, personID: me.id),
    ]

    // MARK: Helpers

    static func date(daysFromNow days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: .now) ?? .now
    }

    static func person(_ id: Person.ID) -> Person {
        people.first { $0.id == id } ?? me
    }

    static func goal(_ id: Goal.ID?) -> Goal? {
        goals.first { $0.id == id }
    }
}
