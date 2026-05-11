// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, implicit_dynamic_list_literal

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';


import '../routes/users/users.dart' as users_users;
import '../routes/transactions/index.dart' as transactions_index;
import '../routes/transactions/[id].dart' as transactions_$id;
import '../routes/places/details.dart' as places_details;
import '../routes/places/autocomplete.dart' as places_autocomplete;
import '../routes/categories/index.dart' as categories_index;
import '../routes/budgets/index.dart' as budgets_index;
import '../routes/auth/signup.dart' as auth_signup;
import '../routes/auth/login.dart' as auth_login;
import '../routes/accounts/index.dart' as accounts_index;

import '../routes/_middleware.dart' as middleware;

void main() async {
  final address = InternetAddress.tryParse('') ?? InternetAddress.anyIPv6;
  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;
  hotReload(() => createServer(address, port));
}

Future<HttpServer> createServer(InternetAddress address, int port) {
  final handler = Cascade().add(buildRootHandler()).handler;
  return serve(handler, address, port);
}

Handler buildRootHandler() {
  final pipeline = const Pipeline().addMiddleware(middleware.middleware);
  final router = Router()
    ..mount('/users', (context) => buildUsersHandler()(context))
    ..mount('/transactions', (context) => buildTransactionsHandler()(context))
    ..mount('/places', (context) => buildPlacesHandler()(context))
    ..mount('/categories', (context) => buildCategoriesHandler()(context))
    ..mount('/budgets', (context) => buildBudgetsHandler()(context))
    ..mount('/auth', (context) => buildAuthHandler()(context))
    ..mount('/accounts', (context) => buildAccountsHandler()(context));
  return pipeline.addHandler(router);
}

Handler buildUsersHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/users', (context) => users_users.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildTransactionsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/<id>', (context,id,) => transactions_$id.onRequest(context,id,))..all('/', (context) => transactions_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildPlacesHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/autocomplete', (context) => places_autocomplete.onRequest(context,))..all('/details', (context) => places_details.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildCategoriesHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => categories_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildBudgetsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => budgets_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildAuthHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/login', (context) => auth_login.onRequest(context,))..all('/signup', (context) => auth_signup.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildAccountsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => accounts_index.onRequest(context,));
  return pipeline.addHandler(router);
}

