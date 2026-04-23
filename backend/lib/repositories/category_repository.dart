import 'package:budgetting_backend/models/category_model.dart';
import 'package:postgres/postgres.dart';

/// Data access for spending categories.
class CategoryRepository {
  /// Create a [CategoryRepository] backed by [connection].
  const CategoryRepository(this.connection);

  /// The active database connection.
  final Connection connection;

  /// Returns all predefined categories plus custom ones owned by [userId].
  Future<List<CategoryModel>> getCategories(String userId) async {
    final result = await connection.execute(
      Sql.named(
        'SELECT id, name, icon, colour_value, is_predefined '
        'FROM categories '
        'WHERE (is_predefined = TRUE OR user_id = @userId) '
        'AND is_active = TRUE '
        'ORDER BY is_predefined DESC, name ASC',
      ),
      parameters: {'userId': userId},
    );
    return result.map(CategoryModel.fromRow).toList();
  }

  /// Returns an existing custom category by name for [userId], or creates one.
  Future<CategoryModel> findOrCreateCustom(
    String userId,
    String name,
  ) async {
    // Try to find existing custom category with this name.
    final existing = await connection.execute(
      Sql.named(
        'SELECT id, name, icon, colour_value, is_predefined '
        'FROM categories '
        'WHERE user_id = @userId AND name = @name AND is_active = TRUE',
      ),
      parameters: {'userId': userId, 'name': name},
    );

    if (existing.isNotEmpty) {
      return CategoryModel.fromRow(existing.first);
    }

    // Create a new custom category.
    final inserted = await connection.execute(
      Sql.named(
        'INSERT INTO categories (user_id, name, icon, colour_value, '
        'is_predefined) '
        'VALUES (@userId, @name, @icon, @colourValue, FALSE) '
        'RETURNING id, name, icon, colour_value, is_predefined',
      ),
      parameters: {
        'userId': userId,
        'name': name,
        'icon': 'label',
        'colourValue': 4294945792, // accentOrange
      },
    );

    return CategoryModel.fromRow(inserted.first);
  }
}
