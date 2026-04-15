import SwiftUI

// MARK: - Color Tokens
// Source: Stitch "The Sovereign Dark Aesthetic" + DESIGN.md
// Override colors from Stitch project 5944608609805261775

extension Color {
    // ── Backgrounds ──────────────────────────────────────────────
    static let bgBase          = Color(hex: "#000000") // Pure OLED black
    static let bgSurface       = Color(hex: "#131313") // Primary sections
    static let bgCard          = Color(hex: "#1F1F1F") // Cards (surface_container)
    static let bgCardHigh      = Color(hex: "#2A2A2A") // Active states
    static let bgCardHighest   = Color(hex: "#353535") // Highest elevation

    // ── Text ─────────────────────────────────────────────────────
    static let textPrimary     = Color(hex: "#E2E2E2") // on_surface
    static let textSecondary   = Color(hex: "#BACBBE") // on_surface_variant
    static let textTertiary    = Color(hex: "#859589") // outline
    static let textInverse     = Color(hex: "#303030") // inverse_on_surface

    // ── Accents ──────────────────────────────────────────────────
    static let accentGreen     = Color(hex: "#00D68F") // Income / Positive (primary override)
    static let accentGreenBright = Color(hex: "#44F3A9") // primary (gradient start)
    static let accentRed       = Color(hex: "#FF6B6B") // Expense / Negative (tertiary override)
    static let accentBlue      = Color(hex: "#007AFF") // CTA / Links (secondary override)
    static let accentBlueBright = Color(hex: "#4B8EFF") // secondary_container (nav active)
    static let accentGold      = Color(hex: "#F5A623") // Budget warning

    // ── Borders ──────────────────────────────────────────────────
    static let ghostBorder     = Color.white.opacity(0.10) // "Ghost Border" — 10%
    static let ghostBorderActive = Color.white.opacity(0.30) // Tap state
    static let separator       = Color(hex: "#3C4A41") // outline_variant

    // ── Gradients ────────────────────────────────────────────────
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "#44F3A9"), Color(hex: "#00D68F")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let incomeGradient = LinearGradient(
        colors: [Color(hex: "#00D68F").opacity(0.8), Color(hex: "#00D68F").opacity(0.2)],
        startPoint: .top,
        endPoint: .bottom
    )

    // Hex initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Spacing
enum Spacing {
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 12
    static let lg:  CGFloat = 16   // Standard horizontal padding
    static let xl:  CGFloat = 20   // Card internal
    static let xxl: CGFloat = 24   // Section gap
    static let h:   CGFloat = 32
    static let hh:  CGFloat = 40
}

// MARK: - Corner Radius
enum Radius {
    static let sm:   CGFloat = 8
    static let md:   CGFloat = 12
    static let lg:   CGFloat = 16   // Cards (min for luxury feel)
    static let xl:   CGFloat = 20   // Wallet cards
    static let xxl:  CGFloat = 28   // Large modals
    static let full: CGFloat = 999  // Pill / circle
}

// MARK: - Typography
// Source: "SF Pro Display for headers, SF Pro Rounded for numbers"
extension Font {
    // Balance hero — large number on dashboard
    static let balanceHero = Font.system(size: 48, weight: .bold, design: .rounded)

    // Section balance (wallet cards)
    static let balanceMD = Font.system(size: 28, weight: .bold, design: .rounded)

    // Transaction amount
    static let moneyAmount = Font.system(size: 20, weight: .semibold, design: .rounded)

    // Small money label
    static let moneyCaption = Font.system(size: 14, weight: .medium, design: .rounded)

    // Category label — ALL CAPS tracked out
    static let metaLabel = Font.system(size: 11, weight: .medium).uppercaseSmallCaps()
}

// MARK: - Animation
enum AppAnimation {
    static let instant  = Animation.easeInOut(duration: 0.1)
    static let fast     = Animation.easeInOut(duration: 0.2)
    static let normal   = Animation.spring(response: 0.35, dampingFraction: 0.75)
    static let slow     = Animation.spring(response: 0.5, dampingFraction: 0.8)
    static let countUp  = Animation.easeOut(duration: 0.8)
}

// MARK: - Haptics
enum Haptic {
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    static func tap() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func rigid() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }
}
