import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:budgetting_frontend/features/accounts/data/accounts_api_client.dart';
import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:budgetting_frontend/features/accounts/presentation/bloc/accounts_bloc.dart';
import 'package:budgetting_frontend/features/accounts/presentation/bloc/accounts_event.dart';
import 'package:budgetting_frontend/features/accounts/presentation/bloc/accounts_state.dart';
import 'package:budgetting_frontend/features/accounts/presentation/screens/account_detail_screen.dart';
import 'package:budgetting_frontend/features/accounts/presentation/widgets/account_list_card.dart';
import 'package:budgetting_frontend/features/accounts/presentation/widgets/accounts_overview_card.dart';
import 'package:budgetting_frontend/features/accounts/presentation/widgets/accounts_quick_actions.dart';
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
        context
            .read<AccountsBloc>()
            .add(const AccountsRefreshRequested());
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
        onMenuPressed: () => _showComingSoon(context, 'Menu opened'),
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

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 980;
              final overviewCard = AccountsOverviewCard(
                totalBalance: state.accounts
                    .fold(0, (sum, a) => sum + a.balance),
                activeAccounts: state.accounts.length,
                lowBalanceCount:
                    state.accounts.where((a) => a.balance < 1000).length,
                currencyText: formatCurrency(
                  state.accounts.fold(0, (sum, a) => sum + a.balance),
                ),
              );
              final quickActions = AccountsQuickActions(
                onAddAccount: () => _openAddAccountSheet(context),
                onTransfer: () =>
                    _showComingSoon(context, 'Transfer flow coming soon'),
                onExport: () =>
                    _showComingSoon(context, 'Export flow coming soon'),
              );
              final accountSection =
                  _buildAccountSection(context, state);

              if (isWide) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            overviewCard,
                            const SizedBox(height: 12),
                            quickActions,
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: accountSection),
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
                      overviewCard,
                      const SizedBox(height: 12),
                      quickActions,
                      const SizedBox(height: 16),
                      accountSection,
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const AppFooter(activeIndex: 1),
    );
  }

  Widget _buildAccountSection(
    BuildContext context,
    AccountsState state,
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
        const SizedBox(height: 12),
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
