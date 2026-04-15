import SwiftUI

// MARK: - CategoryIconView
// Circular icon with 20% opacity background — from DESIGN.md & Stitch design

struct CategoryIconView: View {
    let symbol: String
    let color: Color
    var size: CGFloat = 40

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.45, weight: .medium))
            .foregroundStyle(color)
            .frame(width: size, height: size)
            .background(color.opacity(0.18))
            .clipShape(Circle())
    }
}

// MARK: - CategoryIconView from Category model

extension CategoryIconView {
    init(category: Category, size: CGFloat = 40) {
        self.symbol = category.icon
        self.color = category.swiftUIColor
        self.size = size
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 12) {
        CategoryIconView(symbol: "fork.knife", color: .accentRed)
        CategoryIconView(symbol: "car.fill", color: .accentGold)
        CategoryIconView(symbol: "banknote.fill", color: .accentGreen)
        CategoryIconView(symbol: "bag.fill", color: .accentBlue)
    }
    .padding()
    .background(Color.bgBase)
}
