import SwiftUI

// MARK: - Spacing (4pt grid)

enum VaultSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48

    /// Horizontal page margin.
    static let page: CGFloat = 20
    /// Minimum tap target (Apple HIG).
    static let minTapTarget: CGFloat = 44
}

// MARK: - Corner radius (always continuous corners)

enum VaultRadius {
    static let small: CGFloat = 8
    /// Buttons, inputs, chips with square-ish shape.
    static let control: CGFloat = 14
    static let card: CGFloat = 20
    static let sheet: CGFloat = 28
}

extension RoundedRectangle {
    static func vault(_ radius: CGFloat) -> RoundedRectangle {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
    }
}

// MARK: - Shadows
//
// Light mode uses soft, wide shadows. Dark mode uses none: elevation is shown
// with the hairline `VaultColor.border` instead, which looks cleaner on black.

struct VaultShadow {
    let color: Color
    let radius: CGFloat
    let y: CGFloat

    static let none = VaultShadow(color: .clear, radius: 0, y: 0)
    /// Resting cards.
    static let card = VaultShadow(
        color: Color(light: Color.black.opacity(0.06), dark: .clear), radius: 16, y: 6)
    /// Floating elements such as the Add deposit button.
    static let floating = VaultShadow(
        color: Color(light: Color.black.opacity(0.14), dark: Color.black.opacity(0.5)), radius: 24, y: 10)
}

extension View {
    func vaultShadow(_ shadow: VaultShadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: 0, y: shadow.y)
    }

    /// The standard card surface: fill, hairline border, and shadow.
    func vaultSurface(radius: CGFloat = VaultRadius.card,
                      fill: Color = VaultColor.surface,
                      shadow: VaultShadow = .card) -> some View {
        self.background(fill, in: RoundedRectangle.vault(radius))
            .overlay(RoundedRectangle.vault(radius).strokeBorder(VaultColor.border, lineWidth: 1))
            .vaultShadow(shadow)
    }
}

// MARK: - Motion

enum VaultMotion {
    /// Default for state changes (selection, number updates).
    static let standard = Animation.snappy(duration: 0.3)
    /// Progress rings/bars filling and charts drawing in.
    static let fill = Animation.easeOut(duration: 0.9)
}
