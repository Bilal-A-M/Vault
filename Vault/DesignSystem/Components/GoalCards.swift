import SwiftUI

/// The compact card in Home's horizontal goals row.
struct GoalCardCompact: View {
    let goal: Goal
    let saved: Int
    var fresh: Milestone? = nil

    private var progress: Double { VaultMath.progress(saved: saved, target: goal.targetCents) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                GoalRing(goal: goal, progress: progress)
                Spacer()
                if let fresh { MilestoneBadge(milestone: fresh, fresh: true) }
            }
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(goal.name).font(.subheadline.weight(.semibold)).lineLimit(1)
                    Spacer(minLength: 4)
                    if progress < 1 {
                        Text("\(Int((progress * 100).rounded(.down)))%").font(.subheadline)
                            .foregroundStyle(VaultColor.textSecondary).monospacedDigit()
                    }
                }
                .foregroundStyle(VaultColor.textPrimary)
                footnote
            }
        }
        .padding(16)
        .frame(width: 160, alignment: .leading)
        .background(VaultColor.card, in: RoundedRectangle(cornerRadius: VaultRadius.card, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: VaultRadius.card, style: .continuous).strokeBorder(VaultColor.hairline))
    }

    @ViewBuilder private var footnote: some View {
        if progress >= 1 {
            Text("Goal reached").font(.footnote).foregroundStyle(VaultColor.textSecondary)
        } else if let next = Milestone.allCases.first(where: { progress < $0.fraction }),
                  next.fraction - progress < 0.05 {
            // Close to the next milestone: say how close, in lime.
            HStack(spacing: 3) {
                MoneyText(cents: Int(Double(goal.targetCents) * next.fraction) - saved, style: .caption, fraction: .never)
                Text("to \(next.label)")
            }
            .font(.footnote.weight(.medium))
            .foregroundStyle(VaultColor.progress)
        } else {
            HStack(spacing: 3) {
                MoneyText(cents: saved, style: .caption, fraction: .never)
                Text("of")
                MoneyText(cents: goal.targetCents, style: .caption, fraction: .never)
            }
            .font(.footnote)
            .foregroundStyle(VaultColor.textSecondary)
        }
    }
}

/// The full-width row on the Goals screen.
struct GoalRowCard: View {
    let goal: Goal
    let saved: Int
    var fresh: Milestone? = nil

    private var progress: Double { VaultMath.progress(saved: saved, target: goal.targetCents) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                GoalRing(goal: goal, progress: progress, size: 56)
                VStack(alignment: .leading, spacing: 3) {
                    Text(goal.name).font(.headline).foregroundStyle(VaultColor.textPrimary)
                    HStack(spacing: 3) {
                        MoneyText(cents: saved, style: .caption, fraction: .never)
                        Text("of")
                        MoneyText(cents: goal.targetCents, style: .caption, fraction: .never)
                        if let date = goal.targetDate {
                            Text("· \(date.formatted(.dateTime.month(.abbreviated).year()))")
                        }
                    }
                    .font(.footnote)
                    .foregroundStyle(VaultColor.textSecondary)
                }
                Spacer(minLength: 8)
                if progress >= 1 {
                    Text("Goal reached")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(VaultColor.onProgress)
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(VaultColor.progress, in: Capsule())
                } else {
                    Text("\(Int((progress * 100).rounded(.down)))%")
                        .moneyFont(.title)
                        .foregroundStyle(VaultColor.textPrimary)
                }
            }
            let earned = Milestone.earned(at: progress).filter { $0 != .complete }
            if progress < 1, !earned.isEmpty || fresh != nil {
                HStack(spacing: 6) {
                    ForEach(earned) { MilestoneBadge(milestone: $0, fresh: $0 == fresh) }
                    if let next = Milestone.allCases.first(where: { progress < $0.fraction }) {
                        HStack(spacing: 3) {
                            MoneyText(cents: Int(Double(goal.targetCents) * next.fraction) - saved, style: .caption, fraction: .never)
                            Text("to the \(next.label) milestone")
                        }
                        .font(.footnote)
                        .foregroundStyle(next.fraction - progress < 0.05 ? VaultColor.progress : VaultColor.textSecondary)
                        .padding(.leading, 4)
                    }
                }
            }
        }
        .vaultCard(padding: 16)
        .accessibilityElement(children: .combine)
    }
}
