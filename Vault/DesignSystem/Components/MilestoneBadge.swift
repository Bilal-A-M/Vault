import SwiftUI

/// A small marker for the 25 / 50 / 75 / 100% milestones.
/// Earned badges are gold; unearned ones are a quiet outline.
struct MilestoneBadge: View {
    let milestone: Milestone
    var isEarned: Bool = true

    var body: some View {
        HStack(spacing: VaultSpacing.xs) {
            Image(systemName: iconName)
                .font(.caption2.weight(.bold))
            Text(milestone.label)
                .font(VaultFont.caption.weight(.semibold))
                .monospacedDigit()
        }
        .foregroundStyle(isEarned ? VaultColor.accent : VaultColor.textTertiary)
        .padding(.horizontal, VaultSpacing.sm)
        .padding(.vertical, VaultSpacing.xs)
        .background(isEarned ? VaultColor.accentSoft : Color.clear, in: Capsule())
        .overlay(Capsule().strokeBorder(isEarned ? Color.clear : VaultColor.border, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(milestone.rawValue) percent milestone, \(isEarned ? "earned" : "not yet earned")")
    }

    private var iconName: String {
        guard isEarned else { return "lock.fill" }
        return milestone == .complete ? "checkmark.seal.fill" : "star.fill"
    }
}
