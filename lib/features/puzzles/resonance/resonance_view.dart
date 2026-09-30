import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../bell/bell_trace.dart';
import '../puzzle_view.dart';

/// The great bell in cross-section over its hollow, the log striker on its
/// ropes to the left, and the ring's trace below. Drag the log back and let
/// go to strike; dig or fill the hollow between strikes.
class ResonanceView extends StatefulWidget {
  const ResonanceView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<ResonanceView> createState() => _ResonanceViewState();
}

class _ResonanceViewState extends State<ResonanceView>
    with SingleTickerProviderStateMixin, SolvesAfterPause<ResonanceView> {
  late final _config = widget.context.puzzle.config as ResonanceConfig;
  late ResonanceState _state = _config.startState();

  /// How far the log is pulled back now, 0–1.
  double _pull = 0;
  double _dragged = 0;
  String? _status;

  /// Runs the trace across the panel after a strike.
  late final _trace = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void dispose() {
    _trace.dispose();
    super.dispose();
  }

  void _depth(ResonanceState next) {
    if (isSolved || identical(next, _state)) return;
    setState(() {
      _state = next;
      _status = null;
      _trace.value = 0;
    });
    widget.context.feedback(UiSound.place);
  }

  void _grab() {
    if (isSolved) return;
    _dragged = 0;
  }

  void _drag(DragUpdateDetails d, double reach) {
    if (isSolved) return;
    _dragged -= d.delta.dx;
    setState(() => _pull = (_dragged / reach).clamp(0.0, 1.0));
  }

  void _release() {
    if (isSolved) return;
    final l10n = AppLocalizations.of(context);
    final pull = _pull;
    final next = _state.strike(pull);
    final ring = next.lastRing ?? 0;
    setState(() {
      _state = next;
      _pull = 0;
      _status = ring == 0
          ? l10n.resonanceWeak
          : next.isSolved
          ? null
          : l10n.resonanceShort;
    });
    if (ring == 0) {
      widget.context.feedback(UiSound.tap);
      return;
    }
    widget.context.feedback(UiSound.bellStrike);
    _trace.forward(from: 0);
    if (next.isSolved) {
      widget.context.feedback(UiSound.solved);
      markSolved(widget.context.onSolved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;
        final reach = w * 0.18;
        return Stack(
          children: [
            // The bell, the hollow and the ground.
            Positioned(
              left: w * 0.2,
              top: 0,
              width: w * 0.6,
              height: h * 0.64,
              child: CustomPaint(
                painter: _BellPainter(
                  depth: _state.depth,
                  depths: _config.depths,
                ),
              ),
            ),
            // The log striker, pulled back to the left.
            Positioned(
              left: w * 0.02 + w * 0.22 * (1 - _pull) - w * 0.04,
              top: h * 0.2,
              width: w * 0.22,
              height: h * 0.16,
              child: GestureDetector(
                key: const ValueKey('resonance_striker'),
                behavior: HitTestBehavior.opaque,
                onPanDown: (_) => _grab(),
                onPanStart: (_) => _grab(),
                onPanUpdate: (d) => _drag(d, reach),
                onPanEnd: (_) => _release(),
                onPanCancel: () => setState(() => _pull = 0),
                child: const CustomPaint(painter: _LogPainter()),
              ),
            ),
            // Dig or fill.
            Positioned(
              right: 12,
              top: h * 0.3,
              child: Column(
                children: [
                  OutlinedButton(
                    key: const ValueKey('resonance_deeper'),
                    onPressed: () => _depth(_state.dig()),
                    child: Text(l10n.resonanceDeeper),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    key: const ValueKey('resonance_shallower'),
                    onPressed: () => _depth(_state.fill()),
                    child: Text(l10n.resonanceShallower),
                  ),
                ],
              ),
            ),
            // The ring.
            Positioned(
              left: w * 0.08,
              right: w * 0.08,
              top: h * 0.67,
              height: h * 0.22,
              child: AnimatedBuilder(
                animation: _trace,
                builder: (context, _) => CustomPaint(
                  key: const ValueKey('resonance_trace'),
                  painter: BellTracePainter(
                    progress: _trace.value,
                    length: _state.lastRing ?? 0,
                    swell: 0.35,
                    mark: _config.mark,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: PuzzleLabel(_status ?? l10n.resonanceInstruction),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The bell in cross-section, its hollow below dug [depth] of [depths]
/// steps into the ground.
class _BellPainter extends CustomPainter {
  const _BellPainter({required this.depth, required this.depths});

  final int depth;
  final int depths;

  @override
  void paint(Canvas canvas, Size size) {
    final ground = size.height * 0.72;
    final cx = size.width / 2;
    final bw = size.height * 0.5;
    // Ground and the hollow in it.
    canvas.drawRect(
      Rect.fromLTRB(0, ground, size.width, size.height),
      Paint()..color = const Color(0xFF3A2E22),
    );
    final hollowDepth =
        (size.height - ground) * (0.15 + 0.8 * depth / (depths - 1));
    final hollow = Path()
      ..moveTo(cx - bw * 0.62, ground)
      ..quadraticBezierTo(
        cx - bw * 0.55,
        ground + hollowDepth,
        cx,
        ground + hollowDepth,
      )
      ..quadraticBezierTo(
        cx + bw * 0.55,
        ground + hollowDepth,
        cx + bw * 0.62,
        ground,
      )
      ..close();
    canvas
      ..drawPath(hollow, Paint()..color = const Color(0xFF120E0A))
      ..drawLine(
        Offset(0, ground),
        Offset(size.width, ground),
        Paint()
          ..strokeWidth = 2
          ..color = const Color(0xFF070504),
      );
    // The bell: a crown with its dragon hook and sound tube, the body
    // flaring to the mouth a little above the ground.
    final mouth = ground - size.height * 0.06;
    final shoulder = size.height * 0.12;
    final bell = Path()
      ..moveTo(cx - bw * 0.36, shoulder)
      ..quadraticBezierTo(
        cx,
        shoulder - size.height * 0.05,
        cx + bw * 0.36,
        shoulder,
      )
      ..cubicTo(
        cx + bw * 0.46,
        shoulder + (mouth - shoulder) * 0.4,
        cx + bw * 0.44,
        mouth - (mouth - shoulder) * 0.2,
        cx + bw * 0.52,
        mouth,
      )
      ..lineTo(cx - bw * 0.52, mouth)
      ..cubicTo(
        cx - bw * 0.44,
        mouth - (mouth - shoulder) * 0.2,
        cx - bw * 0.46,
        shoulder + (mouth - shoulder) * 0.4,
        cx - bw * 0.36,
        shoulder,
      )
      ..close();
    final bronze = Paint()..color = const Color(0xFF5E6A56);
    canvas
      ..drawPath(bell, bronze)
      ..drawPath(
        bell,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF070504),
      );
    // Bands and the lotus striking seat.
    final band = Paint()
      ..strokeWidth = 2
      ..color = const Color(0xFF7E8A72);
    canvas
      ..drawLine(
        Offset(cx - bw * 0.39, shoulder + size.height * 0.05),
        Offset(cx + bw * 0.39, shoulder + size.height * 0.05),
        band,
      )
      ..drawLine(
        Offset(cx - bw * 0.5, mouth - size.height * 0.05),
        Offset(cx + bw * 0.5, mouth - size.height * 0.05),
        band,
      )
      ..drawCircle(
        Offset(cx - bw * 0.3, mouth - (mouth - shoulder) * 0.32),
        size.height * 0.035,
        Paint()..color = const Color(0xFF8A9A7E),
      );
    // Hook, tube and the beam it hangs from.
    canvas
      ..drawRect(
        Rect.fromLTRB(0, 0, size.width, size.height * 0.035),
        Paint()..color = const Color(0xFF3A2A1E),
      )
      ..drawRect(
        Rect.fromCenter(
          center: Offset(cx + bw * 0.08, shoulder - size.height * 0.05),
          width: size.height * 0.03,
          height: size.height * 0.08,
        ),
        bronze,
      )
      ..drawArc(
        Rect.fromCenter(
          center: Offset(cx - bw * 0.04, shoulder - size.height * 0.05),
          width: size.height * 0.12,
          height: size.height * 0.1,
        ),
        math.pi,
        math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.height * 0.025
          ..color = const Color(0xFF5E6A56),
      );
  }

  @override
  bool shouldRepaint(_BellPainter old) => old.depth != depth;
}

/// The log striker, hung level on two ropes.
class _LogPainter extends CustomPainter {
  const _LogPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rope = Paint()
      ..strokeWidth = 2
      ..color = const Color(0xFFB8A070);
    canvas
      ..drawLine(
        Offset(size.width * 0.25, 0),
        Offset(size.width * 0.25, size.height * 0.4),
        rope,
      )
      ..drawLine(
        Offset(size.width * 0.75, 0),
        Offset(size.width * 0.75, size.height * 0.4),
        rope,
      );
    final log = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.4, size.width, size.height * 0.5),
      Radius.circular(size.height * 0.25),
    );
    canvas
      ..drawRRect(log, Paint()..color = StillroomPalette.walnutLight)
      ..drawRRect(
        log,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF070504),
      )
      ..drawOval(
        Rect.fromLTWH(
          size.width - size.height * 0.3,
          size.height * 0.42,
          size.height * 0.28,
          size.height * 0.46,
        ),
        Paint()..color = const Color(0xFF6A5236),
      );
  }

  @override
  bool shouldRepaint(_LogPainter old) => false;
}
