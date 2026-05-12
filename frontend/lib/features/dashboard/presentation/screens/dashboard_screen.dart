import 'package:budgetting_frontend/core/auth/auth_service.dart';
import 'package:budgetting_frontend/core/theme/app_theme.dart';
import 'package:budgetting_frontend/core/utils/colour_utils.dart';
import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:budgetting_frontend/features/accounts/data/accounts_api_client.dart';
import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:budgetting_frontend/features/budgets/data/budgets_api_client.dart';
import 'package:budgetting_frontend/features/budgets/domain/models/budget_models.dart';
import 'package:budgetting_frontend/features/budgets/presentation/widgets/weekly_budget_chart.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_footer.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_header.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/budget_health_card.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/metric_card.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/monthly_trend_chart.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/recent_transactions_card.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/spending_chart.dart';
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
  final _authService = AuthService();

  bool _isLoading = false;
  bool _isAccountsLoading = false;
  bool _isBudgetsLoading = false;
  String? _error;
  bool _hasLoadedOnce = false;

  String? _username;
  List<TransactionModel> _allTransactions = [];
  Map<String, int> _colourByCategory = {};
  List<AccountModel> _accounts = [];
  BudgetSummaryModel? _budgetSummary;
  BudgetSummaryModel? _lastMonthSummary;

  // Derived by _applyPeriod()
  List<Map<String, dynamic>> _currentPeriodData = [];
  Map<String, double> _previousByCategory = {};
  double _totalSpent = 0;
  String _periodMonth = '';
  int _periodYear = 0;
  int _periodTransactionCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final name = await _authService.getUsername();
    if (mounted) setState(() => _username = name);
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

    // ── Budget summaries for this month + last month ──────────────────────
    try {
      final now = DateTime.now();
      final lastMonth = now.month == 1 ? 12 : now.month - 1;
      final lastYear = now.month == 1 ? now.year - 1 : now.year;
      final results = await Future.wait([
        _budgetsClient.getBudgets(year: now.year, month: now.month),
        _budgetsClient.getBudgets(year: lastYear, month: lastMonth),
      ]);
      if (mounted) {
        setState(() {
          _budgetSummary = results[0];
          _lastMonthSummary = results[1];
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
      _currentPeriodData = ensureUniqueColours(
        sorted
            .map(
              (e) => <String, dynamic>{
                'name': e.key,
                'amount': e.value,
                'percentage':
                    totalCurrent > 0 ? e.value / totalCurrent * 100 : 0.0,
                'colour': _colourByCategory[e.key] ?? 0xFF9E9E9E,
              },
            )
            .toList(),
      );
      _previousByCategory = prevTotals;
      _totalSpent = totalCurrent;
      _periodMonth = monthLabel;
      _periodYear = yearLabel;
      _periodTransactionCount = curTxns.length;
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

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = daysInMonth - now.day;
    final totalBalance =
        _accounts.fold<double>(0, (s, a) => s + a.balance);

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // [1] Greeting
              _GreetingSection(username: _username, now: now),
              const SizedBox(height: 12),

              // [2] Hero spending card
              MetricCard(
                totalSpending: _totalSpent,
                month: _periodMonth,
                year: _periodYear,
                budgetGoal: _selectedPeriod == 'this_year'
                    ? (_budgetSummary?.totalGoal ?? 0.0) * 12
                    : (_budgetSummary?.totalGoal ?? 0.0),
                previousSpending: _selectedPeriod != 'this_year'
                    ? _previousByCategory.values
                        .fold<double>(0, (a, b) => a + b)
                    : null,
                useGradient: true,
              ),
              const SizedBox(height: 12),

              // [3] Quick stats row
              _QuickStatsRow(
                totalBalance: totalBalance,
                transactionCount: _periodTransactionCount,
                daysLeft: daysLeft,
                isLoading: _isAccountsLoading,
              ),
              const SizedBox(height: 16),

              // [4] Period selector
              _buildPeriodSelector(),
              const SizedBox(height: 16),

              // [5] Donut chart or empty state
              if (_currentPeriodData.isEmpty)
                _buildEmptyState(context)
              else ...[
                SpendingChart(
                  categories: _currentPeriodData,
                  isSimpleView: true,
                ),
                const SizedBox(height: 16),
              ],

              // [6] Monthly chart for this_year; weekly for month views
              if (_selectedPeriod == 'this_year' &&
                  _allTransactions.isNotEmpty) ...[
                MonthlyTrendChart(
                  transactions: _allTransactions,
                  monthCount: now.month,
                ),
                const SizedBox(height: 16),
              ],

              if (_selectedPeriod != 'this_year' && !_isBudgetsLoading) ...[
                Builder(builder: (context) {
                  final isLastMonth = _selectedPeriod == 'last_month';
                  final summary =
                      isLastMonth ? _lastMonthSummary : _budgetSummary;
                  final weeks = summary?.weeklyBreakdown;
                  if (weeks == null || weeks.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final chartYear =
                      isLastMonth ? _periodYear : now.year;
                  final chartMonth = isLastMonth
                      ? (now.month == 1 ? 12 : now.month - 1)
                      : now.month;
                  return Column(
                    children: [
                      WeeklyBudgetChart(
                        weeks: weeks,
                        totalGoal: summary!.totalGoal,
                        year: chartYear,
                        month: chartMonth,
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },),
              ],


              // [8] Top category alert + biggest saving (month views only)
              if (_selectedPeriod != 'this_year' &&
                  _currentPeriodData.isNotEmpty) ...[
                _buildTopCategoryAlert(),
                const SizedBox(height: 16),
              ],
              if (_selectedPeriod != 'this_year') ...[
                _buildBiggestDecrease(),
                const SizedBox(height: 16),
              ],

              // [8] Budget health
              BudgetHealthCard(
                summary: _isBudgetsLoading ? null : _budgetSummary,
                onManage: () => context.go('/budgets'),
              ),
              const SizedBox(height: 16),

              // [9] Recent transactions
              _buildRecentTransactions(),
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

  Widget _buildBiggestDecrease() {
    // For "last_month" there's no prior-prior month data, so compare against
    // this month's spending instead.
    final Map<String, double> reference;
    if (_selectedPeriod == 'last_month') {
      final now = DateTime.now();
      final totals = <String, double>{};
      for (final t in _allTransactions) {
        if (t.date.year == now.year && t.date.month == now.month) {
          totals[t.categoryName] = (totals[t.categoryName] ?? 0) + t.amount;
        }
      }
      reference = totals;
    } else {
      reference = _previousByCategory;
    }

    if (reference.isEmpty) return const SizedBox.shrink();

    String? bestName;
    double bestPct = 0;
    double bestCurrent = 0;
    double bestPrev = 0;
    var bestColour = 0xFF9E9E9E;

    for (final entry in reference.entries) {
      final prev = entry.value;
      if (prev <= 0) continue;
      final matches = _currentPeriodData.where((d) => d['name'] == entry.key);
      final current =
          matches.isEmpty ? 0.0 : (matches.first['amount'] as double);
      final pct = (current - prev) / prev * 100;
      if (pct < bestPct) {
        bestPct = pct;
        bestName = entry.key;
        bestCurrent = current;
        bestPrev = prev;
        bestColour = matches.isEmpty
            ? (_colourByCategory[entry.key] ?? 0xFF9E9E9E)
            : (matches.first['colour'] as int);
      }
    }

    if (bestName == null) return const SizedBox.shrink();

    final currentPct = _totalSpent > 0 ? bestCurrent / _totalSpent * 100 : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Biggest Saving',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TopCategoryAlert(
          categoryName: bestName,
          currentAmount: bestCurrent,
          previousAmount: bestPrev,
          percentage: currentPct,
          categoryColour: bestColour,
        ),
      ],
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

// ── Private widgets ────────────────────────────────────────────────────────

class _GreetingSection extends StatelessWidget {
  const _GreetingSection({required this.username, required this.now});

  final String? username;
  final DateTime now;

  static const _days = [
    '', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday',
    'Saturday', 'Sunday',
  ];

  static const _months = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayName = _days[now.weekday];
    final monthName = _months[now.month];
    final greeting =
        username != null ? 'Hello, $username!' : 'Hello!';
    final subtitle = '$dayName, ${now.day} $monthName';

    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onPrimaryContainer.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({
    required this.totalBalance,
    required this.transactionCount,
    required this.daysLeft,
    required this.isLoading,
  });

  final double totalBalance;
  final int transactionCount;
  final int daysLeft;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final balanceValue =
        isLoading ? '—' : formatCurrency(totalBalance);

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Total Balance',
            value: balanceValue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(
            icon: Icons.receipt_long_outlined,
            label: 'Transactions',
            value: '$transactionCount',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(
            icon: Icons.calendar_today_outlined,
            label: 'Days Left',
            value: '$daysLeft',
            iconColor: AppTheme.noteGreen,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        iconColor ?? theme.colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppTheme.mediumText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
