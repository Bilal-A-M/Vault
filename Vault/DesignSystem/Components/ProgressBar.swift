import SwiftUI

/// A linear progress bar.
struct ProgressBar: View {
    let progress: Double
    var height: CGFloat = 8
    var tint: Color = VaultColor.accent
    var label: String = "Progress"

    @State private var shown: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(VaultColor.track)
                Capsule().fill(tint)
                    .frame(width: geo.size.width * min(max(shown, 0), 1))
            }
        }
        .frame(height: height)
        .onAppear { update(to: progress) }
        .onChange(of: progress) { _, newValue in update(to: newValue) }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue("\(Int((min(progress, 1) * 100).rounded())) percent")
    }

    private func update(to value: Double) {
        if reduceMotion {
            shown = value
        } else {
            withAnimation(VaultMotion.fill) { shown = value }
        }
    }
}

/// A bar divided between the two people in proportion to what each contributed.
struct ContributionSplitBar: View {
    let shares: [ContributionShare]
    var height: CGFloat = 12

    private var total: Int { shares.reduce(0) { $0 + max($1.cents, 0) } }

    var body: some View {
        GeometryReader { geo in
            if total == 0 {
                Capsule().fill(VaultColor.track)
            } else {
                let gap: CGFloat = 3
                let visible = shares.filter { $0.cents > 0 }
                let usable = geo.size.width - gap * CGFloat(max(visible.count - 1, 0))
                HStack(spacing: gap) {
                    ForEach(visible) { share in
                        Capsule()
                            .fill(share.person.color.color)
                            .frame(width: max(usable * CGFloat(share.cents) / CGFloat(total), 0))
                    }
                }
            }
        }
        .frame(height: height)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Contribution split")
        .accessibilityValue(accessibilitySummary)
    }

    private var accessibilitySummary: String {
        guard total > 0 else { return "No contributions yet" }
        return shares.map { share in
            let percent = Int((Double(max(share.cents, 0)) / Double(total) * 100).rounded())
            return "\(share.person.name) \(percent) percent"
        }
        .joined(separator: ", ")
    }
}
