import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// A robe laid out on the bench, one layer uppermost at a time, and a
/// probe dragged over it. A needle shows the reading under the probe;
/// nothing is revealed, only measured. Mark the places it stands high.
class ScanView extends StatefulWidget {
  const ScanView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<ScanView> createState() => _ScanViewState();
}

enum _Note { none, found, again, faint, miss }

class _ScanViewState extends State<ScanView> with SolvesAfterPause<ScanView> {
  late final _config = widget.context.puzzle.config as ScanConfig;
  late ScanState _state = _config.start();

  /// Where the probe rests on the robe, from 0 to 1 across it.
  Offset _probe = const Offset(0.5, 0.92);
  _Note _note = _Note.none;
  String? _last;

  /// The needle's band last ticked, so it ticks as the reading changes.
  int _band = 0;

  double get _reading => _state.reading(_probe.dx, _probe.dy);

  void _move(Offset local, Size board) {
    if (isSolved) return;
    final next = Offset(
      (local.dx / board.width).clamp(0, 1),
      (local.dy / board.height).clamp(0, 1),
    );
    setState(() {
      _probe = next;
      if (_note != _Note.found) _note = _Note.none;
    });
    final band = (_reading * 10).floor();
    if (band != _band) {
      _band = band;
      widget.context.feedback(UiSound.probeTick);
    }
  }

  void _show(int layer) {
    if (isSolved || layer == _state.layer) return;
    setState(() {
      _state = _state.show(layer);
      _note = _Note.none;
      _band = (_reading * 10).floor();
    });
    widget.context.feedback(UiSound.turn);
  }

