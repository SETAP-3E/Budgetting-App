import 'package:budgetting_frontend/features/accounts/data/accounts_api_client.dart';
import 'package:budgetting_frontend/features/accounts/data/mock_accounts_datasource.dart';
import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:budgetting_frontend/features/accounts/presentation/bloc/accounts_event.dart';
import 'package:budgetting_frontend/features/accounts/presentation/bloc/accounts_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages loading, filtering, and refreshing accounts from the backend API.
class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  /// Create an [AccountsBloc].
  AccountsBloc({required AccountsApiClient apiClient})
      : _apiClient = apiClient,
        super(const AccountsState()) {
    on<AccountsStarted>(_onStarted);
    on<AccountsRefreshRequested>(_onRefreshRequested);
    on<AccountsTypeFilterChanged>(_onTypeFilterChanged);
  }

  final AccountsApiClient _apiClient;

  Future<void> _onStarted(
    AccountsStarted event,
    Emitter<AccountsState> emit,
  ) async {
    emit(state.copyWith(status: AccountsStatus.loading));
    await _fetchAndEmit(emit, selectedType: null);
  }

  Future<void> _onRefreshRequested(
    AccountsRefreshRequested event,
    Emitter<AccountsState> emit,
  ) async {
    emit(state.copyWith(status: AccountsStatus.loading));
    await _fetchAndEmit(emit, selectedType: state.selectedType);
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

  Future<void> _fetchAndEmit(
    Emitter<AccountsState> emit, {
    required AccountType? selectedType,
  }) async {
    try {
      final all = await _apiClient.getAccounts();
      MockAccountsDatasource.syncAccounts(all);
      emit(
        AccountsState(
          status: AccountsStatus.success,
          accounts: all,
          visibleAccounts: _derive(all, selectedType),
          selectedType: selectedType,
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

  List<AccountModel> _derive(List<AccountModel> all, AccountType? type) =>
      type == null ? all : all.where((a) => a.type == type).toList();
}
