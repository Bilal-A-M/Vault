import SwiftUI

/// A goal summary card: ring, name, saved of target, and earned milestones.
struct GoalTile: View {
    let goal: Goal
    let savedCents: Int

    private var progress: Double { goal.progress(savedCents: savedCents) }
    private var percentText: String { "\(Int((min(progress, 1) * 100).rounded()))%" }

    var body: some View {
        VaultCard {
            VStack(alignment: .leading, spacing: VaultSpacing.md) {
                HStack(spacing: VaultSpacing.md) {
                    ProgressRing(progress: progress, lineWidth: 6, label: "\(goal.name) progress") {
                        Text(goal.emoji).font(.title3)
                    }
                    .frame(width: 56, height: 56)

                    VStack(alignment: .leading, spacing: VaultSpacing.xs) {
                        Text(goal.name)
                            .font(VaultFont.headline)
                            .foregroundStyle(VaultColor.textPrimary)
                        Text("\(Money.format(cents: savedCents, fraction: .auto)) of \(Money.format(cents: goal.targetCents, fraction: .auto))")
                            .font(VaultFont.subheadline)
                            .monospacedDigit()
                            .foregroundStyle(VaultColor.textSecondary)
                    }

                    Spacer(minLength: VaultSpacing.sm)

                    Text(percentText)
                        .vaultMoney(.medium)
                        .foregroundStyle(progress >= 1 ? VaultColor.accent : VaultColor.textPrimary)
                        // The ring already announces the percentage.
                        .accessibilityHidden(true)
                }

                let earned = Milestone.earned(at: progress)
                if !earned.isEmpty {
                    HStack(spacing: VaultSpacing.xs + 2) {
                        ForEach(earned) { MilestoneBadge(milestone: $0) }
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}