  void _mark() {
    if (isSolved) return;
    final (x, y) = (_probe.dx, _probe.dy);
    final judged = _state.judge(x, y);
    final spot = _state.spotAt(x, y);
    final next = _state.mark(x, y);
    setState(() {
      _state = next;
      _note = switch (judged) {
        ScanMark.found => _Note.found,
        ScanMark.again => _Note.again,
        ScanMark.faint => _Note.faint,
        ScanMark.miss => _Note.miss,
      };
      if (spot != null) _last = spot.labelKey;
    });
    if (next.isSolved) {
      widget.context.feedback(UiSound.solved);
      markSolved(widget.context.onSolved);
    } else {
      widget.context.feedback(switch (judged) {
        ScanMark.found => UiSound.note,
        ScanMark.miss => UiSound.mistake,
        ScanMark.again || ScanMark.faint => UiSound.reject,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = switch (_note) {
      _Note.found => l10n.scanFound(
        widget.context.text(context, _last ?? _config.spots.first.labelKey),
      ),
      _Note.again => l10n.scanAgain,
      _Note.faint => l10n.scanFaint,
      _Note.miss => l10n.scanWrong,
      _Note.none => l10n.scanInstruction,
    };
    return LayoutBuilder(
      builder: (context, box) {
        final h = box.maxHeight * 0.84;
        final board = Size(math.min(h * 0.95, box.maxWidth * 0.5), h);
        return Stack(
          children: [
            Positioned(
              left: box.maxWidth * 0.08,
              top: box.maxHeight * 0.04,
              width: board.width,
              height: board.height,
              child: GestureDetector(
                key: const ValueKey('scan_board'),
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => _move(d.localPosition, board),
                onPanDown: (d) => _move(d.localPosition, board),
                onPanStart: (d) => _move(d.localPosition, board),
                onPanUpdate: (d) => _move(d.localPosition, board),
                child: CustomPaint(
                  painter: _RobePainter(
                    inner: _config.layers[_state.layer].scale == 1,
                    probe: _probe,
                    found: [
                      for (final s in _config.spots)
                        if (_state.found.contains(s.id)) Offset(s.x, s.y),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: box.maxWidth * 0.08 + board.width + 24,
              right: 24,
              top: box.maxHeight * 0.04,
              bottom: 8,
              child: Column(
                children: [
                  Text(
                    l10n.scanProgress(
                      _state.found.length,
                      _config.spots.length,
                    ),
                    style: const TextStyle(
                      fontFamily: AppTheme.smallCaps,
                      fontSize: 15,
                      color: StillroomPalette.paperShade,
                    ),
                  ),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: _reading),
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      builder: (context, value, _) => CustomPaint(
                        size: Size.infinite,
                        painter: _GaugePainter(value),
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final (i, layer) in _config.layers.indexed)
                        ChoiceChip(
                          key: ValueKey('scan_layer_${layer.id}'),
                          label: Text(
                            widget.context.text(context, layer.labelKey),
                          ),
                          selected: i == _state.layer,
                          onSelected: (_) => _show(i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    key: const ValueKey('scan_mark'),
                    onPressed: isSolved ? null : _mark,
                    child: Text(l10n.scanMark),
                  ),
                  const SizedBox(height: 6),
                  PuzzleLabel(status),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A Qing court robe laid flat: the outer robe of dark blue-black with
/// gold roundels, or the inner garment of plain pale silk. The probe is a
/// brass ring; places marked carry a vermilion circle.
class _RobePainter extends CustomPainter {
  const _RobePainter({
    required this.inner,
    required this.probe,
    required this.found,
  });

  final bool inner;
  final Offset probe;
  final List<Offset> found;

  @override
  void paint(Canvas canvas, Size size) {
    Offset p(double x, double y) => Offset(x * size.width, y * size.height);
    // The white bench paper under it.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(4)),
      Paint()..color = const Color(0xFFCFC9BA),
    );
    // Sleeves out to the sides, the body down to the hem, a slit collar.
    final robe = Path()
      ..moveTo(p(0.42, 0.12).dx, p(0.42, 0.12).dy)
      ..lineTo(p(0.2, 0.17).dx, p(0.2, 0.17).dy)
      ..lineTo(p(0.03, 0.3).dx, p(0.03, 0.3).dy)
      ..lineTo(p(0.05, 0.42).dx, p(0.05, 0.42).dy)
      ..lineTo(p(0.25, 0.36).dx, p(0.25, 0.36).dy)
      ..lineTo(p(0.2, 0.95).dx, p(0.2, 0.95).dy)
      ..lineTo(p(0.8, 0.95).dx, p(0.8, 0.95).dy)
      ..lineTo(p(0.75, 0.36).dx, p(0.75, 0.36).dy)
      ..lineTo(p(0.95, 0.42).dx, p(0.95, 0.42).dy)
      ..lineTo(p(0.97, 0.3).dx, p(0.97, 0.3).dy)
      ..lineTo(p(0.8, 0.17).dx, p(0.8, 0.17).dy)
      ..lineTo(p(0.58, 0.12).dx, p(0.58, 0.12).dy)
      ..close();
    final cloth = inner ? const Color(0xFFE6D9A8) : const Color(0xFF1E2438);
    final edge = inner ? const Color(0xFF9A8A5A) : const Color(0xFF0A0C14);
    canvas
      ..drawPath(robe, Paint()..color = cloth)
      ..drawPath(
        robe,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = edge,
      );
    // The collar and the front opening.
    final seam = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = inner ? const Color(0xFFB3A26A) : const Color(0xFF8A7440);
    canvas
      ..drawArc(
        Rect.fromCenter(
          center: p(0.5, 0.12),
          width: size.width * 0.18,
          height: size.height * 0.1,
        ),
        0,
        math.pi,
        false,
        seam,
      )
      ..drawLine(p(0.5, 0.17), p(0.5, 0.95), seam..strokeWidth = 1.5);
    if (inner) {
      // Plain silk: a few fold lines.
      final fold = Paint()
        ..strokeWidth = 1
        ..color = const Color(0x339A8A5A);
      for (final x in [0.33, 0.42, 0.58, 0.67]) {
        canvas.drawLine(p(x, 0.4), p(x + (x - 0.5) * 0.2, 0.93), fold);
      }
    } else {
      // Gold roundels on the dark court robe.
      final gold = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFFB08A3A);
      for (final c in [
        p(0.5, 0.3),
        p(0.36, 0.55),
        p(0.64, 0.55),
        p(0.36, 0.8),
        p(0.64, 0.8),
        p(0.13, 0.33),
        p(0.87, 0.33),
      ]) {
        final r = size.width * 0.045;
        canvas
          ..drawCircle(c, r, gold)
          ..drawCircle(c, r * 0.45, gold);
      }
      // The horse-hoof cuffs.
      final cuff = Paint()..color = const Color(0xFF6A5A30);
      canvas
        ..drawLine(p(0.03, 0.3), p(0.05, 0.42), cuff..strokeWidth = 5)
        ..drawLine(p(0.97, 0.3), p(0.95, 0.42), cuff);
    }
    // Places marked.
    final mark = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0xFFC0301E);
    for (final f in found) {
      canvas.drawCircle(p(f.dx, f.dy), size.width * 0.06, mark);
    }
    // The probe: a brass ring on a short arm from the right.
    final at = p(probe.dx, probe.dy);
    final r = size.width * 0.045;
    canvas
      ..drawLine(
        at + Offset(r, 0),
        at + Offset(r * 3.2, -r * 1.4),
        Paint()
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFF3A3A3E),
      )
      ..drawCircle(
        at,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFFD8B25A),
      )
      ..drawCircle(at, 2, Paint()..color = const Color(0xFFD8B25A));
  }

  @override
  bool shouldRepaint(_RobePainter old) =>
      old.inner != inner ||
      old.probe != probe ||
      old.found.length != found.length;
}

/// The reader's dial: a pale face, a scale from low to high with the top
/// band in red, and the needle.
class _GaugePainter extends CustomPainter {
  const _GaugePainter(this.value);

  /// The reading, from 0 to 1.
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width * 0.42, size.height * 0.8);
    final c = Offset(size.width / 2, size.height / 2 + r * 0.45);
    const start = math.pi * 1.2;
    const sweep = math.pi * 0.6;
    canvas
      ..drawCircle(c, r * 1.08, Paint()..color = const Color(0xFF2A2A2C))
      ..drawArc(
        Rect.fromCircle(center: c, radius: r),
        math.pi,
        math.pi,
        true,
        Paint()..color = const Color(0xFFE8E0CC),
      );
    final scale = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.06;
    canvas
      ..drawArc(
        Rect.fromCircle(center: c, radius: r * 0.82),
        start,
        sweep * ScanType.clear,
        false,
        scale..color = const Color(0xFF6A6A60),
      )
      ..drawArc(
        Rect.fromCircle(center: c, radius: r * 0.82),
        start + sweep * ScanType.clear,
        sweep * (1 - ScanType.clear),
        false,
        scale..color = const Color(0xFFB0301E),
      );
    final tick = Paint()
      ..strokeWidth = 1.5
      ..color = const Color(0xFF2A2A2C);
    for (var i = 0; i <= 10; i++) {
      final a = start + sweep * i / 10;
      final d = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        c + d * r * 0.7,
        c + d * r * (i.isEven ? 0.62 : 0.66),
        tick,
      );
    }
    final a = start + sweep * value.clamp(0, 1);
    canvas
      ..drawLine(
        c,
        c + Offset(math.cos(a), math.sin(a)) * r * 0.9,
        Paint()
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFF15110D),
      )
      ..drawCircle(c, r * 0.06, Paint()..color = const Color(0xFF15110D));
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.value != value;
}
