import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../dashboard/presentation/widgets/app_footer.dart';
import '../../../dashboard/presentation/widgets/app_header.dart';
import '../widgets/budget_summary_card.dart';
import '../widgets/budget_alert_card.dart';
import '../widgets/budget_chart.dart';
import '../widgets/budget_card.dart';
import '../../data/datasources/mock_budgets_datasource.dart';

/// Budgets screen displaying budget summary, categories, and charts.
///
/// Primary entry point showing:
/// - Total budget (BudgetSummaryCard)
/// - Alert budget near or over limit
/// - Budget vs spending breakdown chart
/// - Category list (Advanced view only)
/// - Time period and view mode controls
class BudgetsScreen extends StatefulWidget {
  /// Create a [BudgetsScreen].
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  String _selectedPeriod = 'this_month';
  bool _isSimpleView = true;

  void _setPeriod(String period) {
    setState(() {
      _selectedPeriod = period;
    });
    // TODO(1.18): Emit ChangePeriod event to BLoC
    // context.read<BudgetsBloc>().add(ChangePeriod(period: period));
  }

  void _toggleViewMode(Set<bool> selected) {
    setState(() {
      _isSimpleView = selected.first;
    });
    // TODO(1.19): Emit ToggleViewMode event to BLoC
    // context.read<BudgetsBloc>().add(ToggleViewMode(isSimpleView: _isSimpleView));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Budgets',
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
              BudgetSummaryCard(
                totalBudget: _getBudgetsData()['totalBudget'] as double,
                totalSpent: _getBudgetsData()['totalSpent'] as double,
                month: _getBudgetsData()['month'] as String,
                year: _getBudgetsData()['year'] as int,
              ),
              const SizedBox(height: 16),
              _buildAlertBudget(),
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
              // Budget chart
              _buildBudgetChart(),
              const SizedBox(height: 16),
              // Budget list (Advanced view only)
              _buildBudgetList(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppFooter(
        activeIndex: 2,
        onNavigation: (index) {
          switch (index) {
            case 0: // Dashboard
              context.go('/');
              break;
            default:
              // TODO: Implement navigation for other screens
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Navigation to screen $index not implemented yet')),
              );
          }
        },
      ),
    );
  }

  Map<String, dynamic> _getBudgetsData() {
    return MockBudgetsDataService.getMockData(_selectedPeriod);
  }

  Widget _buildAlertBudget() {
    final data = _getBudgetsData();
    final alertBudget = data['alertBudget'] as Map<String, dynamic>;

    return BudgetAlertCard(
      categoryName: alertBudget['name'] as String,
      allocatedAmount: alertBudget['allocated'] as double,
      currentAmount: alertBudget['spent'] as double,
      percentage: (alertBudget['percentage'] as double).toInt().toDouble(),
      categoryColour: alertBudget['colour'] as int,
    );
  }

  Widget _buildBudgetList() {
    final mockData = _getBudgetsData();
    final budgets = mockData['budgets'] as List;

    if (_isSimpleView) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Budget Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...budgets.map((b) => BudgetCard(
              rank: b['rank'] as int,
              categoryName: b['name'] as String,
              allocatedAmount: b['allocated'] as double,
              spentAmount: b['spent'] as double,
              percentage: b['percentage'] as double,
              categoryColour: b['colour'] as int,
            )),
      ],
    );
  }

  Widget _buildBudgetChart() {
    final mockData = _getBudgetsData();
    final allBudgets = (mockData['budgets'] as List)
        .map((b) => {
              'name': b['name'] as String,
              'allocated': b['allocated'] as double,
              'spent': b['spent'] as double,
              'colour': b['colour'] as int,
            })
        .toList();

    return BudgetChart(
      categories: allBudgets,
      isSimpleView: _isSimpleView,
    );
  }
}
