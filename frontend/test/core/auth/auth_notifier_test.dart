import 'package:budgetting_frontend/core/auth/auth_notifier.dart';
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
          storage[args['key'] as String] = args['value'] as String?;
          return null;
        case 'read':
          final args = call.arguments as Map<Object?, Object?>;
          return storage[args['key'] as String];
        case 'delete':
          final args = call.arguments as Map<Object?, Object?>;
          storage.remove(args['key'] as String);
          return null;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('init loads token from secure storage', () async {
    storage['auth_token'] = 'init-token';
    final notifier = AuthNotifier();

    await notifier.init();

    expect(notifier.isAuthenticated, isTrue);
    expect(notifier.token, 'init-token');
  });

  test('init reports unauthenticated when no token exists', () async {
    final notifier = AuthNotifier();

    await notifier.init();

    expect(notifier.isAuthenticated, isFalse);
    expect(notifier.token, isNull);
  });

  test('notifyLogin updates state and notifies listeners', () async {
    final notifier = AuthNotifier();
    var called = false;
    notifier.addListener(() => called = true);

    notifier.notifyLogin(newToken: 'new-token');

    expect(notifier.isAuthenticated, isTrue);
    expect(notifier.token, 'new-token');
    expect(called, isTrue);
  });

  test('notifyLogout clears token and notifies listeners', () async {
    storage['auth_token'] = 'token-to-clear';
    final notifier = AuthNotifier();
    var called = false;
    notifier.addListener(() => called = true);

    await notifier.notifyLogout();

    expect(notifier.isAuthenticated, isFalse);
    expect(notifier.token, isNull);
    expect(storage.containsKey('auth_token'), isFalse);
    expect(called, isTrue);
  });
}
