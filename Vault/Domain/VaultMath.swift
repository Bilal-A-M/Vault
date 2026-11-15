import Foundation

/// Every number the app shows is derived here from entries. Nothing is stored
/// as a running total, so two phones can never disagree once their entries
/// match. Pure functions: easy to unit-test.
enum VaultMath {

    static func total(_ entries: [Entry]) -> Int {
        entries.reduce(0) { $0 + $1.signedCents }
    }

    static func saved(goalID: Goal.ID, in entries: [Entry]) -> Int {
        total(entries.filter { $0.goalID == goalID })
    }

    /// 0...1+ (can exceed 1 when over-funded).
    static func progress(saved: Int, target: Int) -> Double {
        guard target > 0 else { return 0 }
        return max(0, Double(saved) / Double(target))
    }

    /// Net contribution per person over the given entries, in `people` order.
    static func shares(_ entries: [Entry], people: [Person]) -> [ContributionShare] {
        people.map { person in
            ContributionShare(person: person, cents: total(entries.filter { $0.personID == person.id }))
        }
    }

    static func entries(_ entries: [Entry], inMonthOf month: Date, calendar: Calendar = .current) -> [Entry] {
        entries.filter { calendar.isDate($0.date, equalTo: month, toGranularity: .month) }
    }

    /// Milestones newly passed when a goal's saved amount moves from `before` to `after`.
    static func crossedMilestones(before: Int, after: Int, target: Int) -> [Milestone] {
        let was = progress(saved: before, target: target)
        let now = progress(saved: after, target: target)
        return Milestone.allCases.filter { was < $0.fraction && now >= $0.fraction }
    }

    // MARK: Charts

    struct BalancePoint: Identifiable, Hashable {
        let date: Date
        let cents: Int
        var series: String = "All"
        var id: String { "\(series)-\(date.timeIntervalSince1970)" }
    }

    /// Running balance after each day that had activity, optionally for one goal,
    /// starting with the balance carried into `since`.
    static func balanceSeries(_ entries: [Entry], goalID: Goal.ID? = nil, since: Date? = nil,
                              series: String = "All", calendar: Calendar = .current) -> [BalancePoint] {
        let relevant = entries.filter { goalID == nil || $0.goalID == goalID }.sorted { $0.date < $1.date }
        guard !relevant.isEmpty else { return [] }
        var running = 0
        var points: [BalancePoint] = []
        var lastDay: Date?
        for entry in relevant {
            running += entry.signedCents
            let day = calendar.startOfDay(for: entry.date)
            if let since, day < since { continue }
            if day == lastDay, !points.isEmpty { points.removeLast() }
            points.append(BalancePoint(date: day, cents: running, series: series))
            lastDay = day
        }
        if let since {
            let carried = total(relevant.filter { calendar.startOfDay(for: $0.date) < since })
            points.insert(BalancePoint(date: since, cents: carried, series: series), at: 0)
        }
        return points
    }

    struct MonthlyContribution: Identifiable, Hashable {
        let month: Date
        let person: Person
        let cents: Int
        var id: String { "\(month.timeIntervalSince1970)-\(person.id)" }
    }

    /// Net deposits per person per calendar month, oldest first.
    static func monthlyContributions(_ entries: [Entry], people: [Person], months: Int,
                                     now: Date = .now, calendar: Calendar = .current) -> [MonthlyContribution] {
        guard let thisMonth = calendar.dateInterval(of: .month, for: now)?.start else { return [] }
        return (0..<months).reversed().flatMap { offset -> [MonthlyContribution] in
            guard let month = calendar.date(byAdding: .month, value: -offset, to: thisMonth) else { return [] }
            let inMonth = self.entries(entries, inMonthOf: month, calendar: calendar)
            return people.map { person in
                let net = total(inMonth.filter { $0.personID == person.id })
                return MonthlyContribution(month: month, person: person, cents: max(0, net))
            }
        }
    }

    // MARK: Pace

    /// Average net monthly saving into a goal over the last `months` months.
    static func monthlyPace(goalID: Goal.ID, entries: [Entry], months: Int = 3,
                            now: Date = .now, calendar: Calendar = .current) -> Int {
        guard let start = calendar.date(byAdding: .month, value: -months, to: now) else { return 0 }
        let recent = entries.filter { $0.goalID == goalID && $0.date >= start }
        return total(recent) / max(months, 1)
    }

    /// Amount per month still needed to hit the target date, if there is one.
    static func monthlyNeeded(remaining: Int, targetDate: Date?, now: Date = .now,
                              calendar: Calendar = .current) -> Int? {
        guard remaining > 0, let targetDate, targetDate > now else { return nil }
        let months = max(1, calendar.dateComponents([.month], from: now, to: targetDate).month ?? 1)
        return remaining / months
    }

    /// When the goal will be reached at the current pace.
    static func projectedCompletion(remaining: Int, pace: Int, now: Date = .now,
                                    calendar: Calendar = .current) -> Date? {
        guard remaining > 0, pace > 0 else { return nil }
        let months = Int((Double(remaining) / Double(pace)).rounded(.up))
        return calendar.date(byAdding: .month, value: months, to: now)
    }

    /// The day the running balance first reached the target, if it did.
    static func reachedDate(goal: Goal, entries: [Entry]) -> Date? {
        var running = 0
        for entry in entries.filter({ $0.goalID == goal.id }).sorted(by: { $0.date < $1.date }) {
            running += entry.signedCents
            if running >= goal.targetCents { return entry.date }
        }
        return nil
    }
}
