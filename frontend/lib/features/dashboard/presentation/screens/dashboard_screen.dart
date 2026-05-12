import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:budgetting_frontend/features/accounts/data/accounts_api_client.dart';
import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:budgetting_frontend/features/accounts/presentation/widgets/accounts_overview_card.dart';
import 'package:budgetting_frontend/features/budgets/data/budgets_api_client.dart';
import 'package:budgetting_frontend/features/budgets/domain/models/budget_models.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_footer.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_header.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/budget_health_card.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/metric_card.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/recent_transactions_card.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/spending_bar_chart.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/top_category_alert.dart';
import 'package:budgetting_frontend/features/transactions/data/datasources/transactions_api_client.dart';
import 'package:budgetting_frontend/features/transactions/domain/models/transaction_model.dart';
import 'package:budgetting_frontend/features/transactions/presentation/widgets/add_expense_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Dashboard screen displaying key financial data at a glance.
class DashboardScreen extends StatefulWidget {
  /// Create a [DashboardScreen].
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedPeriod = 'this_month';

  final _txnClient = TransactionsApiClient();
  final _accountsClient = AccountsApiClient();
  final _budgetsClient = BudgetsApiClient();

  bool _isLoading = false;
  bool _isAccountsLoading = false;
  bool _isBudgetsLoading = false;
  String? _error;
  bool _hasLoadedOnce = false;

  List<TransactionModel> _allTransactions = [];
  Map<String, int> _colourByCategory = {};
  List<AccountModel> _accounts = [];
  BudgetSummaryModel? _budgetSummary;

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
      _isAccountsLoading = true;
      _isBudgetsLoading = true;
      _error = null;
    });

    // ── Transactions + categories ─────────────────────────────────────────
    try {
      final txns = await _txnClient.getTransactions();
      final cats = await _txnClient.getCategories();

      final colourMap = <String, int>{};
      for (final cat in cats) {
        final name = cat['name'] as String?;
        final colour = cat['colour_value'] as int?;
        if (name != null && colour != null) colourMap[name] = colour;
      }

      if (mounted) {
        setState(() {
          _allTransactions = txns;
          _colourByCategory = colourMap;
          _isLoading = false;
          _hasLoadedOnce = true;
        });
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

    // ── Accounts ─────────────────────────────────────────────────────────
    try {
      final accounts = await _accountsClient.getAccounts();
      if (mounted) {
        setState(() {
          _accounts = accounts;
          _isAccountsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isAccountsLoading = false);
    }

    // ── Budget summary for current month ─────────────────────────────────
    try {
      final now = DateTime.now();
      final summary = await _budgetsClient.getBudgets(
        year: now.year,
        month: now.month,
      );
      if (mounted) {
        setState(() {
          _budgetSummary = summary;
          _isBudgetsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isBudgetsLoading = false);
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddExpenseSheet,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // [1] Hero spending card
              MetricCard(
                totalSpending: _totalSpent,
                month: _periodMonth,
                year: _periodYear,
                budgetGoal: _selectedPeriod == 'this_year'
                    ? (_budgetSummary?.totalGoal ?? 0.0) * 12
                    : (_budgetSummary?.totalGoal ?? 0.0),
              ),
              const SizedBox(height: 12),

              // [2] Period selector
              _buildPeriodSelector(),
              const SizedBox(height: 16),

              // [3] Account balance
              _buildAccountsSection(),
              const SizedBox(height: 16),

              // [4] Top category alert (conditional)
              if (_currentPeriodData.isNotEmpty) ...[
                _buildTopCategoryAlert(),
                const SizedBox(height: 16),
              ],

              // [5] Spending chart + [6] category list
              if (_currentPeriodData.isEmpty)
                _buildEmptyState(context)
              else ...[
                SpendingBarChart(categories: _currentPeriodData),
                const SizedBox(height: 16),
              ],

              // [7] Recent transactions
              _buildRecentTransactions(),
              const SizedBox(height: 16),

              // [8] Budget health
              BudgetHealthCard(
                summary: _isBudgetsLoading ? null : _budgetSummary,
                onManage: () => context.go('/budgets'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    const options = [
      ('this_month', 'This Month'),
      ('last_month', 'Last Month'),
      ('this_year', 'This Year'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((opt) {
          final isSelected = _selectedPeriod == opt.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(opt.$2),
              selected: isSelected,
              onSelected: (_) => _setPeriod(opt.$1),
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
              ),
              backgroundColor: Colors.transparent,
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAccountsSection() {
    if (_isAccountsLoading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
              Text(
                'Loading accounts…',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      );
    }

    final totalBalance =
        _accounts.fold<double>(0, (s, a) => s + a.balance);
    final lowCount = _accounts.where((a) => a.balance < 1000).length;

    return AccountsOverviewCard(
      totalBalance: totalBalance,
      activeAccounts: _accounts.length,
      lowBalanceCount: lowCount,
      currencyText: _accounts.isEmpty ? '—' : formatCurrency(totalBalance),
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

  Widget _buildRecentTransactions() {
    final recent = [..._allTransactions]
      ..sort((a, b) => b.date.compareTo(a.date));
    return RecentTransactionsCard(
      transactions: recent.take(5).toList(),
      onSeeAll: () => context.go('/transactions'),
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
          ],
        ),
      ),
    );
  }
}
