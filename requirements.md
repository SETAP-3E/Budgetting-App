# Dashboard Feature - Requirements

## Overview
Dashboard is the primary entry screen showing total spending, top category alert, and interactive pie chart. Loads in ≤2s, no auth required, uses hardcoded data initially.

**Data Example:** Total £2,456.32 | Groceries £687.43 | Utilities £342.50 | Entertainment £289.20

---

## Core Requirements

| Requirement | Spec |
|-------------|------|
| **Launch** | App opens directly to Dashboard |
| **Total Spending** | MetricCard: 36pt bold £ + month/year + optional goal progress |
| **Top Category** | TopCategoryAlert: name, amount, icon, ↑/↓/→ comparison |
| **Chart** | SpendingChart: donut, Simple (top 3 + Other) / Advanced (all) views |
| **Categories List** | CategoryCard: ranked, icon, amount, % bar (Advanced view only) |
| **Time Filter** | Selector: This Month, Last Month, This Year, Custom |
| **View Toggle** | Simple/Advanced toggle + persist via SharedPreferences |
| **Performance** | Load ≤2s, interactions ≤200ms, chart ≤500ms |
| **Accessibility** | WCAG 2.1 AA: 4.5:1 contrast, 44x44dp targets, keyboard nav, screen reader labels |
| **Responsive** | Mobile (<768px) bottom nav; Tablet (768-1024px) sidebar; Desktop (>1024px) sidebar + 2-col layout |
| **Language** | Plain, positive, no jargon, no red for spending |
| **Colours** | **Green #2E7D32 for progress/positive states.** Warm palette for everything else: Teal #4DB6AC, Orange #FF9800, Gold #FFC107, Light Green #66BB6A (category chart cycle). Never red. |

---

## Implementation Checklist

