import SwiftUI

/// One deposit or withdrawal in a list.
struct DepositRow: View {
    let deposit: Deposit
    let person: Person
    var goal: Goal?

    private var title: String {
        if !deposit.note.isEmpty { return deposit.note }
        if let goal { return goal.name }
        return deposit.isWithdrawal ? "Withdrawal" : "Deposit"
    }

    private var subtitle: String {
        var parts = [person.name]
        // Avoid repeating the goal name when it is already the title.
        if let goal, !deposit.note.isEmpty { parts.append(goal.name) }
        parts.append(deposit.date.formatted(.dateTime.month(.abbreviated).day()))
        return parts.joined(separator: " · ")
    }

    var body: some View {
        HStack(spacing: VaultSpacing.md) {
            PersonAvatar(person: person)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(VaultFont.body.weight(.medium))
                    .foregroundStyle(VaultColor.textPrimary)
                    .lineLimit(1)
                Text(subtitle)
                    .font(VaultFont.footnote)
                    .foregroundStyle(VaultColor.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: VaultSpacing.sm)

            MoneyText(cents: deposit.signedCents, style: .small, signed: true)
                .foregroundStyle(deposit.isWithdrawal ? VaultColor.danger : VaultColor.success)
        }
        .frame(minHeight: VaultSpacing.minTapTarget)
        .padding(.vertical, VaultSpacing.xs)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        let verb = deposit.isWithdrawal ? "withdrew" : "added"
        var text = "\(person.name) \(verb) \(Money.format(cents: deposit.amountCents))"
        if let goal { text += deposit.isWithdrawal ? " from \(goal.name)" : " to \(goal.name)" }
        text += ", \(deposit.date.formatted(date: .abbreviated, time: .omitted))"
        if !deposit.note.isEmpty { text += ", \(deposit.note)" }
        return text
    }
}
