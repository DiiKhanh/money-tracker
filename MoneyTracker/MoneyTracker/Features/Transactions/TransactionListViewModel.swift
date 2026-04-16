import Foundation
import Observation

// MARK: - TransactionListViewModel

@Observable
final class TransactionListViewModel {

    // MARK: State

    var transactions: [Transaction] = []
    var categories: [Category] = []
    var wallets: [Wallet] = []
    var searchText = ""
    var selectedFilter: TransactionFilter = .all
    var isLoading = false
    var error: String?

    // MARK: Computed — filtered list

    var filtered: [Transaction] {
        var result = transactions

        switch selectedFilter {
        case .all:     break
        case .income:  result = result.filter { $0.isIncome }
        case .expense: result = result.filter { $0.isExpense }
        }

        if !searchText.isEmpty {
            let q = searchText.lowercased()
            result = result.filter {
                ($0.note?.lowercased().contains(q) ?? false)
                || (category(for: $0)?.name.lowercased().contains(q) ?? false)
            }
        }

        return result.sorted { $0.date > $1.date }
    }

    // Grouped by calendar day (most recent first)
    var groupedByDay: [(date: Date, transactions: [Transaction])] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: filtered) { tx in
            cal.startOfDay(for: tx.date)
        }
        return grouped
            .sorted { $0.key > $1.key }
            .map { (date: $0.key, transactions: $0.value.sorted { $0.date > $1.date }) }
    }

    var totalIncome: Decimal {
        transactions.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
    }

    var totalExpense: Decimal {
        transactions.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
    }

    // MARK: Fetch

    func fetchAll(userId: UUID) async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let (t, c, w) = try await (
                fetchTransactions(userId: userId),
                fetchCategories(userId: userId),
                fetchWallets(userId: userId)
            )
            await MainActor.run {
                self.transactions = t
                self.categories   = c
                self.wallets      = w
            }
        } catch {
            await MainActor.run { self.error = error.localizedDescription }
        }
    }

    func delete(_ transaction: Transaction) {
        transactions.removeAll { $0.id == transaction.id }
    }

    // MARK: Helpers

    func category(for tx: Transaction) -> Category? {
        categories.first { $0.id == tx.categoryId }
    }

    func wallet(for tx: Transaction) -> Wallet? {
        wallets.first { $0.id == tx.walletId }
    }

    // MARK: Private — Stub (Supabase disabled)

    private func fetchTransactions(userId: UUID) async throws -> [Transaction] {
        try await Task.sleep(for: .milliseconds(400))
        return MockData.transactions
    }

    private func fetchCategories(userId: UUID) async throws -> [Category] {
        MockData.categories
    }

    private func fetchWallets(userId: UUID) async throws -> [Wallet] {
        MockData.wallets
    }
}

// MARK: - TransactionFilter

enum TransactionFilter: String, CaseIterable {
    case all     = "Tất cả"
    case income  = "Thu nhập"
    case expense = "Chi tiêu"
}
