import SwiftUI
import Charts

struct GoalDetailView: View {
    let goalID: Goal.ID
    @Environment(VaultStore.self) private var store
    @Environment(AppRouter.self) private var router

    var body: some View {
        if let goal = store.goal(goalID) {
            content(goal)
        } else {
            EmptyStateView(icon: "target", title: "Goal deleted", message: "This goal no longer exists.")
        }
    }

    private func content(_ goal: Goal) -> some View {
        let saved = store.saved(goal)
        let progress = VaultMath.progress(saved: saved, target: goal.targetCents)
        let goalEntries = store.sortedEntries.filter { $0.goalID == goal.id }
        let remaining = max(0, goal.targetCents - saved)
        let fresh = store.freshMilestone(for: goal)

        return ScrollView {
            VStack(spacing: VaultSpace.section) {
                VStack(spacing: 12) {
                    ProgressRing(progress: progress, lineWidth: 12, label: "\(goal.name) progress") {
                        VStack(spacing: 2) {
                            if progress >= 1 {
                                Image(systemName: "checkmark").font(.system(size: 44, weight: .bold))
                                    .foregroundStyle(VaultColor.progress)
                            } else {
                                Text("\(Int((progress * 100).rounded(.down)))%").moneyFont(.large)
                                    .foregroundStyle(VaultColor.textPrimary)
                                Text("funded").font(.footnote).foregroundStyle(VaultColor.textSecondary)
                            }
                        }
                    }
                    .frame(width: 210, height: 210)
                    if let date = goal.targetDate {
                        Text("Target \(date.formatted(date: .abbreviated, time: .omitted)) · \(Self.daysLeft(date))")
                            .font(.subheadline).foregroundStyle(VaultColor.textSecondary)
                    }
                    HStack(spacing: 6) {
                        ForEach(Milestone.allCases) { milestone in
                            MilestoneBadge(milestone: milestone, earned: progress >= milestone.fraction, fresh: milestone == fresh)
                        }
                    }
                }
                .padding(.top, 8)

                stats(saved: saved, target: goal.targetCents, remaining: remaining)

                BalanceChartCard(goal: goal, entries: store.entries, remaining: remaining)

                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Who's chipped in").font(.headline)
                        Spacer()
                        MoneyText(cents: saved, style: .row, fraction: .never).foregroundStyle(VaultColor.textSecondary)
                    }
                    let shares = VaultMath.shares(goalEntries, people: store.people)
                    ContributionBar(shares: shares)
                    ForEach(shares) { share in
                        HStack(spacing: 8) {
                            Circle().fill(share.person.color.solid).frame(width: 9, height: 9)
                            Text(share.person.name)
                            Spacer()
                            MoneyText(cents: share.cents, style: .row, fraction: .auto)
                        }
                        .font(.subheadline)
                    }
                }
                .foregroundStyle(VaultColor.textPrimary)
                .vaultCard()

                VStack(alignment: .leading, spacing: 10) {
                    SectionTitle(title: "Deposits") {
                        Button { router.addDeposit(goalID: goal.id) } label: { ChevronLabel(title: "Add") }
                    }
                    if goalEntries.isEmpty {
                        Text("Nothing logged to this goal yet.").font(.subheadline).foregroundStyle(VaultColor.textSecondary)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(goalEntries) { entry in
                                Button { router.edit(entry) } label: {
                                    ActivityRow(entry: entry, person: store.person(entry.personID), goal: goal,
                                                isNew: store.isNew(entry), showGoal: false, ownerID: store.owner?.id)
                                }
                                .buttonStyle(.plain)
                                if entry.id != goalEntries.last?.id { Divider() }
                            }
                        }
                        .padding(.horizontal, 16)
                        .background(VaultColor.card, in: RoundedRectangle(cornerRadius: VaultRadius.card, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: VaultRadius.card, style: .continuous).strokeBorder(VaultColor.hairline))
                    }
                }
            }
            .padding(.horizontal, VaultSpace.page)
            .padding(.bottom, 24)
        }
        .background(VaultColor.background)
        .navigationTitle(goal.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { Button("Edit") { router.edit(goal) } }
        }
        .onDisappear { store.markMilestonesSeen(for: goal) }
    }

    private func stats(saved: Int, target: Int, remaining: Int) -> some View {
        HStack(spacing: 0) {
            stat("Saved", saved)
            Divider().frame(height: 44)
            stat("Target", target)
            Divider().frame(height: 44)
            stat("To go", remaining)
        }
        .padding(.vertical, 14)
        .background(VaultColor.card, in: RoundedRectangle(cornerRadius: VaultRadius.card, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: VaultRadius.card, style: .continuous).strokeBorder(VaultColor.hairline))
    }

    private func stat(_ label: String, _ cents: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.footnote).foregroundStyle(VaultColor.textSecondary)
            MoneyText(cents: cents, style: .title, fraction: .never).foregroundStyle(VaultColor.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .accessibilityElement(children: .combine)
    }

    static func daysLeft(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: .now, to: date).day ?? 0
        return days > 0 ? "\(days) days left" : "Target date passed"
    }
}

