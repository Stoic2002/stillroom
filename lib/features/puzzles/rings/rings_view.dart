import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// A master chronology across the top, a ring width for every year, and
/// below it the core, its rings drawn the same way but with no years.
/// Drag the core (or step it with the arrows) until its pattern falls in
/// step with the master, and check. Once dated, the core shows its years
/// and a bracket the width of the run; move it over the narrowest rings
/// and mark them.
class RingsView extends StatefulWidget {
  const RingsView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<RingsView> createState() => _RingsViewState();
}

enum _Note { none, wrong, dated, markWrong }

class _RingsViewState extends State<RingsView>
    with SolvesAfterPause<RingsView> {
  late final _config = widget.context.puzzle.config as RingsConfig;
  late RingsState _state = _config.start();
  int _bracket = 0;
  _Note _note = _Note.none;

  // Where a drag began: the core's (or bracket's) place, and the finger.
  int _dragFrom = 0;
  double _dragX = 0;

  int get _lastBracket => _config.core.length - _config.run;

  void _move(int to) {
    if (isSolved) return;
    if (!_state.dated) {
      final next = _state.slide(to);
      if (next.position == _state.position) return;
      setState(() {
        _state = next;
        _note = _Note.none;
      });
    } else {
      final b = to.clamp(0, _lastBracket);
      if (b == _bracket) return;
      setState(() {
        _bracket = b;
        _note = _Note.dated;
      });
    }
    widget.context.feedback(UiSound.coreSlide);
  }

  int get _place => _state.dated ? _bracket : _state.position;

  void _check() {
    if (isSolved || _state.dated) return;
    final next = _state.check();
    setState(() {
      _state = next;
      _note = next.dated ? _Note.dated : _Note.wrong;
      _bracket = 0;
    });
    widget.context.feedback(next.dated ? UiSound.place : UiSound.mistake);
  }

  void _mark() {
    if (isSolved || !_state.dated) return;
    final next = _state.mark(_bracket);
    setState(() {
      _state = next;
      _note = next.marked ? _Note.none : _Note.markWrong;
    });
    if (next.isSolved) {
      widget.context.feedback(UiSound.ringMark);
      markSolved(widget.context.onSolved);
    } else {
      widget.context.feedback(UiSound.mistake);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = switch (_note) {
      _Note.wrong => l10n.ringsWrong,
      _Note.markWrong => l10n.ringsMarkWrong,
      _ when isSolved =>
        '${_config.yearOf(_config.narrowest)}–'
            '${_config.yearOf(_config.narrowest + _config.run - 1)}',
      _Note.dated => l10n.ringsDated(_config.run),
      _Note.none => l10n.ringsInstruction,
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(52, 12, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) {
                final slot = box.maxWidth / _config.master.length;
                return GestureDetector(
                  key: const ValueKey('rings_core'),
                  behavior: HitTestBehavior.opaque,
                  onPanDown: (d) {
                    _dragFrom = _place;
                    _dragX = d.localPosition.dx;
                  },
                  onPanUpdate: (d) => _move(
                    _dragFrom + ((d.localPosition.dx - _dragX) / slot).round(),
                  ),
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _ChronologyPainter(
                      config: _config,
                      position: _state.position,
                      dated: _state.dated,
                      bracket: _state.dated ? _bracket : null,
                      marked: _state.marked,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              IconButton(
                key: const ValueKey('rings_left'),
                onPressed: isSolved ? null : () => _move(_place - 1),
                icon: const Icon(Icons.chevron_left),
                color: StillroomPalette.paper,
              ),
              IconButton(
                key: const ValueKey('rings_right'),
                onPressed: isSolved ? null : () => _move(_place + 1),
                icon: const Icon(Icons.chevron_right),
                color: StillroomPalette.paper,
              ),
              const SizedBox(width: 8),
              Expanded(child: PuzzleLabel(status)),
              const SizedBox(width: 8),
              if (!_state.dated)
                FilledButton(
                  key: const ValueKey('rings_check'),
                  onPressed: _check,
                  child: Text(l10n.ringsCheck),
                )
              else
                FilledButton(
                  key: const ValueKey('rings_mark'),
                  onPressed: isSolved ? null : _mark,
                  child: Text(l10n.ringsMark),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The master as a strip of bars on paper, a bar's height its ring's
/// width, years marked every ten; the core below it as a strip of wood
/// with its bars in the same measure, where it lies along the master.
class _ChronologyPainter extends CustomPainter {
  const _ChronologyPainter({
    required this.config,
    required this.position,
    required this.dated,
    required this.bracket,
    required this.marked,
  });

  final RingsConfig config;
  final int position;
  final bool dated;
  final int? bracket;
  final bool marked;

  @override
  void paint(Canvas canvas, Size size) {
    final slot = size.width / config.master.length;
    final band = size.height * 0.36;
    final masterRect = Rect.fromLTWH(0, 4, size.width, band);
    final coreTop = masterRect.bottom + size.height * 0.16;
    final coreRect = Rect.fromLTWH(
      position * slot,
      coreTop,
      config.core.length * slot,
      band,
    );

    // The master: a paper strip, bars from its foot, decade ticks.
    canvas.drawRRect(
      RRect.fromRectAndRadius(masterRect, const Radius.circular(3)),
      Paint()..color = const Color(0xFFE8DFC8),
    );
    final ink = Paint()..color = const Color(0xFF3A3024);
    for (final (i, w) in config.master.indexed) {
      final h = (band - 10) * w;
      canvas.drawRect(
        Rect.fromLTWH(
          i * slot + slot * 0.2,
          masterRect.bottom - 4 - h,
          slot * 0.6,
          h,
        ),
        ink,
      );
      final year = config.startYear + i;
      if (year % 10 == 0) {
        _label(
          canvas,
          '$year',
          Offset(i * slot + slot / 2, masterRect.bottom + 2),
          StillroomPalette.paper,
        );
      }
    }

    // A faint guide where the core lies on the master.
    canvas.drawRect(
      Rect.fromLTWH(coreRect.left, masterRect.top, coreRect.width, band),
      Paint()..color = const Color(0x22C08A3A),
    );

    // The core: a pale wood strip, its bars in a darker grain.
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(coreRect, Radius.circular(band / 2.5)),
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD8B884), Color(0xFFB08A58)],
          ).createShader(coreRect),
      )
      ..drawRRect(
        RRect.fromRectAndRadius(coreRect, Radius.circular(band / 2.5)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = const Color(0xFF5A3E22),
      );
    final grain = Paint()..color = const Color(0xFF6A4424);
    for (final (i, w) in config.core.indexed) {
      final h = (band - 10) * w;
      final x = coreRect.left + i * slot;
      canvas.drawRect(
        Rect.fromLTWH(x + slot * 0.25, coreRect.bottom - 5 - h, slot * 0.5, h),
        grain,
      );
      if (dated && (config.yearOf(i) % 5 == 0 || i == 0)) {
        _label(
          canvas,
          '${config.yearOf(i)}',
          Offset(x + slot / 2, coreRect.bottom + 2),
          StillroomPalette.gaslight,
        );
      }
    }

    // The bracket over the run being marked.
    final b = bracket;
    if (b != null) {
      final r = Rect.fromLTWH(
        coreRect.left + b * slot,
        coreRect.top - 6,
        config.run * slot,
        band + 12,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(4)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = marked
              ? const Color(0xFFD04030)
              : StillroomPalette.gaslight,
      );
    }
  }

  void _label(Canvas canvas, String text, Offset topCenter, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: AppTheme.serif,
          fontSize: 11,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, topCenter - Offset(painter.width / 2, 0));
  }

  @override
  bool shouldRepaint(_ChronologyPainter old) =>
      old.position != position ||
      old.dated != dated ||
      old.bracket != bracket ||
      old.marked != marked;
}
