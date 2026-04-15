import SwiftUI

// MARK: - DashboardView
// Based on Stitch screen "Dashboard (Refined)" — The Sovereign Dark Aesthetic
// Shows: Balance hero, wallet cards, recent transactions, budget bars

struct DashboardView: View {

    @Environment(AuthService.self) private var auth
    @State private var vm = DashboardViewModel()
    @State private var showAddTransaction = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.bgBase.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        headerSection
                        balanceCard
                        walletScroll
                        recentTransactionsSection
                        budgetSection
                        Spacer().frame(height: 100) // tab bar clearance
                    }
                }
                .refreshable {
                    if let uid = auth.currentUser?.id {
                        await vm.fetchAll(userId: uid)
                    }
                }
            }
            .task {
                if let uid = auth.currentUser?.id {
                    await vm.fetchAll(userId: uid)
                }
            }
            .sheet(isPresented: $showAddTransaction) {
                AddTransactionView()
                    .onDisappear {
                        Task {
                            if let uid = auth.currentUser?.id {
                                await vm.fetchAll(userId: uid)
                            }
                        }
                    }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Sovereign")
                    .font(.metaLabel)
                    .foregroundStyle(Color.textTertiary)
                Text("MoneyTracker")
                    .font(.title2.bold())
                    .foregroundStyle(Color.textPrimary)
            }

            Spacer()

            HStack(spacing: Spacing.md) {
                Button {
                    // TODO: notifications
                } label: {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.textSecondary)
                        .frame(width: 44, height: 44)
                }

                Button {
                    // TODO: profile
                } label: {
                    Circle()
                        .fill(Color.accentGreen.opacity(0.2))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Text(auth.currentUser?.email?.prefix(1).uppercased() ?? "U")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.accentGreen)
                        )
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.lg)
        .padding(.bottom, Spacing.sm)
    }

    // MARK: - Balance Card

    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TỔNG SỐ DƯ")
                        .font(.metaLabel)
                        .foregroundStyle(Color.textTertiary)
                    Text(vm.periodLabel)
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }
                Spacer()
                Image(systemName: "arrow.up.right.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.accentGreen.opacity(0.6))
            }

            Text(vm.totalBalance.formattedVND)
                .font(.balanceHero)
                .foregroundStyle(Color.textPrimary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            HStack(spacing: Spacing.xxl) {
                balanceStat(
                    label: "Thu nhập",
                    amount: vm.monthlyIncome,
                    icon: "arrow.down.circle.fill",
                    color: .accentGreen
                )
                balanceStat(
                    label: "Chi tiêu",
                    amount: vm.monthlyExpense,
                    icon: "arrow.up.circle.fill",
                    color: .accentRed
                )
            }
        }
        .padding(Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: Radius.xl)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.xl)
                        .stroke(Color.ghostBorder, lineWidth: 0.5)
                )
        )
        .shadow(color: .black.opacity(0.4), radius: 20, y: 10)
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.sm)
    }

    private func balanceStat(label: String, amount: Decimal, icon: String, color: Color) -> some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(Color.textSecondary)
                Text(amount.formattedCompact)
                    .font(.moneyCaption)
                    .foregroundStyle(color)
            }
        }
    }

    // MARK: - Wallet Scroll

    private var walletScroll: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Tài khoản")
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                Button("Xem tất cả") {
                    // TODO: navigate to wallets
                }
                .font(.subheadline)
                .foregroundStyle(Color.accentBlue)
            }
            .padding(.horizontal, Spacing.lg)

            if vm.wallets.isEmpty && !vm.isLoading {
                emptyWalletsCard
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.md) {
                        ForEach(vm.wallets) { wallet in
                            WalletCard(wallet: wallet, isSelected: vm.selectedWalletId == wallet.id)
                                .onTapGesture {
                                    withAnimation(AppAnimation.fast) {
                                        vm.selectedWalletId = wallet.id
                                    }
                                    Haptic.light()
                                }
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(.top, Spacing.xxl)
    }

    private var emptyWalletsCard: some View {
        RoundedRectangle(cornerRadius: Radius.lg)
            .fill(Color.bgCard)
            .overlay(
                VStack(spacing: Spacing.sm) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.textSecondary.opacity(0.4))
                    Text("Chưa có ví nào")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                }
            )
            .frame(height: 120)
            .padding(.horizontal, Spacing.lg)
    }

    // MARK: - Recent Transactions

    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Giao dịch gần đây")
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                Button("Lịch sử") {
                    // TODO: navigate to transaction list
                }
                .font(.subheadline)
                .foregroundStyle(Color.accentBlue)
            }
            .padding(.horizontal, Spacing.lg)

            if vm.isLoading {
                transactionSkeletons
            } else if vm.recentTransactions.isEmpty {
                emptyTransactionsView
            } else {
                VStack(spacing: 0) {
                    ForEach(vm.recentTransactions.prefix(5)) { tx in
                        TransactionRowView(
                            transaction: tx,
                            category: vm.category(for: tx)
                        )

                        if tx.id != vm.recentTransactions.prefix(5).last?.id {
                            Divider()
                                .background(Color.separator.opacity(0.3))
                                .padding(.leading, 72)
                        }
                    }
                }
                .background(Color.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.lg)
                        .stroke(Color.ghostBorder, lineWidth: 0.5)
                )
                .padding(.horizontal, Spacing.lg)
            }
        }
        .padding(.top, Spacing.xxl)
    }

    private var transactionSkeletons: some View {
        VStack(spacing: 0) {
            ForEach(0..<3, id: \.self) { _ in
                SkeletonRow()
            }
        }
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .padding(.horizontal, Spacing.lg)
    }

    private var emptyTransactionsView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "tray.fill")
                .font(.system(size: 36))
                .foregroundStyle(Color.textSecondary.opacity(0.3))
            Text("Chưa có giao dịch nào")
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
            Button("Thêm giao dịch đầu tiên") {
                showAddTransaction = true
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color.accentGreen)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.hh)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .padding(.horizontal, Spacing.lg)
    }

    // MARK: - Budget Section

    private var budgetSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Ngân sách tháng")
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                Button("Chi tiết") {
                    // TODO: navigate to budget
                }
                .font(.subheadline)
                .foregroundStyle(Color.accentBlue)
            }
            .padding(.horizontal, Spacing.lg)

            if vm.budgetProgress.isEmpty {
                Text("Chưa thiết lập ngân sách")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.xl)
                    .background(Color.bgCard)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                    .padding(.horizontal, Spacing.lg)
            } else {
                VStack(spacing: Spacing.md) {
                    ForEach(vm.budgetProgress) { progress in
                        BudgetProgressRow(progress: progress)
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }
        }
        .padding(.top, Spacing.xxl)
    }
}

