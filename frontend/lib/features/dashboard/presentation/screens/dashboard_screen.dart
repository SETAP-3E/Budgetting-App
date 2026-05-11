import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_footer.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_header.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/category_card.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/metric_card.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/spending_chart.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/top_category_alert.dart';
import 'package:budgetting_frontend/features/transactions/data/datasources/transactions_api_client.dart';
import 'package:budgetting_frontend/features/transactions/domain/models/transaction_model.dart';
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

  final _txnClient = TransactionsApiClient();
  bool _isLoading = false;
  String? _error;
  bool _hasLoadedOnce = false;

  List<TransactionModel> _allTransactions = [];
  Map<String, int> _colourByCategory = {};

  // Derived by _applyPeriod()
  List<Map<String, dynamic>> _currentPeriodData = [];
  Map<String, double> _previousByCategory = {};
  double _totalSpent = 0;
  String _periodMonth = '';
  int _periodYear = 0;

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

    try {
      final txnFuture = _txnClient.getTransactions();
      final catFuture = _txnClient.getCategories();
      final txns = await txnFuture;
      final cats = await catFuture;

      final colourMap = <String, int>{};
      for (final cat in cats) {
        final name = cat['name'] as String?;
        final colour = cat['colour_value'] as int?;
        if (name != null && colour != null) colourMap[name] = colour;
      }

      if (mounted) {
        _allTransactions = txns;
        _colourByCategory = colourMap;
        _isLoading = false;
        _hasLoadedOnce = true;
        _applyPeriod();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Could not load data. Is the server running?';
        });
      }
    }
  }

  void _applyPeriod() {
    final now = DateTime.now();
    int curYear;
    int? curMonth;
    int prevYear;
    int? prevMonth;
    String monthLabel;
    int yearLabel;

    switch (_selectedPeriod) {
      case 'last_month':
        curMonth = now.month == 1 ? 12 : now.month - 1;
        curYear = now.month == 1 ? now.year - 1 : now.year;
        prevMonth = curMonth == 1 ? 12 : curMonth - 1;
        prevYear = curMonth == 1 ? curYear - 1 : curYear;
        monthLabel = _monthName(curMonth);
        yearLabel = curYear;
      case 'this_year':
        curYear = now.year;
        curMonth = null;
        prevYear = now.year - 1;
        prevMonth = null;
        monthLabel = '';
        yearLabel = now.year;
      default: // 'this_month'
        curYear = now.year;
        curMonth = now.month;
        prevMonth = now.month == 1 ? 12 : now.month - 1;
        prevYear = now.month == 1 ? now.year - 1 : now.year;
        monthLabel = _monthName(now.month);
        yearLabel = now.year;
    }

    final curTxns = _allTransactions.where((t) {
      if (t.date.year != curYear) return false;
      if (curMonth != null && t.date.month != curMonth) return false;
      return true;
    }).toList();

    final prevTxns = _allTransactions.where((t) {
      if (t.date.year != prevYear) return false;
      if (prevMonth != null && t.date.month != prevMonth) return false;
      return true;
    }).toList();

    final curTotals = <String, double>{};
    for (final t in curTxns) {
      curTotals[t.categoryName] = (curTotals[t.categoryName] ?? 0) + t.amount;
    }

    final prevTotals = <String, double>{};
    for (final t in prevTxns) {
      prevTotals[t.categoryName] =
          (prevTotals[t.categoryName] ?? 0) + t.amount;
    }

    final totalCurrent = curTotals.values.fold<double>(0, (a, b) => a + b);
    final sorted = curTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    setState(() {
      _currentPeriodData = sorted
          .map(
            (e) => <String, dynamic>{
              'name': e.key,
              'amount': e.value,
              'percentage':
                  totalCurrent > 0 ? e.value / totalCurrent * 100 : 0.0,
              'colour': _colourByCategory[e.key] ?? 0xFF9E9E9E,
            },
          )
          .toList();
      _previousByCategory = prevTotals;
      _totalSpent = totalCurrent;
      _periodMonth = monthLabel;
      _periodYear = yearLabel;
    });
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
    if (_hasLoadedOnce) _applyPeriod();
  }

  void _toggleViewMode(Set<bool> selected) {
    setState(() => _isSimpleView = selected.first);
  }

  static String _monthName(int month) => const [
        '',
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ][month];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Dashboard'),
      body: _buildBody(context),
      bottomNavigationBar: const AppFooter(),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading && !_hasLoadedOnce) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && !_hasLoadedOnce) {
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
                totalSpending: _totalSpent,
                month: _periodMonth,
                year: _periodYear,
                onAddSpending: _openAddExpenseSheet,
              ),
              const SizedBox(height: 16),
              if (_currentPeriodData.isNotEmpty) ...[
                _buildTopCategoryAlert(),
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
              if (_currentPeriodData.isEmpty)
                _buildEmptyState(context)
              else ...[
                _buildSpendingChart(),
                const SizedBox(height: 16),
                _buildCategoryList(),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopCategoryAlert() {
    final top = _currentPeriodData.first;
    final previousAmount =
        _previousByCategory[top['name'] as String] ?? 0.0;

    return TopCategoryAlert(
      categoryName: top['name'] as String,
      currentAmount: top['amount'] as double,
      previousAmount: previousAmount,
      percentage: top['percentage'] as double,
      categoryColour: top['colour'] as int,
    );
  }

  Widget _buildSpendingChart() {
    return SpendingChart(
      categories: _currentPeriodData,
      isSimpleView: _isSimpleView,
    );
  }

  Widget _buildCategoryList() {
    if (_isSimpleView) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Spending by Category',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._currentPeriodData.asMap().entries.map(
              (entry) => CategoryCard(
                rank: entry.key + 1,
                categoryName: entry.value['name'] as String,
                amount: entry.value['amount'] as double,
                percentage: entry.value['percentage'] as double,
                categoryColour: entry.value['colour'] as int,
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
              'Add an expense to get started.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _openAddExpenseSheet,
              child: const Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
