import 'package:budgetting_frontend/features/budgets/data/budgets_api_client.dart';
import 'package:budgetting_frontend/features/budgets/domain/models/budget_models.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_footer.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_header.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/category_card.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/metric_card.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/spending_chart.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/top_category_alert.dart';
import 'package:budgetting_frontend/features/transactions/presentation/widgets/add_expense_sheet.dart';
import 'package:flutter/material.dart';

/// Dashboard screen displaying spending summary, categories, and charts.
class DashboardScreen extends StatefulWidget {
  /// Create a [DashboardScreen].
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedPeriod = 'this_month';
  bool _isSimpleView = true;

  final _apiClient = BudgetsApiClient();
  bool _isLoading = false;
  String? _error;
  BudgetSummaryModel? _summary;
  BudgetSummaryModel? _previousSummary;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final now = DateTime.now();
    int currentYear;
    int? currentMonth;
    int prevYear;
    int? prevMonth;

    switch (_selectedPeriod) {
      case 'last_month':
        currentMonth = now.month == 1 ? 12 : now.month - 1;
        currentYear = now.month == 1 ? now.year - 1 : now.year;
        prevMonth = currentMonth == 1 ? 12 : currentMonth - 1;
        prevYear = currentMonth == 1 ? currentYear - 1 : currentYear;
      case 'this_year':
        currentYear = now.year;
        currentMonth = null;
        prevYear = now.year - 1;
        prevMonth = null;
      default: // 'this_month'
        currentYear = now.year;
        currentMonth = now.month;
        prevMonth = now.month == 1 ? 12 : now.month - 1;
        prevYear = now.month == 1 ? now.year - 1 : now.year;
    }

    try {
      final results = await Future.wait([
        _apiClient.getBudgets(year: currentYear, month: currentMonth),
        _apiClient.getBudgets(year: prevYear, month: prevMonth),
      ]);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _summary = results[0];
          _previousSummary = results[1];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Could not load data. Is the server running?';
        });
      }
    }
  }

  void _openAddExpenseSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const AddExpenseSheet(),
    ).then((_) {
      if (mounted) _loadData();
    });
  }

  void _setPeriod(String period) {
    setState(() => _selectedPeriod = period);
    _loadData();
  }

  void _toggleViewMode(Set<bool> selected) {
    setState(() => _isSimpleView = selected.first);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Dashboard'),
      body: _buildBody(context),
      bottomNavigationBar: const AppFooter(),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading && _summary == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _summary == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final summary = _summary!;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MetricCard(
                totalSpending: summary.totalSpent,
                month: summary.monthName,
                year: summary.year,
                goalAmount: summary.totalGoal > 0 ? summary.totalGoal : null,
                onAddSpending: _openAddExpenseSheet,
              ),
              const SizedBox(height: 16),
              if (summary.budgets.isNotEmpty) ...[
                _buildTopCategoryAlert(summary),
                const SizedBox(height: 16),
              ],
              // Period selector
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
                      ButtonSegment(value: true, label: Text('Simple')),
                      ButtonSegment(value: false, label: Text('Advanced')),
                    ],
                    selected: {_isSimpleView},
                    onSelectionChanged: _toggleViewMode,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (summary.budgets.isEmpty)
                _buildEmptyState(context)
              else ...[
                _buildSpendingChart(summary),
                const SizedBox(height: 16),
                _buildCategoryList(summary),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopCategoryAlert(BudgetSummaryModel summary) {
    // Top category = highest spender in the current period.
    final sorted = [...summary.budgets]
      ..sort((a, b) => b.spentAmount.compareTo(a.spentAmount));
    final top = sorted.first;

    final totalSpent = summary.totalSpent;
    final percentage =
        totalSpent > 0 ? top.spentAmount / totalSpent * 100 : 0.0;

    // Find same category in previous period for comparison arrow.
    final prevItem = _previousSummary?.budgets
        .where((b) => b.name == top.name)
        .firstOrNull;
    final previousAmount = prevItem?.spentAmount ?? 0.0;

    return TopCategoryAlert(
      categoryName: top.name,
      currentAmount: top.spentAmount,
      previousAmount: previousAmount,
      percentage: percentage,
      categoryColour: top.colourValue,
    );
  }

  Widget _buildSpendingChart(BudgetSummaryModel summary) {
    final totalSpent = summary.totalSpent;
    final chartCategories = summary.budgets
        .map(
          (b) => {
            'name': b.name,
            'amount': b.spentAmount,
            'percentage': totalSpent > 0
                ? b.spentAmount / totalSpent * 100
                : 0.0,
            'colour': b.colourValue,
          },
        )
        .toList();

    return SpendingChart(
      categories: chartCategories,
      isSimpleView: _isSimpleView,
    );
  }

  Widget _buildCategoryList(BudgetSummaryModel summary) {
    if (_isSimpleView) return const SizedBox.shrink();

    final totalSpent = summary.totalSpent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Spending by Category',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...summary.budgets.asMap().entries.map(
              (entry) => CategoryCard(
                rank: entry.key + 1,
                categoryName: entry.value.name,
                amount: entry.value.spentAmount,
                percentage: totalSpent > 0
                    ? entry.value.spentAmount / totalSpent * 100
                    : 0.0,
                categoryColour: entry.value.colourValue,
              ),
            ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              'No spending data for this period',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Set budget goals to see your dashboard.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pushNamed('/budgets'),
              child: const Text('Go to Budgets'),
            ),
          ],
        ),
      ),
    );
  }
}
