import SwiftUI

/// One deposit or withdrawal: avatar, title, "who · when · goal", amount.
struct ActivityRow: View {
    let entry: Entry
    let person: Person?
    let goal: Goal?
    var isNew = false
    /// e.g. "Vacation passed 75%" for a deposit that crossed a milestone.
    var effect: String? = nil
    var showGoal = true
    var ownerID: Person.ID? = nil

    var body: some View {
        HStack(spacing: 12) {
            if let person { PersonAvatar(person: person, size: 40) }
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text(title).font(.body).foregroundStyle(VaultColor.textPrimary).lineLimit(1)
                    if isNew { NewTag() }
                }
                subtitle
            }
            Spacer(minLength: 8)
            MoneyText(cents: entry.signedCents, style: .row, signed: true)
                .foregroundStyle(VaultColor.textPrimary)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }

    private var title: String {
        if !entry.note.isEmpty { return entry.note }
        if let goal { return goal.name }
        return entry.kind.title
    }

    private var who: String {
        guard let person else { return "" }
        return person.id == ownerID ? "You" : person.name
    }

    @ViewBuilder private var subtitle: some View {
        HStack(spacing: 4) {
            Text(subtitleText).lineLimit(1)
            if let effect {
                Image(systemName: "star.fill").font(.caption2).foregroundStyle(VaultColor.progress)
                Text(effect).fontWeight(.semibold).foregroundStyle(VaultColor.progress).lineLimit(1)
            }
        }
        .font(.footnote)
        .foregroundStyle(VaultColor.textSecondary)
    }

    private var subtitleText: String {
        var parts = [who]
        if entry.isWithdrawal {
            parts.append(goal.map { "Withdrawal from \($0.name)" } ?? "Withdrawal")
        } else if showGoal, let goal, !entry.note.isEmpty {
            parts.append(goal.name)
        }
        parts.append(Self.day(entry.date))
        return parts.filter { !$0.isEmpty }.joined(separator: " · ") + (effect == nil ? "" : " ·")
    }

    static func day(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "Today" }
        if Calendar.current.isDateInYesterday(date) { return "Yesterday" }
        return date.formatted(.dateTime.month(.abbreviated).day())
    }
}

/// Section title with an optional "See all ›" link.
struct SectionTitle<Trailing: View>: View {
    let title: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(alignment: .center) {
            Text(title).font(.title2.bold()).foregroundStyle(VaultColor.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            trailing
        }
    }
}

extension SectionTitle where Trailing == EmptyView {
    init(_ title: String) { self.init(title: title) { EmptyView() } }
}

/// Icon in a circle, a title, a line of help, and an optional action.
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(VaultColor.accent)
                .frame(width: 64, height: 64)
                .background(VaultColor.raised, in: Circle())
                .accessibilityHidden(true)
            Text(title).font(.title3.bold()).foregroundStyle(VaultColor.textPrimary)
            Text(message).font(.subheadline).foregroundStyle(VaultColor.textSecondary)
                .multilineTextAlignment(.center)
            if let actionTitle, let action {
                Button(actionTitle, action: action).buttonStyle(.vaultPrimary).padding(.top, 6)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
    }
}
