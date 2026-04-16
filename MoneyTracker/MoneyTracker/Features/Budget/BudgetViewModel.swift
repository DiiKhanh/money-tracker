import Foundation
import Observation

// MARK: - BudgetViewModel

@Observable
final class BudgetViewModel {

    // MARK: State

    var budgetProgress: [BudgetProgress] = []
    var categories: [Category] = []
    var isLoading = false
    var error: String?

    var showAddSheet = false
    var newCategoryId: UUID?
    var newLimitText = ""

    // MARK: Computed

    var totalLimit: Decimal {
        budgetProgress.reduce(0) { $0 + $1.budget.limitAmount }
    }

    var totalSpent: Decimal {
        budgetProgress.reduce(0) { $0 + $1.spent }
    }

    var overallRatio: Double {
        guard totalLimit > 0 else { return 0 }
        return NSDecimalNumber(decimal: totalSpent / totalLimit).doubleValue
    }

    var overallStatus: BudgetStatus {
        switch overallRatio {
        case ..<0.6:    return .safe
        case 0.6..<0.8: return .moderate
        case 0.8..<1.0: return .warning
        default:        return .exceeded
        }
    }

    var availableCategories: [Category] {
        let used = Set(budgetProgress.map { $0.category.id })
        return categories.filter { $0.type == .expense && !used.contains($0.id) }
    }

    // MARK: Fetch

    func fetchAll(userId: UUID) async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let (progress, cats) = try await (
                fetchBudgetProgress(userId: userId),
                fetchCategories(userId: userId)
            )
            await MainActor.run {
                self.budgetProgress = progress
                self.categories = cats
            }
        } catch {
            await MainActor.run { self.error = error.localizedDescription }
        }
    }

    func deleteBudget(_ progress: BudgetProgress) {
        budgetProgress.removeAll { $0.id == progress.id }
    }

    func addBudget() {
        guard
            let catId = newCategoryId,
            let limit = Decimal(string: newLimitText.replacingOccurrences(of: ".", with: "")),
            limit > 0,
            let category = categories.first(where: { $0.id == catId })
        else { return }

        let cal = Calendar.current
        let budget = Budget(
            id: UUID(),
            userId: MockData.userId,
            categoryId: catId,
            walletId: nil,
            limitAmount: limit,
            period: .monthly,
            alertAt: 0.8,
            month: cal.component(.month, from: .now),
            year: cal.component(.year, from: .now),
            createdAt: .now
        )
        let progress = BudgetProgress(id: budget.id, budget: budget, category: category, spent: 0)
        budgetProgress.append(progress)

        newCategoryId = nil
        newLimitText = ""
        showAddSheet = false
    }

    // MARK: Private — Stub

    private func fetchBudgetProgress(userId: UUID) async throws -> [BudgetProgress] {
        try await Task.sleep(for: .milliseconds(300))
        return MockData.budgetProgress
    }

    private func fetchCategories(userId: UUID) async throws -> [Category] {
        MockData.categories
    }
}
