import 'package:budgetting_frontend/core/theme/app_theme.dart';
import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:budgetting_frontend/features/accounts/data/accounts_api_client.dart';
import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:budgetting_frontend/features/accounts/presentation/widgets/account_spending_chart.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_footer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Color _usageColour(double ratio) {
  if (ratio > 1.0) return const Color(0xFFB71C1C);
  if (ratio >= 0.9) return const Color(0xFFE65100);
  if (ratio >= 0.75) return const Color(0xFFFFB300);
  return AppTheme.primaryMint;
}

/// Full-screen view for a single account — live data fetched on open.
class AccountDetailScreen extends StatefulWidget {
  /// Create an [AccountDetailScreen].
  const AccountDetailScreen({required this.account, super.key});

  /// The account to display.
  final AccountModel account;

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

enum _TxSort { dateNewest, dateOldest, amountHighest, amountLowest }

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  List<AccountTransactionItem>? _transactions;
  bool _loading = true;
  String? _error;
  int _txPage = 0;
  _TxSort _sort = _TxSort.dateNewest;
  String? _categoryFilter;

  static const _kPageSize = 5;

  List<AccountTransactionItem> _derive() {
    var list = List<AccountTransactionItem>.from(_transactions ?? []);
    if (_categoryFilter != null) {
      list = list.where((t) => t.categoryName == _categoryFilter).toList();
    }
    switch (_sort) {
      case _TxSort.dateNewest:
        list.sort((a, b) => b.date.compareTo(a.date));
      case _TxSort.dateOldest:
        list.sort((a, b) => a.date.compareTo(b.date));
      case _TxSort.amountHighest:
        list.sort((a, b) => b.amount.compareTo(a.amount));
      case _TxSort.amountLowest:
        list.sort((a, b) => a.amount.compareTo(b.amount));
    }
    return list;
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Text('Sort by',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
                ..._TxSort.values.map((s) {
                  final label = switch (s) {
                    _TxSort.dateNewest    => 'Date — newest first',
                    _TxSort.dateOldest   => 'Date — oldest first',
                    _TxSort.amountHighest => 'Amount — highest first',
                    _TxSort.amountLowest  => 'Amount — lowest first',
                  };
                  final selected = _sort == s;
                  return ListTile(
                    dense: true,
                    title: Text(label, style: theme.textTheme.bodyMedium),
                    trailing: selected
                        ? Icon(Icons.check,
                            size: 18,
                            color: theme.colorScheme.primary,)
                        : null,
                    onTap: () {
                      setState(() { _sort = s; _txPage = 0; });
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final txns = await AccountsApiClient()
          .getAccountTransactions(widget.account.id);
      if (mounted) setState(() { _transactions = txns; _loading = false; });
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Could not load transactions.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = widget.account;
    final theme = Theme.of(context);
    final now = DateTime.now();
    final monthName = DateFormat.MMMM().format(now);

    final currentMonthTxns = _transactions
            ?.where(
              (t) => t.date.year == now.year && t.date.month == now.month,
            )
            .toList() ??
        [];
    final allTxns = _derive();
    final totalPages = (allTxns.length / _kPageSize).ceil().clamp(1, 999);
    final pageTxns = allTxns
        .skip(_txPage * _kPageSize)
        .take(_kPageSize)
        .toList();

    final categories = (_transactions ?? [])
        .map((t) => t.categoryName)
        .toSet()
        .toList()
      ..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text(account.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _transactions == null
              ? _ErrorView(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeaderCard(account: account, theme: theme),
                        const SizedBox(height: 20),
                        _sectionLabel(theme, 'This Month — $monthName'),
                        const SizedBox(height: 10),
                        _MonthlyUsageCard(account: account, theme: theme),
                        if (account.weeklyTarget > 0) ...[
                          const SizedBox(height: 12),
                          _WeeklyUsageCard(account: account, theme: theme),
                        ],
                        if (currentMonthTxns.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          AccountSpendingChart(
                            transactions: currentMonthTxns,
                            accentColor: account.accentColor,
                          ),
                        ],
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _sectionLabel(theme, 'Transactions'),
                            ),
                            TextButton.icon(
                              onPressed: () => _showSortSheet(context),
                              icon: const Icon(Icons.sort, size: 16),
                              label: const Text('Sort'),
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ),
                        if (categories.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                FilterChip(
                                  label: const Text('All'),
                                  selected: _categoryFilter == null,
                                  onSelected: (_) => setState(() {
                                    _categoryFilter = null;
                                    _txPage = 0;
                                  }),
                                ),
                                ...categories.map(
                                  (cat) => Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: FilterChip(
                                      label: Text(cat),
                                      selected: _categoryFilter == cat,
                                      onSelected: (_) => setState(() {
                                        _categoryFilter =
                                            _categoryFilter == cat
                                                ? null
                                                : cat;
                                        _txPage = 0;
                                      }),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        _RecentTransactions(
                          transactions: pageTxns,
                          theme: theme,
                          page: _txPage,
                          totalPages: totalPages,
                          onPrev: _txPage > 0
                              ? () => setState(() => _txPage--)
                              : null,
                          onNext: _txPage < totalPages - 1
                              ? () => setState(() => _txPage++)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: const AppFooter(activeIndex: 1),
    );
  }

  Widget _sectionLabel(ThemeData theme, String text) => Text(
        text,
        style: theme.textTheme.titleSmall
            ?.copyWith(fontWeight: FontWeight.w600),
      );
}

// ── Header ─────────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.account, required this.theme});

  final AccountModel account;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: account.accentColor.withValues(alpha: 0.2),
              child: Icon(
                account.type.icon,
                color: account.accentColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatCurrency(account.balance),
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    account.type.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Monthly usage ──────────────────────────────────────────────────────────

class _MonthlyUsageCard extends StatelessWidget {
  const _MonthlyUsageCard({required this.account, required this.theme});

  final AccountModel account;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final ratio = account.budgetUsageRatio;
    final colour = _usageColour(ratio);
    final pct = (ratio * 100).clamp(0, 999).toStringAsFixed(0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Monthly Budget',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500),),
                Text(
                  '$pct%',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: colour, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: ratio.clamp(0.0, 1.0),
                color: colour,
                backgroundColor: colour.withValues(alpha: 0.15),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatChip(
                    label: 'Spent',
                    value: formatCurrency(account.monthlySpent),
                    colour: colour,
                  ),
                ),
                Expanded(
                  child: _StatChip(
                    label: 'Budget',
                    value: formatCurrency(account.monthlyBudget),
                  ),
                ),
                Expanded(
                  child: _StatChip(
                    label: 'Remaining',
                    value: formatCurrency(account.remainingBudget),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Weekly usage ───────────────────────────────────────────────────────────

class _WeeklyUsageCard extends StatelessWidget {
  const _WeeklyUsageCard({required this.account, required this.theme});

  final AccountModel account;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final ratio = account.weeklyUsageRatio;
    final colour = _usageColour(ratio);
    final pct = (ratio * 100).clamp(0, 999).toStringAsFixed(0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('This Week',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500),),
                Text(
                  '$pct%',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: colour, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: ratio.clamp(0.0, 1.0),
                color: colour,
                backgroundColor: colour.withValues(alpha: 0.15),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${formatCurrency(account.weeklySpent)} spent'
              ' of ${formatCurrency(account.weeklyTarget)} weekly target',
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Recent transactions ────────────────────────────────────────────────────

class _RecentTransactions extends StatelessWidget {
  const _RecentTransactions({
    required this.transactions,
    required this.theme,
    required this.page,
    required this.totalPages,
    required this.onPrev,
    required this.onNext,
  });

  final List<AccountTransactionItem> transactions;
  final ThemeData theme;
  final int page;
  final int totalPages;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'No transactions yet.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          ...transactions.map((tx) {
            final isLast = tx == transactions.last;
            final subtitle = [
              DateFormat('d MMM y').format(tx.date),
              if (tx.location != null && tx.location!.isNotEmpty)
                tx.location!,
            ].join(' · ');
            return Column(
              children: [
                ListTile(
                  dense: true,
                  title: Text(
                    tx.categoryName,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    subtitle,
                    style: theme.textTheme.labelSmall,
                  ),
                  trailing: Text(
                    formatCurrency(tx.amount),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: theme.colorScheme.outlineVariant
                        .withValues(alpha: 0.5),
                  ),
              ],
            );
          }),
          if (totalPages > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: onPrev,
                    visualDensity: VisualDensity.compact,
                  ),
                  Text(
                    '${page + 1} / $totalPages',
                    style: theme.textTheme.labelSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: onNext,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value, this.colour});

  final String label;
  final String value;
  final Color? colour;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colour,
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      );
}
