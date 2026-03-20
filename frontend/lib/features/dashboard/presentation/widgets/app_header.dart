import 'package:flutter/material.dart';

/// Reusable app header with title and menu button.
///
/// Used across all screens as the main app bar.
/// Features: title display, hamburger menu button, consistent styling.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  /// Create an [AppHeader].
  const AppHeader({
    required this.title,
    this.onMenuPressed,
    this.actions,
    super.key,
  });

  /// Title to display in the header.
  final String title;

  /// Callback when menu button (hamburger) is tapped.
  final VoidCallback? onMenuPressed;

  /// Additional action buttons to display on the right.
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: IconButton(
        icon: const Icon(Icons.menu),
        tooltip: 'Menu',
        onPressed: onMenuPressed ?? () => _showDefaultMenu(context),
      ),
      actions: actions,
    );
  }

  /// Show a default menu if no custom callback provided.
  void _showDefaultMenu(BuildContext context) {
    // Placeholder for future menu implementation
    // Could show a drawer, dropdown menu, or navigation options
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Menu button tapped'),
        duration: Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
