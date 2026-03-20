/// Mock data service providing hardcoded dashboard data for development.
///
/// This service returns example data without making network requests.
/// Once backend is ready, replace with RealDashboardDataService.
class MockDashboardDataService {
  /// Get dashboard summary for a given period.
  ///
  /// Returns a map containing:
  /// - totalSpending: double
  /// - month: String
  /// - year: int
  /// - topCategory: Map with name, amount, previousAmount, percentage
  /// - categories: List of Maps with name, amount, percentage, icon
  /// - goalAmount: double (nullable)
  Future<Map<String, dynamic>> getDashboardSummary({
    required String period,
  }) async {
    // TODO(dev): Replace with real API call once backend is ready
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 100));

    return getMockData(period);
  }

  /// Return hardcoded mock data based on period.
  static Map<String, dynamic> getMockData(String period) {
    // Hardcoded example data as per requirements
    return {
      'totalSpending': 2456.32,
      'month': 'March',
      'year': 2026,
      'goalAmount': 3000.00,
      'topCategory': {
        'name': 'Groceries',
        'icon': 'shopping_bag',
        'currentAmount': 687.43,
        'previousAmount': 612.50,
        'percentage': 28.0,
        'colour': 0xFF2E7D32, // Green
      },
      'categories': [
        {
          'rank': 1,
          'name': 'Groceries',
          'icon': 'shopping_bag',
          'amount': 687.43,
          'percentage': 28.0,
          'colour': 0xFF2E7D32, // Green
        },
        {
          'rank': 2,
          'name': 'Utilities',
          'icon': 'electrical_services',
          'amount': 342.50,
          'percentage': 14.0,
          'colour': 0xFF4DB6AC, // Teal
        },
        {
          'rank': 3,
          'name': 'Entertainment',
          'icon': 'sports_esports',
          'amount': 289.20,
          'percentage': 11.8,
          'colour': 0xFFFF9800, // Orange
        },
        {
          'rank': 4,
          'name': 'Dining Out',
          'icon': 'restaurant',
          'amount': 245.67,
          'percentage': 10.0,
          'colour': 0xFFFFC107, // Gold
        },
        {
          'rank': 5,
          'name': 'Transport',
          'icon': 'directions_car',
          'amount': 203.15,
          'percentage': 8.3,
          'colour': 0xFF66BB6A, // Light Green
        },
      ],
    };
  }
}
