import 'dart:js_interop';

import 'package:budgetting_frontend/core/utils/currency_formatter.dart';
import 'package:budgetting_frontend/features/accounts/data/accounts_api_client.dart';
import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:budgetting_frontend/features/accounts/presentation/bloc/accounts_bloc.dart';
import 'package:budgetting_frontend/features/accounts/presentation/bloc/accounts_event.dart';
import 'package:budgetting_frontend/features/accounts/presentation/bloc/accounts_state.dart';
import 'package:budgetting_frontend/features/accounts/presentation/widgets/account_list_card.dart';
import 'package:budgetting_frontend/features/accounts/presentation/widgets/accounts_overview_card.dart';
import 'package:budgetting_frontend/features/accounts/presentation/widgets/add_account_sheet.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_footer.dart';
import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_header.dart';
import 'package:budgetting_frontend/features/transactions/data/datasources/transactions_api_client.dart';
import 'package:budgetting_frontend/features/transactions/domain/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:web/web.dart' as web;

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
    context.go('/accounts/${account.id}', extra: account);
  }

  Future<void> _exportTransactions(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context)
      ..showSnackBar(
        const SnackBar(
          content: Text('Preparing export…'),
          duration: Duration(seconds: 30),
        ),
      );
    try {
      final txns = await TransactionsApiClient().getTransactions();
      final csv = _buildCsv(txns);
      final filename =
          'transactions_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.csv';
      _downloadCsv(csv, filename);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Export downloaded')));
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Export failed — please try again')),
        );
    }
  }

  String _buildCsv(List<TransactionModel> txns) {
    final buf = StringBuffer()
      ..writeln('Date,Account,Category,Amount,Location,Latitude,Longitude');
    for (final t in txns) {
      buf.writeln([
        _esc(DateFormat('yyyy-MM-dd').format(t.date)),
        _esc(t.accountName ?? ''),
        _esc(t.categoryName),
        t.amount.toStringAsFixed(2),
        _esc(t.location ?? ''),
        t.latitude?.toStringAsFixed(6) ?? '',
        t.longitude?.toStringAsFixed(6) ?? '',
      ].join(','),);
    }
    return buf.toString();
  }

  String _esc(String s) {
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  void _downloadCsv(String csv, String filename) {
    final blob = web.Blob(
      [csv.toJS].toJS,
      web.BlobPropertyBag(type: 'text/csv;charset=utf-8'),
    );
    final url = web.URL.createObjectURL(blob);
    (web.document.createElement('a') as web.HTMLAnchorElement)
      ..href = url
      ..download = filename
      ..click();
    web.URL.revokeObjectURL(url);
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
            tooltip: 'Export CSV',
            onPressed: () => _exportTransactions(context),
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
