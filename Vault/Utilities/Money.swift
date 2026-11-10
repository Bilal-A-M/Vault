import Foundation

/// The single place money is turned into text.
/// Amounts are always stored as integer cents; never format them anywhere else.
enum Money {
    /// Swap this when the app supports other currencies.
    static let currencyCode = "USD"

    enum Fraction {
        /// Always show cents: $1,200.00
        case always
        /// Never show cents: $1,200
        case never
        /// Hide cents only when the amount is whole: $1,200 / $1,200.50
        case auto
    }

    /// Formats cents as currency.
    /// - Parameter signed: prefixes "+" for positive and "−" for negative amounts
    ///   (used in deposit rows). Unsigned negatives still show "−".
    static func format(cents: Int, fraction: Fraction = .always, signed: Bool = false) -> String {
        let showCents: Bool
        switch fraction {
        case .always: showCents = true
        case .never: showCents = false
        case .auto: showCents = cents % 100 != 0
        }
        let formatter = showCents ? withCents : wholeOnly
        let magnitude = Decimal(abs(cents)) / 100
        let body = formatter.string(from: magnitude as NSDecimalNumber) ?? "\(magnitude)"
        if cents < 0 { return "−" + body }
        if signed && cents > 0 { return "+" + body }
        return body
    }

    private static let withCents = makeFormatter(fractionDigits: 2)
    private static let wholeOnly = makeFormatter(fractionDigits: 0)

    private static func makeFormatter(fractionDigits: Int) -> NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = currencyCode
        f.minimumFractionDigits = fractionDigits
        f.maximumFractionDigits = fractionDigits
        return f
    }
}
