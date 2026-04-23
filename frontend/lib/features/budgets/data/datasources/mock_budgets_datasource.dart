/// Mock data service providing hardcoded budgets data for development.
///
/// This service returns example data without making network requests.
/// Once backend is ready, replace with RealBudgetsDataService.
class MockBudgetsDataService {
  /// Get budgets summary for a given period.
  ///
  /// Returns a map containing:
  /// - totalBudget: double
  /// - totalSpent: double
  /// - month: String
  /// - year: int
  /// - remainingBudget: double
  /// - budgets: List of Maps with category, allocated, spent, percentage
  /// - alertBudget: Map with category, name, alert message
  Future<Map<String, dynamic>> getBudgetsSummary({
    required String period,
  }) async {
    // TODO(dev): Replace with real API call once backend is ready
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 100));

    return getMockData(period);
  }

  /// Return hardcoded mock data based on period.
  static Map<String, dynamic> getMockData(String period) {
    // Return different data based on period
    switch (period) {
      case 'last_month':
        return {
          'totalBudget': 3500.00,
          'totalSpent': 2100.45,
          'month': 'February',
          'year': 2026,
          'remainingBudget': 1399.55,
          'alertBudget': {
            'name': 'Utilities',
            'allocated': 400.00,
            'spent': 298.00,
            'percentage': 74.5,
            'colour': 0xFF4DB6AC,
          },
          'budgets': [
            {
              'rank': 1,
              'name': 'Groceries',
              'allocated': 650.00,
              'spent': 612.50,
              'percentage': 94.2,
              'colour': 0xFF2E7D32,
            },
            {
              'rank': 2,
              'name': 'Utilities',
              'allocated': 400.00,
              'spent': 298.00,
              'percentage': 74.5,
              'colour': 0xFF4DB6AC,
            },
            {
              'rank': 3,
              'name': 'Entertainment',
              'allocated': 300.00,
              'spent': 256.80,
              'percentage': 85.6,
              'colour': 0xFFFF9800,
            },
            {
              'rank': 4,
              'name': 'Dining Out',
              'allocated': 250.00,
              'spent': 198.50,
              'percentage': 79.4,
              'colour': 0xFFFFC107,
            },
            {
              'rank': 5,
              'name': 'Transport',
              'allocated': 200.00,
              'spent': 169.65,
              'percentage': 84.8,
              'colour': 0xFF66BB6A,
            },
          ],
        };
      case 'this_year':
        return {
          'totalBudget': 25000.00,
          'totalSpent': 15234.80,
          'month': 'YTD',
          'year': 2026,
          'remainingBudget': 9765.20,
          'alertBudget': {
            'name': 'Groceries',
            'allocated': 5000.00,
            'spent': 4250.15,
            'percentage': 85.0,
            'colour': 0xFF2E7D32,
          },
          'budgets': [
            {
              'rank': 1,
              'name': 'Groceries',
              'allocated': 5000.00,
              'spent': 4250.15,
              'percentage': 85.0,
              'colour': 0xFF2E7D32,
            },
            {
              'rank': 2,
              'name': 'Utilities',
              'allocated': 3000.00,
              'spent': 2156.00,
              'percentage': 71.9,
              'colour': 0xFF4DB6AC,
            },
            {
              'rank': 3,
              'name': 'Entertainment',
              'allocated': 2500.00,
              'spent': 1875.45,
              'percentage': 75.0,
              'colour': 0xFFFF9800,
            },
            {
              'rank': 4,
              'name': 'Dining Out',
              'allocated': 2000.00,
              'spent': 1542.30,
              'percentage': 77.1,
              'colour': 0xFFFFC107,
            },
            {
              'rank': 5,
              'name': 'Transport',
              'allocated': 1500.00,
              'spent': 1230.90,
              'percentage': 82.1,
              'colour': 0xFF66BB6A,
            },
          ],
        };
      case 'custom':
        return {
          'totalBudget': 2500.00,
          'totalSpent': 1876.50,
          'month': 'Custom',
          'year': 2026,
          'remainingBudget': 623.50,
          'alertBudget': {
            'name': 'Dining Out',
            'allocated': 300.00,
            'spent': 389.75,
            'percentage': 129.9,
            'colour': 0xFFFFC107,
          },
          'budgets': [
            {
              'rank': 1,
              'name': 'Entertainment',
              'allocated': 500.00,
              'spent': 425.00,
              'percentage': 85.0,
              'colour': 0xFFFF9800,
            },
            {
              'rank': 2,
              'name': 'Groceries',
              'allocated': 600.00,
              'spent': 412.30,
              'percentage': 68.7,
              'colour': 0xFF2E7D32,
            },
            {
              'rank': 3,
              'name': 'Dining Out',
              'allocated': 300.00,
              'spent': 389.75,
              'percentage': 129.9,
              'colour': 0xFFFFC107,
            },
            {
              'rank': 4,
              'name': 'Utilities',
              'allocated': 400.00,
              'spent': 310.20,
              'percentage': 77.6,
              'colour': 0xFF4DB6AC,
            },
            {
              'rank': 5,
              'name': 'Transport',
              'allocated': 250.00,
              'spent': 205.25,
              'percentage': 82.1,
              'colour': 0xFF66BB6A,
            },
          ],
        };
      case 'this_month':
      default:
        return {
          'totalBudget': 3500.00,
          'totalSpent': 2456.32,
          'month': 'March',
          'year': 2026,
          'remainingBudget': 1043.68,
          'alertBudget': {
            'name': 'Groceries',
            'allocated': 650.00,
            'spent': 612.50,
            'percentage': 94.2,
            'colour': 0xFF2E7D32,
          },
          'budgets': [
            {
              'rank': 1,
              'name': 'Groceries',
              'allocated': 650.00,
              'spent': 612.50,
              'percentage': 94.2,
              'colour': 0xFF2E7D32,
            },
            {
              'rank': 2,
              'name': 'Utilities',
              'allocated': 400.00,
              'spent': 298.00,
              'percentage': 74.5,
              'colour': 0xFF4DB6AC,
            },
            {
              'rank': 3,
              'name': 'Entertainment',
              'allocated': 300.00,
              'spent': 256.80,
              'percentage': 85.6,
              'colour': 0xFFFF9800,
            },
            {
              'rank': 4,
              'name': 'Dining Out',
              'allocated': 250.00,
              'spent': 198.50,
              'percentage': 79.4,
              'colour': 0xFFFFC107,
            },
            {
              'rank': 5,
              'name': 'Transport',
              'allocated': 200.00,
              'spent': 169.65,
              'percentage': 84.8,
              'colour': 0xFF66BB6A,
            },
          ],
        };
    }
  }
}
