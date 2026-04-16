import Foundation

// MARK: - MockData
// Stable mock data for UI development (no Supabase required)
// All IDs are deterministic so cross-referencing (categoryId ↔ transactions) always resolves.

enum MockData {

    // MARK: - Stable IDs

    static let userId = UUID(uuidString: "A0000000-0000-0000-0000-000000000000")!

    // Wallet IDs
    static let techcombankId = UUID(uuidString: "B0000000-0000-0000-0000-000000000001")!
    static let cashId        = UUID(uuidString: "B0000000-0000-0000-0000-000000000002")!
    static let momoId        = UUID(uuidString: "B0000000-0000-0000-0000-000000000003")!

    // Expense category IDs
    static let catAnUongId    = UUID(uuidString: "C0000000-0000-0000-0001-000000000001")!
    static let catDiChuyenId  = UUID(uuidString: "C0000000-0000-0000-0001-000000000002")!
    static let catMuaSamId    = UUID(uuidString: "C0000000-0000-0000-0001-000000000003")!
    static let catHoaDonId    = UUID(uuidString: "C0000000-0000-0000-0001-000000000004")!
    static let catGiaiTriId   = UUID(uuidString: "C0000000-0000-0000-0001-000000000005")!
    static let catSucKhoeId   = UUID(uuidString: "C0000000-0000-0000-0001-000000000006")!
    // Income category IDs
    static let catLuongId     = UUID(uuidString: "C0000000-0000-0000-0002-000000000001")!
    static let catThuongId    = UUID(uuidString: "C0000000-0000-0000-0002-000000000002")!
    // Other
    static let catKhacId      = UUID(uuidString: "C0000000-0000-0000-0003-000000000001")!

    // MARK: - Wallets

    static let wallets: [Wallet] = [
        Wallet(
            id: techcombankId, userId: userId,
            name: "Techcombank", type: .bank,
            balance: 8_250_000, color: "#533483",
            icon: "building.columns.fill", isDefault: true,
            createdAt: .now, updatedAt: .now
        ),
        Wallet(
            id: cashId, userId: userId,
            name: "Tiền mặt", type: .cash,
            balance: 1_500_000, color: "#16213e",
            icon: "banknote.fill", isDefault: false,
            createdAt: .now, updatedAt: .now
        ),
        Wallet(
            id: momoId, userId: userId,
            name: "MoMo", type: .eWallet,
            balance: 350_000, color: "#00d68f",
            icon: "iphone", isDefault: false,
            createdAt: .now, updatedAt: .now
        ),
    ]

    // MARK: - Categories

    static let categories: [Category] = [
        Category(id: catAnUongId,   userId: nil, name: "Ăn uống",     icon: "fork.knife",               color: "#FF6B6B", type: .expense, isSystem: true, createdAt: .now),
        Category(id: catDiChuyenId, userId: nil, name: "Di chuyển",   icon: "car.fill",                 color: "#F5A623", type: .expense, isSystem: true, createdAt: .now),
        Category(id: catMuaSamId,   userId: nil, name: "Mua sắm",     icon: "bag.fill",                 color: "#007AFF", type: .expense, isSystem: true, createdAt: .now),
        Category(id: catHoaDonId,   userId: nil, name: "Hóa đơn",     icon: "doc.text.fill",            color: "#5E5CE6", type: .expense, isSystem: true, createdAt: .now),
        Category(id: catGiaiTriId,  userId: nil, name: "Giải trí",    icon: "popcorn.fill",             color: "#AF52DE", type: .expense, isSystem: true, createdAt: .now),
        Category(id: catSucKhoeId,  userId: nil, name: "Sức khỏe",    icon: "heart.fill",               color: "#FF375F", type: .expense, isSystem: true, createdAt: .now),
        Category(id: catLuongId,    userId: nil, name: "Lương",        icon: "banknote.fill",            color: "#00D68F", type: .income,  isSystem: true, createdAt: .now),
        Category(id: catThuongId,   userId: nil, name: "Tiền thưởng", icon: "star.fill",                color: "#FFD700", type: .income,  isSystem: true, createdAt: .now),
        Category(id: catKhacId,     userId: nil, name: "Khác",         icon: "ellipsis.circle.fill",    color: "#8E8E93", type: .both,    isSystem: true, createdAt: .now),
    ]

    // MARK: - Transactions

