import 'package:bloc_test/bloc_test.dart';
import 'package:budgetting_frontend/features/accounts/data/accounts_api_client.dart';
import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:budgetting_frontend/features/accounts/presentation/bloc/accounts_bloc.dart';
import 'package:budgetting_frontend/features/accounts/presentation/bloc/accounts_event.dart';
import 'package:budgetting_frontend/features/accounts/presentation/bloc/accounts_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAccountsApiClient extends Mock implements AccountsApiClient {}

AccountModel _acc({
  required String id,
  required AccountType type,
  double balance = 1000,
  double monthlyBudget = 500,
  double monthlySpent = 200,
}) =>
    AccountModel(
      id: id,
      name: id,
      type: type,
      balance: balance,
      monthlyBudget: monthlyBudget,
      monthlySpent: monthlySpent,
      accentColor: const Color(0xFF4DB6AC),
    );

void main() {
  late MockAccountsApiClient apiClient;

  final current = _acc(id: 'current-1', type: AccountType.current);
  final savings = _acc(id: 'savings-1', type: AccountType.savings);
  final joint = _acc(id: 'joint-1', type: AccountType.joint);

  setUp(() {
    apiClient = MockAccountsApiClient();
  });

  AccountsBloc build() => AccountsBloc(apiClient: apiClient);

  group('AccountsBloc', () {
    group('AccountsStarted', () {
      blocTest<AccountsBloc, AccountsState>(
        'emits [loading, success] with all accounts on successful load',
        setUp: () => when(() => apiClient.getAccounts())
            .thenAnswer((_) async => [current, savings, joint]),
        build: build,
        act: (b) => b.add(const AccountsStarted()),
        expect: () => [
          const AccountsState(status: AccountsStatus.loading),
          isA<AccountsState>()
              .having((s) => s.status, 'status', AccountsStatus.success)
              .having((s) => s.accounts.length, 'accounts', 3)
              .having((s) => s.visibleAccounts.length, 'visibleAccounts', 3),
        ],
      );

      blocTest<AccountsBloc, AccountsState>(
        'emits [loading, failure] when API throws',
        setUp: () => when(() => apiClient.getAccounts())
            .thenThrow(Exception('network error')),
        build: build,
        act: (b) => b.add(const AccountsStarted()),
        expect: () => [
          const AccountsState(status: AccountsStatus.loading),
          isA<AccountsState>()
              .having((s) => s.status, 'status', AccountsStatus.failure)
              .having((s) => s.errorMessage, 'errorMessage', isNotNull),
        ],
      );
    });

    group('AccountsRefreshRequested', () {
      blocTest<AccountsBloc, AccountsState>(
        're-fetches and emits [loading, success]',
        setUp: () => when(() => apiClient.getAccounts())
            .thenAnswer((_) async => [current, savings, joint]),
        build: build,
        seed: () => const AccountsState(status: AccountsStatus.success),
        act: (b) => b.add(const AccountsRefreshRequested()),
        expect: () => [
          isA<AccountsState>()
              .having((s) => s.status, 'status', AccountsStatus.loading),
          isA<AccountsState>()
              .having((s) => s.status, 'status', AccountsStatus.success)
              .having((s) => s.accounts.length, 'accounts', 3),
        ],
      );
    });

    group('AccountsTypeFilterChanged', () {
      blocTest<AccountsBloc, AccountsState>(
        'filters visibleAccounts to current only',
        build: build,
        seed: () => AccountsState(
          status: AccountsStatus.success,
          accounts: [current, savings, joint],
          visibleAccounts: [current, savings, joint],
        ),
        act: (b) =>
            b.add(const AccountsTypeFilterChanged(AccountType.current)),
        expect: () => [
          isA<AccountsState>()
              .having(
                (s) => s.selectedType,
                'selectedType',
                AccountType.current,
              )
              .having((s) => s.visibleAccounts, 'visibleAccounts', [current]),
        ],
      );

      blocTest<AccountsBloc, AccountsState>(
        'null type shows all accounts',
        build: build,
        seed: () => AccountsState(
          status: AccountsStatus.success,
          accounts: [current, savings, joint],
          visibleAccounts: [current],
          selectedType: AccountType.current,
        ),
        act: (b) => b.add(const AccountsTypeFilterChanged(null)),
        expect: () => [
          isA<AccountsState>()
              .having((s) => s.selectedType, 'selectedType', isNull)
              .having(
                (s) => s.visibleAccounts.length,
                'visibleAccounts',
                3,
              ),
        ],
      );
    });
  });
}
