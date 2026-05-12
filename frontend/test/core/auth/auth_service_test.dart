import 'package:budgetting_frontend/core/auth/auth_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  late Map<String, String?> storage;

  TestWidgetsFlutterBinding.ensureInitialized();

  late TestDefaultBinaryMessenger messenger;

  setUp(() {
    storage = {};
    messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        as TestDefaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'write':
          final args = call.arguments as Map<Object?, Object?>;
          final key = args['key'] as String;
          final value = args['value'] as String?;
          storage[key] = value;
          return null;
        case 'read':
          final args = call.arguments as Map<Object?, Object?>;
          final key = args['key'] as String;
          return storage[key];
        case 'delete':
          final args = call.arguments as Map<Object?, Object?>;
          final key = args['key'] as String;
          storage.remove(key);
          return null;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('saveSession writes all expected keys', () async {
    final service = AuthService();
    await service.saveSession(
      token: 'token-123',
      userId: 'user-1',
      username: 'tester',
    );

    expect(storage['auth_token'], 'token-123');
    expect(storage['user_id'], 'user-1');
    expect(storage['username'], 'tester');
  });

  test('getToken returns stored token', () async {
    storage['auth_token'] = 'token-abc';
    final service = AuthService();
    final token = await service.getToken();

    expect(token, 'token-abc');
  });

  test('isLoggedIn returns true when token exists', () async {
    storage['auth_token'] = 'token-abc';
    final service = AuthService();

    expect(await service.isLoggedIn(), isTrue);
  });

  test('isLoggedIn returns false when token is missing', () async {
    final service = AuthService();

    expect(await service.isLoggedIn(), isFalse);
  });

  test('clearSession removes stored values', () async {
    storage['auth_token'] = 'token-abc';
    storage['user_id'] = 'user-1';
    storage['username'] = 'tester';

    final service = AuthService();
    await service.clearSession();

    expect(storage.containsKey('auth_token'), isFalse);
    expect(storage.containsKey('user_id'), isFalse);
    expect(storage.containsKey('username'), isFalse);
  });
}
