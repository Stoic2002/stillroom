import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// Steps cut down the cliff to the sea, and the sea coming up them wave by
/// wave. Tap to go down a step. Before a wave breaks the water draws back,
/// further before a bigger one; before a great sea it draws right back with
/// a rising roar. The cues are seen, heard and felt, so the puzzle plays
/// with the sound off.
class SwellView extends StatefulWidget {
  const SwellView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<SwellView> createState() => _SwellViewState();
}

class _SwellViewState extends State<SwellView>
    with SingleTickerProviderStateMixin, SolvesAfterPause<SwellView> {
  late final _config = widget.context.puzzle.config as SwellConfig;
  late SwellState _state = _config.start();
  final _clock = ValueNotifier<double>(0);
  late final Ticker _ticker;

  /// Where the lantern is drawn, easing towards the step it is on.
  double _shown = 0;
  double? _caughtAt;
  int _cuedGreat = -1;

  /// How long before a great sea breaks its roar starts (the sound's crash
  /// is this far in).
  static const _roarLead = 1.2;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clock.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    final now = elapsed.inMicroseconds / 1e6;
    final dt = now - _clock.value;
    _clock.value = now;
    _shown += (_state.position - _shown) * math.min(1, dt * 10);
    if (isSolved) return;
    // The roar of a great sea, as the water starts to draw back.
    final next = _config.nextWave(now);
    if (_config.isGreat(next) &&
        next != _cuedGreat &&
        _config.breakTime(next) - now <= _roarLead) {
      _cuedGreat = next;
      widget.context.feedback(UiSound.greatSea);
    }
    final advanced = _state.advance(now);
    if (advanced.waves != _state.waves) {
      final broke = advanced.lastBreak!;
      if (!_config.isGreat(broke.index)) widget.context.feedback(UiSound.wave);
      if (advanced.caught != _state.caught) {
        _caughtAt = now;
        widget.context.feedback(UiSound.mistake);
      }
    }
    if (!identical(advanced, _state)) setState(() => _state = advanced);
  }

  void _step() {
    if (isSolved) return;
    final next = _state.stepDown(_clock.value);
    if (next.position == _state.position) return;
    setState(() => _state = next);
    widget.context.feedback(UiSound.step);
    if (next.isSolved) {
      widget.context.feedback(UiSound.solved);
      markSolved(widget.context.onSolved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final caught =
        _caughtAt != null && _clock.value - _caughtAt! < 2.5 && !isSolved;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _step(),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              key: const ValueKey('swell'),
              painter: _SwellPainter(_config, _clock, lantern: () => _shown),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: PuzzleLabel(
                  caught ? l10n.swellCaught : l10n.swellInstruction,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The steps, the sea at its level of the moment, spray where a wave has
/// just broken, and the lantern on the step the player is on.
class _SwellPainter extends CustomPainter {
  _SwellPainter(this.config, this.clock, {required this.lantern})
    : super(repaint: clock);

  final SwellConfig config;
  final ValueNotifier<double> clock;
  final double Function() lantern;

  double get _dy => 0.45 / config.steps;
  double get _dx => 0.5 / config.steps;
  double _stepTop(double i) => 0.3 + i * _dy;
  double _stepLeft(double i) => 0.2 + i * _dx;
  double get _seaY => _stepTop(config.steps + 1.0) - 0.01;

  /// The water's level at [t], in steps from the bottom: above 0 while a
  /// wave runs up the steps, below 0 while the sea draws back before one.
  double level(double t) {
    final next = config.nextWave(t);
    final breakAt = config.breakTime(next);
    final since = t - (breakAt - config.interval);
    final lastReach = next > 0 ? config.reach(next - 1) : 0;
    final surge = config.interval * 0.35;
    if (since < surge && next > 0) {
      final k = 1 - since / surge;
      return lastReach * k * k;
    }
    final great = config.isGreat(next);
    final lead = great ? 1.2 : config.interval * 0.35;
    final until = breakAt - t;
    final bob = math.sin(t * 2.3) * 0.08;
    if (until < lead) {
      final depth = 0.25 + config.reach(next) / config.steps * 1.3;
      return -depth * (1 - until / lead) + bob;
    }
    return bob;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final t = clock.value;
    Offset p(double x, double y) => Offset(x * size.width, y * size.height);
    const stone = Color(0xFF4F5456);
    const stoneTop = Color(0xFF7A8084);

    // The steps, from the top landing down to the lowest.
    for (var i = 0; i <= config.steps; i++) {
      final left = i == 0 ? 0.02 : _stepLeft(i.toDouble());
      final right = _stepLeft(i.toDouble()) + _dx + 0.06;
      final top = _stepTop(i.toDouble());
      final face = Rect.fromPoints(p(left, top), p(right, top + _dy));
      canvas
        ..drawRect(face, Paint()..color = stone)
        ..drawRect(
          Rect.fromPoints(p(left, top), p(right, top + 0.012)),
          Paint()..color = stoneTop,
        )
        ..drawRect(
          face,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2
            ..color = const Color(0xFF15191C),
        );
    }

    // The sea.
    final l = level(t);
    final surface = _seaY - l * _dy;
    final water = Path()..moveTo(0, surface * size.height);
    for (var i = 0; i <= 24; i++) {
      final x = i / 24;
      water.lineTo(
        x * size.width,
        (surface + math.sin(x * 18 + t * 3) * 0.006) * size.height,
      );
    }
    water
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      water,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xE0253842), Color(0xFF0C1418)],
        ).createShader(Offset.zero & size),
    );
    // Foam along the edge, heavier while a wave runs up.
    canvas.drawPath(
      Path()..addPolygon([
        for (var i = 0; i <= 24; i++)
          p(i / 24, surface + math.sin(i / 24 * 18 + t * 3) * 0.006),
      ], false),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.height * (l > 0.5 ? 0.012 : 0.005)
        ..color = const Color(0xCCD8E2E4),
    );
    // Spray thrown up where a wave has just broken.
    final next = config.nextWave(t);
    final since = t - (config.breakTime(next) - config.interval);
    if (next > 0 && since < 0.6) {
      final reach = config.reach(next - 1);
      final random = math.Random(next);
      final k = since / 0.6;
      for (var i = 0; i < 10 + reach * 8; i++) {
        final x = random.nextDouble();
        final rise = random.nextDouble() * reach * _dy * 1.4;
        canvas.drawCircle(
          p(x, surface - rise * math.sin(k * math.pi)),
          size.shortestSide * (0.006 + random.nextDouble() * 0.01),
          Paint()..color = Color.fromRGBO(226, 234, 236, 0.8 * (1 - k)),
        );
      }
    }

    // The lantern: the player, on their step.
    final at = lantern();
    final lx = at < 0.5 ? 0.12 : _stepLeft(at) + _dx / 2 + 0.03;
    final c = p(lx, _stepTop(at) - 0.05);
    canvas
      ..drawCircle(
        c,
        size.shortestSide * 0.08,
        Paint()
          ..color = const Color(0x55F1C66A)
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            size.shortestSide * 0.05,
          ),
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: c,
            width: size.shortestSide * 0.035,
            height: size.shortestSide * 0.05,
          ),
          Radius.circular(size.shortestSide * 0.006),
        ),
        Paint()..color = StillroomPalette.gaslight,
      );
  }

  @override
  bool shouldRepaint(_SwellPainter old) => old.config != config;
}
