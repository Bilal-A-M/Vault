import SwiftUI

@main
struct VaultApp: App {
    var body: some Scene {
        WindowGroup {
            // Design phase, step 2: the app launches straight into the component
            // gallery. This is replaced by the tab bar once the screens exist.
            NavigationStack {
                DesignGalleryView()
            }
            .tint(VaultColor.accent)
        }
    }
}
