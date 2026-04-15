import SwiftUI

// MARK: - LoginView
// Based on DESIGN.md Section 11.2 + Stitch design system

struct LoginView: View {

    @Environment(AuthService.self) private var auth

    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var displayName = ""
    @State private var showPassword = false
    @State private var shake = false

    var isFormValid: Bool {
        !email.isEmpty && password.count >= 6
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgBase.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.xxl) {
                        Spacer().frame(height: 60)

                        logoSection

                        fieldsSection

                        actionSection

                        Spacer().frame(height: 40)
                    }
                    .padding(.horizontal, Spacing.lg)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
    }

    // MARK: Logo

    private var logoSection: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 72, weight: .medium))
                .foregroundStyle(Color.accentGreen)
                .shadow(color: Color.accentGreen.opacity(0.4), radius: 20)

            Text("MoneyTracker")
                .font(.largeTitle.bold())
                .foregroundStyle(Color.textPrimary)

            Text(isSignUp ? "Tạo tài khoản mới" : "Chào mừng trở lại")
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
        }
    }

    // MARK: Fields

    private var fieldsSection: some View {
        VStack(spacing: Spacing.md) {
            if isSignUp {
                inputField(
                    placeholder: "Họ và tên",
                    symbol: "person.fill",
                    text: $displayName
                )
            }

            inputField(
                placeholder: "Email",
                symbol: "envelope.fill",
                text: $email,
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            )

            passwordField

            if !isSignUp {
                HStack {
                    Spacer()
                    Button("Quên mật khẩu?") {
                        // TODO: reset password
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.accentBlue)
                }
            }
        }
    }

    // MARK: Password Field

    private var passwordField: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "lock.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.textSecondary)
                .frame(width: 20)

            if showPassword {
                TextField("Mật khẩu", text: $password)
                    .textContentType(.password)
            } else {
                SecureField("Mật khẩu", text: $password)
                    .textContentType(.password)
            }

            Button {
                showPassword.toggle()
            } label: {
                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding(Spacing.lg)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md)
                .stroke(Color.ghostBorder, lineWidth: 1)
        )
        .modifier(ShakeEffect(animatableData: shake ? 1 : 0))
    }

    // MARK: Actions

    private var actionSection: some View {
        VStack(spacing: Spacing.lg) {
            if let errorMsg = auth.error {
                Text(errorMsg)
                    .font(.footnote)
                    .foregroundStyle(Color.accentRed)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            PrimaryButton(
                title: isSignUp ? "Đăng ký" : "Đăng nhập",
                isLoading: auth.isLoading,
                isDisabled: !isFormValid
            ) {
                Task { await submitForm() }
            }

            HStack(spacing: Spacing.lg) {
                Rectangle().fill(Color.separator).frame(height: 1)
                Text("hoặc").font(.caption).foregroundStyle(Color.textTertiary)
                Rectangle().fill(Color.separator).frame(height: 1)
            }

            googleButton

            toggleModeButton
        }
    }

    private var googleButton: some View {
        Button {
            Task {
                try? await auth.signInWithGoogle()
            }
        } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "globe")
                    .font(.system(size: 18, weight: .medium))
                Text("Tiếp tục với Google")
                    .font(.headline)
            }
            .foregroundStyle(Color.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.lg)
                    .stroke(Color.ghostBorder, lineWidth: 1)
            )
        }
    }

    private var toggleModeButton: some View {
        Button {
            withAnimation(AppAnimation.fast) {
                isSignUp.toggle()
            }
        } label: {
            HStack(spacing: 4) {
                Text(isSignUp ? "Đã có tài khoản?" : "Chưa có tài khoản?")
                    .foregroundStyle(Color.textSecondary)
                Text(isSignUp ? "Đăng nhập" : "Đăng ký")
                    .foregroundStyle(Color.accentBlue)
            }
            .font(.subheadline)
        }
    }

    // MARK: Submit

    private func submitForm() async {
        do {
            if isSignUp {
                try await auth.signUp(email: email, password: password, displayName: displayName.isEmpty ? nil : displayName)
            } else {
                try await auth.signIn(email: email, password: password)
            }
        } catch {
            withAnimation(AppAnimation.normal) { shake = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                shake = false
            }
        }
    }

    // MARK: Reusable Input

    private func inputField(
        placeholder: String,
        symbol: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil
    ) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.textSecondary)
                .frame(width: 20)

            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(Spacing.lg)
        .background(Color.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md)
                .stroke(Color.ghostBorder, lineWidth: 1)
        )
    }
}

// MARK: - ShakeEffect

struct ShakeEffect: AnimatableModifier {
    var animatableData: CGFloat

    func body(content: Content) -> some View {
        content.offset(x: sin(animatableData * .pi * 4) * 8)
    }
}

// MARK: - Preview

#Preview {
    LoginView()
        .environment(AuthService())
        .preferredColorScheme(.dark)
}
