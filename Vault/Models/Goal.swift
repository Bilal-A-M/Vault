import Foundation

struct Goal: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var icon: GoalIcon
    var targetCents: Int
    var targetDate: Date?
    var createdAt: Date

    init(id: UUID = UUID(), name: String, icon: GoalIcon, targetCents: Int,
         targetDate: Date? = nil, createdAt: Date = .now) {
        self.id = id
        self.name = name
        self.icon = icon
        self.targetCents = targetCents
        self.targetDate = targetDate
        self.createdAt = createdAt
    }
}

/// Goals are told apart by icon, never by colour (see DESIGN.md).
enum GoalIcon: String, CaseIterable, Identifiable, Codable {
    case plane, house, shield, car, gift, heart, graduation, bag, stroller, paw, laptop, star

    var id: String { rawValue }

    /// SF Symbol name.
    var symbol: String {
        switch self {
        case .plane: "airplane"
        case .house: "house"
        case .shield: "shield"
        case .car: "car"
        case .gift: "gift"
        case .heart: "heart"
        case .graduation: "graduationcap"
        case .bag: "bag"
        case .stroller: "stroller"
        case .paw: "pawprint"
        case .laptop: "laptopcomputer"
        case .star: "star"
        }
    }

    var label: String {
        switch self {
        case .plane: "Travel"
        case .house: "Home"
        case .shield: "Safety net"
        case .car: "Car"
        case .gift: "Gift"
        case .heart: "Wedding or anniversary"
        case .graduation: "Education"
        case .bag: "Shopping"
        case .stroller: "Baby"
        case .paw: "Pet"
        case .laptop: "Tech"
        case .star: "Something special"
        }
    }
}

/// The four points at which a goal celebrates.
enum Milestone: Int, CaseIterable, Identifiable, Codable, Comparable {
    case quarter = 25, half = 50, threeQuarters = 75, complete = 100

    var id: Int { rawValue }
    var fraction: Double { Double(rawValue) / 100 }
    var label: String { "\(rawValue)%" }

    static func < (lhs: Milestone, rhs: Milestone) -> Bool { lhs.rawValue < rhs.rawValue }

    /// Milestones reached at a given progress (0...1+).
    static func earned(at progress: Double) -> [Milestone] {
        allCases.filter { progress >= $0.fraction }
    }
}
