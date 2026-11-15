import SwiftUI

/// Brushed platinum (graphite in light mode). One per screen: the main action.
struct VaultPrimaryButtonStyle: ButtonStyle {
    var height: CGFloat = 54
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(VaultColor.onAccent)
            .frame(maxWidth: .infinity, minHeight: height)
            .background(
                LinearGradient(colors: [VaultColor.accentTop, VaultColor.accentBottom], startPoint: .top, endPoint: .bottom),
                in: RoundedRectangle(cornerRadius: VaultRadius.button, style: .continuous))
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: VaultRadius.button, style: .continuous)
                    .stroke(Color.white.opacity(0.45), lineWidth: 1)
                    .mask(LinearGradient(colors: [.white, .clear], startPoint: .top, endPoint: .center))
            }
            .opacity(isEnabled ? (configuration.isPressed ? 0.85 : 1) : 0.4)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Quiet graphite. For the second action beside a primary one.
struct VaultSecondaryButtonStyle: ButtonStyle {
    var height: CGFloat = 54
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.medium))
            .foregroundStyle(VaultColor.textPrimary)
            .frame(maxWidth: .infinity, minHeight: height)
            .background(VaultColor.raised, in: RoundedRectangle(cornerRadius: VaultRadius.button, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: VaultRadius.button, style: .continuous)
                .strokeBorder(VaultColor.hairline, lineWidth: 1))
            .opacity(isEnabled ? (configuration.isPressed ? 0.7 : 1) : 0.4)
    }
}

extension ButtonStyle where Self == VaultPrimaryButtonStyle {
    static var vaultPrimary: VaultPrimaryButtonStyle { .init() }
}

extension ButtonStyle where Self == VaultSecondaryButtonStyle {
    static var vaultSecondary: VaultSecondaryButtonStyle { .init() }
}

/// "See all ›" style link: weight plus a chevron, so it reads as tappable.
struct ChevronLabel: View {
    let title: String
    var body: some View {
        HStack(spacing: 2) {
            Text(title)
            Image(systemName: "chevron.right").font(.footnote.weight(.bold))
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(VaultColor.accent)
        .frame(minHeight: 44)
    }
}
