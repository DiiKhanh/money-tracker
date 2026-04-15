# MoneyTracker — Design System

> **Version:** 1.0 | **Platform:** iOS 17+ (iPhone) | **Framework:** SwiftUI
> **Design Direction:** Dark Luxury + OLED Optimized + Micro-interactions
> **Last updated:** 2026-04-15

---

## Mục lục

1. [Visual Theme & Atmosphere](#1-visual-theme--atmosphere)
2. [Color Palette & Roles](#2-color-palette--roles)
3. [Typography Rules](#3-typography-rules)
4. [Spacing & Grid System](#4-spacing--grid-system)
5. [Component Styling](#5-component-styling)
6. [Depth & Elevation](#6-depth--elevation)
7. [Iconography](#7-iconography)
8. [Motion & Micro-interactions](#8-motion--micro-interactions)
9. [Charts & Data Visualization](#9-charts--data-visualization)
10. [Layout Principles](#10-layout-principles)
11. [Screen Designs](#11-screen-designs)
12. [Accessibility](#12-accessibility)
13. [Do's and Don'ts](#13-dos-and-donts)

---

## 1. Visual Theme & Atmosphere

### Hướng thiết kế

**Dark Luxury Finance** — Cảm giác premium, đáng tin cậy, và hiện đại như Revolut, N26, hay Monzo phiên bản tối. Người dùng mở app và cảm thấy tiền bạc được quản lý nghiêm túc.

### Từ khóa mô tả cảm xúc

```
Trustworthy  •  Premium  •  Clean  •  Focused  •  OLED-dark  •  Tactile
```

### Nguồn cảm hứng

- **Revolut** — Card layout, dark mode, số liệu lớn
- **Apple Wallet** — Typography sắc nét, depth & blur
- **N26** — Clean dark, color-coded categories
- **Robinhood** — Chart green/red tương phản rõ

### Đặc trưng nhận diện

1. Nền OLED đen thuần (#000000) — tiết kiệm pin, contrast cực cao
2. Số dư lớn và nổi bật ở trung tâm mỗi màn hình chính
3. Màu xanh lá (#00D68F) cho thu nhập, đỏ san hô (#FF6B6B) cho chi tiêu
4. Glass card với blur effect (`.ultraThinMaterial` của SwiftUI)
5. Haptic feedback nhẹ trên mỗi tương tác chính

---

## 2. Color Palette & Roles

### Bảng màu chính

```swift
// Định nghĩa trong Assets.xcassets > Color Set
// Hỗ trợ Dark Mode tự động
```

| Tên biến | Dark Mode | Light Mode | Vai trò |
|----------|-----------|------------|---------|
| `bgPrimary` | #000000 | #F2F2F7 | Nền chính (OLED black / iOS System) |
| `bgSecondary` | #0D0D0D | #FFFFFF | Nền card, sheet |
| `bgTertiary` | #1C1C1E | #F2F2F7 | Nền grouped section |
| `textPrimary` | #FFFFFF | #000000 | Tiêu đề, số dư |
| `textSecondary` | #8E8E93 | #6C6C70 | Label phụ, ngày tháng |
| `textTertiary` | #48484A | #C7C7CC | Placeholder |
| `accentGreen` | #00D68F | #00A86B | Thu nhập, số dương, thành công |
| `accentRed` | #FF6B6B | #FF3B30 | Chi tiêu, số âm, cảnh báo |
| `accentGold` | #F5A623 | #D4870A | Budget warning, highlight |
| `accentBlue` | #0A84FF | #007AFF | CTA button, link |
| `separator` | #38383A | #C6C6C8 | Divider, border |
| `glassOverlay` | #FFFFFF10 | #00000008 | Glass card overlay |

### Màu danh mục mặc định (Category Colors)

```swift
enum CategoryColor: String, CaseIterable {
    case coral   = "#FF6B6B"   // Ăn uống
    case amber   = "#F5A623"   // Di chuyển
    case mint    = "#00D68F"   // Lương / Thu nhập
    case blue    = "#0A84FF"   // Mua sắm
    case purple  = "#AF52DE"   // Giải trí
    case teal    = "#5AC8FA"   // Sức khỏe
    case pink    = "#FF375F"   // Làm đẹp
    case orange  = "#FF9F0A"   // Gia đình
    case indigo  = "#5E5CE6"   // Giáo dục
    case gray    = "#8E8E93"   // Khác
}
```

### Màu ví (Wallet Colors)

```swift
// Gradient cho wallet card
let walletGradients = [
    ["#1a1a2e", "#16213e"],  // Navy — Tiền mặt
    ["#0f3460", "#533483"],  // Royal — Ngân hàng
    ["#1a1a2e", "#e94560"],  // Dark Red — Thẻ tín dụng
    ["#0d0d0d", "#00d68f"],  // Dark Green — Ví điện tử
]
```

---

## 3. Typography Rules

### Font Stack

> **Quy tắc chính:** Dùng SF Pro Display/Text của iOS — KHÔNG import font ngoài.
> SF Pro là font hệ thống Apple, render sắc nét nhất trên iPhone, hỗ trợ Dynamic Type sẵn có.

```swift
// Mapping design → SwiftUI Text Styles
let typography = [
    "balanceHero":    Font.system(size: 48, weight: .bold, design: .rounded),
    "title1":         Font.largeTitle.weight(.bold),         // 34pt Bold
    "title2":         Font.title.weight(.semibold),          // 28pt Semibold
    "title3":         Font.title2.weight(.semibold),         // 22pt Semibold
    "headline":       Font.headline,                          // 17pt Semibold
    "body":           Font.body,                              // 17pt Regular
    "callout":        Font.callout,                           // 16pt Regular
    "subheadline":    Font.subheadline,                       // 15pt Regular
    "footnote":       Font.footnote,                          // 13pt Regular
    "caption1":       Font.caption,                           // 12pt Regular
    "caption2":       Font.caption2,                          // 11pt Regular
    "moneyAmount":    Font.system(size: 24, weight: .semibold, design: .rounded),
    "categoryLabel":  Font.system(size: 13, weight: .medium),
]
```

### Quy tắc sử dụng

| Dùng cho | Font Style | Weight | Size |
|----------|-----------|--------|------|
| Số dư tổng (hero balance) | `.rounded` | Bold | 48pt |
| Số tiền giao dịch | `.rounded` | Semibold | 24pt |
| Tiêu đề màn hình | Default | Bold | 34pt |
| Tên danh mục | Default | Medium | 13pt |
| Ngày tháng | Default | Regular | 13pt |
| Ghi chú giao dịch | Default | Regular | 15pt |
| Label nút | Default | Semibold | 17pt |

### Formatting số tiền (VND)

```swift
extension Decimal {
    var formattedVND: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.maximumFractionDigits = 0
        let number = NSDecimalNumber(decimal: self)
        return (formatter.string(from: number) ?? "0") + " ₫"
    }

    // "1.250.000 ₫"   → số dư nhỏ
    // "12.5M ₫"       → số dư lớn (triệu rút gọn)
    var formattedCompact: String {
        if self >= 1_000_000_000 {
            return String(format: "%.1fB ₫", NSDecimalNumber(decimal: self / 1_000_000_000).doubleValue)
        } else if self >= 1_000_000 {
            return String(format: "%.1fM ₫", NSDecimalNumber(decimal: self / 1_000_000).doubleValue)
        }
        return formattedVND
    }
}
```

---

## 4. Spacing & Grid System

### Base Unit: 4pt

```swift
enum Spacing {
    static let xs:  CGFloat = 4    // Icon padding, chip internal
    static let sm:  CGFloat = 8    // List item gap, icon-text gap
    static let md:  CGFloat = 12   // Section padding, card internal
    static let lg:  CGFloat = 16   // Standard padding (hScreen)
    static let xl:  CGFloat = 20   // Card padding
    static let xxl: CGFloat = 24   // Section gap
    static let h:   CGFloat = 32   // Header gap
    static let hh:  CGFloat = 40   // Hero area
}
```

### Corner Radius

```swift
enum Radius {
    static let sm:   CGFloat = 8    // Button nhỏ, badge
    static let md:   CGFloat = 12   // Card nội dung
    static let lg:   CGFloat = 16   // Card chính, sheet
    static let xl:   CGFloat = 20   // Wallet card
    static let full: CGFloat = 999  // Pill button, avatar
}
```

### Safe Area & Tab Bar

```swift
// Luôn respect safe area:
// - Top:    Dynamic Island / Notch
// - Bottom: Tab bar (83pt) + home indicator (34pt)

// Content cuối trang cần padding bottom:
.padding(.bottom, 100) // Tab bar (49pt) + safe area (34pt) + extra (17pt)
```

---

## 5. Component Styling

### 5.1 Balance Card (Hero)

```
╔══════════════════════════════════════╗
║  Tổng số dư           Tháng 4/2026  ║
║                                      ║
║       12.500.000 ₫                   ║
║       ▲ +2.1M so với tháng trước     ║
║                                      ║
║  ↑ Thu    3.500.000    ↓ Chi  1M     ║
╚══════════════════════════════════════╝
```

```swift
struct BalanceCard: View {
    var body: some View {
        ZStack {
            // Glass background
            RoundedRectangle(cornerRadius: Radius.xl)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.xl)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: Spacing.md) {
                // Label + period selector
                // Hero balance number
                // Income / Expense row
            }
            .padding(Spacing.xl)
        }
        .shadow(color: .black.opacity(0.4), radius: 20, y: 10)
    }
}
```

### 5.2 Transaction Row

```
┌─────────────────────────────────────────┐
│  [icon bg]  Ăn trưa          -45.000 ₫  │
│   🟠 circle  Grab • Hôm nay    14:30    │
└─────────────────────────────────────────┘
```

```swift
// Màu amount: accentRed nếu expense, accentGreen nếu income
// Background: bgSecondary (#0D0D0D)
// Separator: 1pt, separator color, chỉ hiện giữa các row
// Swipe left: "Xóa" button (destructive red)
// Swipe right: "Sửa" button (blue)
// Tap: mở TransactionDetailSheet
```

**Quy tắc icon danh mục:**
- Hình tròn đường kính 40pt
- Background: màu danh mục với opacity 20%
- SF Symbol 18pt, màu danh mục 100%

```swift
struct CategoryIcon: View {
    let symbol: String  // SF Symbol name
    let color: Color

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 18, weight: .medium))
            .foregroundStyle(color)
            .frame(width: 40, height: 40)
            .background(color.opacity(0.18))
            .clipShape(Circle())
    }
}
```

### 5.3 Primary Button

```swift
struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.accentGreen)
                .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        }
    }
}
// Disabled: opacity 0.4
// Loading: ProgressView thay text + disabled
```

### 5.4 Secondary Button (Outline)

```swift
// Border: 1.5pt separator color
// Background: transparent
// Text: textPrimary
// Same size as Primary (56pt height)
```

### 5.5 Tab Bar

```
╔═════════════════════════════════════════╗
║  🏠      💳      ➕      📊      ⚙️   ║
║  Home   Trans   Add    Chart   Settings  ║
╚═════════════════════════════════════════╝
```

```swift
// Background: bgSecondary với blur (.regularMaterial)
// Active icon: accentBlue, filled SF Symbol
// Inactive icon: textSecondary, outline SF Symbol
// Nút Add (+) ở giữa: 56x56, accentGreen, shadow
// Không có label text dưới icon (để clean hơn)
// Floating style: không stick sát bottom edge
```

### 5.6 Input Field

```swift
struct MoneyInputField: View {
    @Binding var amount: String

    var body: some View {
        HStack {
            Text("₫")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.textSecondary)

            TextField("0", text: $amount)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
        }
        .padding(Spacing.lg)
        .background(Color.bgTertiary)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }
}
// Focus state: border 2pt accentBlue
// Error state: border 2pt accentRed + shake animation
```

### 5.7 Wallet Card (Scrollable)

```
╔══════════════════════════════════════╗
║  💳  Techcombank Savings             ║
║                                      ║
║       8.250.000 ₫                    ║
║                                      ║
║  ···  ···  ···  4521                 ║
╚══════════════════════════════════════╝
```

```swift
// Kích thước: width fillWidth - 32pt padding, height 180pt
// Background: LinearGradient từ walletGradients
// Border radius: Radius.xl (20pt)
// Số thẻ: Font.monospaced, caption
// Horizontal scroll trong horizontalScrollView
// PageIndicator dots bên dưới
```

### 5.8 Budget Progress Bar

```
Ăn uống          [████████░░░░░░░] 1.8M / 5M (36%)
```

```swift
// Track: bgTertiary, height 6pt, cornerRadius 3pt
// Fill: gradient
//   - 0–60%:  accentGreen → accentGold
//   - 60–80%: accentGold (warning)
//   - 80–100%: accentRed (danger)
// Animation: spring khi load hoặc cập nhật
```

### 5.9 Empty State

```swift
struct EmptyStateView: View {
    let icon: String      // SF Symbol
    let title: String
    let subtitle: String
    let action: (() -> Void)?  // Optional CTA

    // Icon: 64pt, textSecondary opacity 0.4
    // Title: headline, textSecondary
    // Subtitle: footnote, textTertiary
    // CTA Button (nếu có): secondary style
}
```

### 5.10 Sheet / Modal

```swift
// presentationDetents: [.medium, .large]
// presentationDragIndicator: .visible
// Background: bgSecondary
// Grab indicator: 5x36pt, separator color, opacity 0.5
// Padding top: Spacing.xl bên dưới grab indicator
```

---

## 6. Depth & Elevation

### Hệ thống tầng (Z-layer)

| Tầng | Dùng cho | Shadow |
|------|----------|--------|
| 0 | Background screens | None |
| 1 | Cards, rows | `radius: 8, y: 2, opacity: 0.3` |
| 2 | Floating buttons, popovers | `radius: 16, y: 6, opacity: 0.4` |
| 3 | Modals, sheets | `radius: 24, y: -4, opacity: 0.5` |
| 4 | Tab bar | `radius: 20, y: -2, opacity: 0.6` |

### Glass Material

```swift
// Trong SwiftUI dùng Material API:
.background(.ultraThinMaterial)   // Mờ nhất - overlay light
.background(.thinMaterial)        // Mờ vừa - card trên background
.background(.regularMaterial)     // Mờ chuẩn - tab bar, nav bar
.background(.thickMaterial)       // Ít mờ - sheet background

// Overlay thêm border để tăng depth:
.overlay(
    RoundedRectangle(cornerRadius: 16)
        .stroke(Color.white.opacity(0.08), lineWidth: 1)
)
```

### Sử dụng shadow đúng cách

```swift
// GOOD: shadow theo màu, không dùng black cứng
.shadow(color: Color.accentGreen.opacity(0.3), radius: 12)

// GOOD: Card elevation
.shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)

// BAD: quá nhiều shadow layers
// BAD: shadow quá đậm (opacity > 0.6)
```

---

## 7. Iconography

### SF Symbols — Mapping danh mục

```swift
enum CategorySymbol {
    static let mapping: [String: String] = [
        "Ăn uống":      "fork.knife",
        "Di chuyển":    "car.fill",
        "Mua sắm":      "bag.fill",
        "Sức khỏe":     "heart.fill",
        "Giải trí":     "popcorn.fill",
        "Gia đình":     "house.fill",
        "Giáo dục":     "book.fill",
        "Làm đẹp":      "sparkles",
        "Du lịch":      "airplane",
        "Lương":        "banknote.fill",
        "Tiền thưởng":  "star.fill",
        "Đầu tư":       "chart.line.uptrend.xyaxis",
        "Khác":         "ellipsis.circle.fill",
    ]
}
```

### SF Symbols — Navigation & UI

```swift
enum AppIcon {
    static let home      = "house.fill"
    static let list      = "list.bullet.rectangle.portrait.fill"
    static let add       = "plus"
    static let chart     = "chart.bar.fill"
    static let settings  = "gearshape.fill"
    static let wallet    = "creditcard.fill"
    static let budget    = "chart.pie.fill"
    static let income    = "arrow.down.circle.fill"
    static let expense   = "arrow.up.circle.fill"
    static let search    = "magnifyingglass"
    static let filter    = "line.3.horizontal.decrease.circle"
    static let edit      = "pencil"
    static let delete    = "trash.fill"
    static let camera    = "camera.fill"
    static let attach    = "paperclip"
    static let recurring = "arrow.clockwise"
    static let chevronRight = "chevron.right"
    static let checkmark = "checkmark.circle.fill"
}
```

### Quy tắc icon

- **Luôn dùng SF Symbols** — không dùng emoji làm icon UI
- Weight icon = weight font của context (headline = semibold)
- Icon trong navigation: 22pt
- Icon trong list row: 18pt (trong CategoryIcon 40pt circle)
- Icon trong tab bar: 24pt (selected), 22pt (unselected)
- Dùng `.fill` variant cho active/selected states

---

## 8. Motion & Micro-interactions

### Timing chuẩn

```swift
enum AnimationDuration {
    static let instant:  Double = 0.1   // Tap feedback
    static let fast:     Double = 0.2   // Toggle, switch
    static let normal:   Double = 0.3   // Card appear, transition
    static let slow:     Double = 0.5   // Hero number count-up
    static let slower:   Double = 0.8   // Page transition
}
```

### Spring Presets

```swift
// Button press
.animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)

// Card appear
.animation(.spring(response: 0.4, dampingFraction: 0.8), value: isVisible)

// List item
.animation(.spring(response: 0.35, dampingFraction: 0.75), value: items)

// Balance count-up
.animation(.easeOut(duration: 0.5), value: balance)
```

### Haptic Feedback Mapping

```swift
enum HapticStyle {
    // Thêm giao dịch thành công
    static func transactionAdded() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    // Xóa giao dịch
    static func transactionDeleted() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    // Nhấn nút chính
    static func buttonTap() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    // Tab bar tap
    static func tabTap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    // Budget warning
    static func budgetWarning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    // Swipe to delete
    static func swipeReveal() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }
}
```

### Hiệu ứng cụ thể

| Tương tác | Hiệu ứng | Duration |
|-----------|---------|----------|
| Mở app → Dashboard | Số dư count-up từ 0 | 0.8s ease-out |
| Thêm transaction | Row slide in từ dưới, số dư update | 0.3s spring |
| Xóa transaction (swipe) | Row slide out + fade | 0.25s ease-in |
| Chuyển tab | Cross-fade nhẹ | 0.2s ease |
| Pull to refresh | Native iOS style | System |
| Budget đạt 80% | Progress bar pulse (glow animation) | 1.5s loop |
| Swipe wallet card | Parallax header movement | Realtime |
| Sheet modal open | Bottom sheet spring up | 0.35s spring |

### Prefers Reduced Motion

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var animation: Animation {
    reduceMotion ? .easeInOut(duration: 0.01) : .spring(response: 0.35)
}
```

---

## 9. Charts & Data Visualization

### Thư viện: Swift Charts (native, iOS 16+)

### 9.1 Donut Chart — Phân bổ chi tiêu

```swift
// Dùng cho: tỷ lệ chi tiêu theo danh mục trong tháng
Chart(categoryData) { item in
    SectorMark(
        angle: .value("Amount", item.amount),
        innerRadius: .ratio(0.65),   // Donut hole 65%
        angularInset: 3              // Gap giữa sector
    )
    .foregroundStyle(item.color)
    .cornerRadius(4)
}
// Center: tổng chi tiêu + label "Chi tiêu"
// Legend: dưới chart, 2 cột, màu + tên + %
// Tap sector: highlight + show tooltip
```

### 9.2 Bar Chart — So sánh tháng

```swift
// Dùng cho: thu/chi 6 tháng gần nhất
Chart(monthlyData) { item in
    BarMark(
        x: .value("Month", item.month),
        y: .value("Amount", item.amount)
    )
    .foregroundStyle(item.type == .income ? Color.accentGreen : Color.accentRed)
    .cornerRadius(6)
}
// Grouped: income + expense side by side
// Y-axis: compact format (1M, 5M, ...)
// Tap bar: show exact value tooltip
```

### 9.3 Line/Area Chart — Xu hướng

```swift
// Dùng cho: xu hướng chi tiêu theo ngày trong tháng
Chart(dailyData) { item in
    AreaMark(
        x: .value("Date", item.date),
        y: .value("Amount", item.amount)
    )
    .foregroundStyle(
        LinearGradient(
            colors: [Color.accentBlue.opacity(0.4), .clear],
            startPoint: .top,
            endPoint: .bottom
        )
    )

    LineMark(
        x: .value("Date", item.date),
        y: .value("Amount", item.amount)
    )
    .foregroundStyle(Color.accentBlue)
    .lineStyle(StrokeStyle(lineWidth: 2))
    .interpolationMethod(.catmullRom)  // Smooth curve
}
// Drag gesture: crosshair cursor + tooltip
```

### Quy tắc chart

- Background chart: bgSecondary (#0D0D0D)
- Padding chart: Spacing.lg (16pt) mỗi cạnh
- Axis labels: caption2, textSecondary
- Grid lines: separator color, opacity 0.3
- **Tối đa 8 màu** cho chart một lúc — sau đó nhóm vào "Khác"
- Luôn có empty state khi không có data

---

## 10. Layout Principles

### 10.1 Content Hierarchy (quan trọng nhất → ít quan trọng)

```
1. Số tiền (balance / amount)    → Largest, most prominent
2. Tên giao dịch / danh mục      → Headline weight
3. Ngày giờ / ghi chú            → Secondary, smaller
4. Action buttons                 → Accessible but not competing
```

### 10.2 Màn hình Portrait Only

```swift
// Info.plist:
// UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
// Chỉ hỗ trợ portrait — finance app không cần landscape
```

### 10.3 Safe Area Handling

```swift
// ÚP DỤNG MỌI NƠI — không override safe area trừ background gradient
GeometryReader { geo in
    VStack {
        // Content
    }
    .padding(.top, geo.safeAreaInsets.top)
    .padding(.bottom, geo.safeAreaInsets.bottom + 83) // tab bar height
}

// Background color có thể extend ra safe area:
.ignoresSafeArea(edges: .top)  // Chỉ cho gradient header
```

### 10.4 Content Padding chuẩn

```swift
// Horizontal padding của content toàn app: 16pt (Spacing.lg)
// Padding giữa các section: 24pt (Spacing.xxl)
// Card internal padding: 20pt (Spacing.xl)
// List row height tối thiểu: 60pt (touch target ≥ 44pt)
```

### 10.5 Scroll Behavior

```swift
// Dashboard: ScrollView vertical
//   - Sticky header: BalanceCard (disappear khi scroll past)
//   - Recent transactions section
//   - Quick stats row
//
// Transaction List: LazyVStack trong ScrollView
//   - Group theo ngày (DateSection header)
//   - Infinite scroll / pagination (20 items/page)
//
// Charts: Non-scrollable per chart, tab between chart types
```

---

## 11. Screen Designs

### 11.1 Onboarding / Splash

```
┌─────────────────────┐
│                     │
│         💰          │
│    MoneyTracker     │  ← SF Pro Display Bold 34pt
│  Quản lý tài chính  │  ← Body, textSecondary
│     thông minh      │
│                     │
│  [Bắt đầu ngay]    │  ← PrimaryButton (accentGreen)
│  [Đã có tài khoản] │  ← SecondaryButton
│                     │
└─────────────────────┘
```

- Background: gradient từ #000000 → #0D1117
- Logo: SF Symbol "dollarsign.circle.fill" 80pt, accentGreen
- Animation: fade in từng element, stagger 0.1s

---

### 11.2 Login / Sign Up

```
┌─────────────────────┐
│  ←                  │
│                     │
│  Đăng nhập          │  ← LargeTitle Bold
│  Chào mừng trở lại  │  ← Subheadline, textSecondary
│                     │
│  ┌───────────────┐  │
│  │ 📧  Email     │  │  ← TextField
│  └───────────────┘  │
│  ┌───────────────┐  │
│  │ 🔒  Mật khẩu  │  │  ← SecureField
│  └───────────────┘  │
│                     │
│  Quên mật khẩu?     │  ← accentBlue, trailing
│                     │
│  [    Đăng nhập   ] │  ← PrimaryButton
│                     │
│  ─── hoặc ───       │
│                     │
│  [  🍎 Apple ID  ]  │  ← Black button với Apple logo
│  [  G  Google    ]  │  ← White/gray button
│                     │
└─────────────────────┘
```

- Keyboard avoidance: ScrollView + `.ignoresSafeArea(.keyboard)`
- Show/hide password: SF Symbol "eye.slash.fill"
- Error state: field border accentRed + error label dưới field

---

### 11.3 Dashboard (Tab 1)

```
┌─────────────────────────────────┐
│ MoneyTracker        🔔  👤      │  ← Large title + icons
│                                 │
│ ╔═══════════════════════════╗   │
│ ║ Tổng số dư   Tháng 4/2026 ║   │  ← BalanceCard (glass)
│ ║                           ║   │
│ ║      12.500.000 ₫         ║   │
│ ║   ▲ +15% tháng trước      ║   │
│ ║                           ║   │
│ ║  ↑ 3.5M Thu  ↓ 1M Chi    ║   │
│ ╚═══════════════════════════╝   │
│                                 │
│ ← [Ví 1] [Ví 2] [Ví 3] →      │  ← Wallet horizontal scroll
│                                 │
│ Giao dịch gần đây     Xem tất  │
│ ┌───────────────────────────┐   │
│ │ 🟠 Ăn trưa     -45.000 ₫ │   │
│ │ 🟣 Netflix      -139.000 ₫│   │
│ │ 🟢 Lương    +15.000.000 ₫ │   │
│ └───────────────────────────┘   │
│                                 │
│ Ngân sách tháng này             │
│ [██████░░░░] Ăn uống 36%       │
│ [████░░░░░░] Di chuyển 24%     │
│                                 │
│ ─────[🏠]──[💳]──[➕]──[📊]──[⚙️]─ │
└─────────────────────────────────┘
```

**Behavior:**
- Pull to refresh: cập nhật balance + transactions
- BalanceCard: tap vào period → date picker popover
- Wallet cards: horizontal scroll, tap → filter transactions
- "Xem tất" → push TransactionListView
- Budget bars: tap → push BudgetDetailView

---

### 11.4 Transaction List (Tab 2)

```
┌─────────────────────────────────┐
│ Giao dịch          🔍  ≡filter  │
│                                 │
│ [Thu nhập] [Chi tiêu] [Tất cả] │  ← Segmented control
│                                 │
│ Hôm nay • 15 tháng 4           │  ← Section header
│ ┌───────────────────────────┐   │
│ │🟠 Ăn sáng     -35.000 ₫  │   │
│ │    Bún bò       08:30      │   │
│ └───────────────────────────┘   │
│ ┌───────────────────────────┐   │
│ │🔵 Lương    +15.000.000 ₫  │   │
│ │    Tháng 4      09:00      │   │
│ └───────────────────────────┘   │
│                                 │
│ Hôm qua • 14 tháng 4           │
│ ...                             │
│                                 │
└─────────────────────────────────┘
```

**Search:**
- SearchBar xuất hiện khi scroll lên hoặc tap icon
- Real-time filter by note text
- Highlight matching text

**Filter Sheet (bottom sheet .medium):**
```
Loại: [Thu nhập ✓] [Chi tiêu ✓]
Ví:   [Tất cả ▼]
Danh mục: [chip list, multi-select]
Khoảng tiền: [slider range]
Khoảng thời gian: [DateRangePicker]
[Áp dụng]  [Xóa filter]
```

---

### 11.5 Add Transaction (Center FAB / Tab 3)

```
┌─────────────────────────────────┐
│ ×  Giao dịch mới              ✓ │  ← Dismiss + Save
│                                 │
│ ┌─────────────┬─────────────┐   │
│ │  Chi tiêu   │  Thu nhập   │   │  ← Segmented, red/green
│ └─────────────┴─────────────┘   │
│                                 │
│              ₫                  │
│         0                       │  ← Big number input
│         [Nhập số tiền...]       │
│                                 │
│ ─────────────────────────────── │
│ Danh mục                        │
│ ┌──┐┌──┐┌──┐┌──┐┌──┐┌──┐       │  ← Category grid
│ │🍜││🚗││🛍️││❤️││🎬││···│       │
│ └──┘└──┘└──┘└──┘└──┘└──┘       │
│                                 │
│ Ví                [Ví tiền mặt ▼│
│ Ngày              [Hôm nay   📅]│
│ Ghi chú           [Nhập ghi chú]│
│ Hóa đơn           [📷 Chụp ảnh ]│
│                                 │
│ [    Lưu giao dịch    ]         │
└─────────────────────────────────┘
```

**UX chi tiết:**
- Mở bằng cách tap FAB (+) → present as sheet
- Focus vào input số tiền ngay khi mở
- Custom number pad (không dùng system keyboard)
- Danh mục: grid 4 cột, tự scroll nếu nhiều
- Selected category: border accentBlue + scale 1.05
- Lưu thành công: dismiss sheet + haptic + balance update

---

### 11.6 Charts / Analytics (Tab 4)

```
┌─────────────────────────────────┐
│ Phân tích                       │
│                                 │
│ [Tháng này ▼]  [2026 ▼]        │  ← Period selector
│                                 │
│ ┌── Tổng quan ──────────────┐   │
│ │ Thu: 15M ₫  Chi: 8.2M ₫  │   │
│ │ Tiết kiệm: 6.8M ₫ (45%)  │   │
│ └───────────────────────────┘   │
│                                 │
│ Chi tiêu theo danh mục         │
│     ┌─────────────┐             │
│     │   donut     │             │  ← Donut chart
│     │  chart      │             │
│     └─────────────┘             │
│ ● Ăn uống 36%   ● Di chuyển 24%│
│                                 │
│ [Chi tiêu][Thu nhập][So sánh]  │  ← Tab để chuyển chart
│                                 │
│ Thu/Chi 6 tháng gần đây        │
│ ┌─────────────────────────────┐ │
│ │  bar chart grouped          │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

---

### 11.7 Budget Screen

```
┌─────────────────────────────────┐
│ Ngân sách                    ➕  │
│                                 │
│ Tháng 4 / 2026        [Sửa]    │
│                                 │
│ Tổng ngân sách: 10.000.000 ₫   │
│ Đã dùng: 4.200.000 ₫ (42%)     │
│ [██████████░░░░░░░░░░░] 42%    │
│                                 │
│ ── Theo danh mục ──────────     │
│ ┌───────────────────────────┐   │
│ │ 🟠 Ăn uống                │   │
│ │ 1.800.000 / 5.000.000 ₫   │   │
│ │ [████████░░░░░░░░░] 36%   │   │
│ └───────────────────────────┘   │
│ ┌───────────────────────────┐   │
│ │ 🟡 Di chuyển    ⚠️ 82%   │   │  ← Warning state
│ │ 1.640.000 / 2.000.000 ₫   │   │
│ │ [█████████████████░] 82%  │   │
│ └───────────────────────────┘   │
└─────────────────────────────────┘
```

---

### 11.8 Settings Screen

```
┌─────────────────────────────────┐
│ Cài đặt                         │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ 👤  Nguyễn Văn A            │ │  ← Profile card
│ │ khanh@example.com          > │ │
│ └─────────────────────────────┘ │
│                                 │
│ ── Tùy chọn ────────────        │
│ Đơn vị tiền tệ          VND >  │
│ Thông báo              Bật  ●  │  ← Toggle
│ Dark Mode              Tự động  │
│ Touch ID / Face ID     Bật  ●  │
│                                 │
│ ── Dữ liệu ────────────         │
│ Xuất báo cáo               >   │
│ Sao lưu dữ liệu            >   │
│                                 │
│ ── Thông tin ───────────        │
│ Phiên bản app         1.0.0    │
│ Chính sách bảo mật        >    │
│                                 │
│ [    Đăng xuất    ]            │  ← Destructive, red
└─────────────────────────────────┘
```

---

## 12. Accessibility

### Tối thiểu bắt buộc

```swift
// 1. Tất cả interactive elements phải có accessibilityLabel
Button(action: addTransaction) { Image(systemName: "plus") }
    .accessibilityLabel("Thêm giao dịch mới")

// 2. Số tiền phải được đọc đúng
Text(amount.formattedVND)
    .accessibilityLabel("Số dư: \(amount.formattedVND)")

// 3. Color không phải indicator duy nhất
// BAD:  Chỉ dùng màu đỏ/xanh để phân biệt thu/chi
// GOOD: Dùng màu + icon (↑ ↓) + label text

// 4. Dynamic Type
.font(.body)  // Tự scale theo system font size
// KHÔNG dùng fixed pixel size trừ số dư hero

// 5. Minimum touch target 44x44pt
.frame(minWidth: 44, minHeight: 44)
```

### Contrast Ratios

| Combo | Ratio | Pass |
|-------|-------|------|
| White text on #000000 | 21:1 | ✅ AAA |
| accentGreen (#00D68F) on #000000 | 8.2:1 | ✅ AAA |
| textSecondary (#8E8E93) on #000000 | 4.6:1 | ✅ AA |
| accentRed (#FF6B6B) on #000000 | 5.1:1 | ✅ AA |

### VoiceOver Navigation Order

```
Dashboard:
1. Balance card → amount, period, income, expense
2. Wallet cards (scroll hint)
3. Recent transactions header + "Xem tất cả"
4. Transaction rows (category, name, amount, time)
5. Budget progress bars
6. Tab bar
```

---

## 13. Do's and Don'ts

### ✅ DO

**Layout & Spacing**
- Padding horizontal **luôn là 16pt** — nhất quán toàn app
- Card corner radius **16–20pt** — không ít hơn, không nhiều hơn
- Touch target tối thiểu **44x44pt** cho mọi interactive element
- Respect **Dynamic Island** — không đặt content quan trọng sát top

**Typography**
- Số tiền dùng **font `.rounded`** — dễ đọc hơn cho số
- **Bold** cho số tiền, Regular cho label, Medium cho category
- Số âm: tiền tố "-" + màu đỏ; Số dương: "+", màu xanh
- Rút gọn số lớn: "15.5M ₫" thay vì "15.500.000 ₫" trong compact view

**Interaction**
- **Haptic feedback** sau mỗi hành động quan trọng
- Loading state cho mọi async operation (skeleton hoặc spinner)
- Undo cho destructive actions (xóa → show snackbar "Đã xóa · Hoàn tác")
- Swipe to delete chỉ reveal sau khi **swipe ≥ 30% row width**

**Color**
- Income: luôn **accentGreen (#00D68F)**
- Expense: luôn **accentRed (#FF6B6B)**
- CTA button: **accentGreen** (positive action) hoặc **accentBlue** (neutral)
- Destructive actions: **accentRed** — chỉ dùng cho xóa, logout

---

### ❌ DON'T

**Layout**
- ❌ Overlay content lên tab bar (luôn padding bottom đủ)
- ❌ Dùng `fixed height` cho text container — dùng `minHeight`
- ❌ Horizontal scroll quá 3 screens — user mất orientation
- ❌ Modal over modal — tối đa 1 sheet, 1 alert cùng lúc

**Typography**
- ❌ Quá 3 font weights trên 1 màn hình
- ❌ ALL CAPS cho body text — chỉ dùng cho label ngắn (TAB, SECTION HEADER)
- ❌ Text nhỏ hơn 12pt (caption2) cho nội dung quan trọng
- ❌ White text trên light background mà không check contrast

**Color**
- ❌ Dùng màu gradient phức tạp cho text
- ❌ Quá 5 màu khác nhau trong 1 màn hình
- ❌ Nền trắng thuần (#FFFFFF) trong dark mode — dùng #F2F2F7
- ❌ Màu accentGold cho CTA thông thường — chỉ dùng cho warning/premium

**Interaction**
- ❌ Haptic loop liên tục — gây phiền, chỉ dùng 1 lần per action
- ❌ Animation dài hơn 500ms — cảm giác lag
- ❌ Empty state không có CTA — user không biết làm gì
- ❌ Form submit khi còn trống — disable button, validate ngay khi type

**Architecture**
- ❌ Hardcode màu hex trong component — luôn dùng từ color token
- ❌ Font size hardcode — dùng `.font(.headline)` style thay vì `.font(.system(size: 17))`
- ❌ `GeometryReader` lồng nhau nhiều lớp — gây layout bug

---

## Checklist trước khi build từng màn hình

### Visual
- [ ] Nền đúng màu (bgPrimary / bgSecondary)
- [ ] Text color đúng role (primary / secondary / tertiary)
- [ ] Amount color đúng (green income / red expense)
- [ ] Icon dùng SF Symbols, đúng weight, đúng size
- [ ] Corner radius nhất quán (Radius enum)

### Interaction
- [ ] Touch target ≥ 44x44pt
- [ ] Loading state cho mọi async call
- [ ] Empty state với CTA
- [ ] Error state hiển thị message rõ ràng
- [ ] Haptic feedback đúng chỗ

### Accessibility
- [ ] `accessibilityLabel` trên icon-only buttons
- [ ] Số tiền readable by VoiceOver
- [ ] Dynamic Type không bị clip
- [ ] Contrast ratio ≥ 4.5:1

### Layout
- [ ] Horizontal padding 16pt nhất quán
- [ ] Safe area respected (top + bottom)
- [ ] Content không bị tab bar che
- [ ] Keyboard avoidance đúng cách

---

*Design system này là living document — cập nhật khi thêm screen mới hoặc refine component.*
