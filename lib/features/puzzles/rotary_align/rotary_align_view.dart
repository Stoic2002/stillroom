import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/art/vector_art.dart';
import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/placeholder_palette.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../puzzle_view.dart';

/// Concentric rings, outermost first; tap a ring to turn it one step
/// clockwise. A fixed pointer at the top marks the reference angle.
class RotaryAlignView extends StatefulWidget {
  const RotaryAlignView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<RotaryAlignView> createState() => _RotaryAlignViewState();
}

class _RotaryAlignViewState extends State<RotaryAlignView>
    with SolvesAfterPause<RotaryAlignView> {
  late final _config = widget.context.puzzle.config as RotaryAlignConfig;
  late RotaryAlignState _state = _config.start();

  /// Cumulative steps per ring, so animations always turn the short way
  /// instead of spinning back on wrap-around.
  late final List<int> _spins = [..._state.positions];

  void _turn(int ring) {
    if (isSolved) return;
    final next = _state.turn(ring);
    setState(() {
      for (var i = 0; i < _spins.length; i++) {
        final steps = _config.rings[i].steps;
        var delta = (next.positions[i] - _state.positions[i]) % steps;
        if (delta > steps / 2) delta -= steps;
        _spins[i] += delta;
      }
      _state = next;
    });
    widget.context.feedback(UiSound.turn);
    if (_state.isSolved) {
      widget.context.feedback(UiSound.solved);
      markSolved(widget.context.onSolved);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.biggest.shortestSide * 0.9;
        final radius = side / 2;
        final count = _config.rings.length;
        // Rings share the radius equally, leaving a hub in the middle.
        final ringWidth = radius / (count + 0.6);

        return Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              final offset = details.localPosition - Offset(radius, radius);
              final ring = ((radius - offset.distance) / ringWidth).floor();
              if (ring >= 0 && ring < count) _turn(ring);
            },
            child: SizedBox.square(
              dimension: side,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  for (final (i, ring) in _config.rings.indexed)
                    AnimatedRotation(
                      key: ValueKey('ring_${ring.id}'),
                      turns: _spins[i] / ring.steps,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      child: _RingVisual(
                        ring: ring,
                        outerRadius: radius - i * ringWidth,
                        width: ringWidth,
                        assets: widget.context.assets,
                      ),
                    ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Icon(
                      Icons.arrow_drop_down,
                      size: 40,
                      color: isSolved
                          ? StillroomPalette.gaslight
                          : StillroomPalette.paper,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingVisual extends StatelessWidget {
  const _RingVisual({
    required this.ring,
    required this.outerRadius,
    required this.width,
    required this.assets,
  });

  final RotaryRing ring;
  final double outerRadius;
  final double width;
  final Set<String> assets;

  @override
  Widget build(BuildContext context) {
    final image = ring.image;
    final size = Size.square(outerRadius * 2);
    if (image != null && assets.contains('assets/$image')) {
      return SizedBox.fromSize(size: size, child: Image.asset('assets/$image'));
    }
    final art = image == null ? null : vectorArtFor(image);
    if (art != null) {
      return SizedBox.fromSize(size: size, child: VectorArt(art));
    }
    return CustomPaint(size: size, painter: _RingPainter(ring, width));
  }
}

/// Placeholder ring: a colored band with step ticks and a marker at step 0.
class _RingPainter extends CustomPainter {
  _RingPainter(this.ring, this.width);

  final RotaryRing ring;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outer = size.width / 2;
    final mid = outer - width / 2;
    canvas.drawCircle(
      center,
      mid,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width * 0.92
        ..color = placeholderColor(ring.id, background: false),
    );
    final tick = Paint()
      ..strokeWidth = 2
      ..color = StillroomPalette.paper.withValues(alpha: 0.5);
    for (var s = 0; s < ring.steps; s++) {
      final angle = 2 * math.pi * s / ring.steps - math.pi / 2;
      final dir = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + dir * (outer - width * 0.15),
        center + dir * (outer - width * 0.3),
        tick,
      );
    }
    // Marker at step 0, pointing outward.
    final marker = Path()
      ..moveTo(center.dx, center.dy - outer + width * 0.1)
      ..lineTo(center.dx - width * 0.2, center.dy - outer + width * 0.6)
      ..lineTo(center.dx + width * 0.2, center.dy - outer + width * 0.6)
      ..close();
    canvas.drawPath(marker, Paint()..color = StillroomPalette.paper);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.ring != ring || old.width != width;
}
