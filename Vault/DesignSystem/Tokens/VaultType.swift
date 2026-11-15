import SwiftUI
import UIKit

// MARK: - Typography
//
// SF Pro (the system font) carries the interface through standard text
// styles, so everything follows Dynamic Type. Money uses Sora with tabular
// figures. If the Sora files aren't bundled yet, money falls back to
// SF Pro Rounded.

enum MoneyStyle {
    case hero, large, title, row, caption

    var size: CGFloat {
        switch self {
        case .hero: 50
        case .large: 40
        case .title: 20
        case .row: 17
        case .caption: 13
        }
    }

    var relativeTo: Font.TextStyle {
        switch self {
        case .hero, .large: .largeTitle
        case .title: .title3
        case .row: .body
        case .caption: .footnote
        }
    }

    var tracking: CGFloat {
        switch self {
        case .hero: -1.8
        case .large: -1.2
        case .title: -0.4
        default: 0
        }
    }
}

private enum Sora {
    static let available = UIFont(name: "Sora-Medium", size: 12) != nil
}

private struct MoneyFont: ViewModifier {
    let style: MoneyStyle
    @ScaledMetric private var size: CGFloat

    init(style: MoneyStyle) {
        self.style = style
        _size = ScaledMetric(wrappedValue: style.size, relativeTo: style.relativeTo)
    }

    func body(content: Content) -> some View {
        content
            .font(Sora.available ? .custom("Sora-Medium", fixedSize: size)
                                 : .system(size: size, weight: .medium, design: .rounded))
            .tracking(style.tracking)
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.5)
    }
}

extension View {
    func moneyFont(_ style: MoneyStyle) -> some View { modifier(MoneyFont(style: style)) }
}

extension EnvironmentValues {
    /// "Hide balance": every amount renders as ••••.
    @Entry var hideAmounts: Bool = false
}

/// The one way amounts appear on screen. Formats through `Money` and honours
/// "Hide balance".
struct MoneyText: View {
    let cents: Int
    var style: MoneyStyle = .row
    var fraction: Money.Fraction = .auto
    var signed: Bool = false
    @Environment(\.hideAmounts) private var hidden
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Text(hidden ? "••••" : Money.format(cents: cents, fraction: fraction, signed: signed))
            .moneyFont(style)
            .contentTransition(reduceMotion ? .identity : .numericText(value: Double(cents)))
            .accessibilityLabel(hidden ? "Hidden amount" : Money.format(cents: cents, fraction: fraction, signed: signed))
    }
}

// MARK: - Layout

enum VaultSpace {
    static let page: CGFloat = 20
    static let section: CGFloat = 24
    static let card: CGFloat = 18
}

enum VaultRadius {
    static let hero: CGFloat = 26
    static let card: CGFloat = 22
    static let button: CGFloat = 15
    static let list: CGFloat = 12
}

extension View {
    /// The standard flat graphite card.
    func vaultCard(padding: CGFloat = VaultSpace.card) -> some View {
        self.padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(VaultColor.card, in: RoundedRectangle(cornerRadius: VaultRadius.card, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: VaultRadius.card, style: .continuous)
                .strokeBorder(VaultColor.hairline, lineWidth: 1))
    }
}
