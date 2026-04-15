import Foundation
import Observation

// MARK: - AddTransactionViewModel

@Observable
final class AddTransactionViewModel {

    // MARK: Form State

    var selectedType: TransactionType = .expense
    var amountText: String = ""
    var selectedCategoryId: UUID? = nil
    var selectedWalletId: UUID? = nil
    var selectedDate: Date = .now
    var note: String = ""

    // MARK: Data

    var categories: [Category] = []
    var wallets: [Wallet] = []

    // MARK: UI State

    var isSaving = false
    var error: String? = nil

    // MARK: Computed

    var amount: Decimal? {
        guard !amountText.isEmpty else { return nil }
        let cleaned = amountText.replacingOccurrences(of: ".", with: "")
        return Decimal(string: cleaned)
    }

    var isFormValid: Bool {
        guard let amt = amount, amt > 0 else { return false }
        return selectedCategoryId != nil && selectedWalletId != nil
    }

    /// Filtered by selected type + "both"
    var filteredCategories: [Category] {
        categories.filter {
            $0.type.rawValue == selectedType.rawValue || $0.type == .both
        }
    }

    // MARK: Format amount while typing

    func formatAmountInput(_ raw: String) {
        let digits = raw.filter { $0.isNumber }
        guard let number = Int(digits) else {
            amountText = ""
            return
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        amountText = formatter.string(from: NSNumber(value: number)) ?? digits
    }

    // MARK: Load

    func loadInitialData(userId: UUID) async {
        async let catsTask     = fetchCategories(userId: userId)
        async let walletsTask  = fetchWallets(userId: userId)

        do {
            let (cats, wallets) = try await (catsTask, walletsTask)
            await MainActor.run {
                self.categories = cats
                self.wallets = wallets
                self.selectedWalletId = wallets.first(where: { $0.isDefault })?.id ?? wallets.first?.id
                self.selectedCategoryId = filteredCategories.first?.id
            }
        } catch {
            await MainActor.run { self.error = error.localizedDescription }
        }
    }

    // MARK: Save

    @discardableResult
    func save(userId: UUID) async -> Bool {
        guard
            let amt = amount,
            let categoryId = selectedCategoryId,
            let walletId = selectedWalletId
        else { return false }

        isSaving = true
        defer { isSaving = false }

        // Stub: Supabase disabled
        return true
    }

    // MARK: Private — Stub (Supabase disabled)

    private func fetchCategories(userId: UUID) async throws -> [Category] { [] }

    private func fetchWallets(userId: UUID) async throws -> [Wallet] { [] }
}
