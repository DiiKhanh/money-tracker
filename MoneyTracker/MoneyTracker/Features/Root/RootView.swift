import SwiftUI

// MARK: - RootView
// Session gating: shows LoginView or MainTabView based on auth state

struct RootView: View {

    @Environment(AuthService.self) private var auth
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        Group {
            if auth.isAuthenticated {
                MainTabView(selectedTab: $selectedTab)
                    .transition(.opacity)
            } else {
                LoginView()
                    .transition(.opacity)
            }
        }
        .animation(AppAnimation.normal, value: auth.isAuthenticated)
    }
}

// MARK: - AppTab

enum AppTab: Int, CaseIterable {
    case dashboard    = 0
    case transactions = 1
    case budget       = 2
    case charts       = 3
    case settings     = 4

    var label: String {
        switch self {
        case .dashboard:    return "Tổng quan"
        case .transactions: return "Giao dịch"
        case .budget:       return "Ngân sách"
        case .charts:       return "Phân tích"
        case .settings:     return "Cài đặt"
        }
    }

    var icon: String {
        switch self {
        case .dashboard:    return "house.fill"
        case .transactions: return "list.bullet.rectangle.portrait.fill"
        case .budget:       return "chart.pie.fill"
        case .charts:       return "chart.bar.fill"
        case .settings:     return "gearshape.fill"
        }
    }
}

// MARK: - MainTabView
// Floating tab bar — from Stitch + DESIGN.md: detached 16pt, ultraThinMaterial

struct MainTabView: View {
    @Binding var selectedTab: AppTab
    @State private var showAddTransaction = false
    @Environment(AuthService.self) private var auth

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tag(AppTab.dashboard)

                TransactionListView()
                    .tag(AppTab.transactions)

                BudgetView()
                    .tag(AppTab.budget)

                ChartsView()
                    .tag(AppTab.charts)

                SettingsView()
                    .tag(AppTab.settings)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            floatingTabBar
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
        }
    }

    // MARK: Floating Tab Bar

    private var floatingTabBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                if tab == .budget {
                    // Center FAB — Add Transaction
                    addButton
                } else {
                    tabButton(tab)
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(
            Capsule()
                .fill(.regularMaterial)
                .overlay(
                    Capsule()
                        .stroke(Color.ghostBorder, lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.5), radius: 20, y: 5)
        )
        .padding(.horizontal, Spacing.xxl)
        .padding(.bottom, Spacing.lg)
    }

    private func tabButton(_ tab: AppTab) -> some View {
        Button {
            Haptic.light()
            withAnimation(AppAnimation.fast) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: selectedTab == tab ? 22 : 20, weight: selectedTab == tab ? .semibold : .regular))
                    .foregroundStyle(selectedTab == tab ? Color.accentBlueBright : Color.textSecondary)

                // Active indicator dot
                Circle()
                    .fill(selectedTab == tab ? Color.accentBlueBright : .clear)
                    .frame(width: 4, height: 4)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .contentShape(Rectangle())
        }
        .animation(AppAnimation.fast, value: selectedTab)
    }

    private var addButton: some View {
        Button {
            Haptic.tap()
            showAddTransaction = true
        } label: {
            ZStack {
                Circle()
                    .fill(Color.primaryGradient)
                    .frame(width: 52, height: 52)
                    .shadow(color: Color.accentGreen.opacity(0.4), radius: 10)

                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.black)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    RootView()
        .environment(AuthService())
        .preferredColorScheme(.dark)
}
