import SwiftUI

/// The basic container: surface fill, hairline border, soft shadow (light mode).
struct VaultCard<Content: View>: View {
    private let padding: CGFloat
    private let content: Content

    init(padding: CGFloat = VaultSpacing.lg, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .vaultSurface()
    }
}
