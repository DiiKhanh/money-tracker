import SwiftUI

// MARK: - Wallet

struct Wallet: Identifiable, Codable, Equatable {
    let id: UUID
    let userId: UUID
    var name: String
    var type: WalletType
    var balance: Decimal
    var color: String
    var icon: String
    var isDefault: Bool
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId    = "user_id"
        case name
        case type
        case balance
        case color
        case icon
        case isDefault = "is_default"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var swiftUIColor: Color { Color(hex: color) }

    var gradientColors: [Color] {
        WalletType.gradientColors(for: type)
    }
}

// MARK: - WalletType
// Matches Stitch dashboard: Techcombank (bank), Tiền mặt (cash)

enum WalletType: String, Codable, CaseIterable {
    case cash        = "cash"
    case bank        = "bank"
    case creditCard  = "credit_card"
    case eWallet     = "e_wallet"

    enum CodingKeys: String, CodingKey {
        case cash, bank
        case creditCard = "credit_card"
        case eWallet    = "e_wallet"
    }

    var label: String {
        switch self {
        case .cash:       return "Tiền mặt"
        case .bank:       return "Ngân hàng"
        case .creditCard: return "Thẻ tín dụng"
        case .eWallet:    return "Ví điện tử"
        }
    }

    var sfSymbol: String {
        switch self {
        case .cash:       return "banknote.fill"
        case .bank:       return "building.columns.fill"
        case .creditCard: return "creditcard.fill"
        case .eWallet:    return "iphone"
        }
    }

    /// Wallet card gradients — from DESIGN.md
    static func gradientColors(for type: WalletType) -> [Color] {
        switch type {
        case .cash:       return [Color(hex: "#1a1a2e"), Color(hex: "#16213e")]
        case .bank:       return [Color(hex: "#0f3460"), Color(hex: "#533483")]
        case .creditCard: return [Color(hex: "#1a1a2e"), Color(hex: "#e94560")]
        case .eWallet:    return [Color(hex: "#0d0d0d"), Color(hex: "#00d68f")]
        }
    }
}

// MARK: - WalletCardViewModel
// Used by the horizontal scroll in Dashboard

struct WalletCardData: Identifiable {
    let id: UUID
    let wallet: Wallet
    var isSelected: Bool
}
