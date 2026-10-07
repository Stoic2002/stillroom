import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// The fallen Buddhas in a row, each drawn with its hands; beside them the
/// monument seen from above, north up: its four faces, the fifth
/// balustrade within them, the stupas at the centre. Tap a statue, then
/// the place its hands belong to.
class MudraView extends StatefulWidget {
  const MudraView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<MudraView> createState() => _MudraViewState();
}

enum _Note { none, wrong, full }

class _MudraViewState extends State<MudraView>
    with SolvesAfterPause<MudraView> {
  late final _config = widget.context.puzzle.config as MudraConfig;
  late MudraState _state = _config.start();
  int? _picked;
  _Note _note = _Note.none;

  void _pick(int i) {
    if (isSolved || _state.placed.containsKey(i)) return;
    setState(() {
      _picked = i;
      _note = _Note.none;
    });
    widget.context.feedback(UiSound.lift);
  }

  void _place(int p) {
    final s = _picked;
    if (isSolved || s == null) return;
    final judged = _state.judge(s, p);
    final next = _state.set(s, p);
    setState(() {
      _state = next;
      _note = switch (judged) {
        MudraSet.wrong => _Note.wrong,
        MudraSet.full => _Note.full,
        _ => _Note.none,
      };
      if (judged == MudraSet.set) _picked = null;
    });
    if (next.isSolved) {
      widget.context.feedback(UiSound.solved);
      markSolved(widget.context.onSolved);
      return;
    }
    widget.context.feedback(switch (judged) {
      MudraSet.set => UiSound.nicheSet,
      MudraSet.wrong => UiSound.mistake,
      _ => UiSound.reject,
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = switch (_note) {
      _Note.wrong => l10n.mudraWrong,
      _Note.full => l10n.mudraFull,
      _Note.none =>
        '${l10n.mudraInstruction}\n'
            '${l10n.mudraProgress(_state.placed.length, _config.statues.length)}',
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(52, 8, 20, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: [
                        for (var i = 0; i < _config.statues.length; i++)
                          if (!_state.placed.containsKey(i))
                            GestureDetector(
                              key: ValueKey('mudra_statue_$i'),
                              onTap: () => _pick(i),
                              child: Container(
                                width: 64,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: _picked == i
                                        ? StillroomPalette.gaslight
                                        : const Color(0x33D8C9A8),
                                    width: _picked == i ? 2.5 : 1,
                                  ),
                                ),
                                child: CustomPaint(
                                  painter: BuddhaPainter(_config.statues[i]),
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
                PuzzleLabel(status, maxLines: 3),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(
              builder: (context, box) {
                final s = box.maxWidth;
                final face = s * 0.22;
                Widget area(int p, Rect r, {bool round = false}) {
                  final place = _config.places[p];
                  return Positioned.fromRect(
                    rect: r,
                    child: GestureDetector(
                      key: ValueKey('mudra_place_${place.mudra.name}'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _place(p),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0x22E8DCC0),
                          shape: round ? BoxShape.circle : BoxShape.rectangle,
                          border: Border.all(color: const Color(0x66E8DCC0)),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Text(
                              '${widget.context.text(context, place.labelKey)}'
                              '\n${_state.filled(p)}/${place.slots}',
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: AppTheme.serif,
                                fontSize: 11,
                                height: 1.1,
                                color: StillroomPalette.paper,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                Rect? rectFor(Mudra m) => switch (m) {
                  Mudra.noFear => Rect.fromLTWH(face, 0, s - face * 2, face),
                  Mudra.giving => Rect.fromLTWH(
                    face,
                    s - face,
                    s - face * 2,
                    face,
                  ),
                  Mudra.meditation => Rect.fromLTWH(
                    0,
                    face,
                    face,
                    s - face * 2,
                  ),
                  Mudra.earth => Rect.fromLTWH(
                    s - face,
                    face,
                    face,
                    s - face * 2,
                  ),
                  Mudra.teaching => Rect.fromLTWH(
                    face * 1.15,
                    face * 1.15,
                    s - face * 2.3,
                    face * 0.7,
                  ),
                  Mudra.wheel => Rect.fromCenter(
                    center: Offset(s / 2, s * 0.6),
                    width: face * 1.5,
                    height: face * 1.5,
                  ),
                };
                return Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: _PlanPainter()),
                    ),
                    for (final (p, place) in _config.places.indexed)
                      if (rectFor(place.mudra) case final r?)
                        area(p, r, round: place.mudra == Mudra.wheel),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// The monument from above: stepped squares, the round terraces, a north
/// arrow.
class _PlanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    for (var k = 0; k < 5; k++) {
      final inset = size.width * (0.02 + k * 0.05);
      canvas.drawRect(
        (Offset.zero & size).deflate(inset),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0x55B0A890),
      );
    }
    for (var k = 0; k < 3; k++) {
      canvas.drawCircle(
        c,
        size.width * (0.16 - k * 0.04),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0x55B0A890),
      );
    }
    // North.
    canvas.drawPath(
      Path()
        ..moveTo(size.width - 10, 4)
        ..lineTo(size.width - 5, 16)
        ..lineTo(size.width - 15, 16)
        ..close(),
      Paint()..color = const Color(0xFFE8DCC0),
    );
  }

  @override
  bool shouldRepaint(_PlanPainter old) => false;
}

/// A seated Buddha in grey stone, drawn plainly, with the hands in the
/// gesture [mudra]: what tells the statues apart.
class BuddhaPainter extends CustomPainter {
  const BuddhaPainter(this.mudra);

  final Mudra mudra;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const stone = Color(0xFF8A8A84);
    final body = Paint()..color = stone;
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF3A3A36);
    final hand = Paint()
      ..color = const Color(0xFFB0B0A8)
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round;
    // The lotus seat, the crossed legs, the body, the head with its knot.
    final seat = Rect.fromLTWH(w * 0.1, h * 0.84, w * 0.8, h * 0.12);
    canvas
      ..drawOval(seat, Paint()..color = const Color(0xFF6A6A64))
      ..drawOval(Rect.fromLTWH(w * 0.14, h * 0.68, w * 0.72, h * 0.2), body)
      ..drawOval(Rect.fromLTWH(w * 0.14, h * 0.68, w * 0.72, h * 0.2), edge);
    final torso = Path()
      ..moveTo(w * 0.3, h * 0.72)
      ..lineTo(w * 0.34, h * 0.36)
      ..lineTo(w * 0.66, h * 0.36)
      ..lineTo(w * 0.7, h * 0.72)
      ..close();
    canvas
      ..drawPath(torso, body)
      ..drawPath(torso, edge)
      ..drawCircle(Offset(w * 0.5, h * 0.25), w * 0.13, body)
      ..drawCircle(Offset(w * 0.5, h * 0.25), w * 0.13, edge)
      ..drawCircle(Offset(w * 0.5, h * 0.1), w * 0.06, body);
    // Shoulders to elbows.
    final ls = Offset(w * 0.34, h * 0.4);
    final rs = Offset(w * 0.66, h * 0.4);
    final le = Offset(w * 0.26, h * 0.6);
    final re = Offset(w * 0.74, h * 0.6);
    final lap = Offset(w * 0.5, h * 0.72);
    void arm(Offset a, Offset b) => canvas.drawLine(a, b, hand);
    switch (mudra) {
      case Mudra.meditation:
        arm(ls, le);
        arm(le, lap.translate(-w * 0.06, 0));
        arm(rs, re);
        arm(re, lap.translate(w * 0.06, 0));
        canvas.drawOval(
          Rect.fromCenter(center: lap, width: w * 0.24, height: h * 0.06),
          Paint()..color = const Color(0xFFB0B0A8),
        );
      case Mudra.earth:
        // Left hand in the lap; right hand reaching down over the knee.
        arm(ls, le);
        arm(le, lap);
        arm(rs, re);
        arm(re, Offset(w * 0.78, h * 0.86));
      case Mudra.giving:
        // Left in the lap; right down by the knee, palm turned out.
        arm(ls, le);
        arm(le, lap);
        arm(rs, re);
        arm(re, Offset(w * 0.8, h * 0.78));
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(w * 0.82, h * 0.8),
            width: w * 0.14,
            height: h * 0.08,
          ),
          Paint()..color = const Color(0xFFC8C8C0),
        );
      case Mudra.noFear:
        // Left in the lap; right raised, palm out, fingers up.
        arm(ls, le);
        arm(le, lap);
        arm(rs, re);
        arm(re, Offset(w * 0.76, h * 0.38));
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(w * 0.76, h * 0.34),
            width: w * 0.1,
            height: h * 0.12,
          ),
          Paint()..color = const Color(0xFFC8C8C0),
        );
      case Mudra.teaching:
        // Right raised, thumb and finger closed in a ring.
        arm(ls, le);
        arm(le, lap);
        arm(rs, re);
        arm(re, Offset(w * 0.76, h * 0.42));
        canvas.drawCircle(
          Offset(w * 0.76, h * 0.38),
          w * 0.06,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.035
            ..color = const Color(0xFFC8C8C0),
        );
      case Mudra.wheel:
        // Both hands at the chest, fingers turning against each other.
        final chest = Offset(w * 0.5, h * 0.5);
        arm(ls, le);
        arm(le, chest.translate(-w * 0.05, 0));
        arm(rs, re);
        arm(re, chest.translate(w * 0.05, 0));
        canvas.drawCircle(
          chest,
          w * 0.07,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.03
            ..color = const Color(0xFFC8C8C0),
        );
        for (var k = 0; k < 4; k++) {
          final a = k * math.pi / 4;
          canvas.drawLine(
            chest - Offset(math.cos(a), math.sin(a)) * w * 0.07,
            chest + Offset(math.cos(a), math.sin(a)) * w * 0.07,
            Paint()
              ..strokeWidth = 1
              ..color = const Color(0x88C8C8C0),
          );
        }
    }
  }

  @override
  bool shouldRepaint(BuddhaPainter old) => old.mudra != mudra;
}
