import 'package:flutter/material.dart';
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
  late Map<String, dynamic> _currentBudgetsData;
  late List<Map<String, dynamic>> _currentBudgets;

  @override
  void initState() {
    super.initState();
    _loadBudgetsData(_selectedPeriod);
  }

  void _loadBudgetsData(String period) {
    final data = MockBudgetsDataService.getMockData(period);
    final budgets = (data['budgets'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map<String, dynamic>))
        .toList();
    final totalBudget = budgets.fold<double>(
        0.0, (sum, budget) => sum + (budget['allocated'] as double));
    final totalSpent = budgets.fold<double>(
        0.0, (sum, budget) => sum + (budget['spent'] as double));
    final alertBudget = _findHighestPercentageBudget(budgets);

    _currentBudgetsData = {
      ...data,
      'budgets': budgets,
      'totalBudget': totalBudget,
      'totalSpent': totalSpent,
      'remainingBudget': totalBudget - totalSpent,
      'alertBudget': alertBudget,
    };
    _currentBudgets = budgets;
  }

  Map<String, dynamic> _findHighestPercentageBudget(
      List<Map<String, dynamic>> budgets) {
    if (budgets.isEmpty) {
      return <String, dynamic>{};
    }
    return budgets.reduce((current, next) {
      final currentPercentage = current['percentage'] as double;
      final nextPercentage = next['percentage'] as double;
      return nextPercentage > currentPercentage ? next : current;
    });
  }

  void _setPeriod(String period) {
    setState(() {
      _selectedPeriod = period;
      _loadBudgetsData(period);
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

  void _showEditBudgetLimitSheet(Map<String, dynamic> budget) {
    final controller = TextEditingController(
      text: (budget['allocated'] as double).toStringAsFixed(2),
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set limit for ${budget['name']}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'New budget limit',
                  prefixText: '£',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final input = controller.text.trim();
                  final parsedLimit = double.tryParse(input);
                  if (parsedLimit == null || parsedLimit <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid budget limit.'),
                      ),
                    );
                    return;
                  }
                  _updateBudgetLimit(budget['name'] as String, parsedLimit);
                  Navigator.of(context).pop();
                },
                child: const Text('Save limit'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _updateBudgetLimit(String categoryName, double newLimit) {
    final updatedBudgets = _currentBudgets
        .map((budget) => Map<String, dynamic>.from(budget))
        .toList();

    for (final budget in updatedBudgets) {
      if (budget['name'] == categoryName) {
        final spent = budget['spent'] as double;
        budget['allocated'] = newLimit;
        budget['percentage'] = newLimit > 0 ? (spent / newLimit * 100) : 0.0;
      }
    }

    final totalBudget = updatedBudgets.fold<double>(
      0.0,
      (sum, budget) => sum + (budget['allocated'] as double),
    );

    final totalSpent = updatedBudgets.fold<double>(
      0.0,
      (sum, budget) => sum + (budget['spent'] as double),
    );

    final alertBudget = _findHighestPercentageBudget(updatedBudgets);

    setState(() {
      _currentBudgets = updatedBudgets;
      _currentBudgetsData['budgets'] = updatedBudgets;
      _currentBudgetsData['totalBudget'] = totalBudget;
      _currentBudgetsData['totalSpent'] = totalSpent;
      _currentBudgetsData['remainingBudget'] = totalBudget - totalSpent;
      _currentBudgetsData['alertBudget'] = alertBudget;
    });
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
                totalBudget: _currentBudgetsData['totalBudget'] as double,
                totalSpent: _currentBudgetsData['totalSpent'] as double,
                month: _currentBudgetsData['month'] as String,
                year: _currentBudgetsData['year'] as int,
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
                        label: Text('Standard view'),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text('Edit budgets'),
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
      bottomNavigationBar: const AppFooter(activeIndex: 2),
    );
  }

  Widget _buildAlertBudget() {
    final alertBudget =
        _currentBudgetsData['alertBudget'] as Map<String, dynamic>;

    return BudgetAlertCard(
      categoryName: alertBudget['name'] as String,
      allocatedAmount: alertBudget['allocated'] as double,
      currentAmount: alertBudget['spent'] as double,
      percentage: (alertBudget['percentage'] as double).toInt().toDouble(),
      categoryColour: alertBudget['colour'] as int,
    );
  }

  Widget _buildBudgetList() {
    if (_isSimpleView) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Budget Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._currentBudgets.map((b) => BudgetCard(
              rank: b['rank'] as int,
              categoryName: b['name'] as String,
              allocatedAmount: b['allocated'] as double,
              spentAmount: b['spent'] as double,
              percentage: b['percentage'] as double,
              categoryColour: b['colour'] as int,
              onEditLimit: () => _showEditBudgetLimitSheet(b),
            )),
      ],
    );
  }

  Widget _buildBudgetChart() {
    final allBudgets = _currentBudgets
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
