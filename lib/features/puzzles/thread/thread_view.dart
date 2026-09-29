import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// Pins on a map and a red thread: drag it from pin to pin (or tap the pins
/// in turn). The next pin in order takes the thread; a wrong one snaps it.
class ThreadView extends StatefulWidget {
  const ThreadView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<ThreadView> createState() => _ThreadViewState();
}

class _ThreadViewState extends State<ThreadView>
    with SolvesAfterPause<ThreadView> {
  late final _config = widget.context.puzzle.config as ThreadConfig;
  late ThreadState _state = _config.start();

  /// Where the finger is while dragging the thread.
  Offset? _finger;

  /// How close to a pin (logical pixels) counts as reaching it.
  static const _reach = 34.0;

  Offset _pinAt(ThreadPin pin, Size board) =>
      Offset(pin.x * board.width, pin.y * board.height);

  ThreadPin? _pinNear(Offset p, Size board) {
    ThreadPin? best;
    var bestDistance = _reach;
    for (final pin in _config.pins) {
      final d = (_pinAt(pin, board) - p).distance;
      if (d <= bestDistance) {
        best = pin;
        bestDistance = d;
      }
    }
    return best;
  }

  void _reachAt(Offset p, Size board) {
    if (isSolved) return;
    final pin = _pinNear(p, board);
    if (pin == null) return;
    final next = _state.reach(pin.id);
    if (identical(next, _state)) return;
    final snapped = next.path.length <= _state.path.length;
    setState(() => _state = next);
    if (snapped) {
      widget.context.feedback(UiSound.mistake);
    } else if (next.isSolved) {
      widget.context.feedback(UiSound.solved);
      markSolved(widget.context.onSolved);
      _finger = null;
    } else {
      widget.context.feedback(UiSound.place);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final board = constraints.biggest;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) => _reachAt(d.localPosition, board),
          // The pin under the finger counts from the moment it touches,
          // so a quick drag cannot skip the pin it started on.
          onPanDown: (d) => _reachAt(d.localPosition, board),
          // Where the drag takes hold may already be the next pin.
          onPanStart: (d) {
            _reachAt(d.localPosition, board);
            setState(() => _finger = d.localPosition);
          },
          onPanUpdate: (d) {
            _reachAt(d.localPosition, board);
            if (!isSolved) setState(() => _finger = d.localPosition);
          },
          onPanEnd: (_) => setState(() => _finger = null),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  key: const ValueKey('thread'),
                  painter: _ThreadPainter(
                    pins: [for (final p in _config.pins) _pinAt(p, board)],
                    path: [
                      for (final id in _state.path)
                        _pinAt(_config.pin(id), board),
                    ],
                    finger: _finger,
                    solved: isSolved,
                  ),
                ),
              ),
              for (final pin in _config.pins)
                if (pin.labelKey case final key?)
                  Positioned(
                    left: _pinAt(pin, board).dx - 90,
                    top: _pinAt(pin, board).dy + 14,
                    width: 180,
                    // Written on the map in ink, not floating over it.
                    child: IgnorePointer(
                      child: Text(
                        widget.context.text(context, key),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: const TextStyle(
                          fontFamily: AppTheme.serif,
                          fontSize: 14,
                          height: 1.1,
                          color: StillroomPalette.inkOnPaper,
                        ),
                      ),
                    ),
                  ),
              Align(
                alignment: Alignment.bottomCenter,
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _state.path.isEmpty ? 1 : 0,
                    duration: const Duration(milliseconds: 400),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: PuzzleLabel(l10n.threadInstruction),
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

class _ThreadPainter extends CustomPainter {
  _ThreadPainter({
    required this.pins,
    required this.path,
    required this.finger,
    required this.solved,
  });

  final List<Offset> pins;
  final List<Offset> path;
  final Offset? finger;
  final bool solved;

  static const _wool = Color(0xFFB0232A);

  @override
  void paint(Canvas canvas, Size size) {
    final thread = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = solved ? StillroomPalette.gaslight : _wool;
    final shadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = const Color(0x66000000);
    final points = [...path, ?finger];
    if (points.length >= 2) {
      final line = Path()..addPolygon(points, false);
      canvas
        ..drawPath(line.shift(const Offset(2, 3)), shadow)
        ..drawPath(line, thread);
    }
    for (final p in pins) {
      final reached = path.contains(p);
      canvas
        ..drawCircle(
          p + const Offset(2, 3),
          9,
          Paint()..color = const Color(0x66000000),
        )
        ..drawCircle(
          p,
          9,
          Paint()..color = reached ? _wool : StillroomPalette.brass,
        )
        ..drawCircle(
          p,
          9,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2
            ..color = const Color(0xFF1A1512),
        )
        ..drawCircle(
          p - const Offset(3, 3),
          2.5,
          Paint()..color = const Color(0x99FFFFFF),
        );
    }
  }

  @override
  bool shouldRepaint(_ThreadPainter old) =>
      old.path.length != path.length ||
      old.finger != finger ||
      old.solved != solved;
}
