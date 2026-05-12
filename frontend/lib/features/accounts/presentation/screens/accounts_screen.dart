import 'package:budgetting_frontend/core/theme/app_theme.dart';
import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:budgetting_frontend/features/accounts/data/accounts_api_client.dart';
import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:budgetting_frontend/features/accounts/presentation/bloc/accounts_bloc.dart';
import 'package:budgetting_frontend/features/accounts/presentation/bloc/accounts_event.dart';
import 'package:budgetting_frontend/features/accounts/presentation/bloc/accounts_state.dart';
import 'package:budgetting_frontend/features/accounts/presentation/screens/account_detail_screen.dart';
import 'package:budgetting_frontend/features/accounts/presentation/widgets/account_list_card.dart';
import 'package:budgetting_frontend/features/accounts/presentation/widgets/add_account_sheet.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_footer.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Accounts screen showing account balances and quick actions.
class AccountsScreen extends StatelessWidget {
  /// Creates the accounts screen.
  ///
  /// [apiClientOverride] is injected in tests to avoid real HTTP calls.
  const AccountsScreen({super.key, this.apiClientOverride});

  /// Replaces the default [AccountsApiClient] — used in tests only.
  final AccountsApiClient? apiClientOverride;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AccountsBloc(apiClient: apiClientOverride ?? AccountsApiClient())
            ..add(const AccountsStarted()),
      child: const _AccountsView(),
    );
  }
}

class _AccountsView extends StatelessWidget {
  const _AccountsView();

  void _openAddAccountSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddAccountSheet(),
    ).then((_) {
      if (context.mounted) {
        context.read<AccountsBloc>().add(const AccountsRefreshRequested());
      }
    });
  }

  void _openAccountDetail(BuildContext context, AccountModel account) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AccountDetailScreen(account: account),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Accounts',
        onMenuPressed: () {},
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export',
            onPressed: () =>
                _showComingSoon(context, 'Export flow coming soon'),
          ),
        ],
      ),
      body: BlocBuilder<AccountsBloc, AccountsState>(
        builder: (context, state) {
          if (state.status == AccountsStatus.loading ||
              state.status == AccountsStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AccountsStatus.failure) {
            return Center(
              child: Text(state.errorMessage ?? 'Something went wrong'),
            );
          }

          final totalBalance =
              state.accounts.fold<double>(0, (s, a) => s + a.balance);
          final lowCount =
              state.accounts.where((a) => a.balance < 1000).length;

          return RefreshIndicator(
            onRefresh: () async => context
                .read<AccountsBloc>()
                .add(const AccountsRefreshRequested()),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Balance header ──────────────────────────────────────
                  ColoredBox(
                    color: AppTheme.primaryMint,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Balance',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatCurrency(totalBalance),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                if (lowCount > 0) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '$lowCount account'
                                    '${lowCount == 1 ? '' : 's'}'
                                    ' need attention',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: () => _openAddAccountSheet(context),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Account'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primaryMint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ── Account list ────────────────────────────────────────
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                        child: _buildAccountSection(context, state),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const AppFooter(activeIndex: 1),
    );
  }

  Widget _buildAccountSection(BuildContext context, AccountsState state) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Accounts', style: theme.textTheme.titleLarge),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<AccountType?>(
            segments: const [
              ButtonSegment<AccountType?>(value: null, label: Text('All')),
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
            selected: {state.selectedType},
            onSelectionChanged: (selection) => context
                .read<AccountsBloc>()
                .add(AccountsTypeFilterChanged(selection.first)),
          ),
        ),
        const SizedBox(height: 14),
        ...state.visibleAccounts.map(
          (account) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AccountListCard(
              account: account,
              balanceText: formatCurrency(account.balance),
              remainingText:
                  'Remaining ${formatCurrency(account.remainingBudget)}',
              onTap: () => _openAccountDetail(context, account),
            ),
          ),
        ),
      ],
    );
  }
}
