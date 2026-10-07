import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// The survey chart: the area as lanes running east and west, north at
/// the top, its named places marked. Tap a lane not yet run to run the
/// sonar along it (an hour); its strip fills with side-scan echoes. Tap a
/// cell of a run lane to mark the wreck there. Beside it: the hours left,
/// what the last mark showed, and Next season once the hours are spent.
class SonarView extends StatefulWidget {
  const SonarView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<SonarView> createState() => _SonarViewState();
}

class _SonarViewState extends State<SonarView>
    with SolvesAfterPause<SonarView> {
  late final _config = widget.context.puzzle.config as SonarConfig;
  late SonarState _state = _config.start();
  SonarJudge? _last;

  void _tap(int c, int r) {
    if (isSolved) return;
    if (!_state.run.contains(r)) {
      final next = _state.runLane(r);
      if (identical(next, _state)) {
        widget.context.feedback(UiSound.reject);
        return;
      }
      setState(() {
        _state = next;
        _last = null;
      });
      widget.context.feedback(UiSound.laneRun);
      return;
    }
    final judged = _state.judge(c, r);
    final next = _state.mark(c, r);
    setState(() {
      _state = next;
      _last = judged;
    });
    if (next.isSolved) {
      widget.context.feedback(UiSound.echoMark);
      markSolved(widget.context.onSolved);
    } else {
      widget.context.feedback(UiSound.mistake);
    }
  }

  void _nextSeason() {
    setState(() {
      _state = _state.nextSeason();
      _last = null;
    });
    widget.context.feedback(UiSound.page);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = switch (_last) {
      SonarJudge.rock => l10n.sonarRock,
      SonarJudge.scour => l10n.sonarScour,
      SonarJudge.nothing => l10n.sonarNothing,
      SonarJudge.unrun => l10n.sonarUnrun,
      _ when _state.spent => l10n.sonarSpent,
      _ => l10n.sonarInstruction,
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(52, 8, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) {
                final cw = box.maxWidth / _config.columns;
                final rh = box.maxHeight / _config.rows;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _SurveyPainter(
                          config: _config,
                          state: _state,
                          label: (k) => widget.context.text(context, k),
                        ),
                      ),
                    ),
                    for (var r = 0; r < _config.rows; r++)
                      for (var c = 0; c < _config.columns; c++)
                        Positioned(
                          left: c * cw,
                          top: r * rh,
                          width: cw,
                          height: rh,
                          child: GestureDetector(
                            key: ValueKey('sonar_cell_${c}_$r'),
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _tap(c, r),
                          ),
                        ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 190,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.sonarHours(_state.hoursLeft),
                  key: const ValueKey('sonar_hours'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppTheme.serif,
                    fontSize: 18,
                    color: StillroomPalette.gaslight,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: PuzzleLabel(status, maxLines: null),
                  ),
                ),
                if (_state.spent)
                  FilledButton(
                    key: const ValueKey('sonar_next'),
                    onPressed: _nextSeason,
                    child: Text(l10n.sonarNextSeason),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The chart and the echoes: dark water, the lanes ruled across it, the
/// named places; each lane run drawn as a strip of side-scan sonar in
/// amber, echoes bright with dark shadows cast away from the track.
class _SurveyPainter extends CustomPainter {
  const _SurveyPainter({
    required this.config,
    required this.state,
    required this.label,
  });

  final SonarConfig config;
  final SonarState state;
  final String Function(String key) label;

  @override
  void paint(Canvas canvas, Size size) {
    final cw = size.width / config.columns;
    final rh = size.height / config.rows;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A2A36), Color(0xFF223640)],
        ).createShader(Offset.zero & size),
    );
    final rule = Paint()
      ..strokeWidth = 0.6
      ..color = const Color(0x44A8C8D8);
    for (var r = 0; r <= config.rows; r++) {
      canvas.drawLine(Offset(0, r * rh), Offset(size.width, r * rh), rule);
    }
    for (var c = 0; c <= config.columns; c++) {
      canvas.drawLine(
        Offset(c * cw, 0),
        Offset(c * cw, size.height),
        rule..color = const Color(0x1AA8C8D8),
      );
    }

    // The lanes run: side-scan strips.
    for (final r in state.run) {
      final strip = Rect.fromLTWH(0, r * rh, size.width, rh);
      canvas.drawRect(
        strip,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6A4A20), Color(0xFFB08440), Color(0xFF6A4A20)],
          ).createShader(strip),
      );
      // Grain of the seabed.
      final random = math.Random(r * 31 + 7);
      for (var i = 0; i < 160; i++) {
        canvas.drawCircle(
          Offset(
            random.nextDouble() * size.width,
            strip.top + random.nextDouble() * rh,
          ),
          0.6 + random.nextDouble(),
          Paint()..color = const Color(0x33FFE0A0),
        );
      }
      // The track down the middle, where the sonar sees nothing.
      canvas.drawLine(
        Offset(0, strip.center.dy),
        Offset(size.width, strip.center.dy),
        Paint()
          ..strokeWidth = 2
          ..color = const Color(0xFF2A1E10),
      );
      for (var c = 0; c < config.columns; c++) {
        final cell = Rect.fromLTWH(c * cw, strip.top, cw, rh);
        switch (config.echoAt(c, r)) {
          case SonarEcho.rock:
            final p = cell.center.translate(0, -rh * 0.18);
            canvas
              ..drawOval(
                Rect.fromCenter(
                  center: p.translate(cw * 0.16, rh * 0.14),
                  width: cw * 0.34,
                  height: rh * 0.16,
                ),
                Paint()..color = const Color(0xFF1E140A),
              )
              ..drawCircle(
                p,
                cw * 0.14,
                Paint()..color = const Color(0xFFFFE6B0),
              );
          case SonarEcho.scour:
            canvas.drawLine(
              cell.centerLeft.translate(cw * 0.05, -rh * 0.25),
              cell.centerRight.translate(-cw * 0.05, rh * 0.25),
              Paint()
                ..strokeWidth = 2.5
                ..color = const Color(0xFFE8C890),
            );
          case SonarEcho.wreck || SonarEcho.none:
            break;
        }
      }
      if (r == config.wreckRow) {
        final hull = Rect.fromLTWH(
          config.wreckColumn * cw + cw * 0.1,
          strip.top + rh * 0.12,
          config.wreckLength * cw - cw * 0.2,
          rh * 0.28,
        );
        // The hull bright, its long straight shadow cast away.
        canvas
          ..drawRect(
            Rect.fromLTRB(
              hull.left,
              hull.bottom,
              hull.right,
              hull.bottom + rh * 0.2,
            ),
            Paint()..color = const Color(0xFF140C06),
          )
          ..drawRRect(
            RRect.fromRectAndRadius(hull, Radius.circular(rh * 0.12)),
            Paint()..color = const Color(0xFFFFEAC0),
          );
        for (var k = 1; k < 3; k++) {
          canvas.drawLine(
            Offset(hull.left + hull.width * k / 3, hull.top - rh * 0.06),
            Offset(hull.left + hull.width * k / 3, hull.bottom),
            Paint()
              ..strokeWidth = 1.5
              ..color = const Color(0xFFB08440),
          );
        }
        if (state.found) {
          canvas.drawRect(
            hull.inflate(4),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = const Color(0xFFD04030),
          );
        }
      }
    }

    // The named places.
    for (final m in config.marks) {
      final p = Offset(m.column * cw, m.row * rh);
      canvas.drawCircle(p, 3, Paint()..color = const Color(0xFFE8DCC0));
      final text = TextPainter(
        text: TextSpan(
          text: label(m.labelKey),
          style: const TextStyle(
            fontFamily: AppTheme.serif,
            fontStyle: FontStyle.italic,
            fontSize: 11,
            color: Color(0xFFE8DCC0),
            shadows: [Shadow(blurRadius: 3)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width * 0.4);
      final right = p.dx + text.width + 6 > size.width;
      text.paint(
        canvas,
        Offset(
          right ? p.dx - text.width - 6 : p.dx + 6,
          p.dy - text.height / 2,
        ),
      );
    }
    // North.
    final n = Offset(size.width - 14, 16);
    canvas.drawPath(
      Path()
        ..moveTo(n.dx, n.dy - 10)
        ..lineTo(n.dx + 5, n.dy + 4)
        ..lineTo(n.dx - 5, n.dy + 4)
        ..close(),
      Paint()..color = const Color(0xFFE8DCC0),
    );
  }

  @override
  bool shouldRepaint(_SurveyPainter old) => old.state != state;
}
