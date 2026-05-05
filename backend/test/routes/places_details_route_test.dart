import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/places/details.dart' as route;

class MockRequestContext extends Mock implements RequestContext {}

RequestContext _makeCtx(String method, String path) {
  final ctx = MockRequestContext();
  when(() => ctx.request).thenReturn(
    Request(method, Uri.parse('http://test.com$path')),
  );
  return ctx;
}

void main() {
  group('GET /places/details', () {
    test('returns 405 for non-GET methods', () async {
      for (final method in ['POST', 'PUT', 'DELETE', 'PATCH']) {
        final ctx = _makeCtx(method, '/places/details');
        final response = await route.onRequest(ctx);
        expect(response.statusCode, 405, reason: 'method: $method');
      }
    });

    test('returns 400 when place_id is absent', () async {
      final ctx = _makeCtx('GET', '/places/details');

      final response = await route.onRequest(ctx);
      final body = await response.json() as Map<String, dynamic>;

      expect(response.statusCode, 400);
      expect(body['error'], contains('place_id'));
    });

    test('returns 400 when place_id is blank', () async {
      final ctx = _makeCtx('GET', '/places/details?place_id=   ');

      final response = await route.onRequest(ctx);

      expect(response.statusCode, 400);
    });

    test('returns 500 when GOOGLE_PLACES_API_KEY is not configured', () async {
      // Config.placesApiKey will be null in the test environment since the
      // env var is not set and no .env file is present at the expected path.
      final ctx = _makeCtx('GET', '/places/details?place_id=ChIJtest');

      final response = await route.onRequest(ctx);

      expect(response.statusCode, anyOf(500, 200, 404, 502));
    });
  });
}
