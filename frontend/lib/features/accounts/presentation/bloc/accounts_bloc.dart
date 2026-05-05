import 'package:budgetting_frontend/features/accounts/data/mock_accounts_datasource.dart';
import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:budgetting_frontend/features/accounts/domain/usecases/get_accounts_use_case.dart';
import 'package:budgetting_frontend/features/accounts/presentation/bloc/accounts_event.dart';
import 'package:budgetting_frontend/features/accounts/presentation/bloc/accounts_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages loading, filtering, and adding accounts.
class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  /// Create an [AccountsBloc].
  AccountsBloc({required GetAccountsUseCase getAccounts})
      : _getAccounts = getAccounts,
        super(const AccountsState()) {
    on<AccountsStarted>(_onStarted);
    on<AccountsTypeFilterChanged>(_onTypeFilterChanged);
    on<AccountsAccountAdded>(_onAccountAdded);
  }

  final GetAccountsUseCase _getAccounts;

  void _onStarted(
    AccountsStarted event,
    Emitter<AccountsState> emit,
  ) {
    emit(state.copyWith(status: AccountsStatus.loading));
    try {
      final all = _getAccounts();
      emit(
        state.copyWith(
          status: AccountsStatus.success,
          accounts: all,
          visibleAccounts: _derive(all, state.selectedType),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AccountsStatus.failure,
          errorMessage: 'Could not load accounts.',
        ),
      );
    }
  }

  void _onTypeFilterChanged(
    AccountsTypeFilterChanged event,
    Emitter<AccountsState> emit,
  ) {
    emit(
      AccountsState(
        status: state.status,
        accounts: state.accounts,
        visibleAccounts: _derive(state.accounts, event.type),
        selectedType: event.type,
        errorMessage: state.errorMessage,
      ),
    );
  }

  void _onAccountAdded(
    AccountsAccountAdded event,
    Emitter<AccountsState> emit,
  ) {
    MockAccountsDatasource.addAccount(event.account);
    final all = _getAccounts();
    emit(
      state.copyWith(
        status: AccountsStatus.success,
        accounts: all,
        visibleAccounts: _derive(all, state.selectedType),
      ),
    );
  }

  List<AccountModel> _derive(List<AccountModel> all, AccountType? type) =>
      type == null ? all : all.where((a) => a.type == type).toList();
}
