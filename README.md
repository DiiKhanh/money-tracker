<div align="center">
**Personal finance, reimagined as a curated gallery of your wealth.**

[![Swift](https://img.shields.io/badge/Swift-5.9-F05138?style=flat&logo=swift&logoColor=white)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-17%2B-000000?style=flat&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-5-0064DB?style=flat&logo=swift&logoColor=white)](https://developer.apple.com/xcode/swiftui/)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?style=flat&logo=supabase&logoColor=white)](https://supabase.com)
[![License](https://img.shields.io/badge/License-MIT-white?style=flat)](LICENSE)

<br/>

</div>

---

## What is this?

MoneyTracker treats financial data not as a spreadsheet, but as a **high-end editorial experience**. Every balance is a headline. Every transaction is a record in your personal ledger.

Built from scratch as a learning project in Swift — evolving from MVP to a full-featured app with real-time sync, analytics, recurring automation, and eventually AI-powered financial insights.

<br/>

## Design

> *"The Obsidian Ledger"* — Pure OLED blacks (#000000) and ultra-thin glass layers create a sense of infinite depth. Large, bold display typography for balances, contrasted with precision labels. Glassmorphism makes the UI float in a void.

| Token | Value | Use |
|-------|-------|-----|
| Background | `#000000` | Pure OLED base |
| Income | `#00D68F` | All positive values |
| Expense | `#FF6B6B` | All negative values |
| Action | `#4B8EFF` | Navigation, links, CTAs |
| Surface | `#1F1F1F` | Cards, sheets |
| Ghost Border | `rgba(255,255,255,0.10)` | Card outlines |

Typography is SF Pro Display for headers and **SF Pro Rounded** for all currency values — softer, more approachable.

<br/>

## Stack

```
┌─────────────────────────────────────────┐
│  SwiftUI (iOS 17+)     @Observable      │  UI Layer
├─────────────────────────────────────────┤
│  MVVM + ViewModel      Swift Charts     │  Logic Layer
├─────────────────────────────────────────┤
│  Supabase Swift SDK v2                  │  Data Layer
│  Auth · Database · Storage · Realtime   │
└─────────────────────────────────────────┘
```

- **`@Observable` macro** (iOS 17) — not the legacy `ObservableObject`
- **Swift Charts** — native, no third-party charting library
- **Row Level Security** — every Supabase table is locked by `auth.uid()`
- **PKCE flow** for OAuth (Google Sign-In)

<br/>

## Roadmap

```
Phase 1 — MVP Core                    [🟡 In Progress]
  ✅  Auth (Email + Google OAuth)
  ✅  Transaction CRUD
  ✅  Category management
  ✅  Dashboard with balance hero
  ✅  Wallet cards

Phase 2 — Extended                    [⬜ Planned]
  ◻   Budget limits + alerts
  ◻   Swift Charts analytics (Donut, Bar, Line)
  ◻   Recurring transactions
  ◻   Multi-wallet support
  ◻   Supabase Realtime sync

Phase 3 — Advanced UX                 [⬜ Planned]
  ◻   Receipt scanning (Supabase Storage)
  ◻   WidgetKit (balance widget, quick-add)
  ◻   Weekly/monthly reports (Edge Functions)
  ◻   Search & filter
  ◻   Haptics + Dark Mode polish

Phase 4 — AI                          [⬜ Future]
  ◻   LLM chatbot (analyze spending)
  ◻   RAG financial advisor (pgvector)
  ◻   Smart auto-categorization
```

<br/>

## Project Structure

```
MoneyTracker/
├── MoneyTrackerApp.swift          # Entry point, DI container
├── Supabase/
│   ├── SupabaseClient.swift       # Singleton (reads from Info.plist)
│   └── schema.sql                 # Full DB schema + RLS policies
├── Core/
│   ├── Models/                    # Codable value types
│   │   ├── Transaction.swift      # + Decimal.formattedVND extension
│   │   ├── Category.swift         # + default categories seed
│   │   ├── Wallet.swift           # + gradient colors per type
│   │   ├── Budget.swift           # + BudgetProgress runtime model
│   │   └── UserProfile.swift
│   └── Services/
│       └── AuthService.swift      # @Observable, authStateChanges listener
├── Features/
│   ├── Root/RootView.swift        # Session gate + floating tab bar
│   ├── Auth/LoginView.swift       # Login + SignUp + Google
│   ├── Dashboard/                 # Balance hero, wallets, transactions, budgets
│   └── Transactions/              # Add transaction sheet + ViewModel
└── Shared/
    ├── Theme/AppTheme.swift       # Color tokens, Spacing, Radius, Haptics
    └── Components/                # CategoryIconView, PrimaryButton, etc.
```

<br/>

## Getting Started

### Prerequisites

- Xcode 15.2+
- iOS 17.0+ simulator or device
- [Supabase](https://supabase.com) account (free tier works)

### 1. Clone

```bash
git clone https://github.com/yourusername/money-tracker.git
cd money-tracker
```

### 2. Create Supabase project

1. Go to [supabase.com](https://supabase.com) → New Project → Region: **Southeast Asia (Singapore)**
2. Go to **Settings → API**, copy your `Project URL` and `anon public` key
3. Go to **SQL Editor**, run the entire contents of `MoneyTracker/Supabase/schema.sql`
4. Go to **Authentication → Providers → Google** and enable it (optional for Phase 1 email auth)

### 3. Configure secrets

Create `Config.xcconfig` in the project root (**never commit this file**):

```ini
SUPABASE_URL = https://your-project-id.supabase.co
SUPABASE_ANON_KEY = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 4. Open in Xcode

```bash
open MoneyTracker.xcodeproj
```

In Xcode:
1. **File → Add Package Dependencies** → `https://github.com/supabase/supabase-swift.git` (v2.x)
2. Select target `MoneyTracker` → **Build Settings** → set `SUPABASE_URL` and `SUPABASE_ANON_KEY` via `Config.xcconfig`
3. In `Info.plist`, add two entries referencing `$(SUPABASE_URL)` and `$(SUPABASE_ANON_KEY)`
4. Set URL Scheme: `moneytracker` (for OAuth callback)

### 5. Run

Hit `⌘R`. The app starts on the Login screen. Create an account → data saves to Supabase.

<br/>

## Key Design Patterns

### Color — always tokens, never hex

```swift
// ✅ Good
Text("12.500.000 ₫").foregroundStyle(Color.accentGreen)

// ❌ Bad
Text("12.500.000 ₫").foregroundStyle(Color(hex: "#00D68F"))
```

### Money formatting

```swift
let balance: Decimal = 12_500_000
balance.formattedVND      // → "12.500.000 ₫"
balance.formattedCompact  // → "12.5M ₫"
```

### ViewModel pattern

```swift
@Observable
final class SomeViewModel {
    private(set) var items: [Item] = []
    var error: String? = nil

    func fetch(userId: UUID) async {
        // async/await directly to Supabase — no repository at MVP
        items = try await supabase.from("items").select()...
    }
}
```

### Cards — glass + ghost border

```swift
RoundedRectangle(cornerRadius: Radius.xl)
    .fill(.ultraThinMaterial)
    .overlay(
        RoundedRectangle(cornerRadius: Radius.xl)
            .stroke(Color.ghostBorder, lineWidth: 0.5)
    )
```

<br/>

## Database Schema (overview)

```
auth.users (Supabase managed)
    │
    ├── profiles        (id, display_name, currency)
    ├── wallets         (user_id, name, type, balance)
    ├── categories      (user_id NULL = system, name, icon, color, type)
    ├── transactions    (user_id, wallet_id, category_id, type, amount, date)
    ├── budgets         (user_id, category_id, limit_amount, alert_at)     ← Phase 2
    └── recurring_rules (user_id, frequency, next_run_date)               ← Phase 2
```

All tables use Postgres **Row Level Security** — users can only read/write their own rows.

<br/>

## Contributing

This is a personal learning project, but PRs are welcome.

1. Fork and create a feature branch: `git checkout -b feat/your-feature`
2. Follow the Swift conventions in `CLAUDE.md`
3. Reference `DESIGN.md` for any UI work — all colors and spacing must use tokens
4. Submit a PR with a description of what changed and why

<br/>

## Learning Resources

If you're learning Swift alongside this project:

| Topic | Resource |
|-------|----------|
| SwiftUI fundamentals | [Apple Developer Tutorials](https://developer.apple.com/tutorials/swiftui) |
| `@Observable` macro | [WWDC23 — Discover Observation](https://developer.apple.com/videos/play/wwdc2023/10149/) |
| Swift Charts | [Apple Charts docs](https://developer.apple.com/documentation/charts) |
| Supabase + Swift | [supabase-swift README](https://github.com/supabase/supabase-swift) |
| async/await | [Swift Concurrency docs](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/) |

<br/>
