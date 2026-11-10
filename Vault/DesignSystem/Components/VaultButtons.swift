import SwiftUI

// Usage: Button("Add deposit") { }.buttonStyle(.vaultPrimary)
//        Button("Cancel") { }.buttonStyle(.vaultSecondary)

/// Gold, filled. One per screen: the main thing to do.
struct VaultPrimaryButtonStyle: ButtonStyle {
    var fullWidth = true
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(VaultFont.headline)
            .foregroundStyle(VaultColor.onAccent)
            .padding(.horizontal, VaultSpacing.xl)
            .frame(maxWidth: fullWidth ? .infinity : nil, minHeight: 52)
            .background(VaultColor.accent, in: RoundedRectangle.vault(VaultRadius.control))
            .opacity(isEnabled ? (configuration.isPressed ? 0.85 : 1) : 0.4)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Neutral, outlined. For everything that is not the main action.
struct VaultSecondaryButtonStyle: ButtonStyle {
    var fullWidth = true
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(VaultFont.headline)
            .foregroundStyle(VaultColor.textPrimary)
            .padding(.horizontal, VaultSpacing.xl)
            .frame(maxWidth: fullWidth ? .infinity : nil, minHeight: 52)
            .background(VaultColor.surfaceRaised, in: RoundedRectangle.vault(VaultRadius.control))
            .overlay(RoundedRectangle.vault(VaultRadius.control).strokeBorder(VaultColor.border, lineWidth: 1))
            .opacity(isEnabled ? (configuration.isPressed ? 0.7 : 1) : 0.4)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == VaultPrimaryButtonStyle {
    static var vaultPrimary: VaultPrimaryButtonStyle { .init() }
    /// A primary button that hugs its label instead of filling the width.
    static var vaultPrimaryCompact: VaultPrimaryButtonStyle { .init(fullWidth: false) }
}

extension ButtonStyle where Self == VaultSecondaryButtonStyle {
    static var vaultSecondary: VaultSecondaryButtonStyle { .init() }
    static var vaultSecondaryCompact: VaultSecondaryButtonStyle { .init(fullWidth: false) }
}
