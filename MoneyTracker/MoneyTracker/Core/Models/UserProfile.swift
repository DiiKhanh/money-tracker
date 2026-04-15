import Foundation

// MARK: - UserProfile

struct UserProfile: Identifiable, Codable, Equatable {
    let id: UUID
    var displayName: String?
    var avatarUrl: String?
    var currency: String
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case avatarUrl   = "avatar_url"
        case currency
        case createdAt   = "created_at"
        case updatedAt   = "updated_at"
    }

    var initials: String {
        guard let name = displayName, !name.isEmpty else { return "?" }
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}
