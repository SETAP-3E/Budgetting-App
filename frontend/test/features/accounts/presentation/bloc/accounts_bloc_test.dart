import 'package:bloc_test/bloc_test.dart';
import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:budgetting_frontend/features/accounts/presentation/bloc/accounts_bloc.dart';
import 'package:budgetting_frontend/features/accounts/presentation/bloc/accounts_event.dart';
import 'package:budgetting_frontend/features/accounts/presentation/bloc/accounts_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
  final current = _acc(id: 'current-1', type: AccountType.current);
  final savings = _acc(id: 'savings-1', type: AccountType.savings);
  final joint = _acc(id: 'joint-1', type: AccountType.joint);
  final newAcc = _acc(id: 'new-1', type: AccountType.savings, balance: 500);

  group('AccountsBloc', () {
    group('AccountsStarted', () {
      blocTest<AccountsBloc, AccountsState>(
        'emits [loading, success] with all accounts on successful load',
        build: () => AccountsBloc(
          getAccounts: () => [current, savings, joint],
        ),
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
        'emits [loading, failure] when use case throws',
        build: () => AccountsBloc(
          getAccounts: () => throw Exception('load error'),
        ),
        act: (b) => b.add(const AccountsStarted()),
        expect: () => [
          const AccountsState(status: AccountsStatus.loading),
          isA<AccountsState>()
              .having((s) => s.status, 'status', AccountsStatus.failure)
              .having((s) => s.errorMessage, 'errorMessage', isNotNull),
        ],
      );
    });

    group('AccountsTypeFilterChanged', () {
      blocTest<AccountsBloc, AccountsState>(
        'filters visibleAccounts to current only',
        build: () => AccountsBloc(getAccounts: () => [current, savings, joint]),
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
        build: () => AccountsBloc(getAccounts: () => [current, savings, joint]),
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

    group('AccountsAccountAdded', () {
      blocTest<AccountsBloc, AccountsState>(
        'adds account and re-emits success with extended list',
        build: () {
          var calls = 0;
          return AccountsBloc(
            getAccounts: () {
              calls++;
              return calls == 1
                  ? [current, savings, joint]
                  : [current, savings, joint, newAcc];
            },
          );
        },
        act: (b) => b
          ..add(const AccountsStarted())
          ..add(AccountsAccountAdded(newAcc)),
        expect: () => [
          const AccountsState(status: AccountsStatus.loading),
          isA<AccountsState>()
              .having((s) => s.accounts.length, 'accounts', 3),
          isA<AccountsState>()
              .having((s) => s.status, 'status', AccountsStatus.success)
              .having((s) => s.accounts.length, 'accounts', 4),
        ],
      );
    });
  });
}
