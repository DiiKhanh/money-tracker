import SwiftUI

// MARK: - MoneyTrackerApp
// Entry point. Injects AuthService as environment object for all views.

@main
struct MoneyTrackerApp: App {

    @State private var authService = AuthService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authService)
                .preferredColorScheme(.dark)  // Force dark mode — OLED-first design
                .onOpenURL { url in
                    // Handle OAuth redirect: moneytracker://auth/callback
                    Task {
                        try? await supabase.auth.session(from: url)
                    }
                }
        }
    }
}
