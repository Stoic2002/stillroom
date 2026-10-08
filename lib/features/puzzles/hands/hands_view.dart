import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// The household's receipt book open on the bench. Across the top, a strip
/// of each hand that wrote in it (its g, its long s, its "and", its slant);
/// below, the receipts, each with the same three letters in its own hand.
/// Pick a receipt, then the hand that wrote it; check when all are sorted.
class HandsView extends StatefulWidget {
  const HandsView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<HandsView> createState() => _HandsViewState();
}

/// A colour for each hand's tag.
const _handColours = [
  Color(0xFF8A3A2A),
  Color(0xFF3A5A7A),
  Color(0xFF4A6A3A),
  Color(0xFF7A5A1E),
  Color(0xFF5A3A6A),
];

class _HandsViewState extends State<HandsView>
    with SolvesAfterPause<HandsView> {
  late final _config = widget.context.puzzle.config as HandsConfig;
  late HandsState _state = _config.start();
  int? _picked;
  int? _cameBack;

  void _pick(int receipt) {
    if (isSolved) return;
    setState(() {
      _picked = _picked == receipt ? null : receipt;
      _cameBack = null;
    });
    widget.context.feedback(UiSound.page);
  }

  void _toHand(int hand) {
    final picked = _picked;
    if (isSolved || picked == null) return;
    setState(() {
      _state = _state.assign(picked, hand);
      _picked = null;
    });
    widget.context.feedback(UiSound.handSorted);
  }

  void _check() {
    if (isSolved || !_state.complete) return;
    if (_state.isSolved) {
      widget.context.feedback(UiSound.solved);
      markSolved(widget.context.onSolved);
      setState(() {});
      return;
    }
    final wrong = _state.wrong.length;
    setState(() {
      _state = _state.check();
      _cameBack = wrong;
    });
    widget.context.feedback(UiSound.mistake);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = _cameBack != null
        ? l10n.handsWrong(_cameBack!)
        : l10n.handsInstruction;
    return Padding(
      padding: const EdgeInsets.fromLTRB(52, 6, 24, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 64,
            child: Row(
              children: [
                for (final (i, hand) in _config.hands.indexed)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GestureDetector(
                        key: ValueKey('hands_hand_$i'),
                        onTap: () => _toHand(i),
                        child: _HandStrip(
                          label: widget.context.text(context, hand.labelKey),
                          tells: hand,
                          colour: _handColours[i],
                          ready: _picked != null,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) {
                final n = _config.receipts.length;
                final columns = n <= 8 ? 4 : 5;
                final rows = (n / columns).ceil();
                final cw = box.maxWidth / columns;
                final rh = box.maxHeight / rows;
                return Stack(
                  children: [
                    for (final (i, receipt) in _config.receipts.indexed)
                      Positioned(
                        left: (i % columns) * cw,
                        top: (i ~/ columns) * rh,
                        width: cw,
                        height: rh,
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: GestureDetector(
                            key: ValueKey('hands_receipt_$i'),
                            onTap: () => _pick(i),
                            child: _ReceiptCard(
                              title: widget.context.text(
                                context,
                                receipt.labelKey,
                              ),
                              tells: _config.hands[receipt.hand],
                              lacks: receipt.lacks,
                              seed: i,
                              picked: _picked == i,
                              tag: _state.assigned[i],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: PuzzleLabel(
                  '$status\n${l10n.handsSorted(_state.assigned.length, _config.receipts.length)}',
                  maxLines: 3,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                key: const ValueKey('hands_check'),
                onPressed: _state.complete && !isSolved ? _check : null,
                child: Text(l10n.handsCheck),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A strip at the head of the page: who wrote this hand, and its g, long s
/// and "and" as it makes them.
class _HandStrip extends StatelessWidget {
  const _HandStrip({
    required this.label,
    required this.tells,
    required this.colour,
    required this.ready,
  });

  final String label;
  final HandTells tells;
  final Color colour;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE6DAB8),
        border: Border.all(color: colour, width: ready ? 3 : 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: AppTheme.smallCaps,
                  fontSize: 12,
                  color: colour,
                ),
              ),
            ),
            Expanded(
              child: CustomPaint(
                painter: HandGlyphsPainter(tells),
                size: Size.infinite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A receipt on the page: its title, a few lines of the hand, and its g,
/// long s and "and" picked out; tagged with the hand it was put to.
class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({
    required this.title,
    required this.tells,
    required this.lacks,
    required this.seed,
    required this.picked,
    required this.tag,
  });

  final String title;
  final HandTells tells;
  final Set<Tell> lacks;
  final int seed;
  final bool picked;
  final int? tag;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEDE2C4),
        border: Border.all(
          color: picked
              ? StillroomPalette.gaslight
              : (tag != null ? _handColours[tag!] : const Color(0xFF8A7A5A)),
          width: picked || tag != null ? 3 : 1,
        ),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Color(0x66000000))],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: AppTheme.serif,
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                  color: Color(0xFF3A2614),
                ),
              ),
            ),
            Expanded(
              child: CustomPaint(
                painter: _ScrawlPainter(tells.slant, seed),
                size: Size.infinite,
              ),
            ),
            SizedBox(
              height: 24,
              child: CustomPaint(
                painter: HandGlyphsPainter(tells, lacks: lacks),
                size: Size.infinite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lines of writing, slanted as the hand slants.
class _ScrawlPainter extends CustomPainter {
  const _ScrawlPainter(this.slant, this.seed);

  final int slant;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed * 31 + 7);
    final ink = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xAA3A2614);
    const gap = 9.0;
    canvas.clipRect(Offset.zero & size);
    for (var y = 6.0; y < size.height - 2; y += gap) {
      var x = 2.0;
      final end = size.width - 2 - random.nextDouble() * size.width * 0.3;
      while (x < end) {
        final w = math.min(6 + random.nextDouble() * 14, end - x);
        final path = Path()..moveTo(x, y);
        for (var s = x; s < x + w; s += 3) {
          path.lineTo(s + 1.5 + slant * 1.2, y - 3);
          path.lineTo(s + 3, y);
        }
        canvas.drawPath(path, ink);
        x += w + 4;
      }
    }
  }

  @override
  bool shouldRepaint(_ScrawlPainter old) => false;
}

/// A hand's three tells side by side: its g, its s, its "and", all
/// slanted as the hand slants. A letter in [lacks] is a blank: the
/// receipt has none of it.
class HandGlyphsPainter extends CustomPainter {
  const HandGlyphsPainter(this.tells, {this.lacks = const {}});

  final HandTells tells;
  final Set<Tell> lacks;

  @override
  void paint(Canvas canvas, Size size) {
    final h = math.min(size.height, size.width / 3.4);
    final ink = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, h * 0.07)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFF2A1A0E);
    final cell = size.width / 3;
    for (var k = 0; k < 3; k++) {
      if (lacks.contains(Tell.values[k])) {
        // Nothing to see: a faint rule where the letter would be.
        canvas.drawLine(
          Offset(cell * (k + 0.3), size.height / 2),
          Offset(cell * (k + 0.7), size.height / 2),
          Paint()
            ..strokeWidth = 1
            ..color = const Color(0x553A2614),
        );
        continue;
      }
      canvas
        ..save()
        ..translate(cell * (k + 0.5), size.height / 2)
        // The slant: a shear about the baseline.
        ..transform(Matrix4.skewX(-tells.slant * 0.32).storage);
      switch (k) {
        case 0:
          _g(canvas, h, ink);
        case 1:
          _s(canvas, h, ink);
        default:
          _amp(canvas, h, ink);
      }
      canvas.restore();
    }
  }

  /// The g: a bowl, then its tail open, looped, or straight down.
  void _g(Canvas canvas, double h, Paint ink) {
    final r = h * 0.17;
    final bowl = Offset(0, -h * 0.08);
    canvas.drawCircle(bowl, r, ink);
    final stemTop = bowl.translate(r, -r * 0.4);
    final path = Path()..moveTo(stemTop.dx, stemTop.dy);
    switch (tells.g) {
      case 0:
        path
          ..lineTo(r, h * 0.22)
          ..quadraticBezierTo(r * 0.6, h * 0.42, -r * 1.3, h * 0.3);
      case 1:
        path
          ..lineTo(r, h * 0.22)
          ..cubicTo(r, h * 0.48, -r * 1.6, h * 0.48, -r * 1.2, h * 0.3)
          ..quadraticBezierTo(-r * 0.4, h * 0.18, r * 1.4, h * 0.2);
      default:
        path.lineTo(r, h * 0.44);
    }
    canvas.drawPath(path, ink);
  }

  /// The s: a tall long s with a hook, a round s, or a long s crossed.
  void _s(Canvas canvas, double h, Paint ink) {
    switch (tells.s) {
      case 1:
        final path = Path()
          ..moveTo(h * 0.14, -h * 0.18)
          ..cubicTo(-h * 0.2, -h * 0.28, -h * 0.22, -h * 0.02, 0, 0)
          ..cubicTo(h * 0.22, h * 0.03, h * 0.2, h * 0.24, -h * 0.15, h * 0.16);
        canvas.drawPath(path, ink);
      default:
        final path = Path()
          ..moveTo(-h * 0.08, h * 0.3)
          ..lineTo(0, -h * 0.26)
          ..quadraticBezierTo(h * 0.04, -h * 0.42, h * 0.2, -h * 0.36);
        canvas.drawPath(path, ink);
        if (tells.s == 2) {
          canvas.drawLine(
            Offset(-h * 0.14, -h * 0.06),
            Offset(h * 0.1, -h * 0.06),
            ink,
          );
        }
    }
  }

  /// The "and": an ampersand, a joined "et", or a plain cross.
  void _amp(Canvas canvas, double h, Paint ink) {
    switch (tells.amp) {
      case 0:
        final path = Path()
          ..moveTo(h * 0.2, h * 0.24)
          ..lineTo(-h * 0.1, -h * 0.08)
          ..cubicTo(
            -h * 0.24,
            -h * 0.26,
            h * 0.06,
            -h * 0.36,
            h * 0.04,
            -h * 0.16,
          )
          ..cubicTo(h * 0.0, -h * 0.04, -h * 0.26, h * 0.06, -h * 0.16, h * 0.2)
          ..quadraticBezierTo(-h * 0.04, h * 0.32, h * 0.16, h * 0.04);
        canvas.drawPath(path, ink);
      case 1:
        // A joined "et": a looped e running into a crossed t.
        final path = Path()
          ..moveTo(-h * 0.24, h * 0.02)
          ..lineTo(-h * 0.04, h * 0.0)
          ..cubicTo(
            -h * 0.02,
            -h * 0.18,
            -h * 0.3,
            -h * 0.2,
            -h * 0.28,
            h * 0.06,
          )
          ..quadraticBezierTo(-h * 0.24, h * 0.24, -h * 0.02, h * 0.16)
          ..lineTo(h * 0.12, -h * 0.3)
          ..moveTo(h * 0.12, -h * 0.3)
          ..lineTo(h * 0.06, h * 0.12)
          ..quadraticBezierTo(h * 0.08, h * 0.24, h * 0.22, h * 0.14);
        canvas
          ..drawPath(path, ink)
          ..drawLine(
            Offset(-h * 0.02, -h * 0.12),
            Offset(h * 0.24, -h * 0.12),
            ink,
          );
      default:
        canvas
          ..drawLine(Offset(0, -h * 0.24), Offset(0, h * 0.24), ink)
          ..drawLine(Offset(-h * 0.2, 0), Offset(h * 0.2, 0), ink);
    }
  }

  @override
  bool shouldRepaint(HandGlyphsPainter old) =>
      old.tells != tells || old.lacks != lacks;
}