/// Running balance with a dashed target line.
private struct BalanceChartCard: View {
    let goal: Goal
    let entries: [Entry]
    let remaining: Int

    var body: some View {
        let points = VaultMath.balanceSeries(entries, goalID: goal.id)
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Balance").font(.headline)
                Spacer()
                if let needed = VaultMath.monthlyNeeded(remaining: remaining, targetDate: goal.targetDate) {
                    Text("About \(Money.format(cents: needed, fraction: .never)) a month to finish on time")
                        .font(.footnote).foregroundStyle(VaultColor.textSecondary)
                        .multilineTextAlignment(.trailing)
                }
            }
            .foregroundStyle(VaultColor.textPrimary)

            if points.count < 2 {
                Text("The chart appears after a couple of deposits.")
                    .font(.subheadline).foregroundStyle(VaultColor.textSecondary)
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                Chart {
                    ForEach(points) { point in
                        AreaMark(x: .value("Date", point.date), y: .value("Balance", Double(point.cents) / 100))
                            .foregroundStyle(LinearGradient(colors: [VaultColor.progress.opacity(0.22), VaultColor.progress.opacity(0)],
                                                            startPoint: .top, endPoint: .bottom))
                            .interpolationMethod(.monotone)
                        LineMark(x: .value("Date", point.date), y: .value("Balance", Double(point.cents) / 100))
                            .foregroundStyle(VaultColor.progress)
                            .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round))
                            .interpolationMethod(.monotone)
                    }
                    RuleMark(y: .value("Target", Double(goal.targetCents) / 100))
                        .foregroundStyle(VaultColor.textSecondary)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 5]))
                        .annotation(position: .top, alignment: .leading) {
                            Text("Target \(Money.format(cents: goal.targetCents, fraction: .never))")
                                .font(.caption).foregroundStyle(VaultColor.textSecondary)
                        }
                }
                .chartYAxis {
                    AxisMarks(position: .trailing) { _ in
                        AxisGridLine().foregroundStyle(VaultColor.separator)
                        AxisValueLabel().foregroundStyle(VaultColor.textTertiary)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { _ in
                        AxisValueLabel(format: .dateTime.month(.abbreviated)).foregroundStyle(VaultColor.textTertiary)
                    }
                }
                .frame(height: 170)
                .accessibilityLabel("\(goal.name) balance over time")
                .accessibilityValue("Now \(Money.format(cents: points.last?.cents ?? 0, fraction: .never)) of a \(Money.format(cents: goal.targetCents, fraction: .never)) target")
            }
        }
        .vaultCard()
    }
}

#Preview {
    NavigationStack { GoalDetailView(goalID: MockData.vacation.id).routes() }
        .environment(VaultStore())
        .environment(AppRouter())
        .preferredColorScheme(.dark)
}
