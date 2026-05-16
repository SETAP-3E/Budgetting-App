import 'package:flutter/material.dart';

/// Stub implementation of [AnimatedMascot] for non-web platforms.
class AnimatedMascot extends StatelessWidget {
  /// Create an [AnimatedMascot].
  const AnimatedMascot({this.height = 200, super.key});

  /// Height (and width) of the rendered mascot.
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox.square(dimension: height);
}
