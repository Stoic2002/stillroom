import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../core/widgets/content_image.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// A surface in the dark and a lamp to drag round it. Faint marks rise out
/// of the surface as the light grazes them from the right side: shadows on
/// one edge of every stroke, a glint on the other. Holding the lamp there
/// a moment reads them.
class RakingLightView extends StatefulWidget {
  const RakingLightView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<RakingLightView> createState() => _RakingLightViewState();
}

class _RakingLightViewState extends State<RakingLightView>
    with SolvesAfterPause<RakingLightView> {
  late final _config = widget.context.puzzle.config as RakingLightConfig;
  late RakingLightState _state = _config.start();
  Timer? _dwell;
  var _moved = false;
  var _lastStep = 0;

  /// How long the light must rest on the marks to read them.
  static const dwell = Duration(milliseconds: 600);

  @override
  void dispose() {
    _dwell?.cancel();
    super.dispose();
  }

  void _drag(Offset local, Offset center) {
    if (isSolved) return;
    final degrees =
        math.atan2(local.dx - center.dx, -(local.dy - center.dy)) *
        180 /
        math.pi;
    final next = _state.moveTo(degrees < 0 ? degrees + 360 : degrees);
    // A soft tick every 15 degrees, so moving the lamp is felt.
    final step = next.lamp ~/ 15;
    if (step != _lastStep) {
      _lastStep = step;
      widget.context.feedback(UiSound.turn);
    }
    setState(() {
      _state = next;
      _moved = true;
    });
    if (next.isSolved) {
      _dwell ??= Timer(dwell, () {
        if (!mounted || !_state.isSolved) return;
        widget.context.feedback(UiSound.solved);
        setState(() => markSolved(widget.context.onSolved));
      });
    } else {
      _dwell?.cancel();
      _dwell = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final center = size.center(Offset.zero);
        final side = size.shortestSide * 0.72;
        final orbit = side * 0.62;
        final angle = _state.lamp * math.pi / 180;
        final toLamp = Offset(math.sin(angle), -math.cos(angle));
        final lamp = center + toLamp * orbit;
        final clarity = isSolved ? 1.0 : _state.clarity;
        // Strokes cast shadows away from the lamp and catch light on the
        // side facing it.
        final shadow = -toLamp * side * 0.006;
        Widget marks(Color color, Offset shift, double opacity) =>
            Transform.translate(
              offset: shift,
              child: Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  child: ContentImage(
                    path: _config.marks,
                    label: 'marks',
                    assets: widget.context.assets,
                  ),
                ),
              ),
            );
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (d) => _drag(d.localPosition, center),
          onPanUpdate: (d) => _drag(d.localPosition, center),
          child: Stack(
            children: [
              const Positioned.fill(
                child: ColoredBox(color: Color(0xF0080605)),
              ),
              Positioned(
                left: center.dx - side / 2,
                top: center.dy - side / 2,
                width: side,
                height: side,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ContentImage(
                      path: _config.surface,
                      label: widget.context.puzzle.id,
                      assets: widget.context.assets,
                    ),
                    // The lamp's light across the surface, from its side.
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(toLamp.dx, toLamp.dy),
                          end: Alignment(-toLamp.dx, -toLamp.dy),
                          colors: const [Color(0x40F2C46A), Color(0x99000000)],
                        ),
                      ),
                    ),
                    marks(const Color(0xFF0C0806), shadow * 2, clarity * 0.85),
                    marks(
                      const Color(0xFFF6DDA0),
                      -shadow,
                      clarity * (isSolved ? 0.7 : 0.5),
                    ),
                  ],
                ),
              ),
              Positioned(
                key: const ValueKey('raking_lamp'),
                left: lamp.dx - 22,
                top: lamp.dy - 22,
                width: 44,
                height: 44,
                child: IgnorePointer(
                  child: CustomPaint(painter: _LampPainter()),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _moved ? 0 : 1,
                    duration: const Duration(milliseconds: 400),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: PuzzleLabel(l10n.rakingLightInstruction),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A little clay oil lamp with its flame.
class _LampPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    canvas
      ..drawCircle(
        c,
        r * 2.6,
        Paint()
          ..shader = RadialGradient(
            colors: [
              StillroomPalette.gaslight.withValues(alpha: 0.45),
              StillroomPalette.gaslight.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: r * 2.6)),
      )
      ..drawOval(
        Rect.fromCenter(
          center: c.translate(0, r * 0.3),
          width: r * 1.6,
          height: r * 0.8,
        ),
        Paint()..color = const Color(0xFFA0643E),
      )
      ..drawPath(
        Path()
          ..moveTo(c.dx + r * 0.55, c.dy + r * 0.1)
          ..quadraticBezierTo(
            c.dx + r * 0.75,
            c.dy - r * 0.55,
            c.dx + r * 0.62,
            c.dy - r * 0.8,
          )
          ..quadraticBezierTo(
            c.dx + r * 0.45,
            c.dy - r * 0.45,
            c.dx + r * 0.55,
            c.dy + r * 0.1,
          ),
        Paint()..color = StillroomPalette.gaslight,
      );
  }

  @override
  bool shouldRepaint(_LampPainter old) => false;
}
