import 'package:budgetting_frontend/features/accounts/data/mock_accounts_datasource.dart';
import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';

/// Function signature for fetching all accounts.
typedef GetAccountsUseCase = List<AccountModel> Function();

/// Default implementation backed by [MockAccountsDatasource].
List<AccountModel> getAccountsUseCaseImpl() =>
    MockAccountsDatasource.getAccounts();
