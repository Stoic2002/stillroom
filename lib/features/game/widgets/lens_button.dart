import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../content/content_strings.dart';
import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../state/game_session.dart';
import '../../../state/ui_feedback.dart';
import '../flame/stillroom_game.dart';

/// Raises and lowers the lens between eras (scene `lens`). Shown only where
/// the current scene has a lens the player can use; it pulses until the
/// player has tried it once. Where the lens looks at different hours
/// (`lensHours`), a brass tag beside it names the hour; tapping it turns the
/// lens on to the next.
class LensButton extends ConsumerStatefulWidget {
  const LensButton({required this.episodeId, required this.game, super.key});

  final String episodeId;
  final StillroomGame game;

  @override
  ConsumerState<LensButton> createState() => _LensButtonState();
}

class _LensButtonState extends ConsumerState<LensButton>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  var _tried = false;

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _toggle() {
    ref.read(uiFeedbackProvider)(UiSound.lens);
    setState(() {
      _tried = true;
      widget.game.lensUp = !widget.game.lensUp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameSessionProvider(widget.episodeId)).value;
    final available =
        session != null &&
        !session.game.completed &&
        session.openPuzzle == null &&
        session.engine.lens(session.game) != null;
    if (!available) {
      _pulse.stop();
      return const SizedBox.shrink();
    }
    if (!_tried && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (_tried && _pulse.isAnimating) {
      _pulse
        ..stop()
        ..value = 0;
    }
    final l10n = AppLocalizations.of(context);
    final up = widget.game.lensUp;
    final engine = session.engine;
    final hours = engine.content.config.lensHours;
    final turns =
        up &&
        hours != null &&
        (engine.currentScene(session.game).lens?.turnsWithHours ?? false);
    final hourLabel = hours == null
        ? ''
        : contentText(
            session.episode.strings,
            Localizations.localeOf(context).languageCode,
            hours.labels[engine.lensHour(session.game)],
          );
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _lensIcon(l10n, up),
            if (turns) _HourTag(label: hourLabel, onTap: _turnHour),
          ],
        ),
      ),
    );
  }

  void _turnHour() {
    ref.read(uiFeedbackProvider)(UiSound.turn);
    ref.read(gameSessionProvider(widget.episodeId).notifier).turnLensHour();
  }

  Widget _lensIcon(AppLocalizations l10n, bool up) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) => IconButton(
        key: const ValueKey('lens_button'),
        tooltip: up ? l10n.lensLower : l10n.lensRaise,
        iconSize: 40,
        onPressed: _toggle,
        icon: SizedBox.square(
          dimension: 40,
          child: CustomPaint(
            painter: _LensIconPainter(up: up, pulse: _pulse.value),
          ),
        ),
      ),
    );
  }
}

/// A brass tag naming the hour the lens looks at; tap to turn it on.
class _HourTag extends StatelessWidget {
  const _HourTag({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        key: const ValueKey('lens_hour'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xCC1B1510),
            border: Border.all(color: StillroomPalette.brass),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wb_twilight,
                size: 18,
                color: StillroomPalette.brass,
              ),
              const SizedBox(width: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  label,
                  key: ValueKey(label),
                  style: const TextStyle(
                    fontFamily: AppTheme.serif,
                    fontSize: 15,
                    color: StillroomPalette.paper,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LensIconPainter extends CustomPainter {
  _LensIconPainter({required this.up, required this.pulse});

  final bool up;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide * 0.36;
    if (up || pulse > 0) {
      final glow = up ? 0.45 : 0.35 * pulse;
      canvas.drawCircle(
        c,
        r * 1.5,
        Paint()
          ..shader = RadialGradient(
            colors: [
              StillroomPalette.gaslight.withValues(alpha: glow),
              StillroomPalette.gaslight.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: r * 1.5)),
      );
    }
    canvas
      ..drawCircle(
        c,
        r,
        Paint()..color = up ? const Color(0x55F2D9A0) : const Color(0x33101820),
      )
      ..drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.shortestSide * 0.08
          ..color = StillroomPalette.brass,
      )
      ..drawArc(
        Rect.fromCircle(center: c, radius: r * 0.7),
        -math.pi * 0.85,
        0.9,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.shortestSide * 0.045
          ..strokeCap = StrokeCap.round
          ..color = const Color(0x99FFF6DC),
      );
    // The handle.
    const a = math.pi * 0.25;
    canvas.drawLine(
      c + Offset(math.cos(a), math.sin(a)) * r * 1.05,
      c + Offset(math.cos(a), math.sin(a)) * r * 1.55,
      Paint()
        ..strokeWidth = size.shortestSide * 0.1
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF5A3A26),
    );
  }

  @override
  bool shouldRepaint(_LensIconPainter old) =>
      old.up != up || old.pulse != pulse;
}
