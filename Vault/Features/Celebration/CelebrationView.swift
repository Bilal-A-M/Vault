import SwiftUI

/// Full-screen milestone moment. 25/50/75% are a quiet shower; 100% is a
/// bigger burst with a pulsing ring. Reduce Motion gets a still version.
struct CelebrationView: View {
    let celebration: Celebration
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    private var isComplete: Bool { celebration.milestone == .complete }
    private var goal: Goal { celebration.goal }

    var body: some View {
        ZStack {
            VaultColor.background.ignoresSafeArea()
            RadialGradient(colors: [VaultColor.progress.opacity(isComplete ? 0.22 : 0.12), .clear],
                           center: .center, startRadius: 10, endRadius: 360)
                .ignoresSafeArea()
                .accessibilityHidden(true)
            ConfettiView(count: isComplete ? 140 : 50, animated: !reduceMotion)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 26) {
                Spacer()
                ZStack {
                    Circle().stroke(VaultColor.track, lineWidth: 12)
                    Circle()
                        .trim(from: 0, to: appeared ? celebration.milestone.fraction : 0)
                        .stroke(VaultColor.progress, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    if isComplete {
                        Image(systemName: "checkmark").font(.system(size: 64, weight: .bold)).foregroundStyle(VaultColor.progress)
                    } else {
                        Text(celebration.milestone.label).moneyFont(.large).foregroundStyle(VaultColor.textPrimary)
                    }
                }
                .frame(width: 190, height: 190)
                .scaleEffect(isComplete && appeared && !reduceMotion ? 1.04 : 1)
                .accessibilityHidden(true)

                VStack(spacing: 10) {
                    Text(headline).font(.largeTitle.bold()).multilineTextAlignment(.center)
                    MoneyText(cents: celebration.savedCents, style: .large, fraction: .never)
                        .foregroundStyle(VaultColor.progress)
                    Text(subline).font(.body).foregroundStyle(VaultColor.textSecondary).multilineTextAlignment(.center)
                }
                .foregroundStyle(VaultColor.textPrimary)

                VStack(spacing: 12) {
                    ContributionBar(shares: celebration.shares)
                    HStack {
                        ForEach(celebration.shares) { share in
                            HStack(spacing: 7) {
                                Circle().fill(share.person.color.solid).frame(width: 8, height: 8)
                                Text(share.person.name)
                                MoneyText(cents: share.cents, style: .row, fraction: .never).foregroundStyle(VaultColor.textSecondary)
                            }
                            if share.id != celebration.shares.last?.id { Spacer() }
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(VaultColor.textPrimary)
                }
                .vaultCard(padding: 16)

                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.vaultPrimary)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
        }
        .onAppear {
            if reduceMotion {
                appeared = true
            } else {
                withAnimation(.easeOut(duration: 1.1)) { appeared = true }
            }
        }
        .sensoryFeedback(.success, trigger: appeared)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(headline)
    }

    private var headline: String {
        switch celebration.milestone {
        case .complete: "\(goal.name) is fully funded"
        case .threeQuarters: "\(goal.name) passed three quarters"
        case .half: "Halfway to \(goal.name)"
        case .quarter: "A quarter of the way to \(goal.name)"
        }
    }

    private var subline: String {
        if isComplete {
            return "You saved it together in \(celebration.months) month\(celebration.months == 1 ? "" : "s")."
        }
        let remaining = max(0, goal.targetCents - celebration.savedCents)
        return "\(Money.format(cents: remaining, fraction: .never)) to go. Keep it up, together."
    }
}

/// Lightweight confetti: lime, platinum and the two person colours, drawn in
/// a Canvas. Static when Reduce Motion is on.
struct ConfettiView: View {
    let count: Int
    let animated: Bool
    @State private var start = Date.now

    private struct Piece {
        let x: Double, delay: Double, speed: Double, spin: Double, size: CGSize, color: Color
    }

    private let pieces: [Piece]

    init(count: Int, animated: Bool) {
        self.count = count
        self.animated = animated
        let palette: [Color] = [VaultColor.progress, Color(hex: 0xD9DDE3), Color(hex: 0x8FD3E0), Color(hex: 0xE9B3B9)]
        var generator = SystemRandomNumberGenerator()
        pieces = (0..<count).map { index in
            Piece(x: Double.random(in: 0...1, using: &generator),
                  delay: Double.random(in: 0...1.2, using: &generator),
                  speed: Double.random(in: 0.18...0.35, using: &generator),
                  spin: Double.random(in: -3...3, using: &generator),
                  size: CGSize(width: Double.random(in: 4...9, using: &generator), height: Double.random(in: 8...14, using: &generator)),
                  color: palette[index % palette.count])
        }
    }

    var body: some View {
        TimelineView(.animation(paused: !animated)) { timeline in
            Canvas { context, size in
                let elapsed = animated ? timeline.date.timeIntervalSince(start) : 1.6
                for piece in pieces {
                    let t = max(0, elapsed - piece.delay)
                    let y = animated ? -20 + t * piece.speed * size.height : piece.x * size.height * 0.6
                    guard y < size.height + 20 else { continue }
                    var pieceContext = context
                    pieceContext.translateBy(x: piece.x * size.width + sin(t * 2 + piece.spin) * 12, y: y)
                    pieceContext.rotate(by: .radians(t * piece.spin))
                    pieceContext.opacity = animated ? max(0, 1 - t / 5) : 0.8
                    pieceContext.fill(Path(roundedRect: CGRect(origin: CGPoint(x: -piece.size.width / 2, y: -piece.size.height / 2),
                                                               size: piece.size), cornerRadius: 1.5),
                                      with: .color(piece.color))
                }
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    CelebrationView(celebration: Celebration(goal: MockData.emergency, milestone: .complete, savedCents: 1_000_000,
                                             shares: VaultMath.shares(MockData.entries, people: MockData.people), months: 7))
        .preferredColorScheme(.dark)
}
