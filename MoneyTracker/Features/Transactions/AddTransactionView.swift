import SwiftUI

// MARK: - AddTransactionView
// Based on Stitch screen "Thêm giao dịch"
// Features: income/expense toggle, large VND input, category grid, wallet, date, note

struct AddTransactionView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(AuthService.self) private var auth

    @State private var vm = AddTransactionViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgBase.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Spacing.xxl) {
                        typeToggle
                        amountSection
                        categorySection
                        detailsSection
                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.lg)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        Haptic.light()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.textSecondary)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Giao dịch mới")
                        .font(.headline)
                        .foregroundStyle(Color.textPrimary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task { await saveTransaction() }
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(vm.isFormValid ? Color.accentGreen : Color.textTertiary)
                    }
                    .disabled(!vm.isFormValid || vm.isSaving)
                }
            }
            .alert("Lỗi", isPresented: .constant(vm.error != nil), actions: {
                Button("OK") { vm.error = nil }
            }, message: {
                Text(vm.error ?? "")
            })
        }
        .task {
            if let uid = auth.currentUser?.id {
                await vm.loadInitialData(userId: uid)
            }
        }
    }

    // MARK: - Type Toggle
    // From Stitch: "Chi tiêu | Thu nhập" segmented control

    private var typeToggle: some View {
        HStack(spacing: 0) {
            ForEach(TransactionType.allCases, id: \.self) { type in
                Button {
                    withAnimation(AppAnimation.fast) {
                        vm.selectedType = type
                    }
                    Haptic.light()
                } label: {
                    Text(type.label)
                        .font(.headline)
                        .foregroundStyle(vm.selectedType == type ? .black : Color.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            vm.selectedType == type
                                ? (type == .income ? Color.accentGreen : Color.accentRed)
                                : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                }
            }
        }
        .padding(4)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg)
                .stroke(Color.ghostBorder, lineWidth: 0.5)
        )
    }

    // MARK: - Amount Input
    // Large centered VND amount — from Stitch design

    private var amountSection: some View {
        VStack(spacing: Spacing.sm) {
            Text("Số tiền giao dịch")
                .font(.caption)
                .foregroundStyle(Color.textSecondary)

            HStack(alignment: .firstTextBaseline, spacing: Spacing.sm) {
                Text("₫")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.textSecondary)

                TextField("0", text: $vm.amountText)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(vm.selectedType == .income ? Color.accentGreen : Color.accentRed)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.xl)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.lg)
                    .stroke(
                        vm.amountText.isEmpty ? Color.ghostBorder : Color.accentGreen.opacity(0.4),
                        lineWidth: vm.amountText.isEmpty ? 0.5 : 1.5
                    )
            )
        }
    }

    // MARK: - Category Grid
    // From Stitch: 4-column grid with SF Symbol icons

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Danh mục")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            let filteredCategories = vm.filteredCategories

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.sm), count: 4),
                spacing: Spacing.md
            ) {
                ForEach(filteredCategories) { category in
                    CategoryGridItem(
                        category: category,
                        isSelected: vm.selectedCategoryId == category.id
                    )
                    .onTapGesture {
                        withAnimation(AppAnimation.fast) {
                            vm.selectedCategoryId = category.id
                        }
                        Haptic.light()
                    }
                }

                // "Thêm" button
                Button {
                    // TODO: custom category sheet
                } label: {
                    VStack(spacing: Spacing.xs) {
                        Circle()
                            .fill(Color.bgCardHigh)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundStyle(Color.textSecondary)
                            )
                        Text("Thêm")
                            .font(.caption2)
                            .foregroundStyle(Color.textSecondary)
                    }
                }
            }
        }
    }

    // MARK: - Details (wallet, date, note)

    private var detailsSection: some View {
        VStack(spacing: 0) {
            // Wallet
            detailRow(
                icon: "creditcard.fill",
                label: "Tài khoản thanh toán"
            ) {
                Picker("", selection: $vm.selectedWalletId) {
                    ForEach(vm.wallets) { wallet in
                        Text(wallet.name).tag(wallet.id as UUID?)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .tint(Color.accentBlue)
            }

            Divider().background(Color.separator.opacity(0.3)).padding(.leading, 52)

            // Date
            detailRow(icon: "calendar", label: "Thời gian") {
                DatePicker("", selection: $vm.selectedDate, displayedComponents: [.date])
                    .labelsHidden()
                    .tint(Color.accentGreen)
            }

            Divider().background(Color.separator.opacity(0.3)).padding(.leading, 52)

            // Note
            detailRow(icon: "note.text", label: "Ghi chú") {
                TextField("Nhập ghi chú...", text: $vm.note)
                    .font(.subheadline)
                    .foregroundStyle(Color.textPrimary)
                    .multilineTextAlignment(.trailing)
            }
        }
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg)
                .stroke(Color.ghostBorder, lineWidth: 0.5)
        )
    }

    private func detailRow<Content: View>(icon: String, label: String, @ViewBuilder trailing: () -> Content) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.textSecondary)
                .frame(width: 20)

            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)

            Spacer()

            trailing()
        }
        .padding(.horizontal, Spacing.lg)
        .frame(height: 54)
    }

    // MARK: - Save

    private func saveTransaction() async {
        guard let uid = auth.currentUser?.id else { return }
        let success = await vm.save(userId: uid)
        if success {
            Haptic.success()
            dismiss()
        }
    }
}

// MARK: - CategoryGridItem

struct CategoryGridItem: View {
    let category: Category
    var isSelected: Bool = false

    var body: some View {
        VStack(spacing: Spacing.xs) {
            CategoryIconView(
                symbol: category.icon,
                color: isSelected ? category.swiftUIColor : Color.textSecondary,
                size: 44
            )
            .scaleEffect(isSelected ? 1.08 : 1.0)
            .overlay(
                Circle()
                    .stroke(isSelected ? category.swiftUIColor : .clear, lineWidth: 2)
            )

            Text(category.name)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(isSelected ? category.swiftUIColor : Color.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .animation(AppAnimation.fast, value: isSelected)
    }
}

// MARK: - Preview

#Preview {
    AddTransactionView()
        .environment(AuthService())
        .preferredColorScheme(.dark)
}
