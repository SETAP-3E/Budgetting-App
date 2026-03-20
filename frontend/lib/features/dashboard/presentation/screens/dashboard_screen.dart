import 'package:flutter/material.dart';
import '../widgets/metric_card.dart';
import '../widgets/top_category_alert.dart';
import '../widgets/spending_chart.dart';
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
              // More content will be added here
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpendingChart() {
    final mockData = MockDashboardDataService._getMockData('this_month');
    final categories = (mockData['categories'] as List)
        .take(3)
        .map((c) => {'name': c['name'], 'amount': c['amount'], 'colour': c['colour']})
        .toList();

    return SpendingChart(
      categories: categories,
      isSimpleView: true,
    );
  }
}
