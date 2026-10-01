import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// Tanks cut into the rock, dark to the brim, and a reed. Drag the reed
/// down into a tank until it meets the surface, let go, and watch how it
/// drips as it is drawn out; then name what is in the tank. Once every
/// tank is named, say whether the stores were running low or full.
class DipView extends StatefulWidget {
  const DipView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<DipView> createState() => _DipViewState();
}

enum _Note { none, wrong, storesWrong }

class _DipViewState extends State<DipView>
    with SolvesAfterPause<DipView>, SingleTickerProviderStateMixin {
  late final _config = widget.context.puzzle.config as DipConfig;
  late DipState _state = _config.start();
  late final Ticker _ticker;

  /// The tank the reed is in, while it is being lowered.
  int? _lowering;

  /// How deep the reed's tip is in [_lowering], from 0 (rim) to 1 (floor).
  double _tip = 0;
  bool _touched = false;

  /// The tank last dipped: its reed drips above it.
  int? _dripping;
  double _dripTime = 0;
  int _drops = 0;
  _Note _note = _Note.none;

  /// How long the reed drips after it is drawn out.
  static const _dripFor = 6.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Duration _last = Duration.zero;

  void _tick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    final t = _dripping;
    if (t == null || _dripTime >= _dripFor) {
      _ticker.stop();
      return;
    }
    setState(() => _dripTime += dt);
    final style = _Drip.of(_config.tanks[t].liquid);
    final drops = (_dripTime / style.period).floor();
    if (drops > _drops) {
      _drops = drops;
      widget.context.feedback(style.slow ? UiSound.dripSlow : UiSound.drip);
    }
  }

  /// The surface of tank [t], as a depth from 0 (rim) to 1 (floor).
  double _surface(int t) => 1 - _config.tanks[t].level;

  void _lower(int t, double depth) {
    if (isSolved || _state.allNamed) return;
    final surface = _surface(t);
    final next = depth.clamp(0.0, 1.0);
    setState(() {
      if (_lowering != t) {
        _lowering = t;
        _touched = false;
      }
      // Past the surface the reed goes on only a little, heavily.
      _tip = next <= surface ? next : surface + (next - surface) * 0.08;
    });
    if (!_touched && next >= surface) {
      _touched = true;
      widget.context.feedback(UiSound.reedTouch);
    }
  }

  void _release() {
    final t = _lowering;
    if (t == null) return;
    final touched = _touched;
    setState(() {
      _lowering = null;
      _tip = 0;
      _touched = false;
      if (touched) {
        _state = _state.dip(t);
        _dripping = t;
        _dripTime = 0;
        _drops = 0;
        _note = _Note.none;
      }
    });
    if (touched) {
      _last = Duration.zero;
      _ticker
        ..stop()
        ..start();
    }
  }

  void _name(DipLiquid liquid) {
    final t = _dripping;
    if (isSolved || t == null) return;
    final next = _state.name(t, liquid);
    final right = next.named.containsKey(t);
    setState(() {
      _state = next;
      _note = right ? _Note.none : _Note.wrong;
    });
    widget.context.feedback(right ? UiSound.note : UiSound.mistake);
  }

  void _judge({required bool full}) {
    if (isSolved) return;
    final next = _state.judge(full: full);
    setState(() {
      _state = next;
      _note = next.isSolved ? _Note.none : _Note.storesWrong;
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
    final dripping = _dripping;
    final naming =
        dripping != null &&
        !_state.named.containsKey(dripping) &&
        !_state.allNamed;
    final status = switch (_note) {
      _Note.wrong => l10n.dipWrong,
      _Note.storesWrong => l10n.dipStoresWrong,
      _Note.none when _state.allNamed => l10n.dipStoresQuestion,
      _Note.none when naming => l10n.dipWhat,
      _Note.none => l10n.dipInstruction,
    };
    String nameOf(DipLiquid liquid) => widget.context.text(
      context,
      _config.names.firstWhere((n) => n.liquid == liquid).labelKey,
    );
    const small = TextStyle(
      fontFamily: AppTheme.smallCaps,
      fontSize: 14,
      color: StillroomPalette.paperShade,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(48, 8, 48, 6),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                for (var t = 0; t < _config.tanks.length; t++)
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, box) => GestureDetector(
                              key: ValueKey('dip_tank_$t'),
                              behavior: HitTestBehavior.opaque,
                              onPanDown: (d) =>
                                  _lower(t, _depth(d.localPosition, box)),
                              onPanStart: (d) =>
                                  _lower(t, _depth(d.localPosition, box)),
                              onPanUpdate: (d) =>
                                  _lower(t, _depth(d.localPosition, box)),
                              onPanEnd: (_) => _release(),
                              onPanCancel: _release,
                              child: CustomPaint(
                                size: Size.infinite,
                                painter: _TankPainter(
                                  liquid: _config.tanks[t].liquid,
                                  level: _config.tanks[t].level,
                                  dipped: _state.dipped.contains(t),
                                  tip: _lowering == t ? _tip : null,
                                  drip: dripping == t ? _dripTime : null,
                                  chosen: dripping == t,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 22,
                          child: Text(
                            switch (_state.named[t]) {
                              final DipLiquid liquid => nameOf(liquid),
                              null when _state.dipped.contains(t) =>
                                l10n.dipLevel(
                                  (_config.tanks[t].level * 100).round(),
                                ),
                              null => '',
                            },
                            key: ValueKey('dip_label_$t'),
                            style: small,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: _state.allNamed
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.tonal(
                        key: const ValueKey('dip_low'),
                        onPressed: isSolved ? null : () => _judge(full: false),
                        child: Text(l10n.dipLow),
                      ),
                      const SizedBox(width: 16),
                      FilledButton.tonal(
                        key: const ValueKey('dip_full'),
                        onPressed: isSolved ? null : () => _judge(full: true),
                        child: Text(l10n.dipFull),
                      ),
                    ],
                  )
                : naming
                ? Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: [
                      for (final n in _config.names)
                        OutlinedButton(
                          key: ValueKey('dip_name_${n.liquid.name}'),
                          onPressed: () => _name(n.liquid),
                          child: Text(nameOf(n.liquid)),
                        ),
                    ],
                  )
                : null,
          ),
          const SizedBox(height: 2),
          PuzzleLabel(status),
        ],
      ),
    );
  }

  /// The depth a drag at [local] reaches in a tank drawn in [box].
  static double _depth(Offset local, BoxConstraints box) =>
      (local.dy - box.maxHeight * _TankPainter.rim) /
      (box.maxHeight * (_TankPainter.floor - _TankPainter.rim));
}

