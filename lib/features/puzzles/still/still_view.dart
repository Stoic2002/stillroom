import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// The copper still on its little furnace, the worm in its tub of cold
/// water, the spout dripping into a glass. Three glasses on the bench, for
/// the heads, the heart and the tails: tap one to set it under the spout.
/// The fire and the water are set on the right; the drip tells what is
/// coming over by its look.
class StillView extends StatefulWidget {
  const StillView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<StillView> createState() => _StillViewState();
}

class _StillViewState extends State<StillView>
    with SolvesAfterPause<StillView>, SingleTickerProviderStateMixin {
  late final _config = widget.context.puzzle.config as StillConfig;
  late StillState _state = _config.start();
  late final Ticker _ticker = createTicker(_onTick);
  Duration _last = Duration.zero;
  double _clock = 0;
  double _dripTimer = 0;

  @override
  void initState() {
    super.initState();
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final dt = math.min(0.1, (elapsed - _last).inMicroseconds / 1e6);
    _last = elapsed;
    if (isSolved) return;
    final next = _state.tick(dt);
    _clock += dt;
    if (next.end == StillEnd.running &&
        next.heat > 0 &&
        next.water &&
        next.run > _state.run) {
      _dripTimer += dt * next.heat;
      if (_dripTimer > 0.8) {
        _dripTimer = 0;
        widget.context.feedback(UiSound.drip);
      }
    }
    if (next.end != _state.end) {
      switch (next.end) {
        case StillEnd.kept:
          widget.context.feedback(UiSound.solved);
          markSolved(widget.context.onSolved);
        case StillEnd.spoiled || StillEnd.lost:
          widget.context.feedback(UiSound.mistake);
        case StillEnd.running:
          break;
      }
    }
    setState(() => _state = next);
  }

  void _fire(int level) {
    if (isSolved) return;
    setState(() => _state = _state.setHeat(level));
    widget.context.feedback(UiSound.dial);
  }

  void _water(bool on) {
    if (isSolved) return;
    setState(() => _state = _state.setWater(on));
    widget.context.feedback(UiSound.turn);
  }

  void _glass(Cut cut) {
    if (isSolved) return;
    setState(() => _state = _state.moveGlass(cut));
    widget.context.feedback(UiSound.glassMove);
  }

  void _reset() {
    setState(() => _state = _state.reset());
    widget.context.feedback(UiSound.page);
  }

  String _status(AppLocalizations l10n) {
    switch (_state.end) {
      case StillEnd.spoiled:
        return l10n.stillSpoiled;
      case StillEnd.lost:
        return l10n.stillLost;
      case StillEnd.kept:
        return l10n.stillDripHeart;
      case StillEnd.running:
        break;
    }
    if (_state.heat == 0) return l10n.stillIdle;
    if (!_state.water) return l10n.stillDry;
    return switch (_state.dripping) {
      Cut.heads => l10n.stillDripHeads,
      Cut.heart => l10n.stillDripHeart,
      Cut.tails => l10n.stillDripTails,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final glassNames = {
      Cut.heads: l10n.stillGlassHeads,
      Cut.heart: l10n.stillGlassHeart,
      Cut.tails: l10n.stillGlassTails,
    };
    final ended = _state.end == StillEnd.spoiled || _state.end == StillEnd.lost;
    return Padding(
      padding: const EdgeInsets.fromLTRB(52, 6, 20, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: LayoutBuilder(
              builder: (context, box) {
                final size = box.biggest;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _StillPainter(
                          state: _state,
                          clock: _clock,
                          names: glassNames,
                        ),
                      ),
                    ),
                    for (final cut in Cut.values)
                      Positioned.fromRect(
                        rect: _StillPainter.glassRect(
                          size,
                          cut,
                          _state.receiver,
                        ).inflate(8),
                        child: GestureDetector(
                          key: ValueKey('still_glass_${cut.name}'),
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _glass(cut),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 190,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.stillFire,
                  style: const TextStyle(
                    fontFamily: AppTheme.smallCaps,
                    color: StillroomPalette.paper,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    for (final (level, name) in [
                      (0, l10n.stillFireOut),
                      (1, l10n.stillFireGentle),
                      (2, l10n.stillFireFierce),
                    ])
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: _Choice(
                            key: ValueKey('still_fire_$level'),
                            label: name,
                            on: _state.heat == level,
                            onTap: () => _fire(level),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.stillWater,
                  style: const TextStyle(
                    fontFamily: AppTheme.smallCaps,
                    color: StillroomPalette.paper,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    for (final (on, name) in [
                      (true, l10n.stillWaterOn),
                      (false, l10n.stillWaterOff),
                    ])
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: _Choice(
                            key: ValueKey('still_water_$on'),
                            label: name,
                            on: _state.water == on,
                            onTap: () => _water(on),
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                PuzzleLabel(
                  ended
                      ? _status(l10n)
                      : '${_status(l10n)}\n${l10n.stillInstruction}',
                  maxLines: 6,
                ),
                if (ended) ...[
                  const SizedBox(height: 4),
                  FilledButton(
                    key: const ValueKey('still_reset'),
                    onPressed: _reset,
                    child: FittedBox(child: Text(l10n.stillReset)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A small toggle button, lit when chosen.
class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.on,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? const Color(0xFF8A5A2A) : const Color(0xFF2A221C),
          border: Border.all(
            color: on ? StillroomPalette.gaslight : const Color(0xFF5A4A3A),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.serif,
                fontSize: 13,
                color: on
                    ? StillroomPalette.paper
                    : StillroomPalette.paperShade,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The colour of what comes over, by cut.
Color _cutColour(Cut cut) => switch (cut) {
  Cut.heads => const Color(0xCCD8E0E8),
  Cut.heart => const Color(0xAAE8F4FF),
  Cut.tails => const Color(0xDDC8A050),
};

class _StillPainter extends CustomPainter {
  _StillPainter({
    required this.state,
    required this.clock,
    required this.names,
  });

  final StillState state;
  final double clock;
  final Map<Cut, String> names;

  static const _copper = Color(0xFFB0683A);
  static const _copperDark = Color(0xFF6A3A1E);

  /// Where the spout drips, as a fraction of the picture.
  static const _spout = Offset(0.74, 0.6);

  /// Where a glass stands: under the spout if it is the one there,
  /// otherwise at its place along the bench.
  static Rect glassRect(Size size, Cut cut, Cut receiver) {
    final w = size.width * 0.1;
    final h = size.height * 0.2;
    if (cut == receiver) {
      return Rect.fromLTWH(
        size.width * _spout.dx - w / 2,
        size.height * 0.74,
        w,
        h,
      );
    }
    final slots = [0.12, 0.26, 0.4];
    return Rect.fromLTWH(
      size.width * slots[cut.index] - w / 2,
      size.height * 0.74,
      w,
      h,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Offset p(double x, double y) => Offset(x * w, y * h);
    // The stillroom wall and the bench.
    canvas
      ..drawRect(
        Offset.zero & size,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A221C), Color(0xFF3E3228)],
          ).createShader(Offset.zero & size),
      )
      ..drawRect(
        Rect.fromLTWH(0, h * 0.94, w, h * 0.06),
        Paint()..color = const Color(0xFF5A4030),
      );
    // The furnace: brick, its door, the fire's glow by the heat.
    final furnace = Rect.fromLTWH(w * 0.1, h * 0.48, w * 0.26, h * 0.24);
    canvas.drawRect(furnace, Paint()..color = const Color(0xFF6A3E2E));
    for (var y = furnace.top; y < furnace.bottom; y += h * 0.04) {
      canvas.drawLine(
        Offset(furnace.left, y),
        Offset(furnace.right, y),
        Paint()
          ..strokeWidth = 1
          ..color = const Color(0x553A2018),
      );
    }
    final door = Rect.fromLTWH(w * 0.18, h * 0.58, w * 0.1, h * 0.1);
    final flicker = 0.85 + 0.15 * math.sin(clock * 13);
    canvas.drawRect(
      door,
      Paint()
        ..color = switch (state.heat) {
          0 => const Color(0xFF140C08),
          1 => Color.lerp(
            const Color(0xFF8A3A10),
            const Color(0xFFE08A3A),
            flicker,
          )!,
          _ => Color.lerp(
            const Color(0xFFE08A3A),
            const Color(0xFFFFD27A),
            flicker,
          )!,
        },
    );
    if (state.heat > 0) {
      canvas.drawCircle(
        door.center,
        w * 0.08 * state.heat,
        Paint()
          ..color = const Color(0x55F2A040)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }
    // The pot and its head, the arm running to the worm tub.
    final pot = Rect.fromCenter(
      center: p(0.23, 0.42),
      width: w * 0.22,
      height: h * 0.18,
    );
    canvas
      ..drawOval(pot, Paint()..color = _copper)
      ..drawOval(
        pot.deflate(w * 0.03).shift(Offset(-w * 0.02, -h * 0.02)),
        Paint()..color = const Color(0x33FFFFFF),
      );
    final head = Path()
      ..moveTo(w * 0.19, h * 0.34)
      ..quadraticBezierTo(w * 0.23, h * 0.16, w * 0.27, h * 0.34)
      ..close();
    canvas
      ..drawPath(head, Paint()..color = _copper)
      ..drawLine(
        p(0.25, 0.22),
        p(0.56, 0.3),
        Paint()
          ..strokeWidth = w * 0.014
          ..strokeCap = StrokeCap.round
          ..color = _copperDark,
      );
    // The worm tub: a wooden cask of water, the copper coil inside.
    final tub = Rect.fromLTWH(w * 0.52, h * 0.26, w * 0.24, h * 0.36);
    canvas.drawRRect(
      RRect.fromRectAndRadius(tub, Radius.circular(w * 0.02)),
      Paint()..color = const Color(0xFF6A4A30),
    );
    for (final y in [0.32, 0.56]) {
      canvas.drawLine(
        Offset(tub.left, h * y),
        Offset(tub.right, h * y),
        Paint()
          ..strokeWidth = 3
          ..color = const Color(0xFF3A3A3A),
      );
    }
    // The water in the tub, moving while it runs.
    final water = Rect.fromLTWH(tub.left + 4, tub.top + 4, tub.width - 8, 10);
    canvas.drawRect(
      water,
      Paint()
        ..color = state.water
            ? Color.lerp(
                const Color(0xFF5A7A8A),
                const Color(0xFF7A9AAA),
                0.5 + 0.5 * math.sin(clock * 4),
              )!
            : const Color(0xFF3A3028),
    );
    // A tap at the tub's side: open while the water runs.
    canvas.drawCircle(
      p(0.78, 0.3),
      w * 0.012,
      Paint()..color = state.water ? StillroomPalette.brass : _copperDark,
    );
    // The hot worm glows when there is no water.
    if (state.heat > 0 && !state.water && state.end == StillEnd.running) {
      canvas.drawRect(
        tub.deflate(8),
        Paint()
          ..color = Color.fromRGBO(
            220,
            90,
            40,
            0.15 + 0.5 * state.hot / state.config.dry,
          ),
      );
    }
    // The spout, and the drip.
    final spout = p(_spout.dx, _spout.dy);
    canvas.drawLine(
      p(0.7, 0.58),
      spout,
      Paint()
        ..strokeWidth = w * 0.01
        ..strokeCap = StrokeCap.round
        ..color = _copperDark,
    );
    final running =
        state.end == StillEnd.running &&
        state.heat > 0 &&
        state.water &&
        state.run < state.config.total;
    if (running) {
      final period = 1.2 / state.config.rates[state.heat];
      final t = (clock % period) / period;
      final drop = Offset(spout.dx, spout.dy + t * h * 0.16);
      canvas.drawOval(
        Rect.fromCenter(center: drop, width: 6, height: 9),
        Paint()..color = _cutColour(state.dripping),
      );
    }
    // The glasses, each filled with what it caught.
    for (final cut in Cut.values) {
      final r = glassRect(size, cut, state.receiver);
      final g = state.glasses[cut.index];
      final full = (g.total / (state.config.total * 0.75)).clamp(0.0, 1.0);
      final level = r.height * 0.85 * full;
      if (g.total > 0) {
        final mix = g.heads >= g.heart && g.heads >= g.tails
            ? Cut.heads
            : (g.heart >= g.tails ? Cut.heart : Cut.tails);
        canvas.drawRect(
          Rect.fromLTRB(
            r.left + 3,
            r.bottom - 3 - level,
            r.right - 3,
            r.bottom - 3,
          ),
          Paint()..color = _cutColour(mix),
        );
      }
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          r,
          bottomLeft: const Radius.circular(6),
          bottomRight: const Radius.circular(6),
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = cut == state.receiver ? 2.5 : 1.5
          ..color = cut == state.receiver
              ? StillroomPalette.gaslight
              : const Color(0xCCB8C4CC),
      );
      final label = TextPainter(
        text: TextSpan(
          text: names[cut],
          style: const TextStyle(
            fontFamily: AppTheme.smallCaps,
            fontSize: 11,
            color: StillroomPalette.paper,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: r.width + 30);
      label.paint(
        canvas,
        Offset(r.center.dx - label.width / 2, r.top - label.height - 2),
      );
    }
  }

  @override
  bool shouldRepaint(_StillPainter old) => true;
}
