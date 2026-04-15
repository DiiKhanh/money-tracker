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
                // onOpenURL: OAuth redirect — re-enable when Supabase is connected
        }
    }
}
