import 'package:flutter/material.dart';

/// Reusable app header with title.
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

  /// Unused — kept for API compatibility.
  final VoidCallback? onMenuPressed;

  /// Additional action buttons to display on the right.
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
