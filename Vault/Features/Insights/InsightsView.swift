import SwiftUI
import Charts

enum InsightsRange: String, CaseIterable, Identifiable {
    case month = "1M", quarter = "3M", half = "6M", year = "1Y", all = "All"
    var id: String { rawValue }

    var months: Int? {
        switch self {
        case .month: 1
        case .quarter: 3
        case .half: 6
        case .year: 12
        case .all: nil
        }
    }

    func start(now: Date = .now) -> Date? {
        guard let months else { return nil }
        return Calendar.current.date(byAdding: .month, value: -months, to: Calendar.current.startOfDay(for: now))
    }
}

struct InsightsView: View {
    @Environment(VaultStore.self) private var store
    @State private var range: InsightsRange = .half
    @State private var perGoal = false

    private var hasEnoughData: Bool {
        guard let first = store.entries.map(\.date).min() else { return false }
        return (Calendar.current.dateComponents([.month], from: first, to: .now).month ?? 0) >= 2
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if store.entries.isEmpty {
                    EmptyStateView(icon: "chart.bar", title: "No insights yet",
                                   message: "Once you've logged a few deposits, this is where you'll see how your savings grow.")
                        .padding(.top, 40)
                } else {
                    Picker("Range", selection: $range) {
                        ForEach(InsightsRange.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)

                    if !hasEnoughData {
                        Label("Charts get more useful after a couple of months of deposits.", systemImage: "info.circle")
                            .font(.footnote).foregroundStyle(VaultColor.textSecondary)
                    }

                    savingsCard
                    monthlyCard
                    timelineCard
                }
            }
            .padding(.horizontal, VaultSpace.page)
            .padding(.bottom, 24)
        }
        .background(VaultColor.background)
        .navigationTitle("Insights")
    }

    // MARK: Savings over time

    private var savingsCard: some View {
        let start = range.start()
        let points: [VaultMath.BalancePoint] = perGoal
            ? store.sortedGoals.flatMap { VaultMath.balanceSeries(store.entries, goalID: $0.id, since: start, series: $0.name) }
            : VaultMath.balanceSeries(store.entries, since: start)
        let inRange = store.entries.filter { start == nil || $0.date >= start! }
        return VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(range == .all ? "Saved in total" : "Saved in \(range.rawValue)")
                        .font(.subheadline).foregroundStyle(VaultColor.textSecondary)
                    MoneyText(cents: VaultMath.total(inRange), style: .title, fraction: .never, signed: true)
                        .foregroundStyle(VaultColor.textPrimary)
                }
                Spacer()
                Picker("Breakdown", selection: $perGoal) {
                    Text("All").tag(false)
                    Text("Per goal").tag(true)
                }
                .pickerStyle(.segmented)
                .frame(width: 150)
            }
            Chart(points) { point in
                if !perGoal {
                    AreaMark(x: .value("Date", point.date), y: .value("Saved", Double(point.cents) / 100))
                        .foregroundStyle(LinearGradient(colors: [VaultColor.progress.opacity(0.22), VaultColor.progress.opacity(0)],
                                                        startPoint: .top, endPoint: .bottom))
                        .interpolationMethod(.monotone)
                }
                LineMark(x: .value("Date", point.date), y: .value("Saved", Double(point.cents) / 100),
                         series: .value("Goal", point.series))
                    .foregroundStyle(by: .value("Goal", point.series))
                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round))
                    .interpolationMethod(.monotone)
            }
            // Goals are told apart by shade and legend, not by new colours.
            .chartForegroundStyleScale(range: [VaultColor.progress, VaultColor.accent,
                                               VaultColor.textSecondary, VaultColor.progress.opacity(0.5),
                                               VaultColor.textTertiary])
            .chartLegend(perGoal ? .visible : .hidden)
            .chartYAxis {
                AxisMarks(position: .trailing) { _ in
                    AxisGridLine().foregroundStyle(VaultColor.separator)
                    AxisValueLabel().foregroundStyle(VaultColor.textTertiary)
                }
            }
            .frame(height: 190)
            .accessibilityLabel(perGoal ? "Savings per goal over time" : "Total savings over time")
            .accessibilityValue("Now \(Money.format(cents: store.totalCents, fraction: .never))")
        }
        .vaultCard()
    }

    // MARK: Each month, stacked by person

    private var monthlyCard: some View {
        let months = min(range.months ?? 12, 12)
        let data = VaultMath.monthlyContributions(store.entries, people: store.people, months: max(months, 3))
        return VStack(alignment: .leading, spacing: 14) {
            Text("Each month").font(.headline).foregroundStyle(VaultColor.textPrimary)
            Chart(data) { item in
                BarMark(x: .value("Month", item.month, unit: .month),
                        y: .value("Added", Double(item.cents) / 100))
                    .foregroundStyle(by: .value("Person", item.person.name))
                    .cornerRadius(4)
            }
            .chartForegroundStyleScale(domain: store.people.map(\.name), range: store.people.map(\.color.solid))
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { _ in
                    AxisValueLabel(format: .dateTime.month(.abbreviated), centered: true).foregroundStyle(VaultColor.textTertiary)
                }
            }
            .chartYAxis {
                AxisMarks(position: .trailing) { _ in
                    AxisGridLine().foregroundStyle(VaultColor.separator)
                    AxisValueLabel().foregroundStyle(VaultColor.textTertiary)
                }
            }
            .frame(height: 180)
            .accessibilityLabel("Monthly contributions by person")
        }
        .vaultCard()
    }

    // MARK: Goal timeline

    private var timelineCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Goal timeline").font(.headline).foregroundStyle(VaultColor.textPrimary)
            if store.goals.isEmpty {
                Text("Create a goal to see when you'll reach it.").font(.subheadline).foregroundStyle(VaultColor.textSecondary)
            }
            ForEach(store.sortedGoals) { goal in
                let progress = store.progress(goal)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(goal.name).foregroundStyle(VaultColor.textPrimary)
                        Spacer()
                        Text(status(goal, progress: progress))
                            .foregroundStyle(progress >= 1 ? VaultColor.progress : VaultColor.textSecondary)
                    }
                    .font(.subheadline)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(VaultColor.track)
                            Capsule().fill(VaultColor.progress).frame(width: geo.size.width * min(progress, 1))
                        }
                    }
                    .frame(height: 6)
                    .accessibilityHidden(true)
                }
                .accessibilityElement(children: .combine)
                .accessibilityValue("\(Int((min(progress, 1) * 100).rounded())) percent")
            }
        }
        .vaultCard()
    }

    private func status(_ goal: Goal, progress: Double) -> String {
        if progress >= 1 {
            let date = VaultMath.reachedDate(goal: goal, entries: store.entries)
            return "Reached \(date?.formatted(.dateTime.month(.abbreviated).year()) ?? "")"
        }
        let remaining = goal.targetCents - store.saved(goal)
        let pace = VaultMath.monthlyPace(goalID: goal.id, entries: store.entries)
        guard let projected = VaultMath.projectedCompletion(remaining: remaining, pace: pace) else {
            return "Not enough data yet"
        }
        if let target = goal.targetDate, projected > target {
            let months = Calendar.current.dateComponents([.month], from: target, to: projected).month ?? 0
            return months > 0 ? "About \(months) month\(months == 1 ? "" : "s") behind" : "Just behind"
        }
        return "On track for \(projected.formatted(.dateTime.month(.abbreviated).year()))"
    }
}

#Preview {
    NavigationStack { InsightsView() }
        .environment(VaultStore())
        .environment(AppRouter())
        .preferredColorScheme(.dark)
}
