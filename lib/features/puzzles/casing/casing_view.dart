import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// A stretch of the casing at the monument's foot, stone over stone, each
/// numbered. Tap a stone to lift it and see the relief behind it, a deed
/// or a fruit with its caption. Two at a time: a deed with its fruit stays
/// open, framed as photographed; any other two go back when the next stone
/// is lifted.
class CasingView extends StatefulWidget {
  const CasingView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<CasingView> createState() => _CasingViewState();
}

class _CasingViewState extends State<CasingView>
    with SolvesAfterPause<CasingView> {
  late final _config = widget.context.puzzle.config as CasingConfig;
  late CasingState _state = _config.start();
  CasingLift? _last;

  void _lift(int i) {
    if (isSolved) return;
    final judged = _state.judge(i);
    if (judged == CasingLift.none) return;
    final next = _state.lift(i);
    setState(() {
      _state = next;
      _last = judged;
    });
    if (next.isSolved) {
      widget.context.feedback(UiSound.pairFound);
      markSolved(widget.context.onSolved);
      return;
    }
    widget.context.feedback(switch (judged) {
      CasingLift.pair => UiSound.pairFound,
      CasingLift.noPair => UiSound.mistake,
      _ => UiSound.stoneLift,
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pairs = _config.panels.length ~/ 2;
    final status = switch (_last) {
      CasingLift.pair => l10n.casingPair,
      CasingLift.noPair => l10n.casingNoPair,
      _ => l10n.casingInstruction,
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(52, 8, 24, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) {
                final cw = box.maxWidth / _config.columns;
                final rh = box.maxHeight / _config.rows;
                return Stack(
                  children: [
                    for (var i = 0; i < _config.panels.length; i++)
                      Positioned(
                        left: (i % _config.columns) * cw,
                        top: (i ~/ _config.columns) * rh,
                        width: cw,
                        height: rh,
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: GestureDetector(
                            key: ValueKey('casing_stone_$i'),
                            onTap: () => _lift(i),
                            child: _state.shows(i)
                                ? _Panel(
                                    caption: widget.context.text(
                                      context,
                                      _config.panels[i].labelKey,
                                    ),
                                    tag: _config.panels[i].fruit
                                        ? l10n.casingFruit
                                        : l10n.casingDeed,
                                    fruit: _config.panels[i].fruit,
                                    seed: i,
                                    kept: _state.kept.contains(i),
                                  )
                                : CustomPaint(painter: _StonePainter(i + 1)),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          PuzzleLabel(
            '$status\n${l10n.casingProgress(_state.kept.length ~/ 2, pairs)}',
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

/// A relief panel: carved andesite, figures in low relief, its caption and
/// whether it shows a deed or a fruit; framed once photographed.
class _Panel extends StatelessWidget {
  const _Panel({
    required this.caption,
    required this.tag,
    required this.fruit,
    required this.seed,
    required this.kept,
  });

  final String caption;
  final String tag;
  final bool fruit;
  final int seed;
  final bool kept;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ReliefPainter(seed: seed, fruit: fruit, kept: kept),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 3, 4, 3),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                tag,
                style: const TextStyle(
                  fontFamily: AppTheme.smallCaps,
                  fontSize: 10,
                  color: Color(0xFFE8DCC0),
                ),
              ),
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                caption,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTheme.serif,
                  fontSize: 13,
                  color: StillroomPalette.paper,
                  shadows: [Shadow(blurRadius: 3)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReliefPainter extends CustomPainter {
  const _ReliefPainter({
    required this.seed,
    required this.fruit,
    required this.kept,
  });

  final int seed;
  final bool fruit;
  final bool kept;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawRect(
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6E6A62), Color(0xFF4E4A44)],
        ).createShader(r),
    );
    // The frame of the panel, and figures in low relief: a deed has two,
    // one acting on the other; a fruit, one alone, seated or bowed.
    canvas.drawRect(
      r.deflate(3),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF8A867C),
    );
    final random = math.Random(seed * 7 + 3);
    final light = Paint()..color = const Color(0xFF8E8A80);
    final shade = Paint()..color = const Color(0xFF3A3632);
    void figure(double x, double lean) {
      final base = Offset(size.width * x, size.height * 0.78);
      final h = size.height * 0.42;
      canvas
        ..drawCircle(
          base.translate(lean * h * 0.3 + 1, -h + 1),
          h * 0.12,
          shade,
        )
        ..drawCircle(base.translate(lean * h * 0.3, -h), h * 0.12, light)
        ..drawPath(
          Path()
            ..moveTo(base.dx - h * 0.18, base.dy)
            ..lineTo(base.dx + lean * h * 0.3 - h * 0.12, base.dy - h * 0.85)
            ..lineTo(base.dx + lean * h * 0.3 + h * 0.12, base.dy - h * 0.85)
            ..lineTo(base.dx + h * 0.18, base.dy)
            ..close(),
          light,
        );
    }

    if (fruit) {
      figure(0.5, random.nextDouble() * 0.6 - 0.3);
    } else {
      figure(0.32, 0.4);
      figure(0.68, -0.3 - random.nextDouble() * 0.3);
    }
    // A band of foliage along the foot of the panel.
    for (var x = 6.0; x < size.width - 6; x += 9) {
      canvas.drawCircle(
        Offset(x, size.height * 0.86),
        3,
        Paint()..color = const Color(0xFF5E5A54),
      );
    }
    if (kept) {
      // Photographed: the corners of a plate's frame.
      final frame = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = StillroomPalette.gaslight;
      const l = 10.0;
      for (final (c, dx, dy) in [
        (r.topLeft, 1.0, 1.0),
        (r.topRight, -1.0, 1.0),
        (r.bottomLeft, 1.0, -1.0),
        (r.bottomRight, -1.0, -1.0),
      ]) {
        canvas
          ..drawLine(c, c.translate(l * dx, 0), frame)
          ..drawLine(c, c.translate(0, l * dy), frame);
      }
    }
  }

  @override
  bool shouldRepaint(_ReliefPainter old) => old.kept != kept;
}

/// A casing stone: a dressed block of andesite with its number chalked on.
class _StonePainter extends CustomPainter {
  const _StonePainter(this.number);

  final int number;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas
      ..drawRect(r, Paint()..color = const Color(0xFF5A5852))
      ..drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height * 0.12),
        Paint()..color = const Color(0x22FFFFFF),
      )
      ..drawRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = const Color(0xFF2A2824),
      );
    final random = math.Random(number * 13);
    for (var i = 0; i < 30; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        0.8,
        Paint()..color = const Color(0x33000000),
      );
    }
    final text = TextPainter(
      text: TextSpan(
        text: '$number',
        style: const TextStyle(
          fontFamily: AppTheme.serif,
          fontSize: 16,
          color: Color(0xCCE8E4DA),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(canvas, r.center - Offset(text.width / 2, text.height / 2));
  }

  @override
  bool shouldRepaint(_StonePainter old) => false;
}
