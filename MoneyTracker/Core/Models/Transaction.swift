import Foundation

// MARK: - Transaction

struct Transaction: Identifiable, Codable, Equatable {
    let id: UUID
    let userId: UUID
    let walletId: UUID
    let categoryId: UUID
    var type: TransactionType
    var amount: Decimal
    var note: String?
    var date: Date
    var receiptUrl: String?
    var isRecurring: Bool
    var recurringId: UUID?
    let createdAt: Date
    var updatedAt: Date

    // MARK: Codable mapping (snake_case ↔ camelCase)
    enum CodingKeys: String, CodingKey {
        case id
        case userId       = "user_id"
        case walletId     = "wallet_id"
        case categoryId   = "category_id"
        case type
        case amount
        case note
        case date
        case receiptUrl   = "receipt_url"
        case isRecurring  = "is_recurring"
        case recurringId  = "recurring_id"
        case createdAt    = "created_at"
        case updatedAt    = "updated_at"
    }

    // MARK: Helpers

    var isIncome: Bool { type == .income }
    var isExpense: Bool { type == .expense }

    /// Sign-adjusted amount: positive for income, negative for expense
    var signedAmount: Decimal { isIncome ? amount : -amount }
}

// MARK: - TransactionType

enum TransactionType: String, Codable, CaseIterable {
    case income  = "income"
    case expense = "expense"

    var label: String {
        switch self {
        case .income:  return "Thu nhập"
        case .expense: return "Chi tiêu"
        }
    }

    var sfSymbol: String {
        switch self {
        case .income:  return "arrow.down.circle.fill"
        case .expense: return "arrow.up.circle.fill"
        }
    }
}

// MARK: - Decimal Formatting

extension Decimal {
    /// "1.250.000 ₫"
    var formattedVND: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = 0
        let number = NSDecimalNumber(decimal: self)
        return (formatter.string(from: number) ?? "0") + " ₫"
    }

    /// "12.5M ₫" — compact for small spaces
    var formattedCompact: String {
        let billion: Decimal = 1_000_000_000
        let million: Decimal = 1_000_000
        let thousand: Decimal = 1_000

        if self >= billion {
            let v = NSDecimalNumber(decimal: self / billion).doubleValue
            return String(format: "%.1fB ₫", v)
        } else if self >= million {
            let v = NSDecimalNumber(decimal: self / million).doubleValue
            return String(format: "%.1fM ₫", v)
        } else if self >= thousand {
            let v = NSDecimalNumber(decimal: self / thousand).doubleValue
            return String(format: "%.0fk ₫", v)
        }
        return formattedVND
    }

    /// "+12.500.000 ₫" or "-450.000 ₫"
    var formattedSigned: String {
        self >= 0 ? "+\(formattedVND)" : "-\(abs(self).formattedVND)"
    }
}
