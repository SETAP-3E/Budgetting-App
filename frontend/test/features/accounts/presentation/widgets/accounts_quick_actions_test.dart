import 'package:budgetting_frontend/features/accounts/presentation/widgets/accounts_quick_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildWidget({
    VoidCallback? onAddAccount,
    VoidCallback? onTransfer,
    VoidCallback? onExport,
  }) =>
      MaterialApp(
        home: Scaffold(
          body: AccountsQuickActions(
            onAddAccount: onAddAccount ?? () {},
            onTransfer: onTransfer ?? () {},
            onExport: onExport ?? () {},
          ),
        ),
      );

  group('AccountsQuickActions', () {
    testWidgets('renders Add Account button', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Add Account'), findsOneWidget);
    });

    testWidgets('renders Transfer button', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Transfer'), findsOneWidget);
    });

    testWidgets('renders Export button', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Export'), findsOneWidget);
    });

    testWidgets('fires onAddAccount when Add Account tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildWidget(onAddAccount: () => tapped = true));
      await tester.tap(find.text('Add Account'));
      expect(tapped, isTrue);
    });

    testWidgets('fires onTransfer when Transfer tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildWidget(onTransfer: () => tapped = true));
      await tester.tap(find.text('Transfer'));
      expect(tapped, isTrue);
    });

    testWidgets('fires onExport when Export tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildWidget(onExport: () => tapped = true));
      await tester.tap(find.text('Export'));
      expect(tapped, isTrue);
    });
  });
}
