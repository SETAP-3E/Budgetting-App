import 'package:budgetting_frontend/features/accounts/presentation/screens/account_detail_screen.dart';
import 'package:budgetting_frontend/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:budgetting_frontend/features/accounts/presentation/widgets/add_account_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget buildWidget() => const MaterialApp(home: AccountsScreen());

void main() {
  group('AccountsScreen', () {
    testWidgets('shows CircularProgressIndicator before load completes',
        (tester) async {
      await tester.pumpWidget(buildWidget());
      // Do not settle — BLoC is still in loading state after first pump.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows account cards after load', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      expect(find.text('Main Current Account'), findsOneWidget);
      expect(find.text('Savings Pot'), findsOneWidget);
    });

    testWidgets('tapping account card navigates to AccountDetailScreen',
        (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Main Current Account'));
      await tester.pumpAndSettle();
      expect(find.byType(AccountDetailScreen), findsOneWidget);
    });

    testWidgets('tapping Add Account opens AddAccountSheet', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add Account'));
      await tester.pumpAndSettle();
      expect(find.byType(AddAccountSheet), findsOneWidget);
    });

    testWidgets('Transfer shows coming soon snackbar', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Transfer'));
      await tester.pump();
      expect(find.text('Transfer flow coming soon'), findsOneWidget);
    });

    testWidgets('Export shows coming soon snackbar', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export'));
      await tester.pump();
      expect(find.text('Export flow coming soon'), findsOneWidget);
    });
  });
}
