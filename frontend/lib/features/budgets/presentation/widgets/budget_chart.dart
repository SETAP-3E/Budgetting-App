import 'dart:math';

import 'package:flutter/material.dart';

/// Visual chart showing budget distribution and spending.
///
/// Displays a pie chart in standard view and stacked horizontal bars in edit view.
class BudgetChart extends StatelessWidget {
  /// Create a [BudgetChart].
  const BudgetChart({
    required this.categories,
    required this.isSimpleView,
    super.key,
  });

  /// List of budget categories with name, allocated, spent, and color.
  final List<Map<String, dynamic>> categories;

  /// Whether to show simplified chart (less detail).
  final bool isSimpleView;

  @override
  Widget build(BuildContext context) {
    if (isSimpleView) {
      final totalAllocated = categories.fold<double>(
        0.0,
        (sum, c) => sum + (c['allocated'] as double),
      );

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Budget allocation',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: 180,
                        height: 180,
                        child: CustomPaint(
                          painter: _PieChartPainter(categories),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: categories.map((category) {
                        final allocated = category['allocated'] as double;
                        final name = category['name'] as String;
                        final colour = Color(category['colour'] as int);
                        final percentage = totalAllocated > 0
                            ? allocated / totalAllocated * 100
                            : 0.0;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: colour,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$name • ${percentage.toStringAsFixed(1)}%',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final maxAllocated = categories.fold<double>(
        0,
        (max, c) =>
            c['allocated'] as double > max ? c['allocated'] as double : max);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget vs Spending',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...categories.map((category) {
              final allocated = category['allocated'] as double;
              final spent = category['spent'] as double;
              final name = category['name'] as String;
              final colour = Color(category['colour'] as int);

              final allocatedRatio = allocated / maxAllocated;
              final spentRatio = spent / maxAllocated;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Text(
                          '£${spent.toStringAsFixed(2)} / £${allocated.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Stacked bar chart
                    Stack(
                      children: [
                        // Allocated bar (background)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: allocatedRatio,
                            minHeight: 8,
                            backgroundColor: colour.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colour.withOpacity(0.4),
                            ),
                          ),
                        ),
                        // Spent bar (foreground)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: spentRatio,
                            minHeight: 8,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              spent > allocated ? Colors.red : colour,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  _PieChartPainter(this.categories);

  final List<Map<String, dynamic>> categories;

  @override
  void paint(Canvas canvas, Size size) {
    final total = categories.fold<double>(
      0,
      (sum, category) => sum + (category['allocated'] as double),
    );
    if (total <= 0) {
      return;
    }

    final rect = Offset.zero & size;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    double startAngle = -pi / 2;

    for (final category in categories) {
      final allocated = category['allocated'] as double;
      final sweepAngle = allocated / total * 2 * pi;
      final paint = Paint()
        ..color = Color(category['colour'] as int)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.categories != categories;
  }
}
