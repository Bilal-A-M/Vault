import SwiftUI

enum AppTab: Hashable {
    case home, history, goals, insights
    /// The round glass ＋ beside the tab bar. Never actually selected: it
    /// opens the Add deposit sheet and the previous tab stays put.
    case add
}

enum Route: Hashable {
    case goal(Goal.ID)
    case settings
    case person(Person.ID)
    case notificationPreview
    case notificationPermission
    case gallery
}

struct EntrySheetConfig: Identifiable {
    let id = UUID()
    var kind: Entry.Kind = .deposit
    var goalID: Goal.ID?
    var editing: Entry?
}

struct GoalSheetConfig: Identifiable {
    let id = UUID()
    var editing: Goal?
}

/// Navigation state: selected tab, each tab's stack, and the open sheet.
@MainActor
@Observable
final class AppRouter {
    var tab: AppTab = .home
    var homePath: [Route] = []
    var historyPath: [Route] = []
    var goalsPath: [Route] = []
    var insightsPath: [Route] = []

    var entrySheet: EntrySheetConfig?
    var goalSheet: GoalSheetConfig?

    func addDeposit(goalID: Goal.ID? = nil) { entrySheet = EntrySheetConfig(kind: .deposit, goalID: goalID) }
    func logWithdrawal(goalID: Goal.ID? = nil) { entrySheet = EntrySheetConfig(kind: .withdrawal, goalID: goalID) }
    func edit(_ entry: Entry) { entrySheet = EntrySheetConfig(kind: entry.kind, goalID: entry.goalID, editing: entry) }
    func newGoal() { goalSheet = GoalSheetConfig() }
    func edit(_ goal: Goal) { goalSheet = GoalSheetConfig(editing: goal) }
}
