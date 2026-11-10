import Foundation

struct Goal: Identifiable, Hashable {
    let id: UUID
    var name: String
    var emoji: String
    var targetCents: Int
    var targetDate: Date?
    var createdAt: Date

    init(id: UUID = UUID(), name: String, emoji: String, targetCents: Int,
         targetDate: Date? = nil, createdAt: Date = .now) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.targetCents = targetCents
        self.targetDate = targetDate
        self.createdAt = createdAt
    }

    /// 0...1 (can exceed 1 when over-funded). The saved amount is passed in
    /// because it is derived from deposits, not stored on the goal.
    func progress(savedCents: Int) -> Double {
        guard targetCents > 0 else { return 0 }
        return max(0, Double(savedCents) / Double(targetCents))
    }
}

/// The four points at which a goal celebrates.
enum Milestone: Int, CaseIterable, Identifiable, Hashable {
    case quarter = 25, half = 50, threeQuarters = 75, complete = 100

    var id: Int { rawValue }
    var fraction: Double { Double(rawValue) / 100 }
    var label: String { "\(rawValue)%" }

    /// Milestones reached at a given progress (0...1).
    static func earned(at progress: Double) -> [Milestone] {
        allCases.filter { progress >= $0.fraction }
    }
}
