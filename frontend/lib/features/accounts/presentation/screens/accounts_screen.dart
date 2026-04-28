import 'package:budgetting_frontend/features/accounts/data/mock_accounts_datasource.dart';
import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:budgetting_frontend/features/accounts/presentation/widgets/account_list_card.dart';
import 'package:budgetting_frontend/features/accounts/presentation/widgets/accounts_overview_card.dart';
import 'package:budgetting_frontend/features/accounts/presentation/widgets/accounts_quick_actions.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_footer.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Accounts screen showing account balances and quick actions.
class AccountsScreen extends StatefulWidget {
  /// Creates the accounts screen.
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  AccountType? _selectedType;

  List<AccountModel> get _allAccounts => MockAccountsDatasource.getAccounts();

  List<AccountModel> get _visibleAccounts {
    if (_selectedType == null) {
      return _allAccounts;
    }

    return _allAccounts.where((a) => a.type == _selectedType).toList();
  }

  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'en_GB',
    symbol: '£',
    decimalDigits: 2,
  );

  double get _totalBalance =>
      _allAccounts.fold(0, (sum, account) => sum + account.balance);

  int get _lowBalanceCount =>
      _allAccounts.where((a) => a.balance < 1000).length;

  @override
  Widget build(BuildContext context) {
    final visibleAccounts = _visibleAccounts;

    return Scaffold(
      appBar: AppHeader(
        title: 'Accounts',
        onMenuPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menu opened')),
          );
        },
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 980;

          if (isWide) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        AccountsOverviewCard(
                          totalBalance: _totalBalance,
                          activeAccounts: _allAccounts.length,
                          lowBalanceCount: _lowBalanceCount,
                          currencyText: _currencyFormatter.format(
                            _totalBalance,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AccountsQuickActions(
                          onAddAccount: () => _showComingSoon(
                            context,
                            'Add account flow coming soon',
                          ),
                          onTransfer: () => _showComingSoon(
                            context,
                            'Transfer flow coming soon',
                          ),
                          onExport: () => _showComingSoon(
                            context,
                            'Export flow coming soon',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildAccountSection(
                      context,
                      visibleAccounts,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AccountsOverviewCard(
                    totalBalance: _totalBalance,
                    activeAccounts: _allAccounts.length,
                    lowBalanceCount: _lowBalanceCount,
                    currencyText: _currencyFormatter.format(_totalBalance),
                  ),
                  const SizedBox(height: 12),
                  AccountsQuickActions(
                    onAddAccount: () =>
                        _showComingSoon(
                      context,
                      'Add account flow coming soon',
                    ),
                    onTransfer: () =>
                        _showComingSoon(context, 'Transfer flow coming soon'),
                    onExport: () =>
                        _showComingSoon(context, 'Export flow coming soon'),
                  ),
                  const SizedBox(height: 16),
                  _buildAccountSection(context, visibleAccounts),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const AppFooter(activeIndex: 1),
    );
  }

  Widget _buildAccountSection(
    BuildContext context,
    List<AccountModel> visibleAccounts,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Accounts', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<AccountType?>(
            segments: const [
              ButtonSegment<AccountType?>(
                value: null,
                label: Text('All'),
              ),
              ButtonSegment<AccountType?>(
                value: AccountType.current,
                label: Text('Current'),
              ),
              ButtonSegment<AccountType?>(
                value: AccountType.savings,
                label: Text('Savings'),
              ),
              ButtonSegment<AccountType?>(
                value: AccountType.joint,
                label: Text('Joint'),
              ),
            ],
            selected: {_selectedType},
            onSelectionChanged: (selection) {
              setState(() {
                _selectedType = selection.first;
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        ...visibleAccounts.map(
          (account) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AccountListCard(
              account: account,
              balanceText: _currencyFormatter.format(account.balance),
                remainingText: 'Remaining '
                  '${_currencyFormatter.format(account.remainingBudget)}',
              onTap: () => _showComingSoon(
                context,
                'Open ${account.name} details (coming soon)',
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
