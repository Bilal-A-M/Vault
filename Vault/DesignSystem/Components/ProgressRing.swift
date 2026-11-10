import SwiftUI

/// A circular progress indicator, the app's signature shape (it echoes the
/// vault dial in the icon). Fills from 12 o'clock when it appears.
struct ProgressRing<Center: View>: View {
    private let progress: Double
    private let lineWidth: CGFloat
    private let tint: Color
    private let label: String
    private let center: Center

    @State private var shown: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - progress: 0...1. Values above 1 draw as a full ring.
    ///   - label: what the ring measures, read by VoiceOver (e.g. "Vacation progress").
    init(progress: Double, lineWidth: CGFloat = 10, tint: Color = VaultColor.accent,
         label: String = "Progress", @ViewBuilder center: () -> Center) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.tint = tint
        self.label = label
        self.center = center()
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(VaultColor.track, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(shown, 0), 1))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            center
        }
        // Keep the stroke inside the view's frame.
        .padding(lineWidth / 2)
        .aspectRatio(1, contentMode: .fit)
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

extension ProgressRing where Center == EmptyView {
    init(progress: Double, lineWidth: CGFloat = 10, tint: Color = VaultColor.accent,
         label: String = "Progress") {
        self.init(progress: progress, lineWidth: lineWidth, tint: tint, label: label) { EmptyView() }
    }
}
