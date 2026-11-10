import Foundation

struct Deposit: Identifiable, Hashable {
    let id: UUID
    /// Always positive. Use `signedCents` for math.
    var amountCents: Int
    var isWithdrawal: Bool
    var date: Date
    var note: String
    var goalID: Goal.ID?
    var personID: Person.ID

    init(id: UUID = UUID(), amountCents: Int, isWithdrawal: Bool = false, date: Date,
         note: String = "", goalID: Goal.ID? = nil, personID: Person.ID) {
        self.id = id
        self.amountCents = amountCents
        self.isWithdrawal = isWithdrawal
        self.date = date
        self.note = note
        self.goalID = goalID
        self.personID = personID
    }

    var signedCents: Int { isWithdrawal ? -amountCents : amountCents }
}

/// One person's share of some total, used by split bars and contribution lists.
struct ContributionShare: Identifiable, Hashable {
    let person: Person
    let cents: Int
    var id: Person.ID { person.id }
}