### Phase 0: Foundation
- [ ] 0.1 Create frontend/lib/main.dart with MaterialApp + go_router configuration
- [ ] 0.2 Set initial route to Dashboard (no auth yet)
- [ ] 0.3 Configure theme (colour palette: green #2E7D32, teal #4DB6AC, etc.)
- [ ] 0.4 Verify app launches with `flutter run -d web`

### Phase 1: Setup
- [ ] 1.1 Create dashboard_event.dart with FetchDashboard, ChangePeriod, ToggleViewMode events
- [ ] 1.2 Create dashboard_state.dart with DashboardLoading, DashboardLoaded, DashboardError states
- [ ] 1.3 Create dashboard_bloc.dart with initial state and event handlers (no logic yet)
- [ ] 1.4 Create MockDashboardDataService class with getDashboardSummary() stub
- [ ] 1.5 Add hardcoded data to MockDashboardDataService (total £2,456.32 + 5 categories)

**1B: DashboardScreen Creation**
- [ ] 1.6 Create dashboard_screen.dart file with StatelessWidget scaffold
- [ ] 1.7 Add Scaffold widget with AppBar containing "Dashboard" title
- [ ] 1.8 Wrap screen body with BlocProvider<DashboardBloc>
- [ ] 1.9 Create SingleChildScrollView for main content area
- [ ] 1.10 Add MetricCard widget displaying total spending
- [ ] 1.11 Add TopCategoryAlert widget displaying top category
- [ ] 1.12 Add time period selector buttons (This Month, Last Month, This Year, Custom)
- [ ] 1.13 Add Simple/Advanced view toggle button
- [ ] 1.14 Add SpendingChart widget displaying donut chart
- [ ] 1.15 Add CategoryCard list section (with visibility controlled by view mode)
- [ ] 1.16 Add AppFooter widget with 5 navigation buttons
- [ ] 1.17 Implement BLoC state listening with BlocBuilder (loading/error/loaded states)
- [ ] 1.18 Wire time selector buttons to emit ChangePeriod event
- [ ] 1.19 Wire view toggle button to emit ToggleViewMode event + persist with SharedPreferences
- [ ] 1.20 Test DashboardScreen renders correctly on hot reload

**1C: Router Integration**
- [ ] 1.21 Import dashboard_screen in go_router config
- [ ] 1.22 Set Dashboard as home/initial route in go_router

### Phase 2: Widgets (Build in parallel)
**2A: MetricCard**
- [ ] 2A.1 Create metric_card.dart with widget scaffold
- [ ] 2A.2 Implement totalSpending parameter + 36pt bold display
- [ ] 2A.3 Add month/year subtext display (14pt)
- [ ] 2A.4 Add goalAmount parameter + progress bar (if goal exists)
- [ ] 2A.5 Add onAddSpending callback + button (if no goal)
- [ ] 2A.6 Style: white card, elevation 2, 12dp radius

**2B: TopCategoryAlert**
- [ ] 2B.1 Create top_category_alert.dart with widget scaffold
- [ ] 2B.2 Implement category name + icon (32pt) display
- [ ] 2B.3 Add currentAmount (20pt bold) + percentage
- [ ] 2B.4 Implement previousAmount comparison (↑/↓/→ indicator)
- [ ] 2B.5 Add left accent bar (4dp, category colour)
- [ ] 2B.6 Add onTap callback for drill-down

**2C: SpendingChart**
- [ ] 2C.1 Create spending_chart.dart with widget scaffold
- [ ] 2C.2 Add fl_chart donut chart (white centre)
- [ ] 2C.3 Implement Simple view: top 3 categories + Other
- [ ] 2C.4 Implement Advanced view: all categories
- [ ] 2C.5 Add colour cycle: [#2E7D32, #4DB6AC, #FF9800, #FFC107, #66BB6A]
- [ ] 2C.6 Add segment labels (14pt white, if >5%)
- [ ] 2C.7 Add percentage labels (12pt outside)
- [ ] 2C.8 Add hover tooltip (dark bg, white text)
- [ ] 2C.9 Add tap callback for drill-down

**2D: CategoryCard**
- [ ] 2D.1 Create category_card.dart with widget scaffold
- [ ] 2D.2 Implement rank badge (28dp circle)
- [ ] 2D.3 Add category icon (24pt) + name (14pt semi-bold)
- [ ] 2D.4 Add amount + percentage display
- [ ] 2D.5 Add visual bar (4dp) showing spending %
- [ ] 2D.6 Style: elevation 1, 8dp radius OR row + divider
- [ ] 2D.7 Add onTap callback

### Phase 3: Integration
- [ ] 3.1 Create dashboard_screen.dart scaffold with Scaffold structure
- [ ] 3.2 Add AppHeader with "Dashboard" title
- [ ] 3.3 Add AppFooter with 5 nav buttons (Dashboard active)
- [ ] 3.4 Wrap screen with BlocProvider<DashboardBloc>
- [ ] 3.5 Implement time selector (This Month, Last Month, This Year, Custom buttons)
- [ ] 3.6 Implement Simple/Advanced toggle button
- [ ] 3.7 Layout order: Header → MetricCard → TopCategoryAlert → TimeSelector → ViewToggle → SpendingChart → CategoryList (Advanced only) → Footer
- [ ] 3.8 Wire time selector to ChangePeriod event
- [ ] 3.9 Wire view toggle to ToggleViewMode event + persistence (SharedPreferences)
- [ ] 3.10 Add loading state UI (progress indicator)
- [ ] 3.11 Add error state UI (message + retry button)
- [ ] 3.12 BLoC listens to FetchDashboard + updates UI with data

### Phase 4: Testing
**4A: Unit Tests - BLoC**
- [ ] 4A.1 Test FetchDashboard event triggers DashboardLoading → DashboardLoaded
- [ ] 4A.2 Test ChangePeriod event updates state
- [ ] 4A.3 Test ToggleViewMode event toggles isSimpleView flag
- [ ] 4A.4 Test error handling (mock service failure → DashboardError)
- [ ] 4A.5 Verify 100% BLoC code coverage

**4B: Widget Tests**
- [ ] 4B.1 Test MetricCard renders with total + month/year
- [ ] 4B.2 Test MetricCard goal progress bar (if goal exists)
- [ ] 4B.3 Test MetricCard "Add Spending" button (if no goal)
- [ ] 4B.4 Test TopCategoryAlert displays category + comparison
- [ ] 4B.5 Test SpendingChart renders donut chart within 500ms
- [ ] 4B.6 Test SpendingChart Simple view (top 3 + Other)
- [ ] 4B.7 Test SpendingChart Advanced view (all categories)
- [ ] 4B.8 Test CategoryCard renders all fields
- [ ] 4B.9 Test CategoryCard list order (highest to lowest)
- [ ] 4B.10 Test DashboardScreen layout order
- [ ] 4B.11 Test CategoryCard list hidden in Simple view
- [ ] 4B.12 Verify 100% widget code coverage

**4C: Accessibility**
- [ ] 4C.1 Check all text ≥4.5:1 contrast ratio
- [ ] 4C.2 Check all buttons ≥44x44dp
- [ ] 4C.3 Test Tab navigation through all elements
- [ ] 4C.4 Test Enter key activation
- [ ] 4C.5 Add semantic labels to SpendingChart for screen readers
- [ ] 4C.6 Verify focus indicators visible on all interactive elements
- [ ] 4C.7 Verify no colour-only information (use symbols: ↑/↓/→)

**4D: Responsive Layout**
- [ ] 4D.1 Test mobile layout (<768px): bottom nav visible, vertical stack
- [ ] 4D.2 Test tablet layout (768-1024px): sidebar nav, vertical stack
- [ ] 4D.3 Test desktop layout (>1024px): sidebar nav, 2-column if space
- [ ] 4D.4 Verify load time ≤2s on target devices
- [ ] 4D.5 Verify interactions ≤200ms response time

---

## Success Criteria
✅ Loads in ≤2s  
✅ All interactions ≤200ms  
✅ 100% unit + widget test coverage  
✅ WCAG 2.1 AA compliant  
✅ Responsive (mobile, tablet, desktop)  
✅ Plain language, no jargon  
✅ Hardcoded data: £2,456.32 total (Groceries £687.43, Utilities £342.50, Entertainment £289.20)  
✅ 100% code health (lint/analysis passing)

---

## Dependencies
- `flutter_bloc` (^8.0.0)
- `go_router` (^13.0.0)
- `fl_chart` or similar
- `shared_preferences`

---

## File Structure
```
dashboard/
├── data/ → datasources/ (MockDashboardDataService)
├── domain/ → entities, usecases
└── presentation/
    ├── bloc/ (dashboard_bloc.dart, events, states)
    ├── screens/ (dashboard_screen.dart)
    └── widgets/ (metric_card, top_category_alert, spending_chart, category_card)
```

**Test Path:** `test/features/dashboard/` (mirror structure above)
