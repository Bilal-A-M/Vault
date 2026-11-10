import SwiftUI

/// A section title with an optional trailing action ("See all").
struct SectionHeader: View {
    let title: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(VaultFont.title)
                .foregroundStyle(VaultColor.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(VaultFont.subheadline.weight(.medium))
                    .foregroundStyle(VaultColor.accent)
                    .frame(minHeight: VaultSpacing.minTapTarget)
            }
        }
    }
}
