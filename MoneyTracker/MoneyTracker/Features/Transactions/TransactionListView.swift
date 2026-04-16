import SwiftUI

// MARK: - TransactionListView

struct TransactionListView: View {

    @State private var viewModel = TransactionListViewModel()
    @Environment(AuthService.self) private var auth

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgBase.ignoresSafeArea()

                if viewModel.isLoading {
                    loadingOverlay
                } else if viewModel.groupedByDay.isEmpty {
                    emptyState
                } else {
                    transactionList
                }
            }
            .navigationTitle("Giao dịch")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "Tìm giao dịch..."
            )
            .toolbar { filterMenu }
        }
        .task {
            let userId = auth.currentUser?.id ?? MockData.userId
            await viewModel.fetchAll(userId: userId)
        }
    }

    // MARK: - Transaction List

    private var transactionList: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                summaryBar
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.md)
                    .padding(.bottom, Spacing.lg)

                filterChips
                    .padding(.bottom, Spacing.md)

                ForEach(viewModel.groupedByDay, id: \.date) { group in
                    Section {
                        ForEach(group.transactions) { tx in
                            TxRowView(
                                transaction: tx,
                                category: viewModel.category(for: tx),
                                onDelete: { viewModel.delete(tx) }
                            )
                            .padding(.horizontal, Spacing.lg)
                        }
                    } header: {
                        dayHeader(group.date, transactions: group.transactions)
                    }
                }

                Color.clear.frame(height: 120) // tab bar clearance
            }
        }
    }

    // MARK: - Summary Bar

    private var summaryBar: some View {
        HStack(spacing: Spacing.md) {
            summaryChip(
                label: "Thu nhập",
                amount: viewModel.totalIncome,
                color: .accentGreen,
                icon: "arrow.down.circle.fill"
            )

            summaryChip(
                label: "Chi tiêu",
                amount: viewModel.totalExpense,
                color: .accentRed,
                icon: "arrow.up.circle.fill"
            )
        }
    }

    private func summaryChip(label: String, amount: Decimal, color: Color, icon: String) -> some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.metaLabel)
                    .foregroundStyle(Color.textTertiary)
                Text(amount.formattedCompact)
                    .font(.moneyCaption)
                    .foregroundStyle(color)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(TransactionFilter.allCases, id: \.self) { filter in
                    filterChip(filter)
                }
            }
            .padding(.horizontal, Spacing.lg)
        }
    }

    private func filterChip(_ filter: TransactionFilter) -> some View {
        let isSelected = viewModel.selectedFilter == filter
        return Button {
            withAnimation(AppAnimation.fast) {
                viewModel.selectedFilter = filter
            }
            Haptic.light()
        } label: {
            Text(filter.rawValue)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .black : Color.textSecondary)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(isSelected ? Color.accentGreen : Color.bgCard)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.ghostBorder, lineWidth: 0.5)
                )
        }
    }

    // MARK: - Day Header

    private func dayHeader(_ date: Date, transactions: [Transaction]) -> some View {
        let dayTotal = transactions.reduce(Decimal(0)) { $0 + $1.signedAmount }

        return HStack {
            Text(date.formatted(as: .dayHeader))
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.textSecondary)

            Spacer()

            Text(dayTotal.formattedSigned)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(dayTotal >= 0 ? .accentGreen : .accentRed)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
        .background(Color.bgBase)
    }

    // MARK: - Filter Menu

    @ToolbarContentBuilder
    private var filterMenu: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.textSecondary)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "tray")
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(Color.textTertiary.opacity(0.5))

            VStack(spacing: Spacing.sm) {
                Text(viewModel.searchText.isEmpty ? "Chưa có giao dịch" : "Không tìm thấy")
                    .font(.headline)
                    .foregroundStyle(Color.textSecondary)

                Text(viewModel.searchText.isEmpty
                     ? "Nhấn + để thêm giao dịch đầu tiên"
                     : "Thử từ khóa khác")
                    .font(.footnote)
                    .foregroundStyle(Color.textTertiary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.bottom, 100)
    }

    // MARK: - Loading

    private var loadingOverlay: some View {
        VStack(spacing: Spacing.lg) {
            ForEach(0..<6, id: \.self) { _ in
                SkeletonTxRow()
                    .padding(.horizontal, Spacing.lg)
            }
            Spacer()
        }
        .padding(.top, Spacing.xxl)
    }
}

// MARK: - TxRowView

struct TxRowView: View {

    let transaction: Transaction
    let category: Category?
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Category icon
            CategoryIconView(
                symbol: category?.icon ?? "questionmark",
                color: category?.swiftUIColor ?? .textTertiary,
                size: 40
            )

            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.note ?? category?.name ?? "—")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                HStack(spacing: Spacing.xs) {
                    Text(category?.name ?? "")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.textTertiary)

                    Text("•")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.textTertiary)

                    Text(transaction.date.formatted(as: .timeOnly))
                        .font(.system(size: 12))
                        .foregroundStyle(Color.textTertiary)
                }
            }

            Spacer()

            // Amount
            Text(transaction.amount.formattedVND)
                .font(.moneyCaption)
                .foregroundStyle(transaction.isIncome ? .accentGreen : .accentRed)
                .lineLimit(1)
        }
        .padding(.vertical, Spacing.md)
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                Haptic.rigid()
                withAnimation { onDelete() }
            } label: {
                Label("Xóa", systemImage: "trash.fill")
            }
        }
    }
}

// MARK: - SkeletonTxRow

private struct SkeletonTxRow: View {

    @State private var shimmer = false

    var body: some View {
        HStack(spacing: Spacing.md) {
            Circle()
                .fill(Color.bgCard)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.bgCard)
                    .frame(width: 140, height: 14)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.bgCard)
                    .frame(width: 90, height: 11)
            }

            Spacer()

            RoundedRectangle(cornerRadius: 4)
                .fill(Color.bgCard)
                .frame(width: 80, height: 14)
        }
        .opacity(shimmer ? 0.4 : 1)
        .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: shimmer)
        .onAppear { shimmer = true }
    }
}

// MARK: - Date Formatting Helpers

extension Date {
    enum FormatStyle {
        case dayHeader, timeOnly
    }

    func formatted(as style: FormatStyle) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        switch style {
        case .dayHeader:
            let cal = Calendar.current
            if cal.isDateInToday(self) {
                formatter.dateFormat = "'Hôm nay' • d MMMM"
            } else if cal.isDateInYesterday(self) {
                formatter.dateFormat = "'Hôm qua' • d MMMM"
            } else {
                formatter.dateFormat = "EEEE • d MMMM"
            }
        case .timeOnly:
            formatter.dateFormat = "HH:mm"
        }
        return formatter.string(from: self)
    }
}

// MARK: - Preview

#Preview {
    TransactionListView()
        .environment(AuthService())
        .preferredColorScheme(.dark)
}
