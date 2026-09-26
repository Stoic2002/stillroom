import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/art/vector_art.dart';
import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../core/widgets/content_image.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// Drag a finger over the surface to uncover what lies under it: fog wiped
/// from glass, or paper shaded with a pencil until pressed-in writing shows.
class RevealView extends StatefulWidget {
  const RevealView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<RevealView> createState() => _RevealViewState();
}

class _RevealViewState extends State<RevealView>
    with SolvesAfterPause<RevealView> {
  late final _config = widget.context.puzzle.config as RevealConfig;
  late RevealState _state = _config.start();
  DateTime _lastSound = DateTime.fromMillisecondsSinceEpoch(0);

  UiSound get _sound =>
      _config.style == RevealStyle.rub ? UiSound.rub : UiSound.wipe;

  void _stroke(Offset local, Size board) {
    if (isSolved || board.isEmpty) return;
    final next = _state.stroke(
      local.dx / board.width,
      local.dy / board.height,
      aspect: board.width / board.height,
    );
    if (identical(next, _state)) return;
    final now = DateTime.now();
    if (now.difference(_lastSound) > const Duration(milliseconds: 140)) {
      _lastSound = now;
      widget.context.feedback(_sound);
    }
    setState(() => _state = next.isSolved ? next.uncoverAll() : next);
    if (next.isSolved) {
      widget.context.feedback(UiSound.solved);
      markSolved(widget.context.onSolved);
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
          onPanDown: (d) => _stroke(d.localPosition, board),
          onPanUpdate: (d) => _stroke(d.localPosition, board),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ContentImage(
                path: _config.hidden,
                label: widget.context.puzzle.id,
                assets: widget.context.assets,
                background: true,
              ),
              CustomPaint(
                key: const ValueKey('reveal_cover'),
                painter: _CoverPainter(
                  _state,
                  cover: _config.cover == null
                      ? null
                      : vectorArtFor(_config.cover!),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _state.progress < 0.05 ? 1 : 0,
                    duration: const Duration(milliseconds: 400),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: PuzzleLabel(
                        _config.style == RevealStyle.rub
                            ? l10n.revealRub
                            : l10n.revealWipe,
                      ),
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

/// The surface, with soft holes where the finger has been.
class _CoverPainter extends CustomPainter {
  _CoverPainter(this.state, {this.cover});

  final RevealState state;

  /// Code-drawn cover art, if the config names one.
  final void Function(Canvas canvas, Size size)? cover;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    final art = cover;
    if (art != null) {
      art(canvas, size);
    } else if (state.config.style == RevealStyle.rub) {
      _paper(canvas, size);
    } else {
      _fog(canvas, size);
    }

    const columns = RevealConfig.columns;
    const rows = RevealConfig.rows;
    final cellW = size.width / columns;
    final cellH = size.height / rows;
    final holes = Path();
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < columns; c++) {
        if (!state.isUncovered(c, r)) continue;
        holes.addOval(
          Rect.fromCenter(
            center: Offset((c + 0.5) * cellW, (r + 0.5) * cellH),
            width: cellW * 1.9,
            height: cellH * 1.9,
          ),
        );
      }
    }
    canvas
      ..drawPath(
        holes,
        Paint()
          ..blendMode = BlendMode.dstOut
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, cellW * 0.6),
      )
      ..restore();
  }

  /// Breath on cold glass: pale, uneven, with a few drips.
  void _fog(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xF0A9B3AE), Color(0xF7C4CCC6)],
        ).createShader(rect),
    );
    final random = math.Random(7);
    for (var i = 0; i < 40; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        size.shortestSide * (0.03 + random.nextDouble() * 0.08),
        Paint()
          ..color = const Color(0xFFDDE3DE).withValues(alpha: 0.18)
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            size.shortestSide * 0.03,
          ),
      );
    }
    for (var i = 0; i < 9; i++) {
      final x = random.nextDouble() * size.width;
      final top = random.nextDouble() * size.height * 0.6;
      canvas.drawLine(
        Offset(x, top),
        Offset(x, top + size.height * (0.1 + random.nextDouble() * 0.3)),
        Paint()
          ..color = const Color(0x55707C76)
          ..strokeWidth = 1.5,
      );
    }
  }

  /// A clean sheet of paper, waiting for the pencil.
  void _paper(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = StillroomPalette.paper,
    );
    final random = math.Random(11);
    final fibre = Paint()
      ..color = StillroomPalette.paperShade.withValues(alpha: 0.35)
      ..strokeWidth = 0.8;
    for (var i = 0; i < 120; i++) {
      final p = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      canvas.drawLine(
        p,
        p + Offset(4 + random.nextDouble() * 10, random.nextDouble() * 2 - 1),
        fibre,
      );
    }
  }

  @override
  bool shouldRepaint(_CoverPainter old) => !identical(old.state, state);
}
