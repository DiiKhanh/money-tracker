import SwiftUI

// MARK: - Category

struct Category: Identifiable, Codable, Equatable {
    let id: UUID
    var userId: UUID?     // nil = system default
    var name: String
    var icon: String      // SF Symbol name
    var color: String     // hex string
    var type: CategoryType
    var isSystem: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId    = "user_id"
        case name
        case icon
        case color
        case type
        case isSystem  = "is_system"
        case createdAt = "created_at"
    }

    var swiftUIColor: Color { Color(hex: color) }
    var iconColor: Color { Color(hex: color) }
}

// MARK: - CategoryType

enum CategoryType: String, Codable, CaseIterable {
    case income  = "income"
    case expense = "expense"
    case both    = "both"
}

// MARK: - Default Categories
// Matches DESIGN.md and Stitch screen "Thêm giao dịch"

extension Category {
    static let defaults: [Category] = [
        // Expense categories
        Category(id: UUID(), userId: nil, name: "Ăn uống",    icon: "fork.knife",              color: "#FF6B6B", type: .expense, isSystem: true, createdAt: .now),
        Category(id: UUID(), userId: nil, name: "Di chuyển",  icon: "car.fill",                color: "#F5A623", type: .expense, isSystem: true, createdAt: .now),
        Category(id: UUID(), userId: nil, name: "Mua sắm",    icon: "bag.fill",                color: "#007AFF", type: .expense, isSystem: true, createdAt: .now),
        Category(id: UUID(), userId: nil, name: "Hóa đơn",    icon: "doc.text.fill",           color: "#5E5CE6", type: .expense, isSystem: true, createdAt: .now),
        Category(id: UUID(), userId: nil, name: "Giải trí",   icon: "popcorn.fill",            color: "#AF52DE", type: .expense, isSystem: true, createdAt: .now),
        Category(id: UUID(), userId: nil, name: "Sức khỏe",   icon: "heart.fill",              color: "#FF375F", type: .expense, isSystem: true, createdAt: .now),
        Category(id: UUID(), userId: nil, name: "Quà tặng",   icon: "gift.fill",               color: "#FF9F0A", type: .expense, isSystem: true, createdAt: .now),
        Category(id: UUID(), userId: nil, name: "Gia đình",   icon: "house.fill",              color: "#5AC8FA", type: .expense, isSystem: true, createdAt: .now),
        Category(id: UUID(), userId: nil, name: "Giáo dục",   icon: "book.fill",               color: "#30D158", type: .expense, isSystem: true, createdAt: .now),
        // Income categories
        Category(id: UUID(), userId: nil, name: "Lương",       icon: "banknote.fill",           color: "#00D68F", type: .income,  isSystem: true, createdAt: .now),
        Category(id: UUID(), userId: nil, name: "Tiền thưởng", icon: "star.fill",              color: "#00D68F", type: .income,  isSystem: true, createdAt: .now),
        Category(id: UUID(), userId: nil, name: "Đầu tư",      icon: "chart.line.uptrend.xyaxis", color: "#00D68F", type: .income, isSystem: true, createdAt: .now),
        // Both
        Category(id: UUID(), userId: nil, name: "Khác",        icon: "ellipsis.circle.fill",   color: "#8E8E93", type: .both,    isSystem: true, createdAt: .now),
    ]
}

// MARK: - SF Symbol Mapping (from Stitch screen)

extension Category {
    /// Maps Stitch Material Icon names → SF Symbol equivalents
    static let materialToSFSymbol: [String: String] = [
        "restaurant":         "fork.knife",
        "commute":            "car.fill",
        "shopping_bag":       "bag.fill",
        "payments":           "doc.text.fill",
        "theater_comedy":     "popcorn.fill",
        "medical_services":   "heart.fill",
        "redeem":             "gift.fill",
        "monetization_on":    "banknote.fill",
        "more_horiz":         "ellipsis.circle.fill",
        "theaters":           "film.fill",
    ]
}
