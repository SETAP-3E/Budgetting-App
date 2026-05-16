import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import '../../routes/categories/index.dart' as route;
import '../helpers/db_helpers.dart';

class MockRequestContext extends Mock implements RequestContext {}

class MockConnection extends Mock implements Connection {}

RequestContext _makeCtx(
  String path,
  MockConnection connection, {
  String userId = 'user-uuid-1',
}) {
  final ctx = MockRequestContext();
  when(() => ctx.request).thenReturn(
    Request('GET', Uri.parse('http://test.com$path')),
  );
  when(() => ctx.read<String>()).thenReturn(userId);
  when(() => ctx.read<Future<Connection>>())
      .thenAnswer((_) => Future.value(connection));
  return ctx;
}

RequestContext _makeCtxMethod(String method, MockConnection connection) {
  final ctx = MockRequestContext();
  when(() => ctx.request).thenReturn(
    Request(method, Uri.parse('http://test.com/categories')),
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

  group('GET /categories', () {
    test('returns 405 for non-GET methods', () async {
      for (final method in ['POST', 'PUT', 'DELETE', 'PATCH']) {
        final ctx = _makeCtxMethod(method, connection);
        final response = await route.onRequest(ctx);
        expect(response.statusCode, 405, reason: 'method: $method');
      }
    });

    test('returns 200 with category list for authenticated user', () async {
      when(
        () => connection.execute(
          any(),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer(
        (_) async => makeResult([
          {
            'id': 'cat-1',
            'name': 'Food',
            'icon': 'fastfood',
            'colour_value': 4294945792,
            'is_predefined': true,
          },
        ]),
      );

      final ctx = _makeCtx('/categories', connection);

      final response = await route.onRequest(ctx);
      final body = await response.json() as List<dynamic>;

      expect(response.statusCode, 200);
      expect(body, hasLength(1));
      expect((body[0] as Map<String, dynamic>)['name'], 'Food');
    });

    test('returns 200 with empty list when no categories', () async {
      when(
        () => connection.execute(
          any(),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async => makeResult([]));

      final ctx = _makeCtx('/categories', connection);

      final response = await route.onRequest(ctx);
      final body = await response.json() as List<dynamic>;

      expect(response.statusCode, 200);
      expect(body, isEmpty);
    });
  });
}
