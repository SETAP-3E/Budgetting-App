import 'package:flutter/material.dart';
import '../widgets/metric_card.dart';
import '../widgets/top_category_alert.dart';
import '../widgets/spending_chart.dart';
import '../widgets/category_card.dart';
import '../widgets/app_footer.dart';
import '../../data/datasources/mock_dashboard_datasource.dart';

/// Dashboard screen displaying spending summary, categories, and charts.
///
/// Primary entry point showing:
/// - Total spending (MetricCard)
/// - Top category alert
/// - Spending breakdown chart
/// - Category list (Advanced view only)
/// - Time period and view mode controls
class DashboardScreen extends StatelessWidget {
  /// Create a [DashboardScreen].
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MetricCard(
                totalSpending: 2456.32,
                month: 'March',
                year: 2026,
              ),
              const SizedBox(height: 16),
              TopCategoryAlert(
                categoryName: 'Groceries',
                currentAmount: 687.43,
                previousAmount: 650.00,
                percentage: 28,
              ),
              const SizedBox(height: 16),
              // Time period selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('This Month'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Last Month'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('This Year'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Custom'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // View mode toggle
              Row(
                children: [
                  const Text('View Mode:'),
                  const SizedBox(width: 12),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: true,
                        label: Text('Simple'),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text('Advanced'),
                      ),
                    ],
                    selected: {true},
                    onSelectionChanged: (selected) {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Spending chart
              _buildSpendingChart(),
              const SizedBox(height: 16),
              // Category list (Advanced view only)
              _buildCategoryList(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppFooter(
        activeIndex: 0,
        onNavigation: (index) {},
      ),
    );
  }

  Widget _buildCategoryList() {
    final mockData = MockDashboardDataService.getMockData('this_month');
    final isSimpleView = true; // TODO: Wire to BLoC state
    final categories = mockData['categories'] as List;

    if (isSimpleView) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Spending by Category',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...categories.map((c) => CategoryCard(
              rank: c['rank'] as int,
              categoryName: c['name'] as String,
              amount: c['amount'] as double,
              percentage: c['percentage'] as double,
              categoryColour: c['colour'] as int,
            )),
      ],
    );
  }

  Widget _buildSpendingChart() {
    final mockData = MockDashboardDataService.getMockData('this_month');
    final categories = (mockData['categories'] as List)
        .take(3)
        .map((c) =>
            {'name': c['name'], 'amount': c['amount'], 'colour': c['colour']})
        .toList();

    return SpendingChart(
      categories: categories,
      isSimpleView: true,
    );
  }
}
