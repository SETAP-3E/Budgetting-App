import 'package:budgetting_frontend/features/accounts/domain/models/account_model.dart';
import 'package:budgetting_frontend/features/accounts/presentation/widgets/account_list_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const account = AccountModel(
    id: 'acc-1',
    name: 'Main Spending',
    type: AccountType.current,
    balance: 1500,
    monthlyBudget: 1000,
    monthlySpent: 600,
    accentColor: Colors.blue,
  );

  Widget buildWidget({VoidCallback? onTap}) => MaterialApp(
        home: Scaffold(
          body: AccountListCard(
            account: account,
            balanceText: '£1,500.00',
            remainingText: '£400.00 left',
            onTap: onTap ?? () {},
          ),
        ),
      );

  group('AccountListCard', () {
    testWidgets('renders the account name', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Main Spending'), findsOneWidget);
    });

    testWidgets('renders the account type label', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Current Account'), findsOneWidget);
    });

    testWidgets('renders the balance text', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('£1,500.00'), findsOneWidget);
    });

    testWidgets('renders the remaining budget text', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('£400.00 left'), findsOneWidget);
    });

    testWidgets('shows a LinearProgressIndicator', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('fires onTap when the card is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildWidget(onTap: () => tapped = true));
      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });
  });
}
