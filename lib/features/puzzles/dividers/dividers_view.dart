import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// An old chart, turned as its maker drew it (its compass rose shows
/// where north lies), with its places, a scale of miles, and a pair of
/// dividers. Beside it: the clue, the spans to open the dividers to, the
/// eight headings, and Step, Back and Mark. The walk is drawn on the
/// chart as the dividers' legs swing from point to point.
class DividersView extends StatefulWidget {
  const DividersView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<DividersView> createState() => _DividersViewState();
}

enum _Note { none, elsewhere, nothing, unset }

class _DividersViewState extends State<DividersView>
    with SolvesAfterPause<DividersView> {
  late final _config = widget.context.puzzle.config as DividersConfig;
  late DividersState _state = _config.start();
  _Note _note = _Note.none;

  void _set(DividersState next, UiSound sound) {
    if (isSolved) return;
    setState(() {
      _state = next;
      _note = _Note.none;
    });
    widget.context.feedback(sound);
  }

  void _step() {
    if (_state.span == null || _state.heading == null) {
      setState(() => _note = _Note.unset);
      widget.context.feedback(UiSound.reject);
      return;
    }
    _set(_state.step(), UiSound.dividerStep);
  }

  void _mark() {
    if (isSolved) return;
    final judged = _state.judge();
    final next = _state.mark();
    setState(() {
      _state = next;
      _note = switch (judged) {
        DividersMark.elsewhere => _Note.elsewhere,
        DividersMark.nothing => _Note.nothing,
        DividersMark.unset => _Note.unset,
        DividersMark.found => _Note.none,
      };
    });
    if (next.isSolved) {
      widget.context.feedback(UiSound.solved);
      markSolved(widget.context.onSolved);
    } else {
      widget.context.feedback(switch (judged) {
        DividersMark.found => UiSound.place,
        DividersMark.unset => UiSound.reject,
        _ => UiSound.mistake,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final headings = l10n.dividersHeadings.split(',');
    final current = _state.current;
    final walked = (_state.span ?? 0) * _state.steps;
    final status = switch (_note) {
      _Note.elsewhere => l10n.dividersElsewhere,
      _Note.nothing => l10n.dividersNothing,
      _Note.unset => l10n.dividersUnset,
      _Note.none when _state.steps > 0 => l10n.dividersWalked(walked.round()),
      _Note.none => l10n.dividersProgress(_state.found, _config.targets.length),
    };
    Widget heading(Heading h) {
      final picked = _state.heading == h;
      return SizedBox(
        width: 44,
        height: 40,
        child: OutlinedButton(
          key: ValueKey('dividers_heading_${h.name}'),
          onPressed: isSolved
              ? null
              : () => _set(_state.setHeading(h), UiSound.tap),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: picked ? const Color(0x55E8C87A) : null,
            side: BorderSide(
              color: picked
                  ? StillroomPalette.gaslight
                  : const Color(0x88D8C9A8),
            ),
          ),
          child: FittedBox(
            child: Text(
              headings.length == 8 ? headings[h.index] : h.name.toUpperCase(),
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(52, 8, 20, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1 / _config.aspect,
                child: CustomPaint(
                  key: const ValueKey('dividers_chart'),
                  painter: _ChartPainter(
                    config: _config,
                    state: _state,
                    label: (key) => widget.context.text(context, key),
                    north: headings.isEmpty ? 'N' : headings.first,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 236,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8DCC0),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        current == null
                            ? l10n.dividersProgress(
                                _state.found,
                                _config.targets.length,
                              )
                            : widget.context.text(context, current.clueKey),
                        key: const ValueKey('dividers_clue'),
                        style: const TextStyle(
                          fontFamily: AppTheme.serif,
                          fontSize: 13.5,
                          height: 1.25,
                          color: Color(0xFF241A10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (final span in _config.spans)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: SizedBox(
                            height: 40,
                            child: OutlinedButton(
                              key: ValueKey('dividers_span_${span.round()}'),
                              onPressed: isSolved
                                  ? null
                                  : () =>
                                        _set(_state.setSpan(span), UiSound.tap),
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                backgroundColor: _state.span == span
                                    ? const Color(0x55E8C87A)
                                    : null,
                              ),
                              child: FittedBox(
                                child: Text(l10n.dividersSpan(span.round())),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final row in const [
                          [Heading.nw, Heading.n, Heading.ne],
                          [Heading.w, null, Heading.e],
                          [Heading.sw, Heading.s, Heading.se],
                        ])
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (final h in row)
                                if (h == null)
                                  const SizedBox(
                                    width: 44,
                                    height: 40,
                                    child: Icon(
                                      Icons.explore_outlined,
                                      size: 20,
                                      color: StillroomPalette.paperShade,
                                    ),
                                  )
                                else
                                  heading(h),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OutlinedButton(
                            key: const ValueKey('dividers_step'),
                            onPressed: isSolved ? null : _step,
                            child: FittedBox(child: Text(l10n.dividersStep)),
                          ),
                          OutlinedButton(
                            key: const ValueKey('dividers_back'),
                            onPressed: isSolved
                                ? null
                                : () => _set(_state.back(), UiSound.tap),
                            child: FittedBox(child: Text(l10n.dividersBack)),
                          ),
                          FilledButton(
                            key: const ValueKey('dividers_mark'),
                            onPressed: isSolved ? null : _mark,
                            child: FittedBox(child: Text(l10n.dividersMark)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                PuzzleLabel(status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The chart: parchment, the sea along its foot, the banks and the sound,
/// the mainland above with a river; its places, a compass rose turned to
/// the chart's north, a scale of miles; found places ringed in red, and
/// the dividers' walk.
class _ChartPainter extends CustomPainter {
  const _ChartPainter({
    required this.config,
    required this.state,
    required this.label,
    required this.north,
  });

  final DividersConfig config;
  final DividersState state;
  final String Function(String key) label;
  final String north;

  @override
  void paint(Canvas canvas, Size size) {
    Offset at(math.Point<double> p) =>
        Offset(p.x * size.width, p.y * size.height);
    final whole = Offset.zero & size;
    canvas
      ..drawRect(whole, Paint()..color = const Color(0xFFE6D8B4))
      ..drawRect(
        whole,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF6A5236),
      );
    // The sea along the foot (east, on a chart turned west-up), the long
    // banks, the sound behind them.
    final sea = Path()
      ..moveTo(0, size.height * 0.9)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.92,
        size.width * 0.6,
        size.height * 0.88,
        size.width,
        size.height * 0.91,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(sea, Paint()..color = const Color(0xFF9AB0A8));
    final sound = Path()
      ..moveTo(0, size.height * 0.66)
      ..cubicTo(
        size.width * 0.35,
        size.height * 0.62,
        size.width * 0.7,
        size.height * 0.7,
        size.width,
        size.height * 0.64,
      )
      ..lineTo(size.width, size.height * 0.88)
      ..cubicTo(
        size.width * 0.6,
        size.height * 0.86,
        size.width * 0.3,
        size.height * 0.9,
        0,
        size.height * 0.87,
      )
      ..close();
    canvas.drawPath(sound, Paint()..color = const Color(0xFFB4C4B6));
    // A river winding down from the main to the sound.
    final river = Path()
      ..moveTo(size.width * 0.5, 0)
      ..cubicTo(
        size.width * 0.66,
        size.height * 0.2,
        size.width * 0.52,
        size.height * 0.4,
        size.width * 0.6,
        size.height * 0.64,
      );
    canvas.drawPath(
      river,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFF9AB0A8),
    );
    // Ships in the sea, as White drew them.
    for (final x in [0.15, 0.55, 0.85]) {
      final c = Offset(size.width * x, size.height * 0.955);
      canvas
        ..drawPath(
          Path()
            ..moveTo(c.dx - 9, c.dy)
            ..lineTo(c.dx + 9, c.dy)
            ..lineTo(c.dx + 6, c.dy + 4)
            ..lineTo(c.dx - 6, c.dy + 4)
            ..close(),
          Paint()..color = const Color(0xFF5A4030),
        )
        ..drawLine(
          c,
          c.translate(0, -12),
          Paint()
            ..strokeWidth = 1
            ..color = const Color(0xFF5A4030),
        )
        ..drawPath(
          Path()
            ..moveTo(c.dx, c.dy - 12)
            ..lineTo(c.dx + 7, c.dy - 4)
            ..lineTo(c.dx, c.dy - 3)
            ..close(),
          Paint()..color = const Color(0xFFF2EAD4),
        );
    }

    // The places.
    final found = {for (final t in config.targets.take(state.found)) t.place};
    for (final (i, p) in config.places.indexed) {
      final c = at(p.at);
      canvas.drawCircle(c, 3, Paint()..color = const Color(0xFF3A2A1A));
      if (found.contains(i)) {
        canvas.drawCircle(
          c,
          10,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = const Color(0xFFB0302A),
        );
      }
      _text(
        canvas,
        label(p.labelKey),
        c.translate(6, -14),
        10.5,
        rightAligned: p.at.x > 0.72,
      );
    }
    // Roanoke, where every walk starts.
    canvas.drawCircle(
      at(config.origin),
      4.5,
      Paint()..color = const Color(0xFFB0302A),
    );

    // The compass rose, its north where the chart's north lies.
    final rose = Offset(size.width * 0.9, size.height * 0.34);
    final r = size.shortestSide * 0.09;
    canvas
      ..drawCircle(
        rose,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0xFF6A5236),
      )
      ..save()
      ..translate(rose.dx, rose.dy)
      ..rotate(config.north * math.pi / 180);
    for (var k = 0; k < 4; k++) {
      canvas
        ..drawPath(
          Path()
            ..moveTo(0, -r)
            ..lineTo(r * 0.18, 0)
            ..lineTo(-r * 0.18, 0)
            ..close(),
          Paint()
            ..color = k == 0
                ? const Color(0xFFB0302A)
                : const Color(0xFF6A5236),
        )
        ..rotate(math.pi / 2);
    }
    canvas.restore();
    final a = config.north * math.pi / 180;
    _text(
      canvas,
      north,
      rose + Offset(math.sin(a), -math.cos(a)) * (r + 8) - const Offset(4, 7),
      11,
    );

    // The scale of miles, along the top left.
    const scaleMiles = 50;
    final scaleLen = size.width * scaleMiles / config.milesAcross;
    final s0 = Offset(size.width * 0.06, size.height * 0.07);
    final tick = Paint()
      ..strokeWidth = 1.2
      ..color = const Color(0xFF3A2A1A);
    canvas.drawLine(s0, s0.translate(scaleLen, 0), tick);
    for (var m = 0; m <= scaleMiles; m += 10) {
      final x = s0.dx + scaleLen * m / scaleMiles;
      canvas.drawLine(Offset(x, s0.dy - 4), Offset(x, s0.dy + 4), tick);
      _text(canvas, '$m', Offset(x - 5, s0.dy + 5), 9);
    }

    // The walk: the dividers' legs swinging from point to point.
    final span = state.span;
    final h = state.heading;
    if (span != null && h != null && state.steps > 0) {
      final leg = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0xFF2A4A7A);
      var prev = at(config.origin);
      for (var k = 1; k <= state.steps; k++) {
        final next = at(config.standAt(span, h, k));
        final mid = Offset.lerp(prev, next, 0.5)!;
        final d = next - prev;
        final apex = mid + Offset(-d.dy, d.dx) * 0.35;
        canvas
          ..drawLine(prev, apex, leg)
          ..drawLine(apex, next, leg)
          ..drawCircle(next, 2.5, Paint()..color = const Color(0xFF2A4A7A));
        prev = next;
      }
    }
  }

  void _text(
    Canvas canvas,
    String text,
    Offset at,
    double size, {
    bool rightAligned = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: AppTheme.serif,
          fontStyle: FontStyle.italic,
          fontSize: size,
          color: const Color(0xFF3A2A1A),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      rightAligned ? at.translate(-painter.width - 12, 0) : at,
    );
  }

  @override
  bool shouldRepaint(_ChartPainter old) => old.state != state;
}
