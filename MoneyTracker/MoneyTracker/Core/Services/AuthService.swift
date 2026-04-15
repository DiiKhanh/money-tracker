import Foundation

// MARK: - AppUser (stub — replaces Supabase.User)

struct AppUser {
    let id: UUID
    let email: String?
}

// MARK: - AuthService

@Observable
final class AuthService {

    private(set) var currentUser: AppUser? = nil
    private(set) var isLoading: Bool = false
    private(set) var error: String? = nil

    var isAuthenticated: Bool { currentUser != nil }

    // MARK: Sign Up

    func signUp(email: String, password: String, displayName: String? = nil) async throws {
        isLoading = true
        defer { isLoading = false }
        // Stub: auto-succeed
        currentUser = AppUser(id: UUID(), email: email)
    }

    // MARK: Sign In

    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        // Stub: auto-succeed
        currentUser = AppUser(id: UUID(), email: email)
    }

    // MARK: Sign In with Google

    func signInWithGoogle() async throws {
        isLoading = true
        defer { isLoading = false }
        currentUser = AppUser(id: UUID(), email: "google@example.com")
    }

    // MARK: Sign Out

    func signOut() async throws {
        currentUser = nil
    }

    // MARK: Reset Password

    func resetPassword(email: String) async throws {
        // Stub: no-op
    }
}
