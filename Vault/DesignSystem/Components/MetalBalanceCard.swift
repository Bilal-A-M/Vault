import SwiftUI

/// "The Black Card": brushed gunmetal panel with the total, a sync pill and
/// the hide-balance eye, over a dark strip holding the two actions.
struct MetalBalanceCard: View {
    let totalCents: Int
    let syncStatus: SyncStatus
    let partnerName: String
    var isEmpty = false
    @Binding var hideAmounts: Bool
    var onAdd: () -> Void
    var onWithdraw: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Saved together").font(.subheadline).foregroundStyle(VaultColor.metalLabel)
                    Spacer()
                    SyncPill(status: syncStatus, partnerName: partnerName)
                }
                HStack(alignment: .center) {
                    MoneyText(cents: totalCents, style: .hero)
                        .foregroundStyle(isEmpty ? Color(hex: 0xC9CDD3) : .white)
                    Spacer()
                    Button {
                        hideAmounts.toggle()
                    } label: {
                        Image(systemName: hideAmounts ? "eye.slash" : "eye")
                            .font(.title3)
                            .foregroundStyle(VaultColor.metalLabel)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel(hideAmounts ? "Show balance" : "Hide balance")
                }
            }
            .padding(EdgeInsets(top: 18, leading: 20, bottom: 22, trailing: 14))
            .background(BrushedMetal())

            HStack(spacing: 10) {
                Button(action: onAdd) {
                    Label("Add deposit", systemImage: "plus")
                }
                .buttonStyle(VaultPrimaryButtonStyle(height: 50))
                .environment(\.colorScheme, .dark)
                if !isEmpty {
                    Button(action: onWithdraw) {
                        Label("Log withdrawal", systemImage: "minus")
                    }
                    .buttonStyle(VaultSecondaryButtonStyle(height: 50))
                    .environment(\.colorScheme, .dark)
                }
            }
            .padding(14)
            .background(VaultColor.metalStrip)
            .overlay(alignment: .top) { Rectangle().fill(Color.black.opacity(0.55)).frame(height: 1) }
        }
        .clipShape(RoundedRectangle(cornerRadius: VaultRadius.hero, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: VaultRadius.hero, style: .continuous)
            .strokeBorder(Color(hex: 0xD9DDE3).opacity(0.14), lineWidth: 1))
        .shadow(color: .black.opacity(0.55), radius: 25, y: 18)
    }
}

/// Gunmetal gradient + fine brushed grain + a diagonal sheen + a lit top edge.
struct BrushedMetal: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [VaultColor.metalTop, VaultColor.metalMid, VaultColor.metalBottom],
                           startPoint: .top, endPoint: .bottom)
            Canvas { context, size in
                var x: CGFloat = 0
                while x < size.width {
                    context.fill(Path(CGRect(x: x, y: 0, width: 1, height: size.height)), with: .color(.white.opacity(0.05)))
                    context.fill(Path(CGRect(x: x + 1, y: 0, width: 1, height: size.height)), with: .color(.black.opacity(0.06)))
                    x += 4
                }
            }
            LinearGradient(stops: [
                .init(color: .white.opacity(0), location: 0.22),
                .init(color: .white.opacity(0.10), location: 0.40),
                .init(color: .white.opacity(0), location: 0.58),
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        .overlay(alignment: .top) { Rectangle().fill(Color.white.opacity(0.24)).frame(height: 1) }
        .accessibilityHidden(true)
    }
}
