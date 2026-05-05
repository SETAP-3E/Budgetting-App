import 'package:budgetting_backend/repositories/category_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import '../helpers/db_helpers.dart';

class MockConnection extends Mock implements Connection {}

void main() {
  late MockConnection connection;
  late CategoryRepository repo;

  setUp(() {
    connection = MockConnection();
    repo = CategoryRepository(connection);
  });

  group('CategoryRepository', () {
    group('getCategories', () {
      test('returns mapped categories from DB result', () async {
        final result = makeResult([
          {
            'id': 'cat-1',
            'name': 'Groceries',
            'icon': 'shopping_bag',
            'colour_value': 4294945792,
            'is_predefined': true,
          },
          {
            'id': 'cat-2',
            'name': 'My Category',
            'icon': 'label',
            'colour_value': 4278190335,
            'is_predefined': false,
          },
        ]);

        when(
          () => connection.execute(
            any(),
            parameters: any(named: 'parameters'),
          ),
        ).thenAnswer((_) async => result);

        final categories = await repo.getCategories('user-uuid-1');

        expect(categories, hasLength(2));
        expect(categories[0].id, 'cat-1');
        expect(categories[0].name, 'Groceries');
        expect(categories[0].isPredefined, isTrue);
        expect(categories[1].id, 'cat-2');
        expect(categories[1].isPredefined, isFalse);
      });

      test('returns empty list when no categories found', () async {
        when(
          () => connection.execute(
            any(),
            parameters: any(named: 'parameters'),
          ),
        ).thenAnswer((_) async => makeResult([]));

        final categories = await repo.getCategories('user-uuid-1');

        expect(categories, isEmpty);
      });
    });

    group('findOrCreateCustom', () {
      test('returns existing category when found', () async {
        final existingResult = makeResult([
          {
            'id': 'cat-existing',
            'name': 'Coffee',
            'icon': 'local_cafe',
            'colour_value': 4294945792,
            'is_predefined': false,
          },
        ]);

        when(
          () => connection.execute(
            any(),
            parameters: any(named: 'parameters'),
          ),
        ).thenAnswer((_) async => existingResult);

        final category =
            await repo.findOrCreateCustom('user-uuid-1', 'Coffee');

        expect(category.id, 'cat-existing');
        expect(category.name, 'Coffee');
        verify(
          () => connection.execute(
            any(),
            parameters: any(named: 'parameters'),
          ),
        ).called(1);
      });

      test('inserts new category when none found', () async {
        var callCount = 0;
        when(
          () => connection.execute(
            any(),
            parameters: any(named: 'parameters'),
          ),
        ).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) return makeResult([]);
          return makeResult([
            {
              'id': 'cat-new',
              'name': 'Taxi',
              'icon': 'label',
              'colour_value': 4294945792,
              'is_predefined': false,
            },
          ]);
        });

        final category = await repo.findOrCreateCustom('user-uuid-1', 'Taxi');

        expect(category.id, 'cat-new');
        expect(category.name, 'Taxi');
        expect(callCount, 2);
      });
    });
  });
}
