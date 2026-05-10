import 'package:budgetting_frontend/features/budgets/data/budgets_api_client.dart';
import 'package:budgetting_frontend/features/budgets/presentation/widgets/budget_alert_card.dart';
import 'package:budgetting_frontend/features/budgets/presentation/widgets/budget_card.dart';
import 'package:budgetting_frontend/features/budgets/presentation/widgets/budget_chart.dart';
import 'package:budgetting_frontend/features/budgets/presentation/widgets/budget_summary_card.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_footer.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_header.dart';
import 'package:flutter/material.dart';

/// Budgets screen displaying budget summary, categories, and charts.
class BudgetsScreen extends StatefulWidget {
  /// Create a [BudgetsScreen].
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  final _apiClient = BudgetsApiClient();

  String _selectedPeriod = 'this_month';
  bool _isSimpleView = true;
  bool _isLoading = false;
  String? _error;

  double _totalBudget = 0;
  double _totalSpent = 0;
  String _periodMonth = '';
  int _periodYear = DateTime.now().year;
  List<Map<String, dynamic>> _currentBudgets = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final now = DateTime.now();
    int year;
    int? month;

    switch (_selectedPeriod) {
      case 'this_month':
        year = now.year;
        month = now.month;
      case 'last_month':
        if (now.month == 1) {
          month = 12;
          year = now.year - 1;
        } else {
          month = now.month - 1;
          year = now.year;
        }
      default:
        year = now.year;
        month = null;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final summary = await _apiClient.getBudgets(year: year, month: month);
      final budgets = summary.budgets
          .map(
            (item) => <String, dynamic>{
              'rank': item.rank,
              'name': item.name,
              'allocated': item.goalAmount,
              'spent': item.spentAmount,
              'percentage': item.percentage,
              'colour': item.colourValue,
            },
          )
          .toList();
      setState(() {
        _isLoading = false;
        _totalBudget = summary.totalGoal;
        _totalSpent = summary.totalSpent;
        _periodMonth = summary.monthName;
        _periodYear = summary.year;
        _currentBudgets = budgets;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Map<String, dynamic> _findHighestPercentageBudget(
    List<Map<String, dynamic>> budgets,
  ) {
    if (budgets.isEmpty) return <String, dynamic>{};
    return budgets.reduce((current, next) {
      final a = current['percentage'] as double;
      final b = next['percentage'] as double;
      return b > a ? next : current;
    });
  }

  void _setPeriod(String period) {
    setState(() => _selectedPeriod = period);
    _loadData();
  }

  void _toggleViewMode(Set<bool> selected) {
    setState(() => _isSimpleView = selected.first);
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
    final updated = _currentBudgets.map(Map<String, dynamic>.from).toList();

    for (final b in updated) {
      if (b['name'] == categoryName) {
        final spent = b['spent'] as double;
        b['allocated'] = newLimit;
        b['percentage'] = newLimit > 0 ? (spent / newLimit * 100) : 0.0;
      }
    }

    setState(() {
      _currentBudgets = updated;
      _totalBudget =
          updated.fold(0, (sum, b) => sum + (b['allocated'] as double));
      _totalSpent =
          updated.fold(0, (sum, b) => sum + (b['spent'] as double));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: 'Budgets', onMenuPressed: () {}),
      body: _isLoading && _currentBudgets.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _currentBudgets.isEmpty
              ? _buildErrorState()
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BudgetSummaryCard(
                          totalBudget: _totalBudget,
                          totalSpent: _totalSpent,
                          month: _periodMonth,
                          year: _periodYear,
                        ),
                        const SizedBox(height: 16),
                        _buildAlertBudget(),
                        const SizedBox(height: 16),
                        _buildPeriodSelector(),
                        const SizedBox(height: 16),
                        _buildViewModeToggle(),
                        const SizedBox(height: 16),
                        _buildBudgetChart(),
                        const SizedBox(height: 16),
                        _buildBudgetList(),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: const AppFooter(activeIndex: 2),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error ?? 'Something went wrong.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertBudget() {
    if (_currentBudgets.isEmpty) return const SizedBox.shrink();
    final alert = _findHighestPercentageBudget(_currentBudgets);
    if (alert.isEmpty) return const SizedBox.shrink();
    return BudgetAlertCard(
      categoryName: alert['name'] as String,
      allocatedAmount: alert['allocated'] as double,
      currentAmount: alert['spent'] as double,
      percentage: (alert['percentage'] as double).toInt().toDouble(),
      categoryColour: alert['colour'] as int,
    );
  }

  Widget _buildPeriodSelector() {
    return SingleChildScrollView(
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
        ],
      ),
    );
  }

  Widget _buildViewModeToggle() {
    return Row(
      children: [
        const Text('View Mode:'),
        const SizedBox(width: 12),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Standard view')),
            ButtonSegment(value: false, label: Text('Edit budgets')),
          ],
          selected: {_isSimpleView},
          onSelectionChanged: _toggleViewMode,
        ),
      ],
    );
  }

  Widget _buildBudgetList() {
    if (_isSimpleView) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Budget Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._currentBudgets.map(
          (b) => BudgetCard(
            rank: b['rank'] as int,
            categoryName: b['name'] as String,
            allocatedAmount: b['allocated'] as double,
            spentAmount: b['spent'] as double,
            percentage: b['percentage'] as double,
            categoryColour: b['colour'] as int,
            onEditLimit: () => _showEditBudgetLimitSheet(b),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetChart() {
    final chartCategories = _currentBudgets
        .map(
          (b) => <String, dynamic>{
            'name': b['name'] as String,
            'allocated': b['allocated'] as double,
            'spent': b['spent'] as double,
            'colour': b['colour'] as int,
          },
        )
        .toList();

    return BudgetChart(
      categories: chartCategories,
      isSimpleView: _isSimpleView,
    );
  }
}
