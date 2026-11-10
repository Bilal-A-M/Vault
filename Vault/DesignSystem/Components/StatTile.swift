import SwiftUI

/// A compact labelled figure: "This month · $1,250".
struct StatTile: View {
    let label: String
    let value: String
    var caption: String?
    var icon: String?
    var tint: Color = VaultColor.accent

    var body: some View {
        VaultCard {
            VStack(alignment: .leading, spacing: VaultSpacing.sm) {
                HStack(spacing: VaultSpacing.xs + 2) {
                    if let icon {
                        Image(systemName: icon)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(tint)
                            .accessibilityHidden(true)
                    }
                    Text(label).vaultOverline()
                }
                Text(value)
                    .vaultMoney(.medium)
                    .foregroundStyle(VaultColor.textPrimary)
                if let caption {
                    Text(caption)
                        .font(VaultFont.caption)
                        .foregroundStyle(VaultColor.textSecondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}
