import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {

    @Environment(AuthService.self) private var auth
    @State private var notificationsEnabled = true
    @State private var faceIDEnabled = true
    @State private var showSignOutAlert = false

    private var displayName: String {
        auth.currentUser?.email?.components(separatedBy: "@").first?.capitalized ?? "Người dùng"
    }

    private var email: String {
        auth.currentUser?.email ?? "—"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgBase.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.xxl) {
                        profileCard

                        settingsSection(title: "Tùy chọn") {
                            settingsRow(
                                icon: "dollarsign.circle.fill",
                                iconColor: .accentGreen,
                                label: "Đơn vị tiền tệ",
                                value: "VND"
                            )

                            Divider().background(Color.separator)

                            settingsToggle(
                                icon: "bell.fill",
                                iconColor: .accentGold,
                                label: "Thông báo",
                                isOn: $notificationsEnabled
                            )

                            Divider().background(Color.separator)

                            settingsToggle(
                                icon: "faceid",
                                iconColor: .accentBlue,
                                label: "Face ID / Touch ID",
                                isOn: $faceIDEnabled
                            )
                        }

                        settingsSection(title: "Dữ liệu") {
                            settingsRow(
                                icon: "square.and.arrow.up.fill",
                                iconColor: .accentBlue,
                                label: "Xuất báo cáo",
                                value: nil,
                                showChevron: true
                            )

                            Divider().background(Color.separator)

                            settingsRow(
                                icon: "arrow.clockwise.icloud.fill",
                                iconColor: .accentGreen,
                                label: "Sao lưu dữ liệu",
                                value: nil,
                                showChevron: true
                            )
                        }

                        settingsSection(title: "Thông tin") {
                            settingsRow(
                                icon: "info.circle.fill",
                                iconColor: .textTertiary,
                                label: "Phiên bản",
                                value: "1.0.0"
                            )

                            Divider().background(Color.separator)

                            settingsRow(
                                icon: "hand.raised.fill",
                                iconColor: .textTertiary,
                                label: "Chính sách bảo mật",
                                value: nil,
                                showChevron: true
                            )
                        }

                        // Sign out
                        Button {
                            showSignOutAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Đăng xuất")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundStyle(Color.accentRed)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.accentRed.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                            .overlay(
                                RoundedRectangle(cornerRadius: Radius.lg)
                                    .stroke(Color.accentRed.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, Spacing.lg)

                        Color.clear.frame(height: 120)
                    }
                    .padding(.top, Spacing.md)
                }
            }
            .navigationTitle("Cài đặt")
            .navigationBarTitleDisplayMode(.large)
            .alert("Đăng xuất?", isPresented: $showSignOutAlert) {
                Button("Đăng xuất", role: .destructive) {
                    Haptic.warning()
                    Task { try? await auth.signOut() }
                }
                Button("Hủy", role: .cancel) {}
            } message: {
                Text("Bạn sẽ cần đăng nhập lại để sử dụng ứng dụng.")
            }
        }
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        HStack(spacing: Spacing.lg) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.accentGreen.opacity(0.6), Color.accentGreen.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)

                Text(String(displayName.prefix(1)))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.black)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(displayName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)

                Text(email)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.textTertiary)
        }
        .padding(Spacing.xl)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg)
                .stroke(Color.ghostBorder, lineWidth: 0.5)
        )
        .padding(.horizontal, Spacing.lg)
    }

    // MARK: - Section Builder

    private func settingsSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title.uppercased())
                .font(.metaLabel)
                .foregroundStyle(Color.textTertiary)
                .padding(.horizontal, Spacing.lg)

            VStack(spacing: 0) {
                content()
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

    // MARK: - Row Variants

    private func settingsRow(
        icon: String,
        iconColor: Color,
        label: String,
        value: String?,
        showChevron: Bool = false
    ) -> some View {
        HStack(spacing: Spacing.md) {
            iconBadge(icon, color: iconColor)

            Text(label)
                .font(.system(size: 15))
                .foregroundStyle(Color.textPrimary)

            Spacer()

            if let value = value {
                Text(value)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textTertiary)
            }

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.textTertiary)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .contentShape(Rectangle())
    }

    private func settingsToggle(
        icon: String,
        iconColor: Color,
        label: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: Spacing.md) {
            iconBadge(icon, color: iconColor)

            Text(label)
                .font(.system(size: 15))
                .foregroundStyle(Color.textPrimary)

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color.accentGreen)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }

    private func iconBadge(_ symbol: String, color: Color) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(color == .textTertiary ? Color.textTertiary : .white)
            .frame(width: 30, height: 30)
            .background(color == .textTertiary ? Color.bgCardHigh : color)
            .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .environment(AuthService())
        .preferredColorScheme(.dark)
}
