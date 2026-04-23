import 'package:postgres/postgres.dart';

/// Represents a spending category (predefined or user-created).
class CategoryModel {
  /// Create a [CategoryModel].
  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.colourValue,
    required this.isPredefined,
  });

  /// Creates a [CategoryModel] from a postgres result row.
  factory CategoryModel.fromRow(ResultRow row) {
    final map = row.toColumnMap();
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String,
      colourValue: (map['colour_value'] as int?) ?? 0,
      isPredefined: map['is_predefined'] as bool,
    );
  }

  /// Unique identifier (UUID).
  final String id;

  /// Display name of the category.
  final String name;

  /// Material icon name (e.g. 'shopping_bag').
  final String icon;

  /// Flutter ARGB integer colour value.
  final int colourValue;

  /// Whether this is a system-wide predefined category.
  final bool isPredefined;

  /// Serialises to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'colour_value': colourValue,
        'is_predefined': isPredefined,
      };
}
