import Supabase
import Foundation

// MARK: - Supabase Singleton
//
// Setup:
// 1. Create Config.xcconfig (DO NOT commit):
//    SUPABASE_URL = https://your-project.supabase.co
//    SUPABASE_ANON_KEY = your-anon-key
//
// 2. Add to .gitignore:
//    *.xcconfig
//    Config.xcconfig
//
// 3. Reference in Info.plist:
//    SUPABASE_URL  → $(SUPABASE_URL)
//    SUPABASE_ANON_KEY → $(SUPABASE_ANON_KEY)

private enum SupabaseConfig {
    static var url: URL {
        guard
            let urlString = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String,
            !urlString.isEmpty,
            let url = URL(string: urlString)
        else {
            // Development fallback — replace before first run
            return URL(string: "https://placeholder.supabase.co")!
        }
        return url
    }

    static var anonKey: String {
        guard
            let key = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String,
            !key.isEmpty
        else {
            return "placeholder-key"
        }
        return key
    }
}

let supabase = SupabaseClient(
    supabaseURL: SupabaseConfig.url,
    supabaseKey: SupabaseConfig.anonKey,
    options: SupabaseClientOptions(
        auth: .init(
            flowType: .pkce,
            redirectToURL: URL(string: "moneytracker://auth/callback")
        )
    )
)