/// How each liquid drips from the reed: its colour, how thick, how often.
final class _Drip {
  const _Drip(this.color, {required this.period, this.slow = false});

  factory _Drip.of(DipLiquid liquid) => switch (liquid) {
    DipLiquid.water => const _Drip(Color(0xAAD8E6EA), period: 0.45),
    DipLiquid.vinegar => const _Drip(Color(0xC8D8B870), period: 0.38),
    DipLiquid.wine => const _Drip(Color(0xF05A0E1A), period: 0.7),
    DipLiquid.honey => const _Drip(Color(0xF0D8961E), period: 2.6, slow: true),
    DipLiquid.milk => const _Drip(Color(0xF4F2EEE4), period: 0.8),
    DipLiquid.oil => const _Drip(Color(0xE0B8A838), period: 1.6, slow: true),
  };

  final Color color;

  /// Seconds between drops.
  final double period;

  /// A thick liquid: it stretches into a thread before a drop falls.
  final bool slow;
}

/// One tank seen in section: the rock round a dark shaft, its wooden cover
/// slid aside, the reed lowered into it or held dripping above it.
class _TankPainter extends CustomPainter {
  const _TankPainter({
    required this.liquid,
    required this.level,
    required this.dipped,
    required this.tip,
    required this.drip,
    required this.chosen,
  });

  /// The shaft's rim and floor, as shares of the height.
  static const rim = 0.3;
  static const floor = 0.96;

  final DipLiquid liquid;
  final double level;
  final bool dipped;

  /// The reed's depth while lowered, from 0 (rim) to 1 (floor).
  final double? tip;

