import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// Night over the island, and the lighthouse beam turning through it: the
/// picture shows only where the beam falls. Tap each target while it is lit.
class BeamSweepView extends StatefulWidget {
  const BeamSweepView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<BeamSweepView> createState() => _BeamSweepViewState();
}

class _BeamSweepViewState extends State<BeamSweepView>
    with SingleTickerProviderStateMixin, SolvesAfterPause<BeamSweepView> {
  late final _config = widget.context.puzzle.config as BeamSweepConfig;
  late BeamSweepState _state = _config.start();
  final _seconds = ValueNotifier<double>(0);
  late final Ticker _ticker;
  bool _missed = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(
      (elapsed) => _seconds.value = elapsed.inMicroseconds / 1e6,
    )..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _seconds.dispose();
    super.dispose();
  }

  void _tap(Offset local, Size board) {
    if (isSolved) return;
    for (final target in _config.targets) {
      if (_state.found.contains(target.id)) continue;
      if (!boardHitRect(target.rect, board).contains(local)) continue;
      final next = _state.tap(
        target.id,
        _seconds.value,
        aspect: board.width / board.height,
      );
      final found = next.found.length > _state.found.length;
      setState(() {
        _state = next;
        _missed = !found;
      });
      widget.context.feedback(found ? UiSound.place : UiSound.reject);
      if (next.isSolved) {
        widget.context.feedback(UiSound.solved);
        markSolved(widget.context.onSolved);
      }
      return;
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
          onTapUp: (d) => _tap(d.localPosition, board),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  key: const ValueKey('beam'),
                  painter: _NightPainter(
                    _config,
                    _seconds,
                    found: _state.found,
                  ),
                ),
              ),
              for (final target in _config.targets)
                if (_state.found.contains(target.id))
                  if (target.labelKey case final key?)
                    Positioned.fromRect(
                      rect: boardRect(
                        target.rect,
                        board,
                      ).translate(0, board.height * target.rect.height),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: OverflowBox(
                          maxWidth: board.width * 0.3,
                          child: PuzzleLabel(widget.context.text(context, key)),
                        ),
                      ),
                    ),
              Align(
                alignment: Alignment.bottomCenter,
                child: IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: PuzzleLabel(
                      _missed ? l10n.beamSweepMiss : l10n.beamSweepInstruction,
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

/// Darkness over the board, with the beam's wedge cut out of it and the
/// found targets ringed in gaslight.
class _NightPainter extends CustomPainter {
  _NightPainter(this.config, this.seconds, {required this.found})
    : super(repaint: seconds);

  final BeamSweepConfig config;
  final ValueNotifier<double> seconds;
  final Set<String> found;

  @override
  void paint(Canvas canvas, Size size) {
    final pivot = Offset(
      config.pivotX * size.width,
      config.pivotY * size.height,
    );
    final angle = config.angleAt(seconds.value);
    final reach = size.longestSide * 1.6;
    final bounds = Offset.zero & size;

    canvas.saveLayer(bounds, Paint());
    canvas.drawRect(bounds, Paint()..color = const Color(0xF2050709));
    // The beam: a wedge from the lamp, brightest along its middle.
    Path wedge(double spread) => Path()
      ..moveTo(pivot.dx, pivot.dy)
      ..lineTo(
        pivot.dx + math.cos(angle - spread) * reach,
        pivot.dy + math.sin(angle - spread) * reach,
      )
      ..lineTo(
        pivot.dx + math.cos(angle + spread) * reach,
        pivot.dy + math.sin(angle + spread) * reach,
      )
      ..close();
    final beam = wedge(config.spread);
    canvas
      ..drawPath(
        beam,
        Paint()
          ..blendMode = BlendMode.dstOut
          ..color = const Color(0xCC000000),
      )
      ..drawPath(
        wedge(config.spread * 0.55),
        Paint()
          ..blendMode = BlendMode.dstOut
          ..color = const Color(0xFF000000),
      );
    canvas.restore();

    // A warm cast along the beam, and the lamp itself.
    canvas
      ..drawPath(beam, Paint()..color = const Color(0x22F1C66A))
      ..drawCircle(
        pivot,
        size.shortestSide * 0.03,
        Paint()
          ..color = const Color(0xFFF1C66A)
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            size.shortestSide * 0.02,
          ),
      );

    for (final target in config.targets) {
      if (!found.contains(target.id)) continue;
      final rect = boardRect(target.rect, size);
      canvas
        ..drawRect(rect, Paint()..color = const Color(0x33F1C66A))
        ..drawRect(
          rect,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = StillroomPalette.gaslight,
        );
    }
  }

  @override
  bool shouldRepaint(_NightPainter old) =>
      old.config != config || old.found != found;
}
