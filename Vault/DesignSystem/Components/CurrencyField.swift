import SwiftUI

/// Big amount entry. Digits fill from the right like a card terminal
/// (typing 1, 2, 5, 0 gives $12.50), so the value is integer cents the whole
/// time. A hidden number-pad field captures typing; the formatted amount is
/// what you see.
struct CurrencyField: View {
    @Binding var cents: Int
    var autofocus = true
    @FocusState private var focused: Bool

    private var digits: Binding<String> {
        Binding(
            get: { cents == 0 ? "" : String(cents) },
            set: { newValue in
                let clean = newValue.filter { $0.isASCII && $0.isNumber }.prefix(9)
                cents = Int(clean) ?? 0
            }
        )
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(Money.format(cents: cents, fraction: cents % 100 == 0 ? .never : .always))
                .moneyFont(.large)
                .foregroundStyle(cents == 0 ? VaultColor.textTertiary : VaultColor.textPrimary)
                .contentTransition(.numericText(value: Double(cents)))
                .animation(.snappy(duration: 0.2), value: cents)
            Capsule().fill(focused ? VaultColor.accent : VaultColor.separator).frame(width: 44, height: 3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background {
            TextField("", text: digits)
                .keyboardType(.numberPad)
                .focused($focused)
                .opacity(0.01)
                .accessibilityHidden(true)
        }
        .contentShape(Rectangle())
        .onTapGesture { focused = true }
        .onAppear { if autofocus { focused = true } }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Amount")
        .accessibilityValue(Money.format(cents: cents))
        .accessibilityHint("Double tap to type an amount")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { focused = true }
    }
}
