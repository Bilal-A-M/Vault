import Foundation

/// Where the vault is loaded from and saved to. The app only talks to this
/// protocol, so swapping mock data for Core Data + iCloud is one line in
/// `VaultApp`.
protocol VaultPersistence: AnyObject {
    func loadSnapshot() -> VaultSnapshot
    func loadPreferences() -> DevicePreferences
    func save(_ snapshot: VaultSnapshot)
    func save(_ preferences: DevicePreferences)
}

/// Design-phase storage: keeps everything in memory, seeded from a mock
/// scenario. Changes last until the app is closed.
final class InMemoryPersistence: VaultPersistence {
    private var snapshot: VaultSnapshot
    private var preferences: DevicePreferences

    init(scenario: MockData.Scenario) {
        snapshot = MockData.snapshot(scenario)
        preferences = MockData.preferences(scenario)
    }

    func loadSnapshot() -> VaultSnapshot { snapshot }
    func loadPreferences() -> DevicePreferences { preferences }
    func save(_ snapshot: VaultSnapshot) { self.snapshot = snapshot }
    func save(_ preferences: DevicePreferences) { self.preferences = preferences }
}
