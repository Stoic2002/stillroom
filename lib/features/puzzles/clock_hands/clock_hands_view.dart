import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../core/widgets/content_image.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// A clock face with two hands: drag a hand round the dial. The hand
/// nearest the finger is the one that moves. It solves as soon as the hands
/// show the hour.
class ClockHandsView extends StatefulWidget {
  const ClockHandsView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<ClockHandsView> createState() => _ClockHandsViewState();
}

enum _Hand { hour, minute }

class _ClockHandsViewState extends State<ClockHandsView>
    with SolvesAfterPause<ClockHandsView> {
  late final _config = widget.context.puzzle.config as ClockHandsConfig;
  late ClockHandsState _state = _config.start();
  _Hand? _held;
  var _moved = false;

  /// Clockwise from twelve, 0 to 2π.
  static double _angleOf(Offset local, Offset center) {
    final a = math.atan2(local.dx - center.dx, -(local.dy - center.dy));
    return a < 0 ? a + 2 * math.pi : a;
  }

  static double _gap(double a, double b) {
    final d = (a - b).abs() % (2 * math.pi);
    return math.min(d, 2 * math.pi - d);
  }

  void _grab(Offset local, Offset center) {
    if (isSolved) return;
    final angle = _angleOf(local, center);
    final hour = _ClockPainter.hourAngle(_state);
    final minute = _ClockPainter.minuteAngle(_state);
    _held = _gap(angle, hour) < _gap(angle, minute) ? _Hand.hour : _Hand.minute;
    _drag(local, center);
  }

  void _drag(Offset local, Offset center) {
    final held = _held;
    if (isSolved || held == null) return;
    final turn = _angleOf(local, center) / (2 * math.pi);
    final next = switch (held) {
      _Hand.hour => _state.pointHour((turn * 12).round()),
      _Hand.minute => _state.pointMinute((turn * 60).round()),
    };
    if (identical(next, _state)) return;
    setState(() {
      _state = next;
      _moved = true;
    });
    widget.context.feedback(UiSound.dial);
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
        final side = constraints.biggest.shortestSide * 0.82;
        final center = Offset(
          constraints.maxWidth / 2,
          constraints.maxHeight / 2,
        );
        final image = _config.image;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (d) => _grab(d.localPosition, center),
          onPanUpdate: (d) => _drag(d.localPosition, center),
          onPanEnd: (_) => _held = null,
          child: Stack(
            children: [
              if (image != null)
                Center(
                  child: SizedBox.square(
                    dimension: side,
                    child: ContentImage(
                      path: image,
                      label: widget.context.puzzle.id,
                      assets: widget.context.assets,
                    ),
                  ),
                ),
              Positioned.fill(
                child: CustomPaint(
                  key: const ValueKey('clock_hands'),
                  painter: _ClockPainter(
                    _state,
                    radius: side / 2,
                    drawDial: image == null,
                    solved: isSolved,
                  ),
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
                      child: PuzzleLabel(l10n.clockHandsInstruction),
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

class _ClockPainter extends CustomPainter {
  _ClockPainter(
    this.state, {
    required this.radius,
    required this.drawDial,
    required this.solved,
  });

  final ClockHandsState state;
  final double radius;
  final bool drawDial;
  final bool solved;

  static const _numerals = [
    'XII', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI', //
  ];

  /// Clockwise from twelve: the hour hand creeps on with the minutes.
  static double hourAngle(ClockHandsState s) =>
      ((s.hour % 12) + s.minute / 60) / 12 * 2 * math.pi;

  static double minuteAngle(ClockHandsState s) => s.minute / 60 * 2 * math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    Offset at(double angle, double r) =>
        c + Offset(math.sin(angle), -math.cos(angle)) * r;
    if (drawDial) {
      canvas
        ..drawCircle(c, radius, Paint()..color = StillroomPalette.paper)
        ..drawCircle(
          c,
          radius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = radius * 0.06
            ..color = StillroomPalette.brass,
        );
      for (var i = 0; i < 60; i++) {
        final a = i / 60 * 2 * math.pi;
        canvas.drawLine(
          at(a, radius * (i % 5 == 0 ? 0.86 : 0.9)),
          at(a, radius * 0.94),
          Paint()
            ..strokeWidth = i % 5 == 0 ? 2.2 : 1
            ..color = StillroomPalette.inkOnPaper,
        );
      }
      for (var i = 0; i < 12; i++) {
        final painter = TextPainter(
          text: TextSpan(
            text: _numerals[i],
            style: TextStyle(
              fontFamily: AppTheme.serif,
              fontSize: radius * 0.13,
              color: StillroomPalette.inkOnPaper,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        painter.paint(
          canvas,
          at(i / 12 * 2 * math.pi, radius * 0.72) -
              Offset(painter.width / 2, painter.height / 2),
        );
      }
    }
    final ink = solved ? StillroomPalette.oxblood : const Color(0xFF1A1512);
    canvas
      ..drawLine(
        c,
        at(hourAngle(state), radius * 0.5),
        Paint()
          ..strokeWidth = radius * 0.05
          ..strokeCap = StrokeCap.round
          ..color = ink,
      )
      ..drawLine(
        c,
        at(minuteAngle(state), radius * 0.8),
        Paint()
          ..strokeWidth = radius * 0.025
          ..strokeCap = StrokeCap.round
          ..color = ink,
      )
      ..drawCircle(c, radius * 0.05, Paint()..color = StillroomPalette.brass);
    if (solved) {
      canvas.drawCircle(
        c,
        radius * 1.05,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.02
          ..color = StillroomPalette.gaslight,
      );
    }
  }

  @override
  bool shouldRepaint(_ClockPainter old) =>
      !identical(old.state, state) || old.solved != solved;
}
