import SwiftUI

// MARK: - BudgetView

struct BudgetView: View {

    @State private var viewModel = BudgetViewModel()
    @Environment(AuthService.self) private var auth

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgBase.ignoresSafeArea()

                if viewModel.isLoading {
                    loadingView
                } else if viewModel.budgetProgress.isEmpty {
                    emptyState
                } else {
                    budgetList
                }
            }
            .navigationTitle("Ngân sách")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Haptic.tap()
                        viewModel.showAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(Color.accentGreen)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddSheet) {
                AddBudgetSheet(viewModel: viewModel)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .preferredColorScheme(.dark)
            }
        }
        .task {
            let userId = auth.currentUser?.id ?? MockData.userId
            await viewModel.fetchAll(userId: userId)
        }
    }

    // MARK: - Budget List

    private var budgetList: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                overallCard
                    .padding(.horizontal, Spacing.lg)

                periodLabel
                    .padding(.horizontal, Spacing.lg)

                VStack(spacing: Spacing.md) {
                    ForEach(viewModel.budgetProgress) { progress in
                        BudgetCardRow(
                            progress: progress,
                            onDelete: { viewModel.deleteBudget(progress) }
                        )
                        .padding(.horizontal, Spacing.lg)
                    }
                }

                Color.clear.frame(height: 120)
            }
            .padding(.top, Spacing.md)
        }
    }

    // MARK: - Overall Card

    private var overallCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tổng ngân sách")
                        .font(.metaLabel)
                        .foregroundStyle(Color.textTertiary)
                    Text(viewModel.totalLimit.formattedCompact)
                        .font(.balanceMD)
                        .foregroundStyle(Color.textPrimary)
                }

                Spacer()

                statusBadge(viewModel.overallStatus)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.bgCardHigh)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(progressGradient(for: viewModel.overallStatus))
                        .frame(width: geo.size.width * min(CGFloat(viewModel.overallRatio), 1), height: 8)
                        .animation(AppAnimation.slow, value: viewModel.overallRatio)
                }
            }
            .frame(height: 8)

            HStack {
                Text("Đã chi: \(viewModel.totalSpent.formattedCompact)")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                Spacer()
                Text("\(Int(viewModel.overallRatio * 100))%")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(statusColor(viewModel.overallStatus))
            }
        }
        .padding(Spacing.xl)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg)
                .stroke(Color.ghostBorder, lineWidth: 0.5)
        )
    }

    // MARK: - Period Label

    private var periodLabel: some View {
        HStack {
            Text(currentMonthLabel)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.textSecondary)

            Spacer()

            Text("\(viewModel.budgetProgress.count) danh mục")
                .font(.caption)
                .foregroundStyle(Color.textTertiary)
        }
    }

    private var currentMonthLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: .now).capitalized
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "chart.pie")
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(Color.textTertiary.opacity(0.4))

            VStack(spacing: Spacing.sm) {
                Text("Chưa có ngân sách")
                    .font(.headline)
                    .foregroundStyle(Color.textSecondary)
                Text("Thiết lập ngân sách theo danh mục\nđể kiểm soát chi tiêu tốt hơn")
                    .font(.footnote)
                    .foregroundStyle(Color.textTertiary)
                    .multilineTextAlignment(.center)
            }

            Button {
                viewModel.showAddSheet = true
            } label: {
                Label("Thêm ngân sách", systemImage: "plus")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.md)
                    .background(Color.accentGreen)
                    .clipShape(Capsule())
            }
        }
        .padding(.bottom, 100)
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: Spacing.md) {
            ForEach(0..<4, id: \.self) { _ in
                RoundedRectangle(cornerRadius: Radius.md)
                    .fill(Color.bgCard)
                    .frame(height: 90)
                    .padding(.horizontal, Spacing.lg)
                    .shimmer()
            }
            Spacer()
        }
        .padding(.top, Spacing.xxl)
    }

    // MARK: - Helpers

    private func statusBadge(_ status: BudgetStatus) -> some View {
        Text(status.label)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(statusColor(status))
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, 4)
            .background(statusColor(status).opacity(0.15))
            .clipShape(Capsule())
    }

    private func statusColor(_ status: BudgetStatus) -> Color {
        Color(hex: status.color)
    }

    private func progressGradient(for status: BudgetStatus) -> LinearGradient {
        let color = statusColor(status)
        return LinearGradient(
            colors: [color.opacity(0.8), color],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - BudgetCardRow

struct BudgetCardRow: View {

    let progress: BudgetProgress
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                CategoryIconView(
                    symbol: progress.category.icon,
                    color: progress.category.swiftUIColor,
                    size: 36
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(progress.category.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)

                    Text("\(progress.spent.formattedCompact) / \(progress.budget.limitAmount.formattedCompact)")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text(progress.percentageText)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(statusColor)

                    if progress.status == .warning || progress.status == .exceeded {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(statusColor)
                    }
                }
            }

            // Progress track
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.bgCardHigh)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(progressGradient)
                        .frame(width: geo.size.width * min(CGFloat(progress.ratio), 1), height: 6)
                        .animation(AppAnimation.slow, value: progress.ratio)
                }
            }
            .frame(height: 6)

            HStack {
                Text("Còn lại: \(progress.remaining.formattedCompact)")
                    .font(.caption)
                    .foregroundStyle(Color.textTertiary)

                Spacer()

                Text(progress.budget.period.label)
                    .font(.caption)
                    .foregroundStyle(Color.textTertiary)
            }
        }
        .padding(Spacing.lg)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg)
                .stroke(warningBorder, lineWidth: 0.5)
        )
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                Haptic.rigid()
                withAnimation { onDelete() }
            } label: {
                Label("Xóa", systemImage: "trash.fill")
            }
        }
    }

    private var statusColor: Color { Color(hex: progress.status.color) }

    private var progressGradient: LinearGradient {
        LinearGradient(
            colors: [statusColor.opacity(0.7), statusColor],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var warningBorder: Color {
        switch progress.status {
        case .warning:  return Color.accentGold.opacity(0.4)
        case .exceeded: return Color.accentRed.opacity(0.4)
        default:        return Color.ghostBorder
        }
    }
}

// MARK: - AddBudgetSheet

struct AddBudgetSheet: View {

    @Bindable var viewModel: BudgetViewModel
    @FocusState private var amountFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.xxl) {
                // Category picker
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("DANH MỤC")
                        .font(.metaLabel)
                        .foregroundStyle(Color.textTertiary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.sm) {
                            ForEach(viewModel.availableCategories) { cat in
                                categoryChip(cat)
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }

                // Amount input
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("HẠN MỨC")
                        .font(.metaLabel)
                        .foregroundStyle(Color.textTertiary)

                    HStack {
                        Text("₫")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(Color.textSecondary)

                        TextField("0", text: $viewModel.newLimitText)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.textPrimary)
                            .keyboardType(.numberPad)
                            .focused($amountFocused)
                    }
                    .padding(Spacing.lg)
                    .background(Color.bgCard)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.md)
                            .stroke(amountFocused ? Color.accentBlue : Color.ghostBorder, lineWidth: amountFocused ? 2 : 0.5)
                    )
                }

                Spacer()

                PrimaryButton(title: "Lưu ngân sách") {
                    Haptic.success()
                    viewModel.addBudget()
                }
                .disabled(viewModel.newCategoryId == nil || viewModel.newLimitText.isEmpty)
            }
            .padding(Spacing.xl)
            .background(Color.bgBase)
            .navigationTitle("Thêm ngân sách")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Hủy") { viewModel.showAddSheet = false }
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .onAppear { amountFocused = true }
    }

    private func categoryChip(_ cat: Category) -> some View {
        let selected = viewModel.newCategoryId == cat.id
        return Button {
            withAnimation(AppAnimation.fast) {
                viewModel.newCategoryId = selected ? nil : cat.id
            }
            Haptic.light()
        } label: {
            HStack(spacing: Spacing.xs) {
                Image(systemName: cat.icon)
                    .font(.system(size: 13, weight: .medium))
                Text(cat.name)
                    .font(.system(size: 13, weight: selected ? .semibold : .regular))
            }
            .foregroundStyle(selected ? .black : Color.textPrimary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(selected ? cat.swiftUIColor : Color.bgCard)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(selected ? Color.clear : Color.ghostBorder, lineWidth: 0.5)
            )
        }
    }
}

// MARK: - Preview

#Preview {
    BudgetView()
        .environment(AuthService())
        .preferredColorScheme(.dark)
}
