import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// Furnaces along the top, the mould's pouring cups along the bottom, and
/// the clay channels between. Tap a channel piece to turn it; tap Pour to
/// open the furnaces. Where the bronze would run out, it shows, and the
/// furnaces close again.
class PourView extends StatefulWidget {
  const PourView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<PourView> createState() => _PourViewState();
}

class _PourViewState extends State<PourView> with SolvesAfterPause<PourView> {
  late final _config = widget.context.puzzle.config as PourConfig;
  late PourState _state = _config.start();

  /// The last pour's run of bronze, shown for a moment.
  PourFlow? _shown;
  String? _status;
  Timer? _clear;

  @override
  void dispose() {
    _clear?.cancel();
    super.dispose();
  }

  void _turn(int index) {
    if (isSolved || _shown != null) return;
    if (!_config.tiles[index].kind.turns) {
      widget.context.feedback(UiSound.reject);
      return;
    }
    setState(() {
      _state = _state.turn(index);
      _status = null;
    });
    widget.context.feedback(UiSound.turn);
  }

  void _pour() {
    if (isSolved || _shown != null) return;
    final l10n = AppLocalizations.of(context);
    final next = _state.pour();
    final flow = next.flow;
    setState(() {
      _state = next;
      _shown = flow;
      _status = next.isSolved
          ? null
          : flow.leaks.isNotEmpty
          ? l10n.pourSpilt
          : l10n.pourShort;
    });
    widget.context.feedback(UiSound.pour);
    if (next.isSolved) {
      widget.context.feedback(UiSound.solved);
      markSolved(widget.context.onSolved);
    } else {
      widget.context.feedback(UiSound.mistake);
      _clear = Timer(const Duration(milliseconds: 1600), () {
        if (mounted) setState(() => _shown = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final flow = _shown;
    return LayoutBuilder(
      builder: (context, box) {
        final cols = _config.columns;
        final rows = _config.rows;
        // Rows of tiles, plus a band for the furnaces and one for the cups.
        final cell = math.min(
          (box.maxWidth - 160) / cols,
          (box.maxHeight - 60) / (rows + 2),
        );
        final gridW = cell * cols;
        final left = (box.maxWidth - gridW) / 2;
        const top = 12.0;
        return Stack(
          children: [
            // Furnaces.
            for (final c in _config.furnaces)
              Positioned(
                left: left + c * cell + cell * 0.1,
                top: top,
                width: cell * 0.8,
                height: cell * 0.9,
                child: CustomPaint(
                  painter: _FurnacePainter(open: flow != null),
                ),
              ),
            // The channels.
            for (var i = 0; i < _config.tiles.length; i++)
              Positioned(
                left: left + (i % cols) * cell,
                top: top + cell + (i ~/ cols) * cell,
                width: cell,
                height: cell,
                child: GestureDetector(
                  key: ValueKey('pour_tile_$i'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _turn(i),
                  child: AnimatedRotation(
                    turns: _state.turns[i] / 4,
                    duration: const Duration(milliseconds: 150),
                    child: CustomPaint(
                      painter: _TilePainter(
                        _config.tiles[i].kind,
                        bronze: flow?.reached.contains(i) ?? false,
                        leaks: {
                          for (final (t, side)
                              in flow?.leaks ?? const <(int, int)>{})
                            if (t == i) (side - _state.turns[i]) % 4,
                        },
                      ),
                    ),
                  ),
                ),
              ),
            // The mould's pouring cups.
            for (final c in _config.cups)
              Positioned(
                left: left + c * cell + cell * 0.15,
                top: top + cell * (rows + 1),
                width: cell * 0.7,
                height: cell * 0.8,
                child: CustomPaint(
                  painter: _CupPainter(full: flow?.filled.contains(c) ?? false),
                ),
              ),
            Positioned(
              right: 16,
              top: top + cell,
              child: FilledButton(
                key: const ValueKey('pour_button'),
                onPressed: isSolved || flow != null ? null : _pour,
                child: Text(l10n.pourButton),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: PuzzleLabel(_status ?? l10n.pourInstruction),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

const _clay = Color(0xFF8A7556);
const _groove = Color(0xFF3E2C1E);
const _bronze = Color(0xFFE08A3A);

/// A square of packed sand with a clay channel cut in it, drawn unturned:
/// the view turns the whole square. [leaks] are unturned sides where the
/// bronze runs out.
class _TilePainter extends CustomPainter {
  const _TilePainter(this.kind, {required this.bronze, required this.leaks});

  final PourTileKind kind;
  final bool bronze;
  final Set<int> leaks;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(1.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(size.width * 0.08)),
      Paint()
        ..color = kind == PourTileKind.empty ? const Color(0xFF6E5E44) : _clay,
    );
    // Grains of sand.
    final random = math.Random(kind.index * 13 + 5);
    final grain = Paint()..color = const Color(0x33000000);
    for (var i = 0; i < 16; i++) {
      canvas.drawCircle(
        Offset(
          rect.left + random.nextDouble() * rect.width,
          rect.top + random.nextDouble() * rect.height,
        ),
        size.width * 0.012,
        grain,
      );
    }
    if (kind == PourTileKind.empty) return;
    final c = size.center(Offset.zero);
    final w = size.width * 0.3;
    final groove = Paint()
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..color = _groove;
    final metal = Paint()
      ..strokeWidth = w * 0.62
      ..strokeCap = StrokeCap.round
      ..color = _bronze;
    final ends = <int, Offset>{
      0: Offset(c.dx, 0),
      1: Offset(size.width, c.dy),
      2: Offset(c.dx, size.height),
      3: Offset(0, c.dy),
    };
    final open = pourOpenings(kind, 0);
    for (final MapEntry(key: side, value: end) in ends.entries) {
      if (open & (1 << side) == 0) continue;
      canvas.drawLine(c, end, groove);
    }
    canvas.drawCircle(c, w / 2, Paint()..color = _groove);
    if (bronze) {
      for (final MapEntry(key: side, value: end) in ends.entries) {
        if (open & (1 << side) == 0) continue;
        canvas.drawLine(c, end, metal);
      }
    }
    // Where the bronze runs out into sand or air, a splash, even on a piece
    // it never entered (a furnace pouring onto a closed side).
    for (final side in leaks) {
      canvas.drawCircle(
        ends[side]!,
        size.width * 0.16,
        Paint()..color = const Color(0xCCE06A2A),
      );
    }
  }

  @override
  bool shouldRepaint(_TilePainter old) =>
      old.bronze != bronze || old.leaks.length != leaks.length;
}

class _FurnacePainter extends CustomPainter {
  const _FurnacePainter({required this.open});

  final bool open;

  @override
  void paint(Canvas canvas, Size size) {
    final body = Path()
      ..moveTo(size.width * 0.1, size.height)
      ..lineTo(size.width * 0.2, size.height * 0.1)
      ..quadraticBezierTo(
        size.width * 0.5,
        -size.height * 0.05,
        size.width * 0.8,
        size.height * 0.1,
      )
      ..lineTo(size.width * 0.9, size.height)
      ..close();
    canvas
      ..drawPath(body, Paint()..color = const Color(0xFF5A4636))
      ..drawPath(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF070504),
      );
    final mouth = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.62),
      width: size.width * 0.34,
      height: size.height * 0.34,
    );
    canvas
      ..drawCircle(
        mouth.center,
        size.width * 0.5,
        Paint()
          ..shader =
              RadialGradient(
                colors: [
                  StillroomPalette.gaslight.withValues(
                    alpha: open ? 0.7 : 0.35,
                  ),
                  StillroomPalette.gaslight.withValues(alpha: 0),
                ],
              ).createShader(
                Rect.fromCircle(center: mouth.center, radius: size.width * 0.5),
              ),
      )
      ..drawOval(
        mouth,
        Paint()..color = open ? _bronze : const Color(0xFFB0562A),
      );
  }

  @override
  bool shouldRepaint(_FurnacePainter old) => old.open != open;
}

class _CupPainter extends CustomPainter {
  const _CupPainter({required this.full});

  final bool full;

  @override
  void paint(Canvas canvas, Size size) {
    final cup = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.65, size.height)
      ..lineTo(size.width * 0.35, size.height)
      ..close();
    canvas
      ..drawPath(cup, Paint()..color = const Color(0xFF6A5236))
      ..drawPath(
        cup,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF070504),
      )
      ..drawOval(
        Rect.fromLTWH(
          size.width * 0.1,
          -size.height * 0.08,
          size.width * 0.8,
          size.height * 0.2,
        ),
        Paint()..color = full ? _bronze : const Color(0xFF241A12),
      );
  }

  @override
  bool shouldRepaint(_CupPainter old) => old.full != full;
}
