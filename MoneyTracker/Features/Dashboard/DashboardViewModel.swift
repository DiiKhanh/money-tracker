import Foundation
import Observation

// MARK: - DashboardViewModel
// Drives Dashboard screen — from Stitch: balance hero, wallet cards, recent transactions, budget bars

@Observable
final class DashboardViewModel {

    // MARK: State

    var wallets: [Wallet] = []
    var recentTransactions: [Transaction] = []
    var categories: [Category] = []
    var budgetProgress: [BudgetProgress] = []
    var selectedWalletId: UUID? = nil

    var isLoading = false
    var error: String? = nil

    // Displayed period
    var displayMonth: Int = Calendar.current.component(.month, from: .now)
    var displayYear: Int  = Calendar.current.component(.year,  from: .now)

    // MARK: Computed

    var selectedWallet: Wallet? {
        guard let id = selectedWalletId else { return nil }
        return wallets.first { $0.id == id }
    }

    var totalBalance: Decimal {
        wallets.reduce(0) { $0 + $1.balance }
    }

    var monthlyIncome: Decimal {
        recentTransactions
            .filter { $0.isIncome && isInCurrentMonth($0.date) }
            .reduce(0) { $0 + $1.amount }
    }

    var monthlyExpense: Decimal {
        recentTransactions
            .filter { $0.isExpense && isInCurrentMonth($0.date) }
            .reduce(0) { $0 + $1.amount }
    }

    var periodLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "MMMM yyyy"
        var components = DateComponents()
        components.month = displayMonth
        components.year = displayYear
        let date = Calendar.current.date(from: components) ?? .now
        return formatter.string(from: date).capitalized
    }

    // MARK: Fetch

    func fetchAll(userId: UUID) async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        async let walletsTask      = fetchWallets(userId: userId)
        async let transactionsTask = fetchRecentTransactions(userId: userId)
        async let categoriesTask   = fetchCategories(userId: userId)

        do {
            let (w, t, c) = try await (walletsTask, transactionsTask, categoriesTask)
            await MainActor.run {
                self.wallets = w
                self.recentTransactions = t
                self.categories = c
                if self.selectedWalletId == nil {
                    self.selectedWalletId = w.first(where: { $0.isDefault })?.id ?? w.first?.id
                }
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
        }
    }

    // MARK: Private — Supabase calls

    private func fetchWallets(userId: UUID) async throws -> [Wallet] {
        try await supabase
            .from("wallets")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("is_default", ascending: false)
            .execute()
            .value
    }

    private func fetchRecentTransactions(userId: UUID) async throws -> [Transaction] {
        try await supabase
            .from("transactions")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("date", ascending: false)
            .order("created_at", ascending: false)
            .limit(20)
            .execute()
            .value
    }

    private func fetchCategories(userId: UUID) async throws -> [Category] {
        try await supabase
            .from("categories")
            .select()
            .or("user_id.is.null,user_id.eq.\(userId.uuidString)")
            .execute()
            .value
    }

    // MARK: Helpers

    func category(for transaction: Transaction) -> Category? {
        categories.first { $0.id == transaction.categoryId }
    }

    func wallet(for transaction: Transaction) -> Wallet? {
        wallets.first { $0.id == transaction.walletId }
    }

    private func isInCurrentMonth(_ date: Date) -> Bool {
        let cal = Calendar.current
        let now = Date()
        return cal.component(.month, from: date) == cal.component(.month, from: now)
            && cal.component(.year, from: date)  == cal.component(.year,  from: now)
    }
}
