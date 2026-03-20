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
    // Return different data based on period
    switch (period) {
      case 'last_month':
        return {
          'totalSpending': 2100.45,
          'month': 'February',
          'year': 2026,
          'goalAmount': 3000.00,
          'topCategory': {
            'name': 'Groceries',
            'icon': 'shopping_bag',
            'currentAmount': 612.50,
            'previousAmount': 550.00,
            'percentage': 29.2,
            'colour': 0xFF2E7D32,
          },
          'categories': [
            {'rank': 1, 'name': 'Groceries', 'icon': 'shopping_bag', 'amount': 612.50, 'percentage': 29.2, 'colour': 0xFF2E7D32},
            {'rank': 2, 'name': 'Utilities', 'icon': 'electrical_services', 'amount': 298.00, 'percentage': 14.2, 'colour': 0xFF4DB6AC},
            {'rank': 3, 'name': 'Entertainment', 'icon': 'sports_esports', 'amount': 256.80, 'percentage': 12.2, 'colour': 0xFFFF9800},
            {'rank': 4, 'name': 'Dining Out', 'icon': 'restaurant', 'amount': 198.50, 'percentage': 9.5, 'colour': 0xFFFFC107},
            {'rank': 5, 'name': 'Transport', 'icon': 'directions_car', 'amount': 169.65, 'percentage': 8.1, 'colour': 0xFF66BB6A},
          ],
        };
      case 'this_year':
        return {
          'totalSpending': 15234.80,
          'month': 'YTD',
          'year': 2026,
          'goalAmount': 18000.00,
          'topCategory': {
            'name': 'Groceries',
            'icon': 'shopping_bag',
            'currentAmount': 4250.15,
            'previousAmount': 3500.00,
            'percentage': 27.9,
            'colour': 0xFF2E7D32,
          },
          'categories': [
            {'rank': 1, 'name': 'Groceries', 'icon': 'shopping_bag', 'amount': 4250.15, 'percentage': 27.9, 'colour': 0xFF2E7D32},
            {'rank': 2, 'name': 'Utilities', 'icon': 'electrical_services', 'amount': 2156.00, 'percentage': 14.1, 'colour': 0xFF4DB6AC},
            {'rank': 3, 'name': 'Entertainment', 'icon': 'sports_esports', 'amount': 1875.45, 'percentage': 12.3, 'colour': 0xFFFF9800},
            {'rank': 4, 'name': 'Dining Out', 'icon': 'restaurant', 'amount': 1542.30, 'percentage': 10.1, 'colour': 0xFFFFC107},
            {'rank': 5, 'name': 'Transport', 'icon': 'directions_car', 'amount': 1230.90, 'percentage': 8.1, 'colour': 0xFF66BB6A},
          ],
        };
      case 'custom':
        return {
          'totalSpending': 1876.50,
          'month': 'Custom',
          'year': 2026,
          'goalAmount': 2500.00,
          'topCategory': {
            'name': 'Entertainment',
            'icon': 'sports_esports',
            'currentAmount': 425.00,
            'previousAmount': 350.00,
            'percentage': 22.6,
            'colour': 0xFFFF9800,
          },
          'categories': [
            {'rank': 1, 'name': 'Entertainment', 'icon': 'sports_esports', 'amount': 425.00, 'percentage': 22.6, 'colour': 0xFFFF9800},
            {'rank': 2, 'name': 'Groceries', 'icon': 'shopping_bag', 'amount': 412.30, 'percentage': 21.9, 'colour': 0xFF2E7D32},
            {'rank': 3, 'name': 'Dining Out', 'icon': 'restaurant', 'amount': 389.75, 'percentage': 20.8, 'colour': 0xFFFFC107},
            {'rank': 4, 'name': 'Utilities', 'icon': 'electrical_services', 'amount': 310.20, 'percentage': 16.5, 'colour': 0xFF4DB6AC},
            {'rank': 5, 'name': 'Transport', 'icon': 'directions_car', 'amount': 205.25, 'percentage': 10.9, 'colour': 0xFF66BB6A},
          ],
        };
      case 'this_month':
      default:
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
            'colour': 0xFF2E7D32,
          },
          'categories': [
            {'rank': 1, 'name': 'Groceries', 'icon': 'shopping_bag', 'amount': 687.43, 'percentage': 28.0, 'colour': 0xFF2E7D32},
            {'rank': 2, 'name': 'Utilities', 'icon': 'electrical_services', 'amount': 342.50, 'percentage': 14.0, 'colour': 0xFF4DB6AC},
            {'rank': 3, 'name': 'Entertainment', 'icon': 'sports_esports', 'amount': 289.20, 'percentage': 11.8, 'colour': 0xFFFF9800},
            {'rank': 4, 'name': 'Dining Out', 'icon': 'restaurant', 'amount': 245.67, 'percentage': 10.0, 'colour': 0xFFFFC107},
            {'rank': 5, 'name': 'Transport', 'icon': 'directions_car', 'amount': 203.15, 'percentage': 8.3, 'colour': 0xFF66BB6A},
          ],
        };
    }
  }
}
