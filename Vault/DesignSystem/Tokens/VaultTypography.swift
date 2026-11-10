import SwiftUI

// MARK: - Text styles
//
// Every style maps to a system text style, so all of it scales with Dynamic Type.
// UI text is SF Pro; money is SF Pro Rounded (see `MoneyStyle`) so numbers feel
// distinct and a little warmer than the labels around them.

enum VaultFont {
    static let largeTitle = Font.system(.largeTitle, weight: .bold)
    static let title = Font.system(.title2, weight: .semibold)
    static let headline = Font.system(.headline, weight: .semibold)
    static let body = Font.system(.body)
    static let callout = Font.system(.callout)
    static let subheadline = Font.system(.subheadline)
    static let footnote = Font.system(.footnote)
    static let caption = Font.system(.caption)
    /// Small uppercase labels. Pair with `.vaultOverline()`.
    static let overline = Font.system(.caption2, weight: .semibold)
}

extension View {
    /// Uppercase, wide-tracked label used above hero numbers and in stat tiles.
    func vaultOverline() -> some View {
        self.font(VaultFont.overline)
            .textCase(.uppercase)
            .tracking(1.2)
            .foregroundStyle(VaultColor.textSecondary)
    }
}

// MARK: - Money styles

/// Large, confident number styles for amounts.
enum MoneyStyle: CaseIterable {
    /// The dashboard total and the currency input.
    case hero
    /// Goal detail totals.
    case large
    /// Stat tiles and card figures.
    case medium
    /// Rows and inline amounts.
    case small

    var baseSize: CGFloat {
        switch self {
        case .hero: 56
        case .large: 34
        case .medium: 22
        case .small: 17
        }
    }

    /// The text style the size scales alongside under Dynamic Type.
    var relativeTo: Font.TextStyle {
        switch self {
        case .hero: .largeTitle
        case .large: .title
        case .medium: .title3
        case .small: .body
        }
    }

    var weight: Font.Weight {
        switch self {
        case .hero, .large: .semibold
        case .medium, .small: .medium
        }
    }
}

private struct MoneyTextModifier: ViewModifier {
    let style: MoneyStyle
    @ScaledMetric private var size: CGFloat

    init(style: MoneyStyle) {
        self.style = style
        _size = ScaledMetric(wrappedValue: style.baseSize, relativeTo: style.relativeTo)
    }

    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: style.weight, design: .rounded))
            // Fixed-width digits stop amounts from jittering as they change.
            .monospacedDigit()
            // Big numbers shrink rather than wrap or truncate at large type sizes.
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .contentTransition(.numericText())
    }
}

extension View {
    func vaultMoney(_ style: MoneyStyle) -> some View {
        modifier(MoneyTextModifier(style: style))
    }
}

/// An amount in cents, formatted through `Money` and set in a money style.
struct MoneyText: View {
    let cents: Int
    var style: MoneyStyle = .medium
    var fraction: Money.Fraction = .always
    var signed: Bool = false

    var body: some View {
        Text(Money.format(cents: cents, fraction: fraction, signed: signed))
            .vaultMoney(style)
    }
}
