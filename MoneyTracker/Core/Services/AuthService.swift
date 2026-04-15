import Supabase
import Foundation

// MARK: - AuthService
// Handles authentication state and operations via Supabase Auth.

@Observable
final class AuthService {

    // MARK: Public State

    private(set) var currentUser: User? = nil
    private(set) var isLoading: Bool = false
    private(set) var error: String? = nil

    var isAuthenticated: Bool { currentUser != nil }

    // MARK: Init

    init() {
        Task { await listenAuthChanges() }
    }

    // MARK: Auth State Listener

    private func listenAuthChanges() async {
        for await (event, session) in supabase.auth.authStateChanges {
            await MainActor.run {
                switch event {
                case .initialSession, .signedIn, .tokenRefreshed, .userUpdated:
                    self.currentUser = session?.user
                case .signedOut, .passwordRecovery:
                    self.currentUser = nil
                default:
                    break
                }
            }
        }
    }

    // MARK: Sign Up

    func signUp(email: String, password: String, displayName: String? = nil) async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password
            )

            if let user = response.user {
                try await createProfile(userId: user.id, email: email, displayName: displayName)
            }
        } catch {
            let message = (error as? AuthError)?.localizedDescription ?? error.localizedDescription
            self.error = message
            throw error
        }
    }

    // MARK: Sign In

    func signIn(email: String, password: String) async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            try await supabase.auth.signIn(email: email, password: password)
        } catch {
            let message = (error as? AuthError)?.localizedDescription ?? error.localizedDescription
            self.error = mapAuthError(message)
            throw error
        }
    }

    // MARK: Sign In with Google

    func signInWithGoogle() async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }

        try await supabase.auth.signInWithOAuth(
            provider: .google,
            redirectTo: URL(string: "moneytracker://auth/callback")
        )
    }

    // MARK: Sign Out

    func signOut() async throws {
        isLoading = true
        defer { isLoading = false }
        try await supabase.auth.signOut()
    }

    // MARK: Reset Password

    func resetPassword(email: String) async throws {
        try await supabase.auth.resetPasswordForEmail(email)
    }

    // MARK: Private Helpers

    private func createProfile(userId: UUID, email: String, displayName: String?) async throws {
        let profile: [String: AnyEncodable] = [
            "id": AnyEncodable(userId.uuidString),
            "display_name": AnyEncodable(displayName ?? email.components(separatedBy: "@").first ?? email),
            "currency": AnyEncodable("VND")
        ]
        try await supabase
            .from("profiles")
            .upsert(profile)
            .execute()
    }

    private func mapAuthError(_ message: String) -> String {
        if message.contains("Invalid login credentials") {
            return "Email hoặc mật khẩu không đúng"
        } else if message.contains("Email not confirmed") {
            return "Vui lòng xác nhận email trước khi đăng nhập"
        } else if message.contains("User already registered") {
            return "Email này đã được đăng ký"
        }
        return message
    }
}

// MARK: - AnyEncodable helper

struct AnyEncodable: Encodable {
    private let encode: (Encoder) throws -> Void

    init<T: Encodable>(_ value: T) {
        self.encode = value.encode
    }

    func encode(to encoder: Encoder) throws {
        try encode(encoder)
    }
}
