import SwiftUI

/// A living style guide: every token and component in one scrollable screen.
/// Open the previews at the bottom of this file for light and dark side by side,
/// or run the app and use the toolbar button to flip the appearance.
struct DesignGalleryView: View {
    @State private var scheme: ColorScheme?
    @State private var name = "Sara"
    @State private var emptyText = ""
    @State private var amountCents = 12_500
    @State private var ringProgress = 0.78
    @State private var selectedPerson = MockData.me.id

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VaultSpacing.xxl) {
                wordmark
                colors
                typography
                layout
                buttons
                progress
                people
                goalsAndDeposits
                tilesAndBadges
                inputs
                emptyState
            }
            .padding(.horizontal, VaultSpacing.page)
            .padding(.vertical, VaultSpacing.xl)
        }
        .background(VaultColor.background.ignoresSafeArea())
        .navigationTitle("Design system")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("System") { scheme = nil }
                    Button("Light") { scheme = .light }
                    Button("Dark") { scheme = .dark }
                } label: {
                    Image(systemName: "circle.lefthalf.filled")
                }
                .accessibilityLabel("Appearance")
            }
        }
        .preferredColorScheme(scheme)
    }

    // MARK: Sections

    private var wordmark: some View {
        VStack(alignment: .leading, spacing: VaultSpacing.sm) {
            HStack(spacing: VaultSpacing.md) {
                // Icon concept: a gold dial ring with a notch at 12 o'clock.
                ZStack {
                    RoundedRectangle.vault(VaultRadius.control).fill(Color(hex: 0x0B0B0D))
                    Circle()
                        .trim(from: 0.04, to: 0.96)
                        .stroke(Color(hex: 0xD4B36A), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .padding(13)
                }
                .frame(width: 56, height: 56)
                .accessibilityHidden(true)

                Text("VAULT")
                    .font(.system(.title, weight: .semibold))
                    .tracking(8)
                    .foregroundStyle(VaultColor.textPrimary)
            }
            Text("Obsidian · near-black, warm white, champagne gold")
                .font(VaultFont.footnote)
                .foregroundStyle(VaultColor.textSecondary)
        }
    }

    private var colors: some View {
        GallerySection("Color") {
            swatchGroup("Surfaces", [
                ("background", VaultColor.background), ("surface", VaultColor.surface),
                ("surfaceRaised", VaultColor.surfaceRaised), ("track", VaultColor.track),
            ])
            swatchGroup("Brand", [
                ("primary", VaultColor.primary), ("accent", VaultColor.accent),
                ("accentSoft", VaultColor.accentSoft),
            ])
            swatchGroup("Text", [
                ("textPrimary", VaultColor.textPrimary), ("textSecondary", VaultColor.textSecondary),
                ("textTertiary", VaultColor.textTertiary),
            ])
            swatchGroup("Semantic", [
                ("success", VaultColor.success), ("warning", VaultColor.warning),
                ("danger", VaultColor.danger),
            ])
            swatchGroup("Person", PersonColor.allCases.map { ($0.rawValue, $0.color) })
        }
    }

    private var typography: some View {
        GallerySection("Typography") {
            VaultCard {
                VStack(alignment: .leading, spacing: VaultSpacing.md) {
                    Text("Total saved").vaultOverline()
                    MoneyText(cents: 3_528_000, style: .hero)
                    MoneyText(cents: 468_000, style: .large)
                    MoneyText(cents: 125_050, style: .medium)
                    MoneyText(cents: 20_000, style: .small, signed: true)
                }
                .foregroundStyle(VaultColor.textPrimary)
            }
            VaultCard {
                VStack(alignment: .leading, spacing: VaultSpacing.sm) {
                    Text("Large title").font(VaultFont.largeTitle)
                    Text("Title").font(VaultFont.title)
                    Text("Headline").font(VaultFont.headline)
                    Text("Body. Every style scales with Dynamic Type.").font(VaultFont.body)
                    Text("Callout").font(VaultFont.callout)
                    Text("Subheadline").font(VaultFont.subheadline)
                    Text("Footnote").font(VaultFont.footnote).foregroundStyle(VaultColor.textSecondary)
                    Text("Caption").font(VaultFont.caption).foregroundStyle(VaultColor.textSecondary)
                    Text("Overline").vaultOverline()
                }
                .foregroundStyle(VaultColor.textPrimary)
            }
        }
    }

    private var layout: some View {
        GallerySection("Spacing, radius, shadow") {
            VaultCard {
                VStack(alignment: .leading, spacing: VaultSpacing.sm) {
                    ForEach(spacingTokens, id: \.name) { token in
                        HStack(spacing: VaultSpacing.md) {
                            Text("\(token.name) · \(Int(token.value))")
                                .font(VaultFont.caption)
                                .monospacedDigit()
                                .foregroundStyle(VaultColor.textSecondary)
                                .frame(width: 80, alignment: .leading)
                            Capsule().fill(VaultColor.accent)
                                .frame(width: token.value, height: 8)
                        }
                    }
                }
            }
            HStack(spacing: VaultSpacing.md) {
                ForEach(radiusTokens, id: \.name) { token in
                    VStack(spacing: VaultSpacing.sm) {
                        RoundedRectangle.vault(token.value)
                            .fill(VaultColor.surfaceRaised)
                            .overlay(RoundedRectangle.vault(token.value).strokeBorder(VaultColor.border))
                            .frame(height: 64)
                        Text("\(token.name) · \(Int(token.value))")
                            .font(VaultFont.caption)
                            .foregroundStyle(VaultColor.textSecondary)
                    }
                }
            }
            HStack(spacing: VaultSpacing.lg) {
                shadowSample("card", .card)
                shadowSample("floating", .floating)
            }
            Text("Dark mode drops shadows and relies on the hairline border.")
                .font(VaultFont.caption)
                .foregroundStyle(VaultColor.textSecondary)
        }
    }

    private var buttons: some View {
        GallerySection("Buttons") {
            Button {} label: { Label("Add deposit", systemImage: "plus") }
                .buttonStyle(.vaultPrimary)
            Button("Secondary action") {}
                .buttonStyle(.vaultSecondary)
            HStack(spacing: VaultSpacing.md) {
                Button("Compact") {}.buttonStyle(.vaultPrimaryCompact)
                Button("Compact") {}.buttonStyle(.vaultSecondaryCompact)
            }
            Button("Disabled") {}
                .buttonStyle(.vaultPrimary)
                .disabled(true)
        }
    }

    private var progress: some View {
        GallerySection("Progress") {
            VaultCard {
                VStack(spacing: VaultSpacing.lg) {
                    HStack(spacing: VaultSpacing.xl) {
                        ProgressRing(progress: ringProgress, lineWidth: 12, label: "Vacation progress") {
                            VStack(spacing: 0) {
                                Text("\(Int(ringProgress * 100))%")
                                    .vaultMoney(.large)
                                    .foregroundStyle(VaultColor.textPrimary)
                                Text("saved").font(VaultFont.caption)
                                    .foregroundStyle(VaultColor.textSecondary)
                            }
                        }
                        .frame(width: 132, height: 132)

                        VStack(spacing: VaultSpacing.md) {
                            ProgressRing(progress: 0.25, lineWidth: 6)
                                .frame(width: 44, height: 44)
                            ProgressRing(progress: 1, lineWidth: 6, tint: VaultColor.success)
                                .frame(width: 44, height: 44)
                        }
                    }
                    ProgressBar(progress: ringProgress)
                    Slider(value: $ringProgress, in: 0...1)
                        .tint(VaultColor.accent)
                        .accessibilityLabel("Demo progress")
                }
            }
            VaultCard {
                VStack(alignment: .leading, spacing: VaultSpacing.md) {
                    Text("This month").vaultOverline()
                    ContributionSplitBar(shares: [
                        ContributionShare(person: MockData.me, cents: 85_000),
                        ContributionShare(person: MockData.wife, cents: 60_000),
                    ])
                }
            }
        }
    }

    private var people: some View {
        GallerySection("Avatars and chips") {
            HStack(spacing: VaultSpacing.lg) {
                PersonAvatar(person: MockData.me, size: 56)
                PersonAvatar(person: MockData.wife, size: 56)
                PersonAvatar(person: Person(name: "Sara", color: .lavender), size: 40)
                PersonAvatar(person: Person(name: "Bilal", color: .sky), size: 28)
            }
            HStack(spacing: VaultSpacing.sm) {
                ForEach(MockData.people) { person in
                    Button {
                        selectedPerson = person.id
                    } label: {
                        AvatarChip(person: person, isSelected: selectedPerson == person.id)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var goalsAndDeposits: some View {
        GallerySection("Goal tiles and deposit rows") {
            ForEach(MockData.goals) { goal in
                GoalTile(goal: goal, savedCents: MockData.savedByGoal[goal.id] ?? 0)
            }
            SectionHeader(title: "Recent deposits", actionTitle: "See all") {}
            VaultCard(padding: VaultSpacing.md) {
                VStack(spacing: 0) {
                    ForEach(MockData.sampleDeposits) { deposit in
                        DepositRow(deposit: deposit,
                                   person: MockData.person(deposit.personID),
                                   goal: MockData.goal(deposit.goalID))
                        if deposit.id != MockData.sampleDeposits.last?.id {
                            Divider().overlay(VaultColor.border)
                        }
                    }
                }
            }
        }
    }

    private var tilesAndBadges: some View {
        GallerySection("Stat tiles and badges") {
            HStack(spacing: VaultSpacing.md) {
                StatTile(label: "This month", value: Money.format(cents: 145_000, fraction: .auto),
                         caption: "+12% vs last month", icon: "arrow.up.right")
                StatTile(label: "Remaining", value: Money.format(cents: 132_000, fraction: .auto),
                         caption: "140 days left", icon: "flag.fill", tint: VaultColor.warning)
            }
            HStack(spacing: VaultSpacing.sm) {
                MilestoneBadge(milestone: .quarter)
                MilestoneBadge(milestone: .half)
                MilestoneBadge(milestone: .threeQuarters, isEarned: false)
                MilestoneBadge(milestone: .complete)
            }
        }
    }

    private var inputs: some View {
        GallerySection("Inputs") {
            VaultCard {
                CurrencyInput(cents: $amountCents)
            }
            VaultTextField(label: "Name", text: $name, placeholder: "Your name", icon: "person")
            VaultTextField(label: "Note", text: $emptyText, placeholder: "What's this for?")
        }
    }

    private var emptyState: some View {
        GallerySection("Empty state") {
            VaultCard {
                EmptyStateView(icon: "tray", title: "No deposits yet",
                               message: "Add your first deposit and it will show up here.",
                               actionTitle: "Add deposit") {}
            }
        }
    }

    // MARK: Helpers

    private var spacingTokens: [(name: String, value: CGFloat)] {
        [("xs", VaultSpacing.xs), ("sm", VaultSpacing.sm), ("md", VaultSpacing.md),
         ("lg", VaultSpacing.lg), ("xl", VaultSpacing.xl), ("xxl", VaultSpacing.xxl),
         ("xxxl", VaultSpacing.xxxl)]
    }

    private var radiusTokens: [(name: String, value: CGFloat)] {
        [("small", VaultRadius.small), ("control", VaultRadius.control),
         ("card", VaultRadius.card), ("sheet", VaultRadius.sheet)]
    }

    private func swatchGroup(_ title: String, _ swatches: [(String, Color)]) -> some View {
        VStack(alignment: .leading, spacing: VaultSpacing.sm) {
            Text(title).vaultOverline()
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: VaultSpacing.sm)],
                      alignment: .leading, spacing: VaultSpacing.sm) {
                ForEach(swatches, id: \.0) { swatch in
                    VStack(alignment: .leading, spacing: VaultSpacing.xs) {
                        RoundedRectangle.vault(VaultRadius.small)
                            .fill(swatch.1)
                            .overlay(RoundedRectangle.vault(VaultRadius.small).strokeBorder(VaultColor.border))
                            .frame(height: 44)
                        Text(swatch.0)
                            .font(VaultFont.caption)
                            .foregroundStyle(VaultColor.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
            }
        }
    }

    private func shadowSample(_ name: String, _ shadow: VaultShadow) -> some View {
        Text(name)
            .font(VaultFont.caption)
            .foregroundStyle(VaultColor.textSecondary)
            .frame(maxWidth: .infinity, minHeight: 64)
            .vaultSurface(shadow: shadow)
    }
}

/// A titled block in the gallery.
private struct GallerySection<Content: View>: View {
    private let title: String
    private let content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: VaultSpacing.lg) {
            Text(title)
                .font(VaultFont.title)
                .foregroundStyle(VaultColor.textPrimary)
                .accessibilityAddTraits(.isHeader)
            content
        }
    }
}

#Preview("Gallery · Dark") {
    NavigationStack { DesignGalleryView() }
        .preferredColorScheme(.dark)
}

#Preview("Gallery · Light") {
    NavigationStack { DesignGalleryView() }
        .preferredColorScheme(.light)
}

#Preview("Gallery · Large type") {
    NavigationStack { DesignGalleryView() }
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.accessibility2)
}
