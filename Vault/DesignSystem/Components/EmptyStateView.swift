import SwiftUI

/// Shown when a screen or section has nothing to display yet.
/// Also used for error states: pass a warning icon and a "Try again" action.
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: VaultSpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(VaultColor.accent)
                .frame(width: 72, height: 72)
                .background(VaultColor.accentSoft, in: Circle())
                .accessibilityHidden(true)

            VStack(spacing: VaultSpacing.sm) {
                Text(title)
                    .font(VaultFont.title)
                    .foregroundStyle(VaultColor.textPrimary)
                Text(message)
                    .font(VaultFont.subheadline)
                    .foregroundStyle(VaultColor.textSecondary)
            }
            .multilineTextAlignment(.center)

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.vaultPrimaryCompact)
                    .padding(.top, VaultSpacing.xs)
            }
        }
        .padding(VaultSpacing.xl)
        .frame(maxWidth: .infinity)
    }
}
