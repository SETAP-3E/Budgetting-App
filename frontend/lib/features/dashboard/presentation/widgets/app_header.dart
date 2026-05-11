import 'package:budgetting_frontend/core/router/app_router.dart';
import 'package:budgetting_frontend/core/widgets/animated_mascot.dart';
import 'package:flutter/material.dart';

/// Reusable app header with Budget Buddy branding and mascot top-left.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  /// Create an [AppHeader].
  const AppHeader({
    required this.title,
    this.onMenuPressed,
    this.actions,
    super.key,
  });

  /// Page title shown beneath the app name.
  final String title;

  /// Unused — kept for API compatibility.
  final VoidCallback? onMenuPressed;

  /// Additional action buttons on the right.
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 52,
      leading: const Padding(
        padding: EdgeInsets.all(4),
        child: AnimatedMascot(height: 40),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Budget Buddy',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Colors.white70,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        ...?actions,
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Log out',
          onPressed: authNotifier.notifyLogout,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
