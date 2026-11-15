import SwiftUI

@main
struct VaultApp: App {
    // Design phase: the store runs on in-memory mock data. When real storage
    // lands, it is created with a Core Data + iCloud persistence instead.
    @State private var store = VaultStore(scenario: .populated)
    @State private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .environment(router)
        }
    }
}

/// Setup on first launch, then the tabbed app.
struct RootView: View {
    @Environment(VaultStore.self) private var store
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var store = store
        Group {
            if store.hasCompletedSetup {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environment(\.hideAmounts, store.hideAmounts)
        .preferredColorScheme(colorScheme)
        .tint(VaultColor.accent)
        .fullScreenCover(item: $store.celebration) { celebration in
            CelebrationView(celebration: celebration)
        }
    }

    private var colorScheme: ColorScheme? {
        switch store.appearance {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
