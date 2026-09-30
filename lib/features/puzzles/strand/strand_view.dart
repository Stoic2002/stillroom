import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// Strands of hair laid out in segments, root to tip, on a bench sheet.
/// Tap a segment to measure it; each strand's sample allows only a few
/// readings. Mark the highest; once every strand's highest is found, its
/// full readings come back from the reactor, and the player says how they
/// run along the hair.
class StrandView extends StatefulWidget {
  const StrandView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<StrandView> createState() => _StrandViewState();
}

enum _Note { none, wrong, out, curveWrong }

class _StrandViewState extends State<StrandView>
    with SolvesAfterPause<StrandView> {
  late final _config = widget.context.puzzle.config as StrandConfig;
  late StrandState _state = _config.start();

  /// The measured segment picked for marking: (strand, segment).
  (int, int)? _picked;
  _Note _note = _Note.none;

  /// Each strand's bars are drawn against a ceiling well above its highest
  /// reading, so a bar's height alone does not say it is the highest.
  late final List<double> _ceiling = [
    for (final s in _config.strands) s.reduce((a, b) => a > b ? a : b) * 2.2,
  ];

  void _tapSegment(int s, int i) {
    if (isSolved || _state.found[s]) return;
    if (_state.measured[s].contains(i)) {
      setState(() {
        _picked = (s, i);
        _note = _Note.none;
      });
      widget.context.feedback(UiSound.tap);
      return;
    }
    if (_state.left(s) <= 0) {
      setState(() => _note = _Note.out);
      widget.context.feedback(UiSound.reject);
      return;
    }
    setState(() {
      _state = _state.measure(s, i);
      _picked = (s, i);
      _note = _Note.none;
    });
    widget.context.feedback(
      UiSound.forCount(_config.strands[s][i] * 2.2 / _ceiling[s]),
    );
  }

  void _mark() {
    final picked = _picked;
    if (isSolved || picked == null) return;
    final (s, i) = picked;
    final next = _state.mark(s, i);
    final found = next.found[s] && !_state.found[s];
    setState(() {
      _state = next;
      _picked = null;
      _note = found ? _Note.none : _Note.wrong;
    });
    widget.context.feedback(found ? UiSound.note : UiSound.mistake);
  }

  void _newSample(int s) {
    if (isSolved || _state.found[s]) return;
    setState(() {
      _state = _state.newSample(s);
      if (_picked?.$1 == s) _picked = null;
      _note = _Note.none;
    });
    widget.context.feedback(UiSound.sample);
  }

  void _choose(StrandCurve curve) {
    if (isSolved) return;
    final next = _state.choose(curve);
    setState(() {
      _state = next;
      _note = next.isSolved ? _Note.none : _Note.curveWrong;
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
    final status = switch (_note) {
      _Note.wrong => l10n.strandWrong,
      _Note.out => l10n.strandOut,
      _Note.curveWrong => l10n.strandCurveWrong,
      _Note.none when _state.allFound => l10n.strandCurveQuestion,
      _Note.none => l10n.strandInstruction,
    };
    final picked = _picked;
    return Padding(
      padding: const EdgeInsets.fromLTRB(56, 12, 56, 6),
      child: Column(
        children: [
          for (var s = 0; s < _config.strands.length; s++)
            Expanded(
              child: _StrandRow(
                index: s,
                readings: _config.strands[s],
                measured: _state.measured[s],
                found: _state.found[s],
                peak: _state.found[s] ? _config.peak(s) : null,
                picked: picked?.$1 == s ? picked?.$2 : null,
                ceiling: _ceiling[s],
                left: l10n.strandBudget(_state.left(s)),
                newSample: l10n.strandNewSample,
                onTap: (i) => _tapSegment(s, i),
                onNewSample: () => _newSample(s),
              ),
            ),
          const SizedBox(height: 4),
          SizedBox(
            height: 48,
            child: _state.allFound
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.tonal(
                        key: const ValueKey('strand_steady'),
                        onPressed: isSolved
                            ? null
                            : () => _choose(StrandCurve.steady),
                        child: Text(l10n.strandSteady),
                      ),
                      const SizedBox(width: 16),
                      FilledButton.tonal(
                        key: const ValueKey('strand_peak'),
                        onPressed: isSolved
                            ? null
                            : () => _choose(StrandCurve.peak),
                        child: Text(l10n.strandPeak),
                      ),
                    ],
                  )
                : Center(
                    child: FilledButton(
                      key: const ValueKey('strand_mark'),
                      onPressed: picked == null ? null : _mark,
                      child: Text(l10n.strandMark),
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          PuzzleLabel(status),
        ],
      ),
    );
  }
}

/// One strand: a row of segment cells with a bar above each one measured,
/// the budget and a button for a new sample beside it.
class _StrandRow extends StatelessWidget {
  const _StrandRow({
    required this.index,
    required this.readings,
    required this.measured,
    required this.found,
    required this.peak,
    required this.picked,
    required this.ceiling,
    required this.left,
    required this.newSample,
    required this.onTap,
    required this.onNewSample,
  });

  final int index;
  final List<double> readings;
  final Set<int> measured;
  final bool found;
  final int? peak;
  final int? picked;
  final double ceiling;
  final String left;
  final String newSample;
  final void Function(int) onTap;
  final VoidCallback onNewSample;

  static const _numerals = ['I', 'II', 'III'];

  @override
  Widget build(BuildContext context) {
    const small = TextStyle(
      fontFamily: AppTheme.smallCaps,
      fontSize: 13,
      color: StillroomPalette.paperShade,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 112,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _numerals[index],
                  style: small.copyWith(
                    fontSize: 20,
                    color: StillroomPalette.paper,
                  ),
                ),
                Text(
                  found ? '✓' : left,
                  textAlign: TextAlign.center,
                  style: small,
                ),
                if (!found)
                  TextButton(
                    key: ValueKey('strand_new_$index'),
                    onPressed: onNewSample,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, minTapSizeDp),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    child: Text(
                      newSample,
                      textAlign: TextAlign.center,
                      style: small.copyWith(color: StillroomPalette.gaslight),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                for (var i = 0; i < readings.length; i++)
                  Expanded(
                    child: GestureDetector(
                      key: ValueKey('strand_${index}_$i'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTap(i),
                      child: CustomPaint(
                        painter: _SegmentPainter(
                          reading: readings[i] / ceiling,
                          shown: measured.contains(i) || found,
                          measured: measured.contains(i),
                          peak: i == peak,
                          picked: i == picked,
                          root: i == 0,
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              measured.contains(i) || found
                                  ? readings[i].round().toString()
                                  : '',
                              style: small.copyWith(
                                fontSize: 11,
                                color: i == peak
                                    ? StillroomPalette.gaslight
                                    : StillroomPalette.paperShade,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One centimetre of hair on the bench sheet: the hair itself across the
/// lower part, its reading as a bar above.
class _SegmentPainter extends CustomPainter {
  const _SegmentPainter({
    required this.reading,
    required this.shown,
    required this.measured,
    required this.peak,
    required this.picked,
    required this.root,
  });

  /// The reading as a share of the bars' ceiling.
  final double reading;
  final bool shown;
  final bool measured;
  final bool peak;
  final bool picked;
  final bool root;

  @override
  void paint(Canvas canvas, Size size) {
    final hairY = size.height - 22;
    const top = 4.0;
    final cell = Rect.fromLTRB(1, top, size.width - 1, hairY + 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(cell, const Radius.circular(3)),
      Paint()
        ..color = picked
            ? const Color(0x44E8C87A)
            : measured
            ? const Color(0x22E8DCC0)
            : const Color(0x10E8DCC0),
    );
    if (picked) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(cell, const Radius.circular(3)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = StillroomPalette.gaslight,
      );
    }
    if (shown) {
      final h = (hairY - 6 - top) * reading.clamp(0.02, 1);
      final bar = Rect.fromLTRB(
        size.width * 0.28,
        hairY - 6 - h,
        size.width * 0.72,
        hairY - 6,
      );
      canvas.drawRect(
        bar,
        Paint()
          ..color = peak
              ? StillroomPalette.gaslight
              : measured
              ? const Color(0xFFB9A57A)
              : const Color(0x66B9A57A),
      );
    }
    // The hair, dark on a strip of white bench paper, a tick between
    // segments.
    canvas.drawRect(
      Rect.fromLTRB(0, hairY - 5, size.width, hairY + 5),
      Paint()..color = const Color(0xFFD9D3C4),
    );
    final hair = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF15110D);
    canvas
      ..drawLine(Offset(0, hairY), Offset(size.width, hairY), hair)
      ..drawLine(
        Offset(size.width, hairY - 4),
        Offset(size.width, hairY + 4),
        Paint()
          ..strokeWidth = 1
          ..color = const Color(0xFF6A6458),
      );
    if (root) {
      canvas.drawCircle(Offset(3, hairY), 3, hair);
    }
  }

  @override
  bool shouldRepaint(_SegmentPainter old) =>
      old.shown != shown ||
      old.measured != measured ||
      old.peak != peak ||
      old.picked != picked;
}
