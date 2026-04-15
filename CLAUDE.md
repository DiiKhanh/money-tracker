# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.
---

## Project Overview

**MoneyTracker** — iOS personal finance app (iPhone, iOS 17+) built with SwiftUI + Supabase.
Design system: **"The Sovereign Dark Aesthetic"** (OLED black, emerald green, coral red).
Stack: SwiftUI · `@Observable` macro · Supabase Swift SDK v2 · Swift Charts · WidgetKit (Phase 3).

Reference files before any work:
- `PLAN.md` — phased roadmap (MVP → Extended → Advanced → AI), DB schema, setup steps
- `DESIGN.md` — full design system: color tokens, spacing, components, screen wireframes

---

## Architecture

**MVVM + Repository Pattern** — strict layering:

```
View (SwiftUI struct)
  └── ViewModel (@Observable class)
        └── Supabase SDK (direct calls, no repository abstraction yet at MVP)
```

- `MoneyTrackerApp.swift` — app entry; creates `AuthService` and injects via `.environment()`
- `Features/Root/RootView.swift` — session gate: `auth.isAuthenticated` → `MainTabView` or `LoginView`
- `Core/Services/AuthService.swift` — `@Observable`, owns `currentUser`, listens to `supabase.auth.authStateChanges`
- All Supabase calls use `async/await` directly in ViewModels (no repository layer at MVP phase)

### Key Design Decisions

1. **`@Observable` macro (iOS 17)** — not `ObservableObject`. All ViewModels use `@Observable final class`.
2. **Immutable models** — all `Core/Models/` are `struct`, never mutated in-place.
3. **`supabase` global** — singleton in `Supabase/SupabaseClient.swift`, initialized from `Info.plist` (never hardcoded).
4. **Color tokens in `AppTheme.swift`** — always use `Color.accentGreen`, `Color.bgCard`, etc. Never use hex literals in views.
5. **No divider lines** — separation via background tonal shifts only (`Color.bgCard` on `Color.bgBase`).

---

## Supabase

Tables (defined in `MoneyTracker/Supabase/schema.sql`):
`profiles` → `wallets` → `categories` → `transactions` → `budgets` → `recurring_rules`

All tables have **Row Level Security** enabled. Every policy uses `auth.uid()`.  
Categories with `user_id IS NULL` are system defaults (seeded in schema).

### Auth redirect URL
`moneytracker://auth/callback` — must be registered in Supabase Dashboard → Auth → URL Configuration.

---

## Secrets & Config

**Never commit secrets.** Config lives in `Config.xcconfig` (git-ignored):
```
SUPABASE_URL = https://xxx.supabase.co
SUPABASE_ANON_KEY = eyJ...
```
Reference in `Info.plist` as `$(SUPABASE_URL)` / `$(SUPABASE_ANON_KEY)`.  
`SupabaseClient.swift` reads from `Bundle.main.infoDictionary` — falls back to placeholder strings (app won't crash but won't auth).

---

## Code Conventions

### Swift / SwiftUI
- Views are `struct`, ViewModels are `@Observable final class`
- Use `Spacing.*`, `Radius.*`, `AppAnimation.*` from `AppTheme.swift` — never magic numbers
- All currency formatted via `Decimal.formattedVND` / `.formattedCompact` (defined in `Transaction.swift`)
- Haptics via `Haptic.*` helpers (never call `UIImpactFeedbackGenerator` inline)
- `@discardableResult` on ViewModel save methods that return `Bool`

### CodingKeys
All models map `snake_case` DB columns to `camelCase` Swift via explicit `CodingKeys` enum.  
Pattern: `case walletId = "wallet_id"`.

### Phase gating
Features marked `// Phase 2`, `// Phase 3` in PLAN.md are **placeholders** in current code. Do not implement ahead of phase without confirmation.

---

## Behavioral Guidelines

### Think Before Coding
- State assumptions explicitly. If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so and push back.

### Surgical Changes
- Touch only what the task requires. Match existing style.
- Remove only imports/variables made unused by **your** changes.

### Simplicity First
- No speculative abstractions. No repository layer until Phase 2 requires it.
- No error handling for impossible scenarios.
- If 200 lines could be 50, rewrite it.

### Goal-Driven Execution
Transform tasks into verifiable criteria before coding:
- "Add validation" → "write failing test, then make it pass"
- "Fix bug" → "reproduce in test, then fix implementation"

---

## Development Phases (current status)

| Phase | Status | Key files |
|-------|--------|-----------|
| Phase 1 MVP | 🟡 In progress | `Auth/`, `Dashboard/`, `Transactions/`, `Core/Models/` |
| Phase 2 Extended | ⬜ Not started | `Budget/`, `Charts/`, `Wallets/`, `Core/Services/RealtimeService` |
| Phase 3 Advanced | ⬜ Not started | `WidgetKit`, `Supabase Edge Functions`, `PhotosUI` |
| Phase 4 AI | ⬜ Not started | `Features/AI/`, Supabase Edge Functions + LLM |
