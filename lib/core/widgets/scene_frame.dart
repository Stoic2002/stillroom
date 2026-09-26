import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Lays [child] over the letterboxed scene area: the largest rect with the
/// logical aspect ratio that fits the screen, centered. Matches how the
/// Flame camera fits the scene, so overlays line up with the art.
class SceneFrame extends StatelessWidget {
  const SceneFrame({
    required this.logicalWidth,
    required this.logicalHeight,
    required this.child,
    super.key,
  });

  final int logicalWidth;
  final int logicalHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = math.min(
          constraints.maxWidth / logicalWidth,
          constraints.maxHeight / logicalHeight,
        );
        return Center(
          child: SizedBox(
            width: logicalWidth * scale,
            height: logicalHeight * scale,
            child: child,
          ),
        );
      },
    );
  }
}
