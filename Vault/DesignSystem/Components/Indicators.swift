import SwiftUI

/// Lime progress ring, drawn clockwise from 12 o'clock. Fills on appear.
struct ProgressRing<Center: View>: View {
    let progress: Double
    var lineWidth: CGFloat = 4
    var label: String
    @ViewBuilder var center: Center

    @State private var shown = 0.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Circle().stroke(VaultColor.track, lineWidth: lineWidth)
            if progress >= 1 {
                Circle().fill(VaultColor.progress.opacity(0.08))
            }
            Circle()
                .trim(from: 0, to: min(max(shown, 0), 1))
                .stroke(VaultColor.progress, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            center
        }
        .padding(lineWidth / 2)
        .aspectRatio(1, contentMode: .fit)
        .onAppear { update(progress) }
        .onChange(of: progress) { _, value in update(value) }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(progress >= 1 ? "Goal reached" : "\(Int((progress * 100).rounded())) percent")
    }

    private func update(_ value: Double) {
        if reduceMotion { shown = value } else { withAnimation(.easeOut(duration: 0.9)) { shown = value } }
    }
}

/// Goal icon inside a ring; a check when the goal is reached.
struct GoalRing: View {
    let goal: Goal
    let progress: Double
    var size: CGFloat = 60
    var lineWidth: CGFloat = 4

    var body: some View {
        ProgressRing(progress: progress, lineWidth: lineWidth, label: goal.name) {
            Image(systemName: progress >= 1 ? "checkmark" : goal.icon.symbol)
                .font(.system(size: size * 0.32, weight: progress >= 1 ? .bold : .regular))
                .foregroundStyle(progress >= 1 ? VaultColor.progress : VaultColor.textPrimary)
        }
        .frame(width: size, height: size)
    }
}

/// The two-person split, in each person's colour.
struct ContributionBar: View {
    let shares: [ContributionShare]
    var height: CGFloat = 8

    private var total: Int { shares.reduce(0) { $0 + max($1.cents, 0) } }

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 3) {
                if total == 0 {
                    Capsule().fill(VaultColor.track)
                } else {
                    let visible = shares.filter { $0.cents > 0 }
                    let usable = geo.size.width - 3 * CGFloat(max(visible.count - 1, 0))
                    ForEach(visible) { share in
                        Capsule()
                            .fill(share.person.color.gradient)
                            .frame(width: usable * CGFloat(share.cents) / CGFloat(total))
                    }
                }
            }
        }
        .frame(height: height)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Contribution split")
        .accessibilityValue(shares.map { share in
            let pct = total > 0 ? Int((Double(max(share.cents, 0)) / Double(total) * 100).rounded()) : 0
            return "\(share.person.name) \(pct) percent"
        }.joined(separator: ", "))
    }
}

/// Lime pill for a milestone. `fresh` marks one not yet seen on this phone.
struct MilestoneBadge: View {
    let milestone: Milestone
    var earned = true
    var fresh = false

    var body: some View {
        HStack(spacing: 3) {
            if fresh { Image(systemName: "star.fill").font(.caption2) }
            Text(milestone.label).monospacedDigit()
        }
        .font(.caption.weight(fresh ? .bold : .semibold))
        .foregroundStyle(fresh ? VaultColor.onProgress : (earned ? VaultColor.progress : VaultColor.textTertiary))
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background {
            if fresh {
                Capsule().fill(VaultColor.progress)
            } else if earned {
                Capsule().fill(VaultColor.progress.opacity(0.14))
            } else {
                Capsule().strokeBorder(VaultColor.separator, lineWidth: 1)
            }
        }
        .accessibilityLabel("\(milestone.rawValue) percent milestone, \(earned ? (fresh ? "new" : "reached") : "not reached")")
    }
}

/// Outlined "New" tag on the partner's unseen entries.
struct NewTag: View {
    var body: some View {
        Text("New")
            .font(.caption.weight(.semibold))
            .foregroundStyle(VaultColor.textPrimary)
            .padding(.horizontal, 7)
            .padding(.vertical, 1)
            .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(VaultColor.accent.opacity(0.45), lineWidth: 1))
    }
}

/// "Synced · just now" pill on the metal card.
struct SyncPill: View {
    let status: SyncStatus
    let partnerName: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.footnote)
        .foregroundStyle(Color(hex: 0xE8EAED))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.black.opacity(0.28), in: Capsule())
        .overlay(Capsule().strokeBorder(Color.white.opacity(0.14), lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var icon: String {
        switch status {
        case .synced: "checkmark.icloud"
        case .syncing: "arrow.triangle.2.circlepath.icloud"
        case .offline: "icloud.slash"
        }
    }

    private var text: String {
        switch status {
        case .synced(let date): "Synced · \(Self.relative(date))"
        case .syncing: "Syncing…"
        case .offline(let date): "Synced \(Self.relative(date))"
        }
    }

    private var accessibilityText: String {
        switch status {
        case .synced(let date): "Synced with \(partnerName) \(Self.relative(date))"
        case .syncing: "Syncing with \(partnerName)"
        case .offline(let date): "Offline. Last synced \(Self.relative(date))"
        }
    }

    static func relative(_ date: Date) -> String {
        let seconds = Date.now.timeIntervalSince(date)
        if seconds < 60 { return "just now" }
        if seconds < 3600 { return "\(Int(seconds / 60))m ago" }
        if seconds < 86_400 { return "\(Int(seconds / 3600))h ago" }
        return date.formatted(.dateTime.month(.abbreviated).day())
    }
}

/// Pulsing placeholder block for loading states.
struct SkeletonBlock: View {
    var height: CGFloat
    var width: CGFloat? = nil
    var radius: CGFloat = 10
    @State private var dim = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(VaultColor.raised)
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil, alignment: .leading)
            .opacity(dim ? 0.55 : 1)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) { dim = true }
            }
            .accessibilityHidden(true)
    }
}
