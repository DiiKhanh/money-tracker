import Foundation

// MARK: - Budget

struct Budget: Identifiable, Codable, Equatable {
    let id: UUID
    let userId: UUID
    let categoryId: UUID
    var walletId: UUID?
    var limitAmount: Decimal
    var period: BudgetPeriod
    var alertAt: Double   // 0.0–1.0, default 0.8 (80%)
    var month: Int?
    var year: Int?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId      = "user_id"
        case categoryId  = "category_id"
        case walletId    = "wallet_id"
        case limitAmount = "limit_amount"
        case period
        case alertAt     = "alert_at"
        case month
        case year
        case createdAt   = "created_at"
    }

    // MARK: Computed

    var alertThreshold: Decimal { Decimal(alertAt) * limitAmount }
}

// MARK: - BudgetPeriod

enum BudgetPeriod: String, Codable, CaseIterable {
    case monthly = "monthly"
    case weekly  = "weekly"
    case yearly  = "yearly"

    var label: String {
        switch self {
        case .monthly: return "Hàng tháng"
        case .weekly:  return "Hàng tuần"
        case .yearly:  return "Hàng năm"
        }
    }
}

// MARK: - BudgetProgress
// Runtime computed model — not stored in Supabase

struct BudgetProgress: Identifiable {
    let id: UUID
    let budget: Budget
    let category: Category
    let spent: Decimal

    var ratio: Double {
        guard budget.limitAmount > 0 else { return 0 }
        return NSDecimalNumber(decimal: spent / budget.limitAmount).doubleValue
    }

    var percentageText: String { "\(Int(ratio * 100))%" }

    var status: BudgetStatus {
        switch ratio {
        case ..<0.6:   return .safe
        case 0.6..<0.8: return .moderate
        case 0.8..<1.0: return .warning
        default:        return .exceeded
        }
    }

    var remaining: Decimal { max(budget.limitAmount - spent, 0) }
}

// MARK: - BudgetStatus
// From Stitch budget screen: "Safe", "Caution", "Critical"

enum BudgetStatus {
    case safe, moderate, warning, exceeded

    var label: String {
        switch self {
        case .safe:     return "Optimal"
        case .moderate: return "Moderate"
        case .warning:  return "Caution"
        case .exceeded: return "Exceeded"
        }
    }

    var color: String {
        switch self {
        case .safe:     return "#00D68F"
        case .moderate: return "#00D68F"
        case .warning:  return "#F5A623"
        case .exceeded: return "#FF6B6B"
        }
    }
}
