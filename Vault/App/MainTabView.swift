import SwiftUI

/// iOS 26 Liquid Glass tab bar: four tabs in the floating glass pill, and
/// Add deposit as the separate round button. The round button uses the
/// system's dedicated slot (the `.search` tab role, which Apple's own apps use
/// for their key action); selecting it opens the Add deposit sheet instead.
struct MainTabView: View {
    @Environment(VaultStore.self) private var store
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router
        TabView(selection: $router.tab) {
            Tab("Home", systemImage: "house.fill", value: AppTab.home) {
                NavigationStack(path: $router.homePath) {
                    HomeView().routes()
                }
            }
            Tab("History", systemImage: "clock.arrow.circlepath", value: AppTab.history) {
                NavigationStack(path: $router.historyPath) {
                    HistoryView().routes()
                }
            }
            Tab("Goals", systemImage: "target", value: AppTab.goals) {
                NavigationStack(path: $router.goalsPath) {
                    GoalsView().routes()
                }
            }
            Tab("Insights", systemImage: "chart.bar.fill", value: AppTab.insights) {
                NavigationStack(path: $router.insightsPath) {
                    InsightsView().routes()
                }
            }
            Tab("Add deposit", systemImage: "plus", value: AppTab.add, role: .search) {
                Color.clear
            }
        }
        .onChange(of: router.tab) { previous, selected in
            guard selected == .add else { return }
            router.tab = previous == .add ? .home : previous
            router.addDeposit()
        }
        .sheet(item: $router.entrySheet) { config in
            EntrySheet(config: config)
        }
        .sheet(item: $router.goalSheet) { config in
            GoalEditorSheet(config: config)
        }
    }
}

extension View {
    /// Every tab's stack can push any of these screens.
    func routes() -> some View {
        navigationDestination(for: Route.self) { route in
            switch route {
            case .goal(let id): GoalDetailView(goalID: id)
            case .settings: SettingsView()
            case .person(let id): PersonEditorView(personID: id)
            case .notificationPreview: NotificationPreviewView()
            case .notificationPermission: NotificationPermissionView()
            case .gallery: DesignGalleryView()
            }
        }
    }
}
