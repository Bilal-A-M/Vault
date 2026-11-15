import SwiftUI

/// Settings → Preview & debug: jump to any state without clicking through.
struct DebugSection: View {
    @Environment(VaultStore.self) private var store

    var body: some View {
        @Bindable var store = store
        Section {
            Picker("Mock data", selection: Binding(get: { store.scenario }, set: { store.load(scenario: $0) })) {
                ForEach(MockData.Scenario.allCases) { Text($0.title).tag($0) }
            }
            Picker("Sync state", selection: Binding(
                get: { if case .offline = store.syncStatus { return 1 } else { return 0 } },
                set: { store.syncStatus = $0 == 1 ? .offline(lastSynced: .now.addingTimeInterval(-7200)) : .synced(.now) })) {
                Text("Synced").tag(0)
                Text("Can't sync").tag(1)
            }
            Toggle("Show loading state", isOn: $store.isLoading)
            ForEach(Milestone.allCases) { milestone in
                Button("Show \(milestone.label) celebration") { store.previewCelebration(milestone) }
                    .disabled(store.goals.isEmpty)
            }
            NavigationLink("Notification permission prompt", value: Route.notificationPermission)
            NavigationLink("Design system gallery", value: Route.gallery)
            Button("Replay first-launch setup", role: .destructive) { store.replaySetup() }
        } header: {
            Text("Preview & debug")
        } footer: {
            Text("Mock data only. Changes reset when the app closes.")
        }
    }
}
