import SwiftUI

/// The single source of truth the screens read from. It holds the synced
/// vault (people, goals, entries) plus this phone's preferences, and derives
/// every total through `VaultMath`.
@MainActor
@Observable
final class VaultStore {

    // MARK: Synced data
    private(set) var people: [Person] = []
    private(set) var goals: [Goal] = []
    private(set) var entries: [Entry] = []

    // MARK: This phone
    private(set) var preferences = DevicePreferences(phoneOwnerID: nil, hasCompletedSetup: false)

    // MARK: Status (mocked until iCloud arrives)
    var syncStatus: SyncStatus = .synced(.now)
    var isLoading = false

    /// Set when an entry crosses a milestone; the root view presents it.
    var celebration: Celebration?
    private(set) var scenario: MockData.Scenario

    private var persistence: VaultPersistence

    init(scenario: MockData.Scenario = .populated) {
        self.scenario = scenario
        persistence = InMemoryPersistence(scenario: scenario)
        reload()
    }

    /// Debug: swap the whole vault for another mock scenario.
    func load(scenario: MockData.Scenario) {
        self.scenario = scenario
        persistence = InMemoryPersistence(scenario: scenario)
        reload()
    }

    private func reload() {
        let snapshot = persistence.loadSnapshot()
        people = snapshot.people
        goals = snapshot.goals
        entries = snapshot.entries
        preferences = persistence.loadPreferences()
    }

    private func persist() {
        persistence.save(VaultSnapshot(people: people, goals: goals, entries: entries))
        persistence.save(preferences)
    }

    // MARK: Preferences (bindable)

    var hideAmounts: Bool {
        get { preferences.hideAmounts }
        set { preferences.hideAmounts = newValue; persist() }
    }
    var depositAlerts: Bool {
        get { preferences.depositAlerts }
        set { preferences.depositAlerts = newValue; persist() }
    }
    var milestoneAlerts: Bool {
        get { preferences.milestoneAlerts }
        set { preferences.milestoneAlerts = newValue; persist() }
    }
    var appearance: Appearance {
        get { preferences.appearance }
        set { preferences.appearance = newValue; persist() }
    }
    var hasCompletedSetup: Bool { preferences.hasCompletedSetup }

    // MARK: People

    var owner: Person? { people.first { $0.id == preferences.phoneOwnerID } ?? people.first }
    var partner: Person? { people.first { $0.id != owner?.id } }

    func person(_ id: Person.ID) -> Person? { people.first { $0.id == id } }

    func setPhoneOwner(_ id: Person.ID) {
        preferences.phoneOwnerID = id
        persist()
    }

    func updatePerson(_ person: Person) {
        guard let index = people.firstIndex(where: { $0.id == person.id }) else { return }
        people[index] = person
        persist()
    }

    // MARK: Setup

    func completeSetup(people newPeople: [Person], ownerID: Person.ID) {
        people = newPeople
        preferences.phoneOwnerID = ownerID
        preferences.hasCompletedSetup = true
        preferences.lastSeen = .now
        persist()
    }

    /// Debug: show first-launch setup again.
    func replaySetup() { load(scenario: .firstLaunch) }

    // MARK: Goals

    func goal(_ id: Goal.ID?) -> Goal? {
        guard let id else { return nil }
        return goals.first { $0.id == id }
    }

    func saved(_ goal: Goal) -> Int { VaultMath.saved(goalID: goal.id, in: entries) }
    func progress(_ goal: Goal) -> Double { VaultMath.progress(saved: saved(goal), target: goal.targetCents) }

    /// Goals ordered for display: in progress first (closest to done), then reached.
    var sortedGoals: [Goal] {
        goals.sorted { a, b in
            let pa = progress(a), pb = progress(b)
            if (pa >= 1) != (pb >= 1) { return pa < 1 }
            return pa > pb
        }
    }

