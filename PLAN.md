# Money Tracker iOS App — Kế hoạch Phát triển Chi tiết

> **Cập nhật lần cuối:** 2026-04-15
> **Developer:** Beginner/Intermediate Swift
> **Mục tiêu:** iPhone app hoàn chỉnh, sẵn sàng cho AI integration

---

## Mục lục

1. [Tổng quan dự án](#1-tổng-quan-dự-án)
2. [Kiến trúc & Tech Stack](#2-kiến-trúc--tech-stack)
3. [Cấu trúc thư mục](#3-cấu-trúc-thư-mục)
4. [Database Schema (Supabase)](#4-database-schema-supabase)
5. [Setup ban đầu](#5-setup-ban-đầu)
6. [Phase 1 — MVP Core](#6-phase-1--mvp-core)
7. [Phase 2 — Extended Features](#7-phase-2--extended-features)
8. [Phase 3 — Advanced UX](#8-phase-3--advanced-ux)
9. [Phase 4 — AI Features](#9-phase-4--ai-features)
10. [Lộ trình học Swift](#10-lộ-trình-học-swift)
11. [Rủi ro & Cách giảm thiểu](#11-rủi-ro--cách-giảm-thiểu)

---

## 1. Tổng quan dự án

**Money Tracker** là ứng dụng quản lý tài chính cá nhân cho iPhone, cho phép người dùng theo dõi thu chi hàng ngày, phân tích xu hướng chi tiêu, và (trong tương lai) nhận tư vấn tài chính từ AI.

### Mục tiêu từng giai đoạn

| Giai đoạn | Mô tả | Timeline |
|-----------|-------|----------|
| Phase 1 | MVP: xác thực + giao dịch cơ bản + ví | 6–8 tuần |
| Phase 2 | Extended: ngân sách, biểu đồ, nhiều ví, realtime | 6–8 tuần |
| Phase 3 | Advanced UX: widgets, báo cáo, hóa đơn | 4–6 tuần |
| Phase 4 | AI: chatbot phân tích, gợi ý tài chính | 6–8 tuần |

---

## 2. Kiến trúc & Tech Stack

### Tech Stack

| Tầng | Công nghệ | Ghi chú |
|------|-----------|---------|
| UI | SwiftUI | iOS 17+, declarative |
| State Management | `@Observable` macro (iOS 17) | Thay thế `ObservableObject` |
| Navigation | NavigationStack | Type-safe routing |
| Backend | Supabase | Auth + DB + Storage + Realtime |
| SDK | supabase-swift 2.x | Swift Package Manager |
| Charts | Swift Charts (iOS 16+) | Native, không cần thư viện ngoài |
| Widgets | WidgetKit | Phần Phase 3 |
| Notifications | UserNotifications + APNs | Phần Phase 2 |
| Local Cache | SwiftData (iOS 17) | Offline support |
| Image Picker | PhotosUI | Built-in iOS |

### Kiến trúc: MVVM + Repository Pattern

```
View (SwiftUI)
  ↕ binds to
ViewModel (@Observable)
  ↕ calls
Repository (protocol)
  ↕ implements
SupabaseRepository / LocalRepository
  ↕ talks to
Supabase SDK / SwiftData
```

**Tại sao MVVM?**
- Phù hợp với SwiftUI's data flow
- Dễ test ViewModel độc lập với View
- Chuẩn bị tốt cho AI layer ở Phase 4

### Nguyên tắc thiết kế

1. **Offline-first**: SwiftData làm cache local, sync khi có mạng
2. **Single source of truth**: Supabase DB là nguồn chính
3. **Protocol-oriented**: Repository dùng protocol → dễ mock cho testing
4. **Error handling rõ ràng**: Mọi lỗi phải hiển thị user-friendly message

---

## 3. Cấu trúc thư mục

```
MoneyTracker/
├── MoneyTrackerApp.swift          # App entry point, DI container
├── Supabase/
│   └── SupabaseClient.swift       # Singleton client initialization
│
├── Core/
│   ├── Models/                    # Plain Swift structs (Codable)
│   │   ├── Transaction.swift
│   │   ├── Category.swift
│   │   ├── Wallet.swift
│   │   ├── Budget.swift
│   │   └── User.swift
│   ├── Repositories/              # Data access layer
│   │   ├── Protocols/
│   │   │   ├── TransactionRepository.swift
│   │   │   └── CategoryRepository.swift
│   │   └── Supabase/
│   │       ├── SupabaseTransactionRepository.swift
│   │       └── SupabaseCategoryRepository.swift
│   └── Services/
│       ├── AuthService.swift
│       ├── RealtimeService.swift
│       └── NotificationService.swift
│
├── Features/
│   ├── Auth/
│   │   ├── AuthViewModel.swift
│   │   ├── LoginView.swift
│   │   └── SignUpView.swift
│   ├── Dashboard/
│   │   ├── DashboardViewModel.swift
│   │   └── DashboardView.swift
│   ├── Transactions/
│   │   ├── TransactionListViewModel.swift
│   │   ├── TransactionListView.swift
│   │   ├── AddTransactionViewModel.swift
│   │   └── AddTransactionView.swift
│   ├── Categories/
│   │   ├── CategoryViewModel.swift
│   │   └── CategoryView.swift
│   ├── Budget/                    # Phase 2
│   ├── Charts/                    # Phase 2
│   ├── Wallets/                   # Phase 2
│   └── AI/                        # Phase 4
│
├── Shared/
│   ├── Components/                # Reusable SwiftUI views
│   │   ├── CurrencyTextField.swift
│   │   ├── CategoryPicker.swift
│   │   └── EmptyStateView.swift
│   ├── Extensions/
│   │   ├── Date+Formatting.swift
│   │   ├── Double+Currency.swift
│   │   └── Color+Hex.swift
│   └── Constants/
│       ├── AppColors.swift
│       └── AppFonts.swift
│
├── MoneyTrackerTests/
└── MoneyTrackerUITests/
```

---

## 4. Database Schema (Supabase)

### Bảng `profiles`

```sql
CREATE TABLE profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  avatar_url   TEXT,
  currency     TEXT NOT NULL DEFAULT 'VND',
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

-- RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own profile"
  ON profiles FOR ALL
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);
```

### Bảng `wallets`

```sql
CREATE TABLE wallets (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  type        TEXT NOT NULL CHECK (type IN ('cash', 'bank', 'credit_card', 'e_wallet')),
  balance     NUMERIC(15,2) NOT NULL DEFAULT 0,
  color       TEXT NOT NULL DEFAULT '#4CAF50',
  icon        TEXT NOT NULL DEFAULT 'wallet',
  is_default  BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- RLS
ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own wallets"
  ON wallets FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```

### Bảng `categories`

```sql
CREATE TABLE categories (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID REFERENCES profiles(id) ON DELETE CASCADE,
  -- NULL user_id = danh mục mặc định của hệ thống
  name        TEXT NOT NULL,
  icon        TEXT NOT NULL DEFAULT 'tag',
  color       TEXT NOT NULL DEFAULT '#2196F3',
  type        TEXT NOT NULL CHECK (type IN ('income', 'expense', 'both')),
  is_system   BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users see system + own categories"
  ON categories FOR SELECT
  USING (user_id IS NULL OR auth.uid() = user_id);
CREATE POLICY "Users manage own categories"
  ON categories FOR INSERT UPDATE DELETE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```

### Bảng `transactions`

```sql
CREATE TABLE transactions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  wallet_id       UUID NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
  category_id     UUID NOT NULL REFERENCES categories(id),
  type            TEXT NOT NULL CHECK (type IN ('income', 'expense')),
  amount          NUMERIC(15,2) NOT NULL CHECK (amount > 0),
  note            TEXT,
  date            DATE NOT NULL DEFAULT CURRENT_DATE,
  receipt_url     TEXT,
  is_recurring    BOOLEAN DEFAULT FALSE,
  recurring_id    UUID,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Index để query nhanh theo user + date
CREATE INDEX idx_transactions_user_date ON transactions(user_id, date DESC);

-- RLS
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own transactions"
  ON transactions FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```

### Bảng `budgets` (Phase 2)

```sql
CREATE TABLE budgets (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  category_id  UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  wallet_id    UUID REFERENCES wallets(id),
  limit_amount NUMERIC(15,2) NOT NULL CHECK (limit_amount > 0),
  period       TEXT NOT NULL CHECK (period IN ('monthly', 'weekly', 'yearly')),
  alert_at     NUMERIC(3,2) DEFAULT 0.8,
  month        INTEGER CHECK (month BETWEEN 1 AND 12),
  year         INTEGER,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE budgets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own budgets"
  ON budgets FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```

### Bảng `recurring_rules` (Phase 2)

```sql
CREATE TABLE recurring_rules (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  wallet_id      UUID NOT NULL REFERENCES wallets(id),
  category_id    UUID NOT NULL REFERENCES categories(id),
  type           TEXT NOT NULL CHECK (type IN ('income', 'expense')),
  amount         NUMERIC(15,2) NOT NULL,
  note           TEXT,
  frequency      TEXT NOT NULL CHECK (frequency IN ('daily', 'weekly', 'monthly', 'yearly')),
  start_date     DATE NOT NULL,
  end_date       DATE,
  next_run_date  DATE NOT NULL,
  is_active      BOOLEAN DEFAULT TRUE,
  created_at     TIMESTAMPTZ DEFAULT NOW()
);
```

### Database Functions hữu ích

```sql
-- Tính số dư ví
CREATE OR REPLACE FUNCTION get_wallet_balance(p_wallet_id UUID)
RETURNS NUMERIC AS $$
  SELECT
    COALESCE(SUM(CASE WHEN type = 'income' THEN amount ELSE -amount END), 0)
  FROM transactions
  WHERE wallet_id = p_wallet_id;
$$ LANGUAGE SQL SECURITY DEFINER;

-- Trigger cập nhật updated_at tự động
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_transactions_updated_at
  BEFORE UPDATE ON transactions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

### Supabase Storage Buckets (Phase 3)

```sql
INSERT INTO storage.buckets (id, name, public)
VALUES ('receipts', 'receipts', false);

CREATE POLICY "Users manage own receipts"
  ON storage.objects FOR ALL
  USING (bucket_id = 'receipts' AND auth.uid()::text = (storage.foldername(name))[1]);
```

---

## 5. Setup ban đầu

### Bước 1: Tạo Xcode Project

```
1. Mở Xcode → File → New → Project
2. Chọn: iOS → App
3. Product Name: MoneyTracker
4. Interface: SwiftUI | Language: Swift
5. BỎ CHECK: Use Core Data (dùng SwiftData)
6. Lưu vào: /Users/duykhanh/Workspaces/money-tracker
```

### Bước 2: Tạo Supabase Project

```
1. Truy cập https://supabase.com → New Project
2. Region: Southeast Asia (Singapore)
3. Vào Settings → API → lưu lại:
   - Project URL
   - anon public key
```

### Bước 3: Thêm Supabase SDK

```
Xcode → File → Add Package Dependencies
URL: https://github.com/supabase/supabase-swift.git
Version: 2.x (mới nhất)
Chọn product: Supabase
```

### Bước 4: Cấu hình secrets

Tạo `Config.xcconfig` (**KHÔNG commit lên git**):
```
SUPABASE_URL = https://your-project.supabase.co
SUPABASE_ANON_KEY = your-anon-key
```

Thêm vào `.gitignore`:
```
Config.xcconfig
```

Tạo `Supabase/SupabaseClient.swift`:
```swift
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: Bundle.main.infoDictionary!["SUPABASE_URL"] as! String)!,
    supabaseKey: Bundle.main.infoDictionary!["SUPABASE_ANON_KEY"] as! String,
    options: SupabaseClientOptions(
        auth: .init(flowType: .pkce)
    )
)
```

### Bước 5: Chạy SQL Schema

```
1. Supabase Dashboard → SQL Editor
2. Chạy lần lượt các CREATE TABLE từ mục 4
3. Bật Realtime: Database → Replication → bật bảng transactions
```

---

## 6. Phase 1 — MVP Core

**Mục tiêu:** App chạy được, user đăng nhập và ghi chép thu chi cơ bản.
**Timeline:** 6–8 tuần

---

### Tuần 1–2: Foundation & Auth

#### Tasks

- [ ] **T1.1** Tạo Xcode project + cấu trúc thư mục theo mục 3
- [ ] **T1.2** Thêm Supabase SDK + tạo `SupabaseClient.swift`
- [ ] **T1.3** Tạo toàn bộ SQL schema trên Supabase
- [ ] **T1.4** Implement `AuthService`:
  - `signUp(email:password:)` → tạo profile sau khi đăng ký
  - `signIn(email:password:)`
  - `signOut()`
  - `authStateChanges` stream
- [ ] **T1.5** Tạo `AuthViewModel` + `LoginView` + `SignUpView`
- [ ] **T1.6** `RootView`: kiểm tra session → redirect đúng màn hình

#### Code mẫu: AuthService

```swift
// Core/Services/AuthService.swift
import Supabase

@Observable
class AuthService {
    var currentUser: User? = nil

    init() {
        Task { await listenAuthChanges() }
    }

    func listenAuthChanges() async {
        for await (event, session) in supabase.auth.authStateChanges {
            switch event {
            case .signedIn, .initialSession:
                self.currentUser = session?.user
            case .signedOut:
                self.currentUser = nil
            default: break
            }
        }
    }

    func signIn(email: String, password: String) async throws {
        try await supabase.auth.signIn(email: email, password: password)
    }

    func signUp(email: String, password: String) async throws {
        let response = try await supabase.auth.signUp(email: email, password: password)
        if let user = response.user {
            try await supabase.from("profiles")
                .insert(["id": user.id.uuidString, "display_name": email])
                .execute()
        }
    }

    func signOut() async throws {
        try await supabase.auth.signOut()
    }
}
```

#### Success Criteria T1

- [ ] Đăng ký tài khoản → profile được tạo trong Supabase
- [ ] Đăng nhập thành công → chuyển đến màn hình chính
- [ ] Đăng xuất → quay về login
- [ ] Refresh app → giữ session (không bị logout)

---

### Tuần 3–4: Categories & Transactions

#### Tasks

- [ ] **T2.1** Seed dữ liệu categories mặc định (Ăn uống, Di chuyển, Giải trí, Lương...)
- [ ] **T2.2** Model `Transaction` + `Category` (Codable, Identifiable)
- [ ] **T2.3** `CategoryRepository` protocol + `SupabaseCategoryRepository`
- [ ] **T2.4** `CategoryView`: danh sách + tạo/sửa/xóa category
- [ ] **T2.5** `TransactionRepository` protocol + `SupabaseTransactionRepository`:
  - `fetchAll(userId:month:year:)`
  - `add(_:)` / `update(_:)` / `delete(id:)`
- [ ] **T2.6** `AddTransactionView` + `AddTransactionViewModel`:
  - Nhập số tiền (custom `CurrencyTextField`)
  - Chọn Thu/Chi | Chọn danh mục | Chọn ngày | Ghi chú
- [ ] **T2.7** `TransactionListView`: nhóm theo ngày
- [ ] **T2.8** Xóa giao dịch bằng swipe

#### Code mẫu: Transaction Model

```swift
// Core/Models/Transaction.swift
struct Transaction: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let walletId: UUID
    let categoryId: UUID
    var type: TransactionType
    var amount: Decimal
    var note: String?
    var date: Date
    var receiptUrl: String?
    let createdAt: Date

    enum TransactionType: String, Codable {
        case income, expense
    }

    enum CodingKeys: String, CodingKey {
        case id, type, amount, note, date
        case userId     = "user_id"
        case walletId   = "wallet_id"
        case categoryId = "category_id"
        case receiptUrl = "receipt_url"
        case createdAt  = "created_at"
    }
}
```

#### Success Criteria T2

- [ ] Tạo/sửa/xóa danh mục với icon + màu sắc
- [ ] Thêm giao dịch Thu/Chi mới
- [ ] Danh sách giao dịch nhóm theo ngày
- [ ] Xóa giao dịch bằng swipe

---

### Tuần 5–6: Dashboard & Wallet

#### Tasks

- [ ] **T3.1** `WalletRepository` + tạo ví mặc định khi đăng ký
- [ ] **T3.2** `DashboardView`:
  - Card tổng số dư (Thu - Chi tháng này)
  - Danh sách 5 giao dịch gần nhất
  - Shortcut thêm giao dịch
- [ ] **T3.3** Tính số dư bằng Supabase function
- [ ] **T3.4** `WalletView`: xem/tạo/sửa ví
- [ ] **T3.5** Tab bar: Dashboard / Transactions / Add (FAB) / Categories / Settings
- [ ] **T3.6** Settings: thông tin user, đơn vị tiền tệ, đăng xuất

#### Success Criteria T3 (MVP Complete)

- [ ] Dashboard hiển thị tổng quan tháng hiện tại
- [ ] Số dư chính xác = tổng Thu - tổng Chi
- [ ] Navigation 5 tabs hoạt động trơn tru
- [ ] Data persist sau khi đóng và mở lại app

---

## 7. Phase 2 — Extended Features

**Mục tiêu:** Tăng giá trị sử dụng với phân tích và tự động hóa.
**Timeline:** 6–8 tuần | **Dependencies:** Phase 1 hoàn thành

---

### Feature 2.1: Ngân sách (Budget)

#### Tasks

- [ ] Tạo bảng `budgets` + RLS
- [ ] `BudgetViewModel` tính % đã dùng = (tổng chi / hạn mức) × 100
- [ ] `BudgetView`: danh sách ngân sách + progress bar từng danh mục
- [ ] Local notification khi chi tiêu vượt 80% hạn mức

#### Logic cảnh báo

```swift
func checkBudgetAlert(for categoryId: UUID, newAmount: Decimal) async {
    guard let budget = await budgetRepo.fetch(categoryId: categoryId) else { return }
    let spent = await transactionRepo.totalSpent(categoryId: categoryId, month: currentMonth)
    let ratio = (spent + newAmount) / budget.limitAmount
    if ratio >= budget.alertAt {
        notificationService.send(
            title: "Cảnh báo ngân sách",
            body: "Bạn đã dùng \(Int(ratio * 100))% ngân sách cho \(budget.category.name)"
        )
    }
}
```

#### Success Criteria

- [ ] Thiết lập ngân sách theo danh mục
- [ ] Nhận thông báo khi gần chạm hạn mức
- [ ] Progress bar hiển thị đúng phần trăm

---

### Feature 2.2: Biểu đồ phân tích

#### Tasks

- [ ] `ChartViewModel`: aggregate data theo danh mục, theo tháng
- [ ] Pie Chart: phân bổ chi tiêu theo danh mục (Swift Charts)
- [ ] Bar Chart: so sánh thu/chi 6 tháng gần nhất
- [ ] Line Chart: xu hướng chi tiêu theo ngày trong tháng

#### Code mẫu: Pie Chart

```swift
import Charts

struct ExpensePieChart: View {
    let data: [CategorySummary]

    var body: some View {
        Chart(data) { item in
            SectorMark(
                angle: .value("Amount", item.amount),
                innerRadius: .ratio(0.6),
                angularInset: 2
            )
            .foregroundStyle(Color(hex: item.color))
        }
        .frame(height: 250)
    }
}
```

#### Success Criteria

- [ ] Pie chart hiển thị đúng tỷ lệ chi tiêu
- [ ] Bar chart so sánh được nhiều tháng
- [ ] Tap vào chart → xem chi tiết danh mục

---

### Feature 2.3: Giao dịch định kỳ

#### Tasks

- [ ] Tạo bảng `recurring_rules` + UI cài đặt
- [ ] BGTaskScheduler chạy mỗi ngày 8h sáng
- [ ] Logic kiểm tra `next_run_date` → tự tạo transaction
- [ ] Cập nhật `next_run_date` sau mỗi lần tạo

```swift
BGTaskScheduler.shared.register(
    forTaskWithIdentifier: "com.yourapp.recurring",
    using: nil
) { task in
    Task { await RecurringTaskHandler.run(task: task as! BGAppRefreshTask) }
}
```

#### Success Criteria

- [ ] Giao dịch tự động được tạo đúng ngày
- [ ] Có thể tắt/bật từng giao dịch định kỳ

---

### Feature 2.4: Nhiều ví

#### Tasks

- [ ] UI tạo/sửa ví: tên, loại, màu, icon
- [ ] Khi thêm giao dịch: chọn ví nguồn
- [ ] Dashboard: dropdown chọn ví hoặc "Tất cả"
- [ ] Chuyển tiền giữa các ví (tạo 2 transaction: expense + income)

#### Success Criteria

- [ ] Tạo được nhiều ví với loại khác nhau
- [ ] Số dư từng ví chính xác
- [ ] Chuyển tiền giữa ví không bị mất/nhân đôi

---

### Feature 2.5: Realtime Sync

#### Tasks

- [ ] `RealtimeService`: subscribe kênh `transactions`
- [ ] Khi có INSERT/UPDATE/DELETE từ thiết bị khác → cập nhật UI ngay
- [ ] Handle reconnect khi mất mạng

```swift
func subscribeToTransactions(userId: UUID, onUpdate: @escaping () -> Void) async {
    let channel = supabase.channel("user-\(userId)-transactions")
    channel.onPostgresChange(AnyAction.self, schema: "public", table: "transactions") { _ in
        onUpdate()
    }
    try? await channel.subscribe()
}
```

#### Success Criteria

- [ ] Thêm transaction trên simulator → hiện ngay trên device thật (và ngược lại)

---

## 8. Phase 3 — Advanced UX

**Mục tiêu:** Trải nghiệm người dùng đẳng cấp.
**Timeline:** 4–6 tuần | **Dependencies:** Phase 2 hoàn thành

### Feature 3.1: Lưu trữ hóa đơn

```
- PhotosUI → chụp/chọn ảnh từ Camera Roll
- Upload lên Supabase Storage bucket "receipts"
- Lưu URL vào transaction.receipt_url
- Thumbnail trong danh sách, full-screen khi tap
```

### Feature 3.2: Báo cáo tuần/tháng (Edge Functions)

```
- Supabase Edge Function (TypeScript) tổng hợp dữ liệu
- Gọi function từ app mỗi đầu tuần/tháng
- Format: tổng thu/chi, top danh mục, so sánh kỳ trước
- Push notification: "Báo cáo tháng 3 đã sẵn sàng"
```

### Feature 3.3: WidgetKit

```
Loại widget:
- Small:  Số dư ví chính
- Medium: 3 giao dịch gần nhất + số dư
- Large:  Mini dashboard (biểu đồ + giao dịch)
- Intent: Nút "Thêm nhanh" → deep link vào AddTransactionView

Data sharing: App Group + UserDefaults
```

### Feature 3.4: Search & Filter

```
- SearchBar trên TransactionListView
- Filter sheet: khoảng tiền, danh mục, ví, loại, khoảng ngày
- Kết quả live update khi gõ
```

### Feature 3.5: Dark Mode & Haptics

```swift
// Sau khi lưu thành công:
let impact = UIImpactFeedbackGenerator(style: .medium)
impact.impactOccurred()

// Khi xóa:
let notification = UINotificationFeedbackGenerator()
notification.notificationOccurred(.success)
```

---

## 9. Phase 4 — AI Features

**Mục tiêu:** Biến Money Tracker thành "trợ lý tài chính cá nhân".
**Timeline:** 6–8 tuần | **Dependencies:** Phase 3 hoàn thành + đủ data lịch sử

### Feature 4.1: LLM Chatbot phân tích chi tiêu

**Kiến trúc:**

```
[iOS App] → [Supabase Edge Function] → [Claude/OpenAI API]
                    ↑
            [Context: 3 tháng giao dịch của user]
```

**Edge Function (`analyze-spending`):**

```typescript
// supabase/functions/analyze-spending/index.ts
import { createClient } from '@supabase/supabase-js'
import Anthropic from '@anthropic-ai/sdk'

Deno.serve(async (req) => {
  const { userId, question } = await req.json()

  const { data: transactions } = await supabase
    .from('transactions')
    .select('*, categories(name)')
    .eq('user_id', userId)
    .gte('date', threeMonthsAgo)

  const response = await anthropic.messages.create({
    model: 'claude-haiku-4-5-20251001',  // Model nhỏ, cost thấp
    max_tokens: 1000,
    system: 'Bạn là trợ lý tài chính cá nhân. Phân tích dữ liệu và trả lời bằng tiếng Việt.',
    messages: [{
      role: 'user',
      content: `Dữ liệu: ${JSON.stringify(transactions)}\n\nCâu hỏi: ${question}`
    }]
  })

  return new Response(JSON.stringify({ answer: response.content[0].text }))
})
```

**iOS Chat UI:**

```
ChatView
├── MessageBubble (user / AI)
├── TypingIndicator (streaming)
└── QuickPromptChips:
    ["Tháng này chi nhiều gì?", "So sánh tháng trước", "Gợi ý tiết kiệm"]
```

### Feature 4.2: RAG cho gợi ý tài chính

```
Knowledge base:
- Bài viết tiết kiệm tiền (embed + lưu Supabase pgvector)
- Quy tắc tài chính (50/30/20, FIRE...)

Flow:
1. User hỏi → embed câu hỏi
2. Tìm chunks liên quan trong pgvector
3. Truyền context vào LLM → câu trả lời có căn cứ

Setup:
CREATE EXTENSION IF NOT EXISTS vector;
ALTER TABLE knowledge_base ADD COLUMN embedding vector(1536);
```

### Feature 4.3: Smart Auto-Categorize

```
Khi user gõ ghi chú ("Grab về nhà", "Phở sáng nay"):
→ Gọi LLM với few-shot examples
→ Tự động chọn danh mục phù hợp
→ User confirm hoặc thay đổi
```

---

## 10. Lộ trình học Swift

### Tháng 1 (Song song Phase 1)

| Chủ đề | Tài nguyên | Áp dụng vào dự án |
|--------|------------|-------------------|
| SwiftUI basics: View, State, Binding | Apple Tutorials, Hacking with Swift | LoginView, AddTransactionView |
| `@Observable` macro | WWDC 2023 - Discover Observation in SwiftUI | AuthService, ViewModels |
| NavigationStack | Hacking with Swift | Tab bar + deep links |
| async/await | Swift concurrency docs | Tất cả API calls |
| Codable / JSONDecoder | Swift docs | Transaction, Category models |

### Tháng 2 (Song song Phase 2)

| Chủ đề | Tài nguyên | Áp dụng vào dự án |
|--------|------------|-------------------|
| Swift Charts | Apple Developer docs | Pie/Bar/Line charts |
| Protocol & Generics | Swift Book Ch.21–23 | Repository pattern |
| Error handling (Result, throws) | Hacking with Swift | Network errors |
| Background Tasks | Apple docs BGTaskScheduler | Giao dịch định kỳ |
| UserNotifications | Apple docs | Cảnh báo ngân sách |

### Tháng 3–4 (Song song Phase 3)

| Chủ đề | Tài nguyên | Áp dụng vào dự án |
|--------|------------|-------------------|
| SwiftData | WWDC 2023 + Hacking with Swift | Local cache |
| WidgetKit | Apple Developer tutorials | Widget số dư |
| PhotosUI | Apple docs | Upload hóa đơn |
| XCTest / Swift Testing | Swift Testing book | Unit test ViewModels |

### Tips học hiệu quả

```
1. Học bằng cách build: Mỗi concept mới → thử ngay trong dự án này
2. Khi bị kẹt, thứ tự ưu tiên:
   a) Apple Developer Documentation (developer.apple.com)
   b) Hacking with Swift (hackingwithswift.com)
   c) Swift Forums (forums.swift.org)
   d) Stack Overflow
3. Đọc error message chậm lại: Swift compiler rất tường minh
4. Commit thường xuyên: mỗi feature nhỏ = 1 commit → dễ rollback
5. Dùng Canvas preview → không cần build full app để xem UI
```

---

## 11. Rủi ro & Cách giảm thiểu

| # | Rủi ro | Khả năng | Tác động | Cách giảm thiểu |
|---|--------|----------|----------|-----------------|
| R1 | SwiftData conflict với Supabase khi offline sync | Trung bình | Cao | SwiftData chỉ làm read cache; Supabase là source of truth duy nhất |
| R2 | Supabase free tier giới hạn (500MB DB, 1GB storage) | Thấp | Trung bình | Theo dõi usage dashboard; nén ảnh trước khi upload |
| R3 | RLS policy sai → data leak giữa users | Thấp | Rất cao | Test kỹ với 2 tài khoản test; dùng Supabase RLS checker |
| R4 | App bị reject vì Google Sign-In sai cấu hình | Trung bình | Trung bình | Test trên TestFlight; đọc kỹ App Store review guidelines |
| R5 | Background task không chạy (iOS kill app) | Trung bình | Thấp | Backup: kiểm tra recurring khi app mở lại |
| R6 | Complexity tăng cao khi nhiều ví + nhiều loại | Cao | Trung bình | Giữ Phase 1 với 1 ví; mở rộng dần sau |
| R7 | LLM API cost vượt kiểm soát (Phase 4) | Trung bình | Trung bình | Rate limit per user; dùng model nhỏ (Haiku) |
| R8 | Không đủ thời gian do học Swift cùng lúc | Cao | Cao | Timeline thực tế: Phase 1 = 6–8 tuần, không phải 2 tuần |

### Nguyên tắc khi bị kẹt

```
1. Bị kẹt < 30 phút  → Tự tìm (docs, StackOverflow)
2. Bị kẹt 30–60 phút → Hỏi AI (Claude) với context cụ thể
3. Bị kẹt > 1 giờ    → Đơn giản hóa requirement, tìm giải pháp thay thế
4. KHÔNG bao giờ bỏ qua lỗi để "giải quyết sau"
```

---

## Checklist trước khi submit App Store

- [ ] Privacy Policy URL (bắt buộc nếu có auth)
- [ ] App Store screenshots (6.7" + 6.5" + iPad nếu support)
- [ ] TestFlight beta test ít nhất 1 tuần
- [ ] Kiểm tra trên iOS 17.0 (minimum) và iOS mới nhất
- [ ] Không hardcode API keys trong source code
- [ ] Handle tất cả network errors gracefully (no crashes)
- [ ] Memory leaks check bằng Instruments → Leaks
- [ ] Accessibility: VoiceOver + Dynamic Type test

---

*Kế hoạch này là living document — cập nhật khi có thay đổi yêu cầu hoặc học được kiến thức mới.*
