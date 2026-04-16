import SwiftUI
import Charts

// MARK: - ChartsView

struct ChartsView: View {

    @State private var viewModel = ChartsViewModel()
    @Environment(AuthService.self) private var auth

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgBase.ignoresSafeArea()

                if viewModel.isLoading {
                    loadingView
                } else {
                    chartContent
                }
            }
            .navigationTitle("Phân tích")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            let userId = auth.currentUser?.id ?? MockData.userId
            await viewModel.fetchAll(userId: userId)
        }
    }

    // MARK: - Main Content

    private var chartContent: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                summaryCard
                    .padding(.horizontal, Spacing.lg)

                chartTabPicker
                    .padding(.horizontal, Spacing.lg)

                switch viewModel.selectedChart {
                case .spending: spendingDonut.padding(.horizontal, Spacing.lg)
                case .income:   incomeView.padding(.horizontal, Spacing.lg)
                case .compare:  compareBar.padding(.horizontal, Spacing.lg)
                }

                Color.clear.frame(height: 120)
            }
            .padding(.top, Spacing.md)
        }
    }

    // MARK: - Summary Card

    private var summaryCard: some View {
        HStack(spacing: 0) {
            summaryItem(
                label: "Thu nhập",
                value: viewModel.currentIncome,
                color: .accentGreen,
                icon: "arrow.down.circle.fill"
            )

            Divider()
                .background(Color.separator)
                .frame(height: 44)

            summaryItem(
                label: "Chi tiêu",
                value: viewModel.currentExpense,
                color: .accentRed,
                icon: "arrow.up.circle.fill"
            )

            Divider()
                .background(Color.separator)
                .frame(height: 44)

            summaryItem(
                label: "Tiết kiệm",
                value: viewModel.currentSavings,
                color: .accentBlue,
                icon: "banknote.fill",
                subtitle: viewModel.savingsRatioText
            )
        }
        .padding(Spacing.lg)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg)
                .stroke(Color.ghostBorder, lineWidth: 0.5)
        )
    }

    private func summaryItem(label: String, value: Decimal, color: Color, icon: String, subtitle: String? = nil) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(color)

            Text(value.formattedCompact)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(color)
            } else {
                Text(label)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Chart Tab Picker

    private var chartTabPicker: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(ChartTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(AppAnimation.fast) {
                        viewModel.selectedChart = tab
                    }
                    Haptic.light()
                } label: {
                    Text(tab.rawValue)
                        .font(.system(size: 13, weight: viewModel.selectedChart == tab ? .semibold : .regular))
                        .foregroundStyle(viewModel.selectedChart == tab ? .black : Color.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.sm)
                        .background(viewModel.selectedChart == tab ? Color.accentGreen : Color.bgCard)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
                }
            }
        }
        .padding(4)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md)
                .stroke(Color.ghostBorder, lineWidth: 0.5)
        )
    }

    // MARK: - Spending Donut Chart

    private var spendingDonut: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Chi tiêu theo danh mục")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.textPrimary)

            if viewModel.topCategorySpending.isEmpty {
                emptyChartPlaceholder(message: "Chưa có dữ liệu chi tiêu")
            } else {
                ZStack {
                    Chart(viewModel.topCategorySpending) { item in
                        SectorMark(
                            angle: .value("Số tiền", NSDecimalNumber(decimal: item.amount).doubleValue),
                            innerRadius: .ratio(0.65),
                            angularInset: 3
                        )
                        .foregroundStyle(item.category.swiftUIColor)
                        .cornerRadius(4)
                    }
                    .frame(height: 220)

                    // Center label
                    VStack(spacing: 2) {
                        Text(viewModel.currentExpense.formattedCompact)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.textPrimary)
                        Text("Chi tiêu")
                            .font(.caption)
                            .foregroundStyle(Color.textTertiary)
                    }
                }

                // Legend
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
                    ForEach(viewModel.topCategorySpending) { item in
                        donutLegendItem(item)
                    }
                }
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

    private func donutLegendItem(_ item: CategorySpending) -> some View {
        let ratio = viewModel.totalCategorySpend > 0
            ? NSDecimalNumber(decimal: item.amount / viewModel.totalCategorySpend).doubleValue
            : 0

        return HStack(spacing: Spacing.sm) {
            Circle()
                .fill(item.category.swiftUIColor)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 1) {
                Text(item.category.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
                Text(String(format: "%.0f%%", ratio * 100))
                    .font(.system(size: 11))
                    .foregroundStyle(Color.textTertiary)
            }

            Spacer()
        }
    }

    // MARK: - Income View

    private var incomeView: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Thu nhập theo tháng")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.textPrimary)

            Chart(viewModel.monthlyData) { item in
                BarMark(
                    x: .value("Tháng", item.label),
                    y: .value("Thu nhập", NSDecimalNumber(decimal: item.income).doubleValue)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.accentGreenBright, Color.accentGreen],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(6)
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.separator.opacity(0.5))
                    AxisValueLabel {
                        if let dbl = value.as(Double.self) {
                            Text(Decimal(dbl).formattedCompact)
                                .font(.system(size: 10))
                                .foregroundStyle(Color.textTertiary)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .font(.system(size: 10))
                        .foregroundStyle(Color.textTertiary)
                }
            }
            .frame(height: 200)
        }
        .padding(Spacing.xl)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg)
                .stroke(Color.ghostBorder, lineWidth: 0.5)
        )
    }

    // MARK: - Compare Bar Chart

    private var compareBar: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Thu / Chi 6 tháng gần đây")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.textPrimary)

            Chart {
                ForEach(viewModel.monthlyData) { item in
                    BarMark(
                        x: .value("Tháng", item.label),
                        y: .value("Số tiền", NSDecimalNumber(decimal: item.income).doubleValue),
                        width: .ratio(0.4)
                    )
                    .foregroundStyle(Color.accentGreen.opacity(0.85))
                    .cornerRadius(4)
                    .offset(x: -8)
                    .annotation(position: .automatic) { EmptyView() }

                    BarMark(
                        x: .value("Tháng", item.label),
                        y: .value("Số tiền", NSDecimalNumber(decimal: item.expense).doubleValue),
                        width: .ratio(0.4)
                    )
                    .foregroundStyle(Color.accentRed.opacity(0.85))
                    .cornerRadius(4)
                    .offset(x: 8)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.separator.opacity(0.5))
                    AxisValueLabel {
                        if let dbl = value.as(Double.self) {
                            Text(Decimal(dbl).formattedCompact)
                                .font(.system(size: 10))
                                .foregroundStyle(Color.textTertiary)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .font(.system(size: 10))
                        .foregroundStyle(Color.textTertiary)
                }
            }
            .frame(height: 200)

            // Legend
            HStack(spacing: Spacing.lg) {
                legendDot(color: .accentGreen, label: "Thu nhập")
                legendDot(color: .accentRed,   label: "Chi tiêu")
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

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: Spacing.xs) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 12, height: 8)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
        }
    }

    // MARK: - Empty / Loading

    private func emptyChartPlaceholder(message: String) -> some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "chart.pie")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(Color.textTertiary.opacity(0.4))
            Text(message)
                .font(.footnote)
                .foregroundStyle(Color.textTertiary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }

    private var loadingView: some View {
        VStack(spacing: Spacing.md) {
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.bgCard)
                .frame(height: 80)
                .padding(.horizontal, Spacing.lg)
                .shimmer()

            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.bgCard)
                .frame(height: 300)
                .padding(.horizontal, Spacing.lg)
                .shimmer()

            Spacer()
        }
        .padding(.top, Spacing.xxl)
    }
}

// MARK: - Preview

#Preview {
    ChartsView()
        .environment(AuthService())
        .preferredColorScheme(.dark)
}
