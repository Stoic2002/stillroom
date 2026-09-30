import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../bell/bell_trace.dart';
import '../puzzle_view.dart';

/// The bell's rim seen from below, with places round it to strike. Each
/// strike rings and draws its trace: the ring swells and fades, deeper at
/// some places than at others. Mark the place where it swells deepest.
class BeatView extends StatefulWidget {
  const BeatView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<BeatView> createState() => _BeatViewState();
}

class _BeatViewState extends State<BeatView>
    with SingleTickerProviderStateMixin, SolvesAfterPause<BeatView> {
  late final _config = widget.context.puzzle.config as BeatConfig;
  late BeatState _state = _config.start();
  int? _last;
  bool _wrong = false;

  late final _trace = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void dispose() {
    _trace.dispose();
    super.dispose();
  }

  void _strike(int place) {
    if (isSolved) return;
    setState(() {
      _state = _state.strike(place);
      _last = place;
      _wrong = false;
    });
    widget.context.feedback(UiSound.forSwell(_config.swell[place]));
    _trace.forward(from: 0);
  }

  void _mark() {
    final place = _last;
    if (isSolved || place == null) return;
    final next = _state.mark(place);
    setState(() {
      _state = next;
      _wrong = !next.isSolved;
    });
    if (next.isSolved) {
      widget.context.feedback(UiSound.solved);
      markSolved(widget.context.onSolved);
    } else {
      widget.context.feedback(UiSound.mistake);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final last = _last;
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;
        final r = math.min(w * 0.22, h * 0.36);
        final centre = Offset(w * 0.28, h * 0.46);
        return Stack(
          children: [
            // The rim from below: a ring of bronze and the dark inside.
            Positioned(
              left: centre.dx - r * 1.2,
              top: centre.dy - r * 1.2,
              width: r * 2.4,
              height: r * 2.4,
              child: CustomPaint(
                painter: _RimPainter(
                  places: _config.places,
                  struck: _state.struck,
                  last: last,
                  marked: _state.marked,
                ),
              ),
            ),
            for (var i = 0; i < _config.places; i++)
              () {
                final a = -math.pi / 2 + 2 * math.pi * i / _config.places;
                final at = centre + Offset(math.cos(a), math.sin(a)) * r;
                return Positioned(
                  left: at.dx - minTapSizeDp / 2,
                  top: at.dy - minTapSizeDp / 2,
                  width: minTapSizeDp,
                  height: minTapSizeDp,
                  child: GestureDetector(
                    key: ValueKey('beat_place_$i'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _strike(i),
                  ),
                );
              }(),
            // The ring's trace for the last place struck.
            Positioned(
              left: w * 0.56,
              right: w * 0.04,
              top: h * 0.2,
              height: h * 0.4,
              child: AnimatedBuilder(
                animation: _trace,
                builder: (context, _) => CustomPaint(
                  painter: BellTracePainter(
                    progress: _trace.value,
                    length: last == null ? 0 : 1,
                    swell: last == null ? 0 : _config.swell[last],
                  ),
                ),
              ),
            ),
            Positioned(
              left: w * 0.56,
              right: w * 0.04,
              top: h * 0.64,
              child: Center(
                child: FilledButton(
                  key: const ValueKey('beat_mark'),
                  onPressed: isSolved || last == null ? null : _mark,
                  child: Text(l10n.beatMark),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: PuzzleLabel(
                    _wrong ? l10n.beatWrong : l10n.beatInstruction,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The bell's mouth from below: a thick ring of bronze, the dark hollow of
/// the bell inside, a studded place for each spot to strike.
class _RimPainter extends CustomPainter {
  const _RimPainter({
    required this.places,
    required this.struck,
    required this.last,
    required this.marked,
  });

  final int places;
  final Set<int> struck;
  final int? last;
  final int? marked;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2.4;
    canvas
      ..drawCircle(c, r * 1.12, Paint()..color = const Color(0xFF5E6A56))
      ..drawCircle(
        c,
        r * 1.12,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF070504),
      )
      ..drawCircle(c, r * 0.86, Paint()..color = const Color(0xFF0E0C0A))
      ..drawCircle(
        c,
        r * 0.86,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF070504),
      )
      // The sound tube's opening, far up inside.
      ..drawCircle(c, r * 0.08, Paint()..color = const Color(0xFF2A2A26));
    for (var i = 0; i < places; i++) {
      final a = -math.pi / 2 + 2 * math.pi * i / places;
      final at = c + Offset(math.cos(a), math.sin(a)) * r;
      final color = i == marked
          ? StillroomPalette.paper
          : i == last
          ? StillroomPalette.gaslight
          : struck.contains(i)
          ? const Color(0xFF9AA88A)
          : const Color(0xFF7E8A72);
      canvas
        ..drawCircle(at, r * 0.09, Paint()..color = color)
        ..drawCircle(
          at,
          r * 0.09,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = const Color(0xFF070504),
        );
    }
    final m = marked;
    if (m != null) {
      // A chalk cross by the place marked.
      final a = -math.pi / 2 + 2 * math.pi * m / places;
      final at = c + Offset(math.cos(a), math.sin(a)) * r * 1.3;
      final chalk = Paint()
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = StillroomPalette.paper;
      canvas
        ..drawLine(
          at + Offset(-r * 0.07, -r * 0.07),
          at + Offset(r * 0.07, r * 0.07),
          chalk,
        )
        ..drawLine(
          at + Offset(-r * 0.07, r * 0.07),
          at + Offset(r * 0.07, -r * 0.07),
          chalk,
        );
    }
  }

  @override
  bool shouldRepaint(_RimPainter old) =>
      old.last != last ||
      old.marked != marked ||
      old.struck.length != struck.length;
}
