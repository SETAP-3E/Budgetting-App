/// Diverse palette used when category colours clash.
const _fallbackPalette = [
  0xFF2E7D32, // dark green
  0xFF4DB6AC, // teal
  0xFFFF9800, // orange
  0xFFFFC107, // amber
  0xFF66BB6A, // light green
  0xFF1565C0, // dark blue
  0xFF9C27B0, // purple
  0xFFE91E63, // pink
  0xFF00BCD4, // cyan
  0xFFFF5722, // deep orange
  0xFF607D8B, // blue grey
  0xFF795548, // brown
  0xFFAB47BC, // medium purple
  0xFF26A69A, // medium teal
  0xFFEF5350, // red
];

/// Returns a new list where every `'colour'` value is unique.
///
/// Categories are processed in order. If a colour has already been used, the
/// duplicate entry is assigned the next available colour from
/// [_fallbackPalette] that is not already taken. If the palette is exhausted
/// the original colour is kept unchanged.
List<Map<String, dynamic>> ensureUniqueColours(
  List<Map<String, dynamic>> categories,
) {
  final seen = <int>{};
  return categories.map((cat) {
    var colour = cat['colour'] as int;
    if (!seen.add(colour)) {
      final replacement = _fallbackPalette.firstWhere(
        (c) => !seen.contains(c),
        orElse: () => colour,
      );
      colour = replacement;
      seen.add(colour);
    }
    return colour == cat['colour'] as int ? cat : {...cat, 'colour': colour};
  }).toList();
}
