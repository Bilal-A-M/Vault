import SwiftUI

struct HomeView: View {
    @Environment(VaultStore.self) private var store
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var store = store
        ScrollView {
            VStack(alignment: .leading, spacing: VaultSpace.section) {
                if store.isLoading {
                    HomeSkeleton()
                } else {
                    if case .offline = store.syncStatus { OfflineBanner(partner: store.partner?.name ?? "your partner") }
                    MetalBalanceCard(
                        totalCents: store.totalCents,
                        syncStatus: store.syncStatus,
                        partnerName: store.partner?.name ?? "",
                        isEmpty: store.entries.isEmpty,
                        hideAmounts: $store.hideAmounts,
                        onAdd: { router.addDeposit() },
                        onWithdraw: { router.logWithdrawal() })
                    if store.entries.isEmpty {
                        Text("Log your first deposit and it shows up here, on both your phones.")
                            .font(.subheadline).foregroundStyle(VaultColor.textSecondary)
                            .padding(.horizontal, 4)
                            .padding(.top, -8)
                    } else {
                        MonthCard()
                    }
                    GoalsStrip()
                    if !store.entries.isEmpty { RecentActivity() }
                }
            }
            .padding(.horizontal, VaultSpace.page)
            .padding(.bottom, 24)
        }
        .background(VaultColor.background)
        .navigationTitle("Hi, \(store.owner?.name ?? "there")")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink(value: Route.settings) {
                    AvatarPair(people: store.people)
                }
                .accessibilityLabel("People and settings")
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: Route.settings) {
                    Image(systemName: "slider.horizontal.3")
                }
                .accessibilityLabel("Settings")
            }
        }
        .refreshable { await fakeSync() }
        .onDisappear { store.markSeen() }
    }

    /// Design phase: pull-to-refresh pretends to sync.
    private func fakeSync() async {
        store.syncStatus = .syncing
        try? await Task.sleep(for: .seconds(1))
        store.syncStatus = .synced(.now)
    }
}

private struct OfflineBanner: View {
    let partner: String
    @Environment(VaultStore.self) private var store

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "icloud.slash").font(.title3).foregroundStyle(VaultColor.accent)
            VStack(alignment: .leading, spacing: 4) {
                Text("Can't reach iCloud").font(.subheadline.weight(.semibold))
                Text("You're seeing what's on this phone. Deposits you add now will sync with \(partner) when you're back online.")
                    .font(.footnote).foregroundStyle(VaultColor.textSecondary)
            }
            Spacer(minLength: 0)
            Button("Retry") { store.syncStatus = .synced(.now) }
                .font(.subheadline.weight(.semibold))
                .frame(minHeight: 44)
        }
        .foregroundStyle(VaultColor.textPrimary)
        .vaultCard(padding: 14)
        .accessibilityElement(children: .combine)
    }
}

/// "November +$1,450" with the two-person split.
private struct MonthCard: View {
    @Environment(VaultStore.self) private var store

    var body: some View {
        let month = VaultMath.entries(store.entries, inMonthOf: .now)
        let shares = VaultMath.shares(month, people: store.people)
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(Date.now.formatted(.dateTime.month(.wide))).font(.headline)
                Spacer()
                MoneyText(cents: VaultMath.total(month), style: .row, fraction: .never, signed: true)
            }
            .foregroundStyle(VaultColor.textPrimary)
            ContributionBar(shares: shares)
            HStack {
                ForEach(shares) { share in
                    HStack(spacing: 7) {
                        Circle().fill(share.person.color.solid).frame(width: 8, height: 8)
                        Text(share.person.name).foregroundStyle(VaultColor.textPrimary)
                        MoneyText(cents: share.cents, style: .row, fraction: .never)
                            .foregroundStyle(VaultColor.textSecondary)
                    }
                    if share.id != shares.last?.id { Spacer() }
                }
            }
            .font(.subheadline)
        }
        .vaultCard()
    }
}

private struct GoalsStrip: View {
    @Environment(VaultStore.self) private var store
    @Environment(AppRouter.self) private var router

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle(title: "Goals") {
                if !store.goals.isEmpty {
                    Button { router.tab = .goals } label: { ChevronLabel(title: "See all \(store.goals.count)") }
                }
            }
            if store.goals.isEmpty {
                Button { router.newGoal() } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "target").font(.title3).foregroundStyle(VaultColor.accent)
                            .frame(width: 48, height: 48).background(VaultColor.raised, in: Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Create a goal").font(.headline).foregroundStyle(VaultColor.textPrimary)
                            Text("A vacation, a house, a rainy-day fund").font(.footnote).foregroundStyle(VaultColor.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(VaultColor.textTertiary)
                    }
                    .padding(18)
                    .overlay(RoundedRectangle(cornerRadius: VaultRadius.card, style: .continuous)
                        .strokeBorder(VaultColor.accent.opacity(0.35), style: StrokeStyle(lineWidth: 1, dash: [5, 4])))
                }
                .buttonStyle(.plain)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(store.sortedGoals) { goal in
                            NavigationLink(value: Route.goal(goal.id)) {
                                GoalCardCompact(goal: goal, saved: store.saved(goal), fresh: store.freshMilestone(for: goal))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, VaultSpace.page)
                }
                .padding(.horizontal, -VaultSpace.page)
            }
        }
    }
}

private struct RecentActivity: View {
    @Environment(VaultStore.self) private var store
    @Environment(AppRouter.self) private var router

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionTitle(title: "Recent activity") {
                Button { router.tab = .history } label: { ChevronLabel(title: "See all") }
            }
            VStack(spacing: 0) {
                let recent = Array(store.sortedEntries.prefix(4))
                ForEach(recent) { entry in
                    Button { router.edit(entry) } label: {
                        ActivityRow(entry: entry, person: store.person(entry.personID), goal: store.goal(entry.goalID),
                                    isNew: store.isNew(entry),
                                    effect: store.milestoneCrossed(by: entry).flatMap { m in
                                        store.goal(entry.goalID).map { "\($0.name) passed \(m.label)" }
                                    },
                                    ownerID: store.owner?.id)
                    }
                    .buttonStyle(.plain)
                    if entry.id != recent.last?.id { Divider().overlay(VaultColor.separator) }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 2)
            .background(VaultColor.card, in: RoundedRectangle(cornerRadius: VaultRadius.card, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: VaultRadius.card, style: .continuous).strokeBorder(VaultColor.hairline))
        }
    }
}

private struct HomeSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: VaultSpace.section) {
            SkeletonBlock(height: 190, radius: VaultRadius.hero)
            SkeletonBlock(height: 96, radius: VaultRadius.card)
            HStack(spacing: 12) {
                SkeletonBlock(height: 150, width: 160, radius: VaultRadius.card)
                SkeletonBlock(height: 150, width: 160, radius: VaultRadius.card)
            }
            Text("Opening the vault…").font(.footnote).foregroundStyle(VaultColor.textSecondary)
                .frame(maxWidth: .infinity)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Loading your vault")
    }
}

#Preview("Home") {
    NavigationStack { HomeView().routes() }
        .environment(VaultStore())
        .environment(AppRouter())
        .preferredColorScheme(.dark)
}