// MARK: - WalletCard

struct WalletCard: View {
    let wallet: Wallet
    var isSelected: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: wallet.type.sfSymbol)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))
                Spacer()
                if wallet.isDefault {
                    Text("DEFAULT")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.white.opacity(0.15))
                        .clipShape(Capsule())
                }
            }

            Spacer()

            Text(wallet.balance.formattedVND)
                .font(.balanceMD)
                .foregroundStyle(.white)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(wallet.name)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(Spacing.xl)
        .frame(width: 200, height: 120)
        .background(
            LinearGradient(
                colors: wallet.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: Radius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.xl)
                .stroke(isSelected ? Color.accentGreen.opacity(0.6) : Color.ghostBorder, lineWidth: isSelected ? 1.5 : 0.5)
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(AppAnimation.fast, value: isSelected)
    }
}

// MARK: - TransactionRowView

struct TransactionRowView: View {
    let transaction: Transaction
    let category: Category?

    var body: some View {
        HStack(spacing: Spacing.md) {
            CategoryIconView(
                symbol: category?.icon ?? "questionmark.circle.fill",
                color: Color(hex: category?.color ?? "#8E8E93"),
                size: 44
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(category?.name ?? "Không xác định")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textPrimary)
                Text(transaction.note ?? transaction.date.relativeFormatted)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Text(transaction.amount.formattedCompact)
                .font(.moneyAmount)
                .foregroundStyle(transaction.isIncome ? Color.accentGreen : Color.accentRed)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .contentShape(Rectangle())
    }
}

// MARK: - BudgetProgressRow

struct BudgetProgressRow: View {
    let progress: BudgetProgress

    var body: some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                CategoryIconView(symbol: progress.category.icon, color: progress.category.swiftUIColor, size: 32)
                Text(progress.category.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                Text("\(progress.spent.formattedCompact) / \(progress.budget.limitAmount.formattedCompact)")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.bgCardHighest).frame(height: 6)
                    Capsule()
                        .fill(progressColor)
                        .frame(width: geo.size.width * min(CGFloat(progress.ratio), 1.0), height: 6)
                        .animation(AppAnimation.slow, value: progress.ratio)
                }
            }
            .frame(height: 6)
        }
        .padding(Spacing.lg)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg)
                .stroke(Color.ghostBorder, lineWidth: 0.5)
        )
    }

    private var progressColor: Color {
        switch progress.status {
        case .safe, .moderate: return Color.accentGreen
        case .warning:          return Color.accentGold
        case .exceeded:         return Color.accentRed
        }
    }
}

// MARK: - SkeletonRow

struct SkeletonRow: View {
    @State private var animated = false

    var body: some View {
        HStack(spacing: Spacing.md) {
            Circle()
                .fill(Color.bgCardHigh)
                .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.bgCardHigh)
                    .frame(width: 120, height: 14)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.bgCardHigh)
                    .frame(width: 80, height: 10)
            }
            Spacer()
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.bgCardHigh)
                .frame(width: 70, height: 14)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .opacity(animated ? 0.5 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever()) {
                animated = true
            }
        }
    }
}

// MARK: - Date Extensions

private extension Date {
    var relativeFormatted: String {
        let cal = Calendar.current
        if cal.isDateInToday(self) {
            return "Hôm nay, " + formatted(.dateTime.hour().minute())
        } else if cal.isDateInYesterday(self) {
            return "Hôm qua, " + formatted(.dateTime.hour().minute())
        }
        return formatted(.dateTime.day().month(.abbreviated))
    }
}

// MARK: - Preview

#Preview {
    DashboardView()
        .environment(AuthService())
        .preferredColorScheme(.dark)
}
