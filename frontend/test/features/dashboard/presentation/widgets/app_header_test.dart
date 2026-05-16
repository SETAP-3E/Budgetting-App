import 'package:budgetting_frontend/features/dashboard/presentation/widgets/app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildHeader({
    String title = 'Test Title',
    List<Widget>? actions,
  }) =>
      MaterialApp(
        home: Scaffold(
          appBar: AppHeader(
            title: title,
            actions: actions,
          ),
          body: const SizedBox(),
        ),
      );

  group('AppHeader', () {
    testWidgets('renders AppBar', (tester) async {
      await tester.pumpWidget(buildHeader());
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders title correctly', (tester) async {
      await tester.pumpWidget(buildHeader(title: 'My App'));
      expect(find.text('My App'), findsOneWidget);
    });

    testWidgets('renders extra actions when provided', (tester) async {
      final actions = [IconButton(onPressed: () {}, icon: const Icon(Icons.add))];
      await tester.pumpWidget(buildHeader(actions: actions));
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renders only the logout button when no actions provided',
        (tester) async {
      await tester.pumpWidget(buildHeader());
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('has correct preferredSize', (tester) async {
      const header = AppHeader(title: 'Test');
      expect(header.preferredSize, const Size.fromHeight(kToolbarHeight));
    });

    testWidgets('implements PreferredSizeWidget', (tester) async {
      const header = AppHeader(title: 'Test');
      expect(header, isA<PreferredSizeWidget>());
    });
  });
}