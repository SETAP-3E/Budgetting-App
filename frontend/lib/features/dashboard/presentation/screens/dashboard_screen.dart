import 'package:flutter/material.dart';

/// Dashboard screen displaying spending summary, categories, and charts.
///
/// Primary entry point showing:
/// - Total spending (MetricCard)
/// - Top category alert
/// - Spending breakdown chart
/// - Category list (Advanced view only)
/// - Time period and view mode controls
class DashboardScreen extends StatelessWidget {
  /// Create a [DashboardScreen].
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content will be added here
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
