import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../content/content_strings.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../state/game_session.dart';
import '../../../state/hint_candle.dart';

/// Hint button (PRD FR-08). Shown while hints are on offer: the open
/// puzzle's, otherwise the current episode stage's. It sits above puzzle
/// screens, so one button serves both.
///
/// Hints are paced by a candle ([HintCandle]): while this button is on
/// screen and the app is in the foreground, the candle of the current hint
/// group burns; the next hint can be read once its flame is full.
class HintButton extends ConsumerStatefulWidget {
  const HintButton({required this.episodeId, super.key});

  final String episodeId;

  static const tick = Duration(seconds: 1);

  @override
  ConsumerState<HintButton> createState() => _HintButtonState();
}

class _HintButtonState extends ConsumerState<HintButton> {
  late final Timer _timer;
  late final AppLifecycleListener _lifecycle;
  var _active = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(HintButton.tick, (_) => _burn());
    _lifecycle = AppLifecycleListener(
      onStateChange: (s) => _active = s == AppLifecycleState.resumed,
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  void _burn() {
    if (!_active) return;
    final session = ref.read(gameSessionProvider(widget.episodeId)).value;
    if (session == null || session.game.completed) return;
    final group = session.engine.hintGroup(
      session.game,
      puzzleId: session.openPuzzle,
    );
    if (group == null || !group.canRevealMore) return;
    ref
        .read(hintCandleProvider(widget.episodeId).notifier)
        .burn(group.key, HintButton.tick);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameSessionProvider(widget.episodeId)).value;
    ref.watch(hintCandleProvider(widget.episodeId));
    if (session == null ||
        session.game.completed ||
        session.currentText != null) {
      return const SizedBox.shrink();
    }
    final group = session.engine.hintGroup(
      session.game,
      puzzleId: session.openPuzzle,
    );
    if (group == null) return const SizedBox.shrink();
    final progress = group.canRevealMore
        ? ref
              .read(hintCandleProvider(widget.episodeId).notifier)
              .progress(group)
        : 0.0;

    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: IconButton(
          tooltip: AppLocalizations.of(context).hintButton,
          icon: CandleIcon(progress: progress),
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => HintDialog(episodeId: widget.episodeId),
          ),
        ),
      ),
    );
  }
}

/// A small candle whose flame grows as the next hint's candle burns, and
/// glows once the hint is ready.
class CandleIcon extends StatelessWidget {
  const CandleIcon({required this.progress, super.key});

  /// 0 to 1; 1 means a hint is ready.
  final double progress;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 28,
    child: CustomPaint(painter: _CandlePainter(progress)),
  );
}

class _CandlePainter extends CustomPainter {
  _CandlePainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final lit = progress >= 1;
    final cx = w / 2;

    // Progress ring: a thin brass arc around the candle.
    final ring = Rect.fromCircle(center: Offset(cx, h / 2), radius: w / 2 - 1);
    canvas.drawArc(
      ring,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = StillroomPalette.brass.withValues(alpha: lit ? 0.0 : 0.55),
    );

    if (lit) {
      canvas.drawCircle(
        Offset(cx, h * 0.34),
        w * 0.42,
        Paint()
          ..shader =
              RadialGradient(
                colors: [
                  StillroomPalette.gaslight.withValues(alpha: 0.45),
                  StillroomPalette.gaslight.withValues(alpha: 0),
                ],
              ).createShader(
                Rect.fromCircle(center: Offset(cx, h * 0.34), radius: w * 0.42),
              ),
      );
    }

    // Wax and wick.
    final wax = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - w * 0.12, h * 0.46, w * 0.24, h * 0.4),
      const Radius.circular(1.5),
    );
    canvas
      ..drawRRect(wax, Paint()..color = StillroomPalette.paperShade)
      ..drawLine(
        Offset(cx, h * 0.46),
        Offset(cx, h * 0.39),
        Paint()
          ..color = StillroomPalette.ink
          ..strokeWidth = 1.2,
      );

    // Flame: an ember that grows into a full flame.
    final f = Curves.easeIn.transform(progress.clamp(0.0, 1.0));
    if (f <= 0.02) return;
    final fh = h * (0.08 + 0.26 * f);
    final fw = w * (0.06 + 0.1 * f);
    final base = Offset(cx, h * 0.4);
    final flame = Path()
      ..moveTo(base.dx, base.dy - fh)
      ..quadraticBezierTo(base.dx + fw, base.dy - fh * 0.35, base.dx, base.dy)
      ..quadraticBezierTo(
        base.dx - fw,
        base.dy - fh * 0.35,
        base.dx,
        base.dy - fh,
      );
    canvas.drawPath(
      flame,
      Paint()
        ..color = Color.lerp(
          StillroomPalette.oxbloodBright,
          StillroomPalette.gaslight,
          f,
        )!.withValues(alpha: 0.5 + 0.5 * f),
    );
  }

  @override
  bool shouldRepaint(_CandlePainter old) => old.progress != progress;
}

/// Lists the hints revealed so far and reveals the next one once its
/// candle has burned down.
class HintDialog extends ConsumerWidget {
  const HintDialog({required this.episodeId, super.key});

  final String episodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final provider = gameSessionProvider(episodeId);
    final session = ref.watch(provider).value;
    ref.watch(hintCandleProvider(episodeId));
    final group = session?.engine.hintGroup(
      session.game,
      puzzleId: session.openPuzzle,
    );
    final canRevealMore = group?.canRevealMore ?? false;
    final progress = canRevealMore
        ? ref.read(hintCandleProvider(episodeId).notifier).progress(group!)
        : 0.0;
    final lit = progress >= 1;

    final shown = group?.shown ?? const [];
    final String? footer;
    if (group == null) {
      footer = l10n.hintNoneAvailable;
    } else if (!canRevealMore) {
      footer = l10n.hintAllShown;
    } else if (!lit) {
      footer = l10n.hintKindling;
    } else {
      footer = null;
    }

    return AlertDialog(
      title: Text(l10n.hintTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, hint) in shown.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '${i + 1}. ${contentText(session!.episode.strings, language, hint.textKey)}',
                ),
              ),
            if (footer != null)
              Text(footer, style: Theme.of(context).textTheme.bodySmall),
            if (canRevealMore && !lit)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    CandleIcon(progress: progress),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 2,
                        color: StillroomPalette.gaslight,
                        backgroundColor: StillroomPalette.walnut,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionClose),
        ),
        if (canRevealMore)
          FilledButton(
            onPressed: lit
                ? () => ref.read(provider.notifier).revealNextHint()
                : null,
            child: Text(l10n.hintRevealNext),
          ),
      ],
    );
  }
}
