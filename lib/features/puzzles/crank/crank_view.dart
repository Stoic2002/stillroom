import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../core/widgets/content_image.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// A wheel with a handle: drag it round and round to wind. A ratchet clicks
/// every quarter turn and holds against turning back.
class CrankView extends StatefulWidget {
  const CrankView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<CrankView> createState() => _CrankViewState();
}

class _CrankViewState extends State<CrankView>
    with SolvesAfterPause<CrankView> {
  late final _config = widget.context.puzzle.config as CrankConfig;
  late CrankState _state = _config.start();
  double? _lastAngle;

  static const _quarter = math.pi / 2;

  void _drag(Offset local, Offset center) {
    if (isSolved) return;
    final angle = math.atan2(local.dy - center.dy, local.dx - center.dx);
    final last = _lastAngle;
    _lastAngle = angle;
    if (last == null) return;
    var delta = angle - last;
    if (delta > math.pi) delta -= 2 * math.pi;
    if (delta < -math.pi) delta += 2 * math.pi;
    final next = _state.turn(delta);
    if (identical(next, _state)) return;
    final clicks =
        (next.wound / _quarter).floor() - (_state.wound / _quarter).floor();
    setState(() => _state = next);
    if (clicks > 0) widget.context.feedback(UiSound.dial);
    if (next.isSolved) {
      widget.context.feedback(UiSound.solved);
      markSolved(widget.context.onSolved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.biggest.shortestSide * 0.78;
        final center = Offset(
          constraints.maxWidth / 2,
          constraints.maxHeight / 2,
        );
        final image = _config.image;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (d) {
            _lastAngle = null;
            _drag(d.localPosition, center);
          },
          onPanUpdate: (d) => _drag(d.localPosition, center),
          onPanEnd: (_) => _lastAngle = null,
          child: Stack(
            children: [
              if (image != null)
                Center(
                  child: SizedBox.square(
                    dimension: side,
                    child: Transform.rotate(
                      angle: _state.wound * (_config.clockwise ? 1 : -1),
                      child: ContentImage(
                        path: image,
                        label: widget.context.puzzle.id,
                        assets: widget.context.assets,
                      ),
                    ),
                  ),
                ),
              Positioned.fill(
                child: CustomPaint(
                  key: const ValueKey('crank'),
                  painter: _CrankPainter(
                    _state,
                    radius: side / 2,
                    drawWheel: image == null,
                    solved: isSolved,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _state.progress < 0.05 ? 1 : 0,
                    duration: const Duration(milliseconds: 400),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: PuzzleLabel(l10n.crankInstruction),
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

class _CrankPainter extends CustomPainter {
  _CrankPainter(
    this.state, {
    required this.radius,
    required this.drawWheel,
    required this.solved,
  });

  final CrankState state;
  final double radius;
  final bool drawWheel;
  final bool solved;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final spin = state.wound * (state.config.clockwise ? 1 : -1);
    if (drawWheel) {
      canvas.drawCircle(
        center,
        radius * 0.82,
        Paint()..color = const Color(0xFF3A2C22),
      );
      final spoke = Paint()
        ..color = StillroomPalette.brass
        ..strokeWidth = radius * 0.05
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 6; i++) {
        final a = spin + i * math.pi / 3;
        canvas.drawLine(
          center,
          center + Offset(math.cos(a), math.sin(a)) * radius * 0.78,
          spoke,
        );
      }
      canvas
        ..drawCircle(
          center,
          radius * 0.82,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = radius * 0.06
            ..color = StillroomPalette.brass,
        )
        ..drawCircle(
          center,
          radius * 0.1,
          Paint()..color = StillroomPalette.brass,
        );
    }

    // How far it is wound: a ring of gaslight around the wheel.
    canvas
      ..drawCircle(
        center,
        radius * 0.95,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.03
          ..color = StillroomPalette.walnut,
      )
      ..drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.95),
        -math.pi / 2,
        2 * math.pi * state.progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.03
          ..strokeCap = StrokeCap.round
          ..color = solved ? StillroomPalette.gaslight : StillroomPalette.brass,
      );

    // The handle, on the rim.
    final knob =
        center +
        Offset(math.cos(spin - math.pi / 2), math.sin(spin - math.pi / 2)) *
            radius *
            0.7;
    canvas
      ..drawLine(
        center,
        knob,
        Paint()
          ..color = StillroomPalette.paperShade
          ..strokeWidth = radius * 0.05
          ..strokeCap = StrokeCap.round,
      )
      ..drawCircle(
        knob,
        radius * 0.11,
        Paint()..color = const Color(0xFF5A3A26),
      )
      ..drawCircle(
        knob,
        radius * 0.11,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.02
          ..color = StillroomPalette.brass,
      );
  }

  @override
  bool shouldRepaint(_CrankPainter old) =>
      !identical(old.state, state) || old.solved != solved;
}
