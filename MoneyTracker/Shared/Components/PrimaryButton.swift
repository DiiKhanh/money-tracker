import SwiftUI

// MARK: - PrimaryButton
// Gradient green CTA button — from Stitch "The Sovereign Dark Aesthetic"
// Gradient: #44F3A9 → #00D68F at 135°

struct PrimaryButton: View {
    let title: String
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: {
            Haptic.tap()
            action()
        }) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(.black)
                } else {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.black)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                isDisabled
                    ? Color.accentGreen.opacity(0.4)
                    : Color.primaryGradient
            )
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        }
        .disabled(isLoading || isDisabled)
    }
}

// MARK: - SecondaryButton (Ghost)
// Glass fill — White @ 10%, ghost border

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            Haptic.light()
            action()
        }) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.lg)
                        .stroke(Color.ghostBorder, lineWidth: 1)
                )
        }
    }
}

// MARK: - DestructiveButton

struct DestructiveButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            Haptic.warning()
            action()
        }) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.accentRed)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.accentRed.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.lg)
                        .stroke(Color.accentRed.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Lưu giao dịch") {}
        PrimaryButton(title: "Loading...", isLoading: true) {}
        PrimaryButton(title: "Disabled", isDisabled: true) {}
        SecondaryButton(title: "Đã có tài khoản") {}
        DestructiveButton(title: "Đăng xuất") {}
    }
    .padding()
    .background(Color.bgBase)
}
