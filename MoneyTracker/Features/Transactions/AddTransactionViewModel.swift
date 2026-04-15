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
            $0.type == selectedType || $0.type == .both
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

        let payload = TransactionPayload(
            userId: userId,
            walletId: walletId,
            categoryId: categoryId,
            type: selectedType.rawValue,
            amount: amt,
            note: note.isEmpty ? nil : note,
            date: ISO8601DateFormatter().string(from: selectedDate)
        )

        do {
            try await supabase
                .from("transactions")
                .insert(payload)
                .execute()
            return true
        } catch {
            await MainActor.run { self.error = error.localizedDescription }
            return false
        }
    }

    // MARK: Private

    private func fetchCategories(userId: UUID) async throws -> [Category] {
        try await supabase
            .from("categories")
            .select()
            .or("user_id.is.null,user_id.eq.\(userId.uuidString)")
            .order("name")
            .execute()
            .value
    }

    private func fetchWallets(userId: UUID) async throws -> [Wallet] {
        try await supabase
            .from("wallets")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("is_default", ascending: false)
            .execute()
            .value
    }
}

// MARK: - TransactionPayload (insert shape)

private struct TransactionPayload: Encodable {
    let userId: UUID
    let walletId: UUID
    let categoryId: UUID
    let type: String
    let amount: Decimal
    let note: String?
    let date: String

    enum CodingKeys: String, CodingKey {
        case userId     = "user_id"
        case walletId   = "wallet_id"
        case categoryId = "category_id"
        case type, amount, note, date
    }
}
