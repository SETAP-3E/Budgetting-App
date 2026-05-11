import 'package:budgetting_frontend/features/accounts/data/accounts_api_client.dart';
import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:budgetting_frontend/features/budgets/presentation/widgets/budget_alert_card.dart';
import 'package:budgetting_frontend/features/budgets/presentation/widgets/budget_card.dart';
import 'package:budgetting_frontend/features/budgets/presentation/widgets/budget_chart.dart';
import 'package:budgetting_frontend/features/budgets/presentation/widgets/budget_summary_card.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_footer.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_header.dart';
import 'package:flutter/material.dart';

/// Budgets screen showing per-account budget vs spending for the current month.
class BudgetsScreen extends StatefulWidget {
  /// Create a [BudgetsScreen].
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  final _apiClient = AccountsApiClient();

  bool _isSimpleView = true;
  bool _isLoading = false;
  String? _error;

  double _totalBudget = 0;
  double _totalSpent = 0;
  List<Map<String, dynamic>> _currentBudgets = [];

  static const _monthNames = [
    '',
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

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
      final accounts = await _apiClient.getAccounts();
      final budgeted = accounts
          .where((a) => a.monthlyBudget > 0)
          .toList()
        ..sort((a, b) => b.monthlyBudget.compareTo(a.monthlyBudget));

      final budgets = budgeted.indexed.map((entry) {
        final (i, account) = entry;
        final spent = account.monthlySpent;
        final allocated = account.monthlyBudget;
        final colour = _resolveColour(account, i);
        return <String, dynamic>{
          'rank': i + 1,
          'name': account.name,
          'allocated': allocated,
          'spent': spent,
          'percentage': allocated > 0 ? spent / allocated * 100 : 0.0,
          'colour': colour,
        };
      }).toList();

      setState(() {
        _isLoading = false;
        _currentBudgets = budgets;
        _totalBudget =
            budgets.fold(0, (s, b) => s + (b['allocated'] as double));
        _totalSpent =
            budgets.fold(0, (s, b) => s + (b['spent'] as double));
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  int _resolveColour(AccountModel account, int index) {
    const fallbacks = [
      0xFF4CAF50, 0xFF2196F3, 0xFFFF9800,
      0xFF9C27B0, 0xFFF44336, 0xFF00BCD4,
    ];
    final value = account.accentColor.toARGB32();
    return value == 0 ? fallbacks[index % fallbacks.length] : value;
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

  void _updateBudgetLimit(String accountName, double newLimit) {
    final updated = _currentBudgets.map(Map<String, dynamic>.from).toList();
    for (final b in updated) {
      if (b['name'] == accountName) {
        final spent = b['spent'] as double;
        b['allocated'] = newLimit;
        b['percentage'] = newLimit > 0 ? (spent / newLimit * 100) : 0.0;
      }
    }
    setState(() {
      _currentBudgets = updated;
      _totalBudget =
          updated.fold(0, (s, b) => s + (b['allocated'] as double));
      _totalSpent =
          updated.fold(0, (s, b) => s + (b['spent'] as double));
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
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
                          month: _monthNames[now.month],
                          year: now.year,
                        ),
                        const SizedBox(height: 16),
                        _buildAlertBudget(),
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
