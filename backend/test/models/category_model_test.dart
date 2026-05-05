import 'package:budgetting_backend/models/category_model.dart';
import 'package:test/test.dart';

import '../helpers/db_helpers.dart';

void main() {
  group('CategoryModel', () {
    group('fromRow', () {
      test('maps all fields correctly', () {
        final row = makeRow({
          'id': 'cat-uuid-1',
          'name': 'Groceries',
          'icon': 'shopping_bag',
          'colour_value': 4294967040,
          'is_predefined': true,
        });

        final model = CategoryModel.fromRow(row);

        expect(model.id, 'cat-uuid-1');
        expect(model.name, 'Groceries');
        expect(model.icon, 'shopping_bag');
        expect(model.colourValue, 4294967040);
        expect(model.isPredefined, isTrue);
      });

      test('defaults colourValue to 0 when colour_value is null', () {
        final row = makeRow({
          'id': 'cat-uuid-2',
          'name': 'Custom',
          'icon': 'label',
          'colour_value': null,
          'is_predefined': false,
        });

        final model = CategoryModel.fromRow(row);

        expect(model.colourValue, 0);
      });

      test('maps isPredefined false correctly', () {
        final row = makeRow({
          'id': 'cat-uuid-3',
          'name': 'Travel',
          'icon': 'flight',
          'colour_value': 4278190335,
          'is_predefined': false,
        });

        final model = CategoryModel.fromRow(row);

        expect(model.isPredefined, isFalse);
      });
    });

    group('toJson', () {
      test('serializes all fields with snake_case keys', () {
        const model = CategoryModel(
          id: 'cat-uuid-1',
          name: 'Groceries',
          icon: 'shopping_bag',
          colourValue: 4294967040,
          isPredefined: true,
        );

        final json = model.toJson();

        expect(json['id'], 'cat-uuid-1');
        expect(json['name'], 'Groceries');
        expect(json['icon'], 'shopping_bag');
        expect(json['colour_value'], 4294967040);
        expect(json['is_predefined'], isTrue);
      });

      test('serializes isPredefined false and zero colourValue', () {
        const model = CategoryModel(
          id: 'cat-uuid-2',
          name: 'Custom',
          icon: 'label',
          colourValue: 0,
          isPredefined: false,
        );

        final json = model.toJson();

        expect(json['is_predefined'], isFalse);
        expect(json['colour_value'], 0);
      });
    });
  });
}
