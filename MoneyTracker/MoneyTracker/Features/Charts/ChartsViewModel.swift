import Foundation
import Observation

// MARK: - ChartsViewModel

@Observable
final class ChartsViewModel {

    // MARK: State

    var monthlyData: [MonthlyData] = []
    var categorySpending: [CategorySpending] = []
    var selectedChart: ChartTab = .spending
    var isLoading = false
    var error: String?

    // MARK: Computed

    var currentMonthData: MonthlyData? { monthlyData.last }

    var currentIncome: Decimal  { currentMonthData?.income  ?? 0 }
    var currentExpense: Decimal { currentMonthData?.expense ?? 0 }
    var currentSavings: Decimal { currentMonthData?.savings ?? 0 }

    var savingsRatioText: String {
        let ratio = currentMonthData?.savingsRatio ?? 0
        return String(format: "%.0f%%", ratio * 100)
    }

    // Top 5 spending categories for donut chart
    var topCategorySpending: [CategorySpending] {
        Array(categorySpending.prefix(5))
    }

    var totalCategorySpend: Decimal {
        categorySpending.reduce(0) { $0 + $1.amount }
    }

    // MARK: Fetch

    func fetchAll(userId: UUID) async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let (monthly, catSpend) = try await (
                fetchMonthlyData(userId: userId),
                fetchCategorySpending(userId: userId)
            )
            await MainActor.run {
                self.monthlyData = monthly
                self.categorySpending = catSpend
            }
        } catch {
            await MainActor.run { self.error = error.localizedDescription }
        }
    }

    // MARK: Private — Stub

    private func fetchMonthlyData(userId: UUID) async throws -> [MonthlyData] {
        try await Task.sleep(for: .milliseconds(350))
        return MockData.monthlyChartData
    }

    private func fetchCategorySpending(userId: UUID) async throws -> [CategorySpending] {
        MockData.categorySpending
    }
}

// MARK: - ChartTab

enum ChartTab: String, CaseIterable {
    case spending  = "Chi tiêu"
    case income    = "Thu nhập"
    case compare   = "So sánh"
}
