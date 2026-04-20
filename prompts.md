# Dashboard Feature - Implementation Prompts

## Dashboard Screen

**Purpose:** Primary screen shown on app launch. Show total spending, top category alert, pie chart, time filters, quick actions.

**Implementation Note:** For now, the app launches directly to the Dashboard (no auth screen yet). Use hardcoded example data (e.g., total spending £2,456.32, categories: Groceries £687.43, Utilities £342.50, Entertainment £289.20). Authentication and backend integration will be added later.

**Key Requirements:**
- Total spending prominently (MetricCard: 36pt bold number + optional goal progress)
- Highest category alert with month-over-month change (TopCategoryAlert)
- Interactive pie chart: top 3 in simple view, all in advanced (SpendingChart)
- Time period selector (This Month, Last Month, This Year, Custom)
- View toggle (Simple/Advanced) + preference persistence
- Plain language, no jargon; green/warm palette only (never red)
- Load ≤2s, interactions ≤200ms
- ≤3 clicks to add spending, access breakdown, set goals

**BLoC:** DashboardBloc with events (FetchDashboard, ChangePeriod, ToggleViewMode) and states (DashboardLoading, DashboardLoaded, DashboardError).

**Layout:**
- Header: AppHeader (reusable)
- Body: MetricCard → TopCategoryAlert → Time selector → View toggle → SpendingChart → CategoryCard list (advanced only) → Quick actions
- Footer: AppFooter (reusable, 5 nav buttons with Dashboard active)

**Initial Route:** Set Dashboard as the default/home route in go_router (will be the first screen users see when opening the app).

**File Structure:**
```
dashboard/
├── data/ (datasources, repositories)
├── domain/ (entities, usecases)
└── presentation/ (bloc, screens/dashboard_screen.dart, widgets)
```

**Success:** Loads in 2s, plain language, no red, toggle persists, ≥4.5:1 contrast, ≥44x44dp targets, 100% test coverage.



---

## 2. SpendingChart Widget

**Purpose:** Interactive pie/donut chart showing spending by category.

**Requirements:**
- Simple: top 3 categories + "Other"
- Advanced: all categories
- Hover tooltips with amounts, tap to drill down
- Renders in ≤500ms, updates instantly
- Colour palette: warm (greens, teals, oranges)—no red
- Accessible table alternative, ≥4.5:1 contrast

**Parameters:** `categories`, `isSimpleView`, `onCategoryTap`, `customColours`, `showPercentages`

**Design:** Donut chart, white centre, colour cycle [#2E7D32, #4DB6AC, #FF9800, #FFC107, #66BB6A]. Segment labels 14pt white (if >5%), percentage labels 12pt outside. Tooltip: dark bg, white text. Hover: scale 1.05x.

---

## 3. MetricCard Widget

**Purpose:** Displays total monthly spending with optional goal progress.

**Requirements:**
- Total spending: 36pt bold £ symbol
- Month/Year subtext
- If goal: progress bar + positive progress message ("You're on track")
- If no goal: optional "Add Spending" button
- Green/warm only, never red

**Parameters:** `totalSpending`, `month`, `year`, `goalAmount`, `onAddSpending`

**Design:** White card, elevation 2, 12dp radius. Metric 36pt bold, subtext 14pt. Progress bar 8dp, green filled. Message 12pt green, encouraging language.

---

## 4. CategoryCard Widget

**Purpose:** Ranked category item in advanced view list.

**Requirements:**
- Show rank, name, icon, amount, percentage, visual bar
- Ordered highest to lowest
- Tap to drill down
- Supports card or row styling

**Parameters:** `category`, `rank`, `totalSpending`, `onTap`, `showRank`, `isCardStyle`

**Design:** 80dp card / 64dp row. Rank badge 28dp circle. Icon 24pt. Name 14pt semi-bold. Amount/percentage right. Bar 4dp. Card: elevation 1, 8dp radius. Row: divider below.

---

## 5. TopCategoryAlert Widget

**Purpose:** Displays top category with month-over-month comparison.

**Requirements:**
- Category name, amount, icon, percentage
- Previous month comparison (↑ more, ↓ less, → same)
- Framing: "Your biggest expense this month"
- No judgment, no red
- Tap to drill down

**Parameters:** `category`, `currentAmount`, `previousAmount`, `percentage`, `onTap`

**Design:** White card, left accent (4dp, category colour), elevation 2, 12dp radius. Icon 32pt + header. Amount 20pt bold. Comparison 12pt neutral (no red).

---

## Design System

**Colours:** Green #2E7D32, Teal #4DB6AC, Orange #FF9800, Gold #FFC107, Light Green #66BB6A, BG #FFFFFF/#F5F5F5, Text #212121/#757575. **Never red for spending.**

**Typography:** Metric 32-36pt bold, title 16-18pt semi-bold, body 14pt, label 12pt.

**Spacing:** Padding 16dp, gaps 8-12dp/24dp, card elevation 1-2, modal 4.
