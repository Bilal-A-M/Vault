import WidgetKit
import SwiftUI

// Home Screen widgets. Design phase: they read mock data. Once the app has
// real storage, the provider reads the shared store through an App Group.

struct VaultEntry: TimelineEntry {
    let date: Date
    let totalCents: Int
    let monthCents: Int
    let goal: Goal
    let goalSaved: Int
    let latest: Entry?
    let latestPerson: Person?
}

struct VaultProvider: TimelineProvider {
    func placeholder(in context: Context) -> VaultEntry { Self.mock() }
    func getSnapshot(in context: Context, completion: @escaping (VaultEntry) -> Void) { completion(Self.mock()) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<VaultEntry>) -> Void) {
        completion(Timeline(entries: [Self.mock()], policy: .after(.now.addingTimeInterval(3600))))
    }

    static func mock() -> VaultEntry {
        let entries = MockData.entries
        let latest = entries.max { $0.date < $1.date }
        return VaultEntry(date: .now,
                          totalCents: VaultMath.total(entries),
                          monthCents: VaultMath.total(VaultMath.entries(entries, inMonthOf: .now)),
                          goal: MockData.house,
                          goalSaved: VaultMath.saved(goalID: MockData.house.id, in: entries),
                          latest: latest,
                          latestPerson: MockData.people.first { $0.id == latest?.personID })
    }
}

// MARK: Views

private struct Ring: View {
    let progress: Double
    var body: some View {
        ZStack {
            Circle().stroke(Color.white.opacity(0.1), lineWidth: 8)
            Circle().trim(from: 0, to: min(progress, 1))
                .stroke(VaultColor.progress, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .widgetAccentable()
            Text("\(Int((progress * 100).rounded(.down)))%")
                .font(.system(size: 20, weight: .medium, design: .rounded)).monospacedDigit()
        }
    }
}

struct TotalWidgetView: View {
    let entry: VaultEntry
    var body: some View {
        VStack(alignment: .leading) {
            Text("Saved together").font(.footnote).foregroundStyle(.secondary)
            Spacer()
            Text(Money.format(cents: entry.totalCents, fraction: .never))
                .font(.system(size: 28, weight: .medium, design: .rounded)).monospacedDigit()
                .minimumScaleFactor(0.6).lineLimit(1)
                .widgetAccentable()
            Text("\(Money.format(cents: entry.monthCents, fraction: .never, signed: true)) in \(Date.now.formatted(.dateTime.month(.abbreviated)))")
                .font(.footnote).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .containerBackground(for: .widget) { Color(light: 0xFFFFFF, dark: 0x0E0E11) }
    }
}

struct GoalWidgetView: View {
    let entry: VaultEntry
    var body: some View {
        VStack(spacing: 8) {
            Ring(progress: VaultMath.progress(saved: entry.goalSaved, target: entry.goal.targetCents))
                .frame(width: 88, height: 88)
            Text(entry.goal.name).font(.subheadline.weight(.semibold)).lineLimit(1)
            Text("\(Money.format(cents: max(0, entry.goal.targetCents - entry.goalSaved), fraction: .never)) to go")
                .font(.caption).foregroundStyle(.secondary)
        }
        .containerBackground(for: .widget) { Color(light: 0xFFFFFF, dark: 0x0E0E11) }
    }
}

struct MediumWidgetView: View {
    let entry: VaultEntry
    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 8) {
                Ring(progress: VaultMath.progress(saved: entry.goalSaved, target: entry.goal.targetCents))
                    .frame(width: 88, height: 88)
                Text(entry.goal.name).font(.footnote.weight(.semibold)).lineLimit(1)
            }
            Divider()
            VStack(alignment: .leading, spacing: 6) {
                Text("Saved").font(.footnote).foregroundStyle(.secondary)
                Text(Money.format(cents: entry.goalSaved, fraction: .never))
                    .font(.system(size: 22, weight: .medium, design: .rounded)).monospacedDigit()
                Spacer(minLength: 0)
                if let latest = entry.latest, let person = entry.latestPerson {
                    Text("\(person.name) added \(Money.format(cents: latest.amountCents, fraction: .auto))")
                        .font(.footnote.weight(.semibold))
                    Text(latest.date.formatted(.relative(presentation: .named)))
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .containerBackground(for: .widget) { Color(light: 0xFFFFFF, dark: 0x0E0E11) }
    }
}

// MARK: Widgets

struct TotalWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "VaultTotal", provider: VaultProvider()) { TotalWidgetView(entry: $0) }
            .configurationDisplayName("Total saved")
            .description("What the two of you have saved.")
            .supportedFamilies([.systemSmall])
    }
}

struct GoalWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "VaultGoal", provider: VaultProvider()) { GoalWidgetView(entry: $0) }
            .configurationDisplayName("Goal progress")
            .description("How close you are to a goal.")
            .supportedFamilies([.systemSmall])
    }
}

struct OverviewWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "VaultOverview", provider: VaultProvider()) { MediumWidgetView(entry: $0) }
            .configurationDisplayName("Goal and latest deposit")
            .description("Your top goal and the newest deposit.")
            .supportedFamilies([.systemMedium])
    }
}

@main
struct VaultWidgetsBundle: WidgetBundle {
    var body: some Widget {
        TotalWidget()
        GoalWidget()
        OverviewWidget()
    }
}

#Preview("Small", as: .systemSmall) {
    TotalWidget()
} timeline: {
    VaultProvider.mock()
}

#Preview("Medium", as: .systemMedium) {
    OverviewWidget()
} timeline: {
    VaultProvider.mock()
}