    func saveGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
        } else {
            goals.append(goal)
        }
        persist()
    }

    func deleteGoal(_ id: Goal.ID) {
        goals.removeAll { $0.id == id }
        // Entries stay in the vault total, just no longer assigned to a goal.
        for index in entries.indices where entries[index].goalID == id {
            entries[index].goalID = nil
        }
        persist()
    }

    /// A milestone reached on this phone but not yet seen (drives the badge).
    func freshMilestone(for goal: Goal) -> Milestone? {
        Milestone.earned(at: progress(goal))
            .filter { !preferences.seenMilestones.contains(key(goal, $0)) }
            .max()
    }

    func markMilestonesSeen(for goal: Goal) {
        for milestone in Milestone.earned(at: progress(goal)) {
            preferences.seenMilestones.insert(key(goal, milestone))
        }
        persist()
    }

    private func key(_ goal: Goal, _ milestone: Milestone) -> String { "\(goal.id):\(milestone.rawValue)" }

    // MARK: Entries

    var totalCents: Int { VaultMath.total(entries) }
    var sortedEntries: [Entry] { entries.sorted { $0.date > $1.date } }

    func entry(_ id: Entry.ID) -> Entry? { entries.first { $0.id == id } }

    /// The partner logged it since this phone last looked.
    func isNew(_ entry: Entry) -> Bool {
        entry.personID != owner?.id && entry.createdAt > preferences.lastSeen
    }

    /// The milestone this entry pushed its goal past, if any.
    func milestoneCrossed(by entry: Entry) -> Milestone? {
        guard let goal = goal(entry.goalID) else { return nil }
        let before = entries
            .filter { $0.goalID == goal.id && $0.id != entry.id && ($0.date, $0.createdAt) < (entry.date, entry.createdAt) }
            .reduce(0) { $0 + $1.signedCents }
        return VaultMath.crossedMilestones(before: before, after: before + entry.signedCents,
                                           target: goal.targetCents).max()
    }

    /// Adds or updates an entry. Returns a celebration when a new deposit
    /// crosses a milestone, so the caller can present it after its sheet closes.
    @discardableResult
    func saveEntry(_ entry: Entry) -> Celebration? {
        var crossed: Milestone?
        if let goal = goal(entry.goalID) {
            let before = saved(goal) - (self.entry(entry.id)?.signedCents ?? 0)
            crossed = VaultMath.crossedMilestones(before: before, after: before + entry.signedCents,
                                                  target: goal.targetCents).max()
        }
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
        } else {
            entries.append(entry)
        }
        persist()
        guard let crossed, let goal = goal(entry.goalID) else { return nil }
        return makeCelebration(goal: goal, milestone: crossed)
    }

    func deleteEntry(_ id: Entry.ID) {
        entries.removeAll { $0.id == id }
        persist()
    }

    func markSeen() {
        preferences.lastSeen = .now
        persist()
    }

    // MARK: Celebrations

    func makeCelebration(goal: Goal, milestone: Milestone) -> Celebration {
        let goalEntries = entries.filter { $0.goalID == goal.id }
        let months = Calendar.current.dateComponents([.month],
                                                     from: goalEntries.map(\.date).min() ?? goal.createdAt,
                                                     to: .now).month ?? 0
        return Celebration(goal: goal, milestone: milestone, savedCents: saved(goal),
                           shares: VaultMath.shares(goalEntries, people: people), months: max(1, months))
    }

    func present(_ celebration: Celebration) {
        preferences.seenMilestones.insert(key(celebration.goal, celebration.milestone))
        persist()
        self.celebration = celebration
    }

    /// Debug: preview each celebration level on the first goal.
    func previewCelebration(_ milestone: Milestone) {
        guard let goal = sortedGoals.first ?? goals.first else { return }
        celebration = makeCelebration(goal: goal, milestone: milestone)
    }
}

struct Celebration: Identifiable {
    let id = UUID()
    let goal: Goal
    let milestone: Milestone
    let savedCents: Int
    let shares: [ContributionShare]
    let months: Int
}
