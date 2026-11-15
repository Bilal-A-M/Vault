import SwiftUI

/// Living style guide: tokens and components in one place. Open it from
/// Settings → Preview & debug, or use the previews below for light and dark.
struct DesignGalleryView: View {
    @State private var cents = 20_000
    @State private var hide = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                group("Colour") {
                    swatches([("Background", VaultColor.background), ("Card", VaultColor.card), ("Raised", VaultColor.raised),
                              ("Accent", VaultColor.accent), ("Progress", VaultColor.progress),
                              ("Text", VaultColor.textPrimary), ("Secondary", VaultColor.textSecondary), ("Tertiary", VaultColor.textTertiary)])
                    swatches(PersonColor.allCases.map { ($0.displayName, $0.solid) })
                }
                group("Money") {
                    MoneyText(cents: 3_528_000, style: .hero)
                    MoneyText(cents: 468_000, style: .large)
                    MoneyText(cents: 145_000, style: .title, signed: true)
                    MoneyText(cents: -12_550, style: .row, signed: true)
                }
                group("Black Card") {
                    MetalBalanceCard(totalCents: 3_528_000, syncStatus: .synced(.now), partnerName: "Hiba",
                                     hideAmounts: $hide, onAdd: {}, onWithdraw: {})
                }
                group("Buttons") {
                    Button {} label: { Label("Add deposit", systemImage: "plus") }.buttonStyle(.vaultPrimary)
                    Button("Log withdrawal") {}.buttonStyle(.vaultSecondary)
                    ChevronLabel(title: "See all 4")
                }
                group("Progress") {
                    HStack(spacing: 18) {
                        GoalRing(goal: MockData.vacation, progress: 0.78, size: 72)
                        GoalRing(goal: MockData.house, progress: 0.485, size: 72)
                        GoalRing(goal: MockData.emergency, progress: 1, size: 72)
                    }
                    ContributionBar(shares: VaultMath.shares(MockData.entries, people: MockData.people))
                    HStack {
                        MilestoneBadge(milestone: .quarter)
                        MilestoneBadge(milestone: .half)
                        MilestoneBadge(milestone: .threeQuarters, fresh: true)
                        MilestoneBadge(milestone: .complete, earned: false)
                        NewTag()
                    }
                }
                group("Goal cards") {
                    ScrollView(.horizontal) {
                        HStack {
                            GoalCardCompact(goal: MockData.vacation, saved: 468_000, fresh: .threeQuarters)
                            GoalCardCompact(goal: MockData.house, saved: 1_940_000)
                        }
                    }
                    GoalRowCard(goal: MockData.house, saved: 1_940_000)
                }
                group("People") {
                    HStack {
                        PersonAvatar(person: MockData.bilal)
                        PersonAvatar(person: MockData.hiba, filled: true)
                        PersonChip(person: MockData.bilal, title: "Me", selected: true)
                        PersonChip(person: MockData.hiba, selected: false)
                    }
                }
                group("Inputs") {
                    CurrencyField(cents: $cents, autofocus: false).vaultCard()
                }
                group("Empty state") {
                    EmptyStateView(icon: "tray", title: "Nothing logged yet", message: "Your deposits show up here.",
                                   actionTitle: "Add deposit") {}
                        .vaultCard()
                }
                group("Loading") {
                    SkeletonBlock(height: 60)
                }
            }
            .padding(VaultSpace.page)
        }
        .background(VaultColor.background)
        .navigationTitle("Design system")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func group<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.title3.bold()).foregroundStyle(VaultColor.textPrimary)
            content()
        }
    }

    private func swatches(_ items: [(String, Color)]) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 10)], alignment: .leading, spacing: 10) {
            ForEach(items, id: \.0) { item in
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 8).fill(item.1).frame(height: 40)
                        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(VaultColor.hairline))
                    Text(item.0).font(.caption).foregroundStyle(VaultColor.textSecondary)
                }
            }
        }
    }
}

#Preview("Gallery · Dark") {
    NavigationStack { DesignGalleryView() }.preferredColorScheme(.dark)
}

#Preview("Gallery · Light") {
    NavigationStack { DesignGalleryView() }.preferredColorScheme(.light)
}

#Preview("Gallery · Large type") {
    NavigationStack { DesignGalleryView() }.preferredColorScheme(.dark).dynamicTypeSize(.accessibility2)
}