  /// Seconds the reed has been dripping, while it is.
  final double? drip;
  final bool chosen;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final shaft = Rect.fromLTRB(w * 0.24, h * rim, w * 0.76, h * floor);
    final style = _Drip.of(liquid);
    // The rock face and the dark shaft cut into it.
    canvas
      ..drawRect(
        Rect.fromLTRB(w * 0.12, h * (rim - 0.04), w * 0.88, h),
        Paint()..color = const Color(0xFF6E5E4C),
      )
      ..drawRect(shaft, Paint()..color = const Color(0xFF0C0907));
    for (var i = 1; i < 6; i++) {
      final y = shaft.top + shaft.height * i / 6;
      canvas.drawLine(
        Offset(w * 0.12, y),
        Offset(shaft.left, y),
        Paint()
          ..color = const Color(0x553A3026)
          ..strokeWidth = 1,
      );
    }
    final surface = shaft.top + shaft.height * (1 - level);
    // Once dipped, the lamp finds the surface: a faint glint.
    if (dipped) {
      canvas
        ..drawRect(
          Rect.fromLTRB(shaft.left, surface, shaft.right, shaft.bottom),
          Paint()..color = style.color.withValues(alpha: 0.18),
        )
        ..drawLine(
          Offset(shaft.left, surface),
          Offset(shaft.right, surface),
          Paint()
            ..color = style.color.withValues(alpha: 0.7)
            ..strokeWidth = 1.5,
        );
    }
    // The cover, slid aside once the tank has been opened.
    final cover = dipped || tip != null
        ? Rect.fromLTWH(w * 0.58, h * (rim - 0.1), w * 0.4, h * 0.06)
        : Rect.fromLTWH(w * 0.2, h * (rim - 0.06), w * 0.6, h * 0.06);
    canvas.drawRect(cover, Paint()..color = const Color(0xFF5A3E26));
    for (var i = 1; i < 4; i++) {
      final x = cover.left + cover.width * i / 4;
      canvas.drawLine(
        Offset(x, cover.top),
        Offset(x, cover.bottom),
        Paint()
          ..color = const Color(0xFF3A2816)
          ..strokeWidth = 1,
      );
    }
    if (chosen) {
      canvas.drawRect(
        shaft.inflate(3),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = StillroomPalette.gaslight.withValues(alpha: 0.7),
      );
    }

    // The reed: lowered into the shaft, or held above it, dripping.
    final reedX = w * 0.5;
    final reed = Paint()
      ..color = const Color(0xFFB8A86C)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final lowered = tip;
    final dripping = drip;
    if (lowered != null) {
      final end = shaft.top + shaft.height * lowered;
      canvas.drawLine(Offset(reedX, 0), Offset(reedX, end), reed);
      if (end > surface) {
        canvas.drawLine(
          Offset(reedX, surface),
          Offset(reedX, end),
          reed..color = const Color(0xFF14100C),
        );
      }
    } else if (dripping != null) {
      final end = h * (rim - 0.12);
      final wet = end - shaft.height * (1 - level) * 0.25;
      canvas
        ..drawLine(Offset(reedX, 0), Offset(reedX, end), reed)
        ..drawLine(
          Offset(reedX, wet),
          Offset(reedX, end),
          Paint()
            ..color = style.color
            ..strokeWidth = 5
            ..strokeCap = StrokeCap.round,
        );
      _drops(canvas, Offset(reedX, end), surface, dripping, style);
    }
  }

  /// Drops falling from the reed's tip at [from] to the [surface] below.
  void _drops(
    Canvas canvas,
    Offset from,
    double surface,
    double time,
    _Drip style,
  ) {
    final paint = Paint()..color = style.color;
    final fall = surface - from.dy;
    final phase = (time % style.period) / style.period;
    if (style.slow) {
      // A thread stretches from the tip, thins, and lets one drop go.
      final stretch = math.min(1.0, phase / 0.75);
      final thread = fall * 0.45 * stretch;
      canvas.drawLine(
        from,
        from.translate(0, thread),
        Paint()
          ..color = style.color
          ..strokeWidth = 3.2 * (1 - stretch * 0.6)
          ..strokeCap = StrokeCap.round,
      );
      final blob = from.translate(0, thread);
      if (phase < 0.75) {
        canvas.drawCircle(blob, 3.5 + stretch * 1.5, paint);
      } else {
        final t = (phase - 0.75) / 0.25;
        canvas.drawCircle(
          blob.translate(0, (fall - thread) * t * t),
          4.5,
          paint,
        );
      }
      return;
    }
    // Quick drops, one after another, falling faster as they go.
    for (var k = 0; k < 3; k++) {
      final t = phase + k / 3;
      final p = t - t.floor();
      canvas.drawOval(
        Rect.fromCenter(
          center: from.translate(0, fall * p * p),
          width: 4,
          height: 5 + p * 3,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_TankPainter old) =>
      old.tip != tip ||
      old.drip != drip ||
      old.dipped != dipped ||
      old.chosen != chosen;
}
