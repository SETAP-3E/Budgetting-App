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

  /// Updates the name and/or colour of a custom category owned by [userId].
  ///
  /// Returns the updated model, or null if not found or predefined.
  Future<CategoryModel?> updateCategory(
    String userId,
    String categoryId, {
    required String name,
    required int colourValue,
  }) async {
    final result = await connection.execute(
      Sql.named(
        'UPDATE categories '
        'SET name = @name, colour_value = @colourValue, updated_at = now() '
        'WHERE id = @id AND user_id = @userId AND is_predefined = FALSE '
        'RETURNING id, name, icon, colour_value, is_predefined',
      ),
      parameters: {
        'id': categoryId,
        'userId': userId,
        'name': name,
        'colourValue': colourValue,
      },
    );
    if (result.isEmpty) return null;
    return CategoryModel.fromRow(result.first);
  }

  /// Returns an existing custom category by name for [userId], or creates one.
  ///
  /// Uses an atomic upsert so concurrent requests for the same name never
  /// race to a duplicate-key error.
  Future<CategoryModel> findOrCreateCustom(
    String userId,
    String name,
  ) async {
    final result = await connection.execute(
      Sql.named(
        'INSERT INTO categories (user_id, name, icon, colour_value, '
        '  is_predefined) '
        'VALUES (@userId, @name, @icon, @colourValue, FALSE) '
        'ON CONFLICT ON CONSTRAINT categories_unique_name_per_scope '
        'DO UPDATE SET updated_at = now() '
        'RETURNING id, name, icon, colour_value, is_predefined',
      ),
      parameters: {
        'userId': userId,
        'name': name,
        'icon': 'label',
        'colourValue': 4294945792, // accentOrange
      },
    );
    return CategoryModel.fromRow(result.first);
  }
}