    static let transactions: [Transaction] = {
        let cal = Calendar.current
        let now = Date()

        func ago(_ days: Int, hour: Int = 9) -> Date {
            var comps = cal.dateComponents([.year, .month, .day], from: now)
            comps.day! -= days
            comps.hour = hour
            comps.minute = 0
            return cal.date(from: comps) ?? now
        }

        return [
            // Today
            tx(45_000,     .expense, catAnUongId,    "Bún bò sáng",         ago(0, hour: 8)),
            tx(25_000,     .expense, catDiChuyenId,  "Grab về nhà",         ago(0, hour: 18)),
            // Yesterday
            tx(139_000,    .expense, catGiaiTriId,   "Netflix",             ago(1, hour: 20)),
            tx(280_000,    .expense, catMuaSamId,    "Uniqlo áo khoác",     ago(1, hour: 15)),
            tx(15_000_000, .income,  catLuongId,     "Lương tháng 4",       ago(1, hour: 9)),
            // 3 days ago
            tx(95_000,     .expense, catAnUongId,    "Cơm văn phòng",       ago(3, hour: 12)),
            tx(50_000,     .expense, catDiChuyenId,  "Xăng xe",             ago(3, hour: 17)),
            tx(500_000,    .expense, catSucKhoeId,   "Khám bệnh",           ago(3, hour: 10)),
            // 5 days ago
            tx(199_000,    .expense, catHoaDonId,    "Spotify Premium",     ago(5, hour: 8)),
            tx(350_000,    .expense, catAnUongId,    "Ăn tối bạn bè",       ago(5, hour: 19)),
            tx(1_000_000,  .income,  catThuongId,    "Thưởng hoàn thành dự án", ago(5, hour: 9)),
            // 7 days ago
            tx(850_000,    .expense, catMuaSamId,    "Sách + văn phòng phẩm", ago(7, hour: 14)),
            tx(120_000,    .expense, catAnUongId,    "Phở sáng",            ago(7, hour: 7)),
            tx(75_000,     .expense, catDiChuyenId,  "Grab đi làm",         ago(7, hour: 8)),
            // 10 days ago
            tx(200_000,    .expense, catGiaiTriId,   "Cinema",              ago(10, hour: 20)),
            tx(45_000,     .expense, catAnUongId,    "Trà sữa",             ago(10, hour: 16)),
        ]
    }()

    // MARK: - Budgets

    static let budgets: [Budget] = {
        let cal = Calendar.current
        let month = cal.component(.month, from: .now)
        let year  = cal.component(.year,  from: .now)
        return [
            Budget(id: UUID(), userId: userId, categoryId: catAnUongId,   walletId: nil, limitAmount: 3_000_000, period: .monthly, alertAt: 0.8, month: month, year: year, createdAt: .now),
            Budget(id: UUID(), userId: userId, categoryId: catDiChuyenId, walletId: nil, limitAmount: 1_000_000, period: .monthly, alertAt: 0.8, month: month, year: year, createdAt: .now),
            Budget(id: UUID(), userId: userId, categoryId: catMuaSamId,   walletId: nil, limitAmount: 2_000_000, period: .monthly, alertAt: 0.8, month: month, year: year, createdAt: .now),
            Budget(id: UUID(), userId: userId, categoryId: catGiaiTriId,  walletId: nil, limitAmount: 500_000,   period: .monthly, alertAt: 0.8, month: month, year: year, createdAt: .now),
        ]
    }()

    // MARK: - BudgetProgress (computed from transactions)

    static var budgetProgress: [BudgetProgress] {
        budgets.compactMap { budget in
            guard let category = categories.first(where: { $0.id == budget.categoryId }) else { return nil }
            let spent = transactions
                .filter { $0.categoryId == budget.categoryId && $0.isExpense }
                .reduce(Decimal(0)) { $0 + $1.amount }
            return BudgetProgress(id: budget.id, budget: budget, category: category, spent: spent)
        }
    }

    // MARK: - Monthly Chart Data (6 months, fixed values)

    static let monthlyChartData: [MonthlyData] = [
        MonthlyData(month: 11, year: 2025, label: "T11", income: 15_000_000, expense: 7_200_000),
        MonthlyData(month: 12, year: 2025, label: "T12", income: 16_500_000, expense: 9_800_000),
        MonthlyData(month: 1,  year: 2026, label: "T1",  income: 15_000_000, expense: 6_500_000),
        MonthlyData(month: 2,  year: 2026, label: "T2",  income: 15_000_000, expense: 8_100_000),
        MonthlyData(month: 3,  year: 2026, label: "T3",  income: 17_000_000, expense: 7_600_000),
        MonthlyData(month: 4,  year: 2026, label: "T4",  income: 16_000_000, expense: 5_630_000),
    ]

    // MARK: - Category Spending (current month, for donut chart)

    static var categorySpending: [CategorySpending] {
        let expenseCategories = categories.filter { $0.type == .expense }
        return expenseCategories.compactMap { cat in
            let total = transactions
                .filter { $0.categoryId == cat.id && $0.isExpense }
                .reduce(Decimal(0)) { $0 + $1.amount }
            guard total > 0 else { return nil }
            return CategorySpending(category: cat, amount: total)
        }
        .sorted { $0.amount > $1.amount }
    }

    // MARK: - Helpers

    static func category(for transaction: Transaction) -> Category? {
        categories.first { $0.id == transaction.categoryId }
    }

    // MARK: - Private

    private static func tx(
        _ amount: Decimal,
        _ type: TransactionType,
        _ catId: UUID,
        _ note: String,
        _ date: Date,
        walletId: UUID = techcombankId
    ) -> Transaction {
        Transaction(
            id: UUID(), userId: userId,
            walletId: walletId, categoryId: catId,
            type: type, amount: amount, note: note, date: date,
            receiptUrl: nil, isRecurring: false, recurringId: nil,
            createdAt: date, updatedAt: date
        )
    }
}

// MARK: - MonthlyData

struct MonthlyData: Identifiable {
    let id = UUID()
    let month: Int
    let year: Int
    let label: String
    let income: Decimal
    let expense: Decimal

    var savings: Decimal { income - expense }
    var savingsRatio: Double {
        guard income > 0 else { return 0 }
        return NSDecimalNumber(decimal: savings / income).doubleValue
    }
}

// MARK: - CategorySpending

struct CategorySpending: Identifiable {
    let id = UUID()
    let category: Category
    let amount: Decimal
}
