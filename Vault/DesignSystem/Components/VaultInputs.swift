import SwiftUI

/// A labelled single-line text field.
struct VaultTextField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var icon: String?

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: VaultSpacing.sm) {
            Text(label).vaultOverline()
            HStack(spacing: VaultSpacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .foregroundStyle(VaultColor.textSecondary)
                        .accessibilityHidden(true)
                }
                TextField(placeholder, text: $text)
                    .font(VaultFont.body)
                    .foregroundStyle(VaultColor.textPrimary)
                    .focused($isFocused)
                    .accessibilityLabel(label)
            }
            .padding(.horizontal, VaultSpacing.lg)
            .frame(minHeight: 52)
            .background(VaultColor.surfaceRaised, in: RoundedRectangle.vault(VaultRadius.control))
            .overlay(
                RoundedRectangle.vault(VaultRadius.control)
                    .strokeBorder(isFocused ? VaultColor.accent : VaultColor.border,
                                  lineWidth: isFocused ? 1.5 : 1)
            )
            .animation(.easeOut(duration: 0.15), value: isFocused)
            .contentShape(Rectangle())
            .onTapGesture { isFocused = true }
        }
    }
}

/// The big amount entry used in the Add deposit sheet.
///
/// Digits fill in from the right like a card terminal: typing 1, 2, 5, 0 gives
/// $12.50. That keeps the value in integer cents the whole time and avoids any
/// decimal-point parsing. An invisible number-pad field captures the typing;
/// the formatted amount is what the user sees.
struct CurrencyInput: View {
    @Binding var cents: Int
    var tint: Color = VaultColor.textPrimary

    @FocusState private var isFocused: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var digits: Binding<String> {
        Binding(
            get: { cents == 0 ? "" : String(cents) },
            set: { newValue in
                // Cap at 9 digits ($9,999,999.99) to stay well inside Int range.
                let clean = newValue.filter { $0.isASCII && $0.isNumber }.prefix(9)
                cents = Int(clean) ?? 0
            }
        )
    }

    var body: some View {
        VStack(spacing: VaultSpacing.md) {
            Text(Money.format(cents: cents))
                .vaultMoney(.hero)
                .foregroundStyle(cents == 0 ? VaultColor.textTertiary : tint)
                .animation(reduceMotion ? nil : VaultMotion.standard, value: cents)
            Capsule()
                .fill(isFocused ? VaultColor.accent : VaultColor.border)
                .frame(width: 48, height: 3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, VaultSpacing.lg)
        .background {
            TextField("", text: digits)
                .keyboardType(.numberPad)
                .focused($isFocused)
                .opacity(0.01)
                .accessibilityHidden(true)
        }
        .contentShape(Rectangle())
        .onTapGesture { isFocused = true }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Amount")
        .accessibilityValue(Money.format(cents: cents))
        .accessibilityHint("Double tap to edit")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { isFocused = true }
    }
}
