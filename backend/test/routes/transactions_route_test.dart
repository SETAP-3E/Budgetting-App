import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import '../../routes/transactions/index.dart' as route;
import '../helpers/db_helpers.dart';

class MockRequestContext extends Mock implements RequestContext {}

class MockConnection extends Mock implements Connection {}

RequestContext _makeGet(String path, MockConnection connection) {
  final ctx = MockRequestContext();
  when(() => ctx.request).thenReturn(
    Request('GET', Uri.parse('http://test.com$path')),
  );
  when(() => ctx.read<Future<Connection>>())
      .thenAnswer((_) => Future.value(connection));
  return ctx;
}

RequestContext _makePost(
  Map<String, dynamic> body,
  MockConnection connection,
) {
  final ctx = MockRequestContext();
  when(() => ctx.request).thenReturn(
    Request(
      'POST',
      Uri.parse('http://test.com/transactions'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode(body),
    ),
  );
  when(() => ctx.read<Future<Connection>>())
      .thenAnswer((_) => Future.value(connection));
  return ctx;
}

RequestContext _makeMethod(String method, MockConnection connection) {
  final ctx = MockRequestContext();
  when(() => ctx.request).thenReturn(
    Request(method, Uri.parse('http://test.com/transactions')),
  );
  when(() => ctx.read<Future<Connection>>())
      .thenAnswer((_) => Future.value(connection));
  return ctx;
}

void main() {
  late MockConnection connection;

  setUp(() {
    connection = MockConnection();
  });

  group('GET /transactions', () {
    test('returns 400 when user_id is absent', () async {
      final ctx = _makeGet('/transactions', connection);

      final response = await route.onRequest(ctx);
      final body = await response.json() as Map<String, dynamic>;

      expect(response.statusCode, 400);
      expect(body['error'], contains('user_id'));
    });

    test('returns 400 when user_id is empty', () async {
      final ctx = _makeGet('/transactions?user_id=', connection);

      final response = await route.onRequest(ctx);

      expect(response.statusCode, 400);
    });

    test('returns 200 with transaction list for valid user_id', () async {
      when(
        () => connection.execute(
          any(),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer(
        (_) async => makeResult([
          {
            'id': 'txn-1',
            'user_id': 'user-1',
            'account_id': 'acc-1',
            'category_id': 'cat-1',
            'category_name': 'Food',
            'amount': '12.50',
            'description': null,
            'transaction_date': DateTime(2026, 3, 10),
            'latitude': null,
            'longitude': null,
          },
        ]),
      );

      final ctx = _makeGet('/transactions?user_id=user-1', connection);

      final response = await route.onRequest(ctx);
      final body = await response.json() as List<dynamic>;

      expect(response.statusCode, 200);
      expect(body, hasLength(1));
    });
  });

  group('POST /transactions', () {
    test('returns 400 when required fields are missing', () async {
      final ctx = _makePost({}, connection);

      final response = await route.onRequest(ctx);
      final body = await response.json() as Map<String, dynamic>;

      expect(response.statusCode, 400);
      expect(body['error'], contains('required'));
    });

    test('returns 400 when amount is zero or negative', () async {
      final ctx = _makePost(
        {
          'user_id': 'user-1',
          'account_id': 'acc-1',
          'amount': -5,
          'transaction_date': '2026-03-01',
          'category_id': 'cat-1',
        },
        connection,
      );

      final response = await route.onRequest(ctx);
      final body = await response.json() as Map<String, dynamic>;

      expect(response.statusCode, 400);
      expect(body['error'], contains('amount'));
    });

    test('returns 400 when latitude is given without longitude', () async {
      final ctx = _makePost(
        {
          'user_id': 'user-1',
          'account_id': 'acc-1',
          'amount': 10,
          'transaction_date': '2026-03-01',
          'category_id': 'cat-1',
          'latitude': 52.28,
        },
        connection,
      );

      final response = await route.onRequest(ctx);
      final body = await response.json() as Map<String, dynamic>;

      expect(response.statusCode, 400);
      expect(body['error'], contains('longitude'));
    });

    test('returns 400 when no category_id or new_category_name', () async {
      final ctx = _makePost(
        {
          'user_id': 'user-1',
          'account_id': 'acc-1',
          'amount': 10,
          'transaction_date': '2026-03-01',
        },
        connection,
      );

      final response = await route.onRequest(ctx);
      final body = await response.json() as Map<String, dynamic>;

      expect(response.statusCode, 400);
      expect(body['error'], contains('category'));
    });

    test('returns 201 with created transaction', () async {
      final txnRow = {
        'id': 'txn-new',
        'user_id': 'user-1',
        'account_id': 'acc-1',
        'category_id': 'cat-1',
        'category_name': 'Food',
        'amount': '10.00',
        'description': null,
        'transaction_date': DateTime(2026, 3),
        'latitude': null,
        'longitude': null,
      };
      when(
        () => connection.execute(
          any(),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async => makeResult([txnRow]));

      final ctx = _makePost(
        {
          'user_id': 'user-1',
          'account_id': 'acc-1',
          'amount': 10,
          'transaction_date': '2026-03-01',
          'category_id': 'cat-1',
        },
        connection,
      );

      final response = await route.onRequest(ctx);
      final body = await response.json() as Map<String, dynamic>;

      expect(response.statusCode, 201);
      expect(body['id'], 'txn-new');
    });
  });

  group('unsupported methods', () {
    test('returns 405 for DELETE, PATCH, PUT, HEAD', () async {
      for (final method in ['DELETE', 'PATCH', 'PUT', 'HEAD']) {
        final ctx = _makeMethod(method, connection);
        final response = await route.onRequest(ctx);
        expect(response.statusCode, 405, reason: 'method: $method');
      }
    });
  });
}
