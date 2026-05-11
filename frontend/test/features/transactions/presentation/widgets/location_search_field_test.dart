import 'package:budgetting_frontend/features/transactions/data/datasources/transactions_api_client.dart';
import 'package:budgetting_frontend/features/transactions/presentation/widgets/location_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionsApiClient extends Mock implements TransactionsApiClient {}

void main() {
  late MockTransactionsApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockTransactionsApiClient();
  });

  Widget buildField({
    required OnPlaceSelected onPlaceSelected,
    VoidCallback? onCleared,
  }) =>
      MaterialApp(
        home: Scaffold(
          body: LocationSearchField(
            onPlaceSelected: onPlaceSelected,
            onCleared: onCleared,
          ),
        ),
      );

  group('LocationSearchField', () {
    testWidgets('renders TextFormField with correct decoration', (tester) async {
      await tester.pumpWidget(buildField(onPlaceSelected: (_, __, ___) {}));
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Location (optional)'), findsOneWidget);
      expect(find.text('Search for a place…'), findsOneWidget);
      expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
    });

    testWidgets('does not show suggestions initially', (tester) async {
      await tester.pumpWidget(buildField(onPlaceSelected: (_, __, ___) {}));
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('does not search for less than 3 characters', (tester) async {
      await tester.pumpWidget(buildField(onPlaceSelected: (_, __, ___) {}));
      await tester.enterText(find.byType(TextFormField), 'ab');
      await tester.pump(const Duration(milliseconds: 400));
      verifyNever(() => mockApiClient.getPlaceSuggestions(any()));
    });

    testWidgets('searches after 3 characters with debounce', (tester) async {
      when(() => mockApiClient.getPlaceSuggestions('abc'))
          .thenAnswer((_) async => []);
      await tester.pumpWidget(buildField(onPlaceSelected: (_, __, ___) {}));
      await tester.enterText(find.byType(TextFormField), 'abc');
      await tester.pump(const Duration(milliseconds: 200)); // Before debounce
      verifyNever(() => mockApiClient.getPlaceSuggestions(any()));
      await tester.pump(const Duration(milliseconds: 200)); // After debounce
      verify(() => mockApiClient.getPlaceSuggestions('abc')).called(1);
    });

    testWidgets('shows loading indicator during search', (tester) async {
      when(() => mockApiClient.getPlaceSuggestions(any()))
          .thenAnswer((_) async => []);
      await tester.pumpWidget(buildField(onPlaceSelected: (_, __, ___) {}));
      await tester.enterText(find.byType(TextFormField), 'test');
      await tester.pump(); // Trigger loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows suggestions when search returns results', (tester) async {
      const suggestions = [
        {'place_id': '1', 'description': 'Place 1'},
        {'place_id': '2', 'description': 'Place 2'},
      ];
      when(() => mockApiClient.getPlaceSuggestions('test'))
          .thenAnswer((_) async => suggestions);
      await tester.pumpWidget(buildField(onPlaceSelected: (_, __, ___) {}));
      await tester.enterText(find.byType(TextFormField), 'test');
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Place 1'), findsOneWidget);
      expect(find.text('Place 2'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('calls onPlaceSelected with correct data on suggestion tap',
        (tester) async {
      const suggestions = [
        {'place_id': '1', 'description': 'Place 1'},
      ];
      const details = {
        'name': 'Selected Place',
        'latitude': 40.0,
        'longitude': -74.0,
      };
      when(() => mockApiClient.getPlaceSuggestions('test'))
          .thenAnswer((_) async => suggestions);
      when(() => mockApiClient.getPlaceDetails('1'))
          .thenAnswer((_) async => details);
      var called = false;
      String? selectedName;
      double? lat, lng;
      await tester.pumpWidget(buildField(
        onPlaceSelected: (name, latitude, longitude) {
          called = true;
          selectedName = name;
          lat = latitude;
          lng = longitude;
        },
      ));
      await tester.enterText(find.byType(TextFormField), 'test');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Place 1'));
      await tester.pump();
      expect(called, true);
      expect(selectedName, 'Selected Place');
      expect(lat, 40.0);
      expect(lng, -74.0);
      expect(find.byType(ListView), findsNothing); // Suggestions hidden
    });

    testWidgets('handles API errors gracefully', (tester) async {
      when(() => mockApiClient.getPlaceSuggestions('test'))
          .thenThrow(Exception('API error'));
      await tester.pumpWidget(buildField(onPlaceSelected: (_, __, ___) {}));
      await tester.enterText(find.byType(TextFormField), 'test');
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('calls onCleared when editing after selection', (tester) async {
      const suggestions = [
        {'place_id': '1', 'description': 'Place 1'},
      ];
      const details = {
        'name': 'Selected Place',
        'latitude': 40.0,
        'longitude': -74.0,
      };
      when(() => mockApiClient.getPlaceSuggestions(any()))
          .thenAnswer((_) async => suggestions);
      when(() => mockApiClient.getPlaceDetails('1'))
          .thenAnswer((_) async => details);
      var clearedCalled = false;
      await tester.pumpWidget(buildField(
        onPlaceSelected: (_, __, ___) {},
        onCleared: () => clearedCalled = true,
      ));
      await tester.enterText(find.byType(TextFormField), 'test');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Place 1'));
      await tester.pump();
      expect(clearedCalled, false);
      await tester.enterText(find.byType(TextFormField), 'test edited');
      expect(clearedCalled, true);
    });

    testWidgets('handles place details error', (tester) async {
      const suggestions = [
        {'place_id': '1', 'description': 'Place 1'},
      ];
      when(() => mockApiClient.getPlaceSuggestions('test'))
          .thenAnswer((_) async => suggestions);
      when(() => mockApiClient.getPlaceDetails('1'))
          .thenThrow(Exception('Details error'));
      var clearedCalled = false;
      await tester.pumpWidget(buildField(
        onPlaceSelected: (_, __, ___) {},
        onCleared: () => clearedCalled = true,
      ));
      await tester.enterText(find.byType(TextFormField), 'test');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Place 1'));
      await tester.pump();
      expect(find.text('Place 1'), findsOneWidget); // Fallback to description
      expect(clearedCalled, true);
    });
  });
}