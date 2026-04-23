import 'package:budgetting_frontend/features/transactions/presentation/widgets/add_expense_sheet.dart';
import 'package:flutter/material.dart';
import '../widgets/metric_card.dart';
import '../widgets/top_category_alert.dart';
import '../widgets/spending_chart.dart';
import '../widgets/category_card.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_header.dart';
import '../../data/datasources/mock_dashboard_datasource.dart';

/// Dashboard screen displaying spending summary, categories, and charts.
///
/// Primary entry point showing:
/// - Total spending (MetricCard)
/// - Top category alert
/// - Spending breakdown chart
/// - Category list (Advanced view only)
/// - Time period and view mode controls
class DashboardScreen extends StatefulWidget {
  /// Create a [DashboardScreen].
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedPeriod = 'this_month';
  bool _isSimpleView = true;

  void _openAddExpenseSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const AddExpenseSheet(),
    );
  }

  void _setPeriod(String period) {
    setState(() {
      _selectedPeriod = period;
    });
    // TODO(1.18): Emit ChangePeriod event to BLoC
    // context.read<DashboardBloc>().add(ChangePeriod(period: period));
  }

  void _toggleViewMode(Set<bool> selected) {
    setState(() {
      _isSimpleView = selected.first;
    });
    // TODO(1.19): Emit ToggleViewMode event to BLoC
    // context.read<DashboardBloc>().add(ToggleViewMode(isSimpleView: _isSimpleView));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Dashboard',
        onMenuPressed: () {
          // TODO: Implement drawer or navigation menu
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu opened')),
          );
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MetricCard(
                totalSpending: _getDashboardData()['totalSpending'] as double,
                month: _getDashboardData()['month'] as String,
                year: _getDashboardData()['year'] as int,
                goalAmount: _getDashboardData()['goalAmount'] as double?,
                onAddSpending: _openAddExpenseSheet,
              ),
              const SizedBox(height: 16),
              _buildTopCategoryAlert(),
              const SizedBox(height: 16),
              // Time period selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: _selectedPeriod == 'this_month'
                          ? null
                          : () => _setPeriod('this_month'),
                      child: const Text('This Month'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _selectedPeriod == 'last_month'
                          ? null
                          : () => _setPeriod('last_month'),
                      child: const Text('Last Month'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _selectedPeriod == 'this_year'
                          ? null
                          : () => _setPeriod('this_year'),
                      child: const Text('This Year'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _selectedPeriod == 'custom'
                          ? null
                          : () => _setPeriod('custom'),
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
                    selected: {_isSimpleView},
                    onSelectionChanged: _toggleViewMode,
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

  Map<String, dynamic> _getDashboardData() {
    return MockDashboardDataService.getMockData(_selectedPeriod);
  }

  Widget _buildTopCategoryAlert() {
    final data = _getDashboardData();
    final topCategory = data['topCategory'] as Map<String, dynamic>;

    return TopCategoryAlert(
      categoryName: topCategory['name'] as String,
      currentAmount: topCategory['currentAmount'] as double,
      previousAmount: topCategory['previousAmount'] as double,
      percentage: (topCategory['percentage'] as double).toInt().toDouble(),
    );
  }

  Widget _buildCategoryList() {
    final mockData = _getDashboardData();
    final categories = mockData['categories'] as List;

    if (_isSimpleView) {
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
    final mockData = _getDashboardData();
    final allCategories = (mockData['categories'] as List)
        .map((c) => {
              'name': c['name'] as String,
              'amount': c['amount'] as double,
              'percentage': c['percentage'] as double,
              'colour': c['colour'] as int,
            })
        .toList();

    return SpendingChart(
      categories: allCategories,
      isSimpleView: _isSimpleView,
    );
  }
}
