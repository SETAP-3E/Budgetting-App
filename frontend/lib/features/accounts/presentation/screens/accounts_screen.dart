import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:budgetting_frontend/features/accounts/data/accounts_api_client.dart';
import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:budgetting_frontend/features/accounts/presentation/bloc/accounts_bloc.dart';
import 'package:budgetting_frontend/features/accounts/presentation/bloc/accounts_event.dart';
import 'package:budgetting_frontend/features/accounts/presentation/bloc/accounts_state.dart';
import 'package:budgetting_frontend/features/accounts/presentation/screens/account_detail_screen.dart';
import 'package:budgetting_frontend/features/accounts/presentation/widgets/account_list_card.dart';
import 'package:budgetting_frontend/features/accounts/presentation/widgets/accounts_overview_card.dart';
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddAccountSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Account'),
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

          return RefreshIndicator(
            onRefresh: () async => context
                .read<AccountsBloc>()
                .add(const AccountsRefreshRequested()),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AccountsOverviewCard(
                    totalBalance: state.accounts
                        .fold(0, (s, a) => s + a.balance),
                    activeAccounts: state.accounts.length,
                    lowBalanceCount: state.accounts
                        .where((a) => a.balance < 1000)
                        .length,
                    currencyText: formatCurrency(
                      state.accounts.fold(0, (s, a) => s + a.balance),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildAccountSection(context, state),
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
        Align(
          alignment: Alignment.centerLeft,
          child: SegmentedButton<AccountType?>(
            showSelectedIcon: false,
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
