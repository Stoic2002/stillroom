import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/content_strings.dart';
import '../../core/audio/ui_sound.dart';
import '../../core/theme/stillroom_palette.dart';
import '../../core/widgets/content_image.dart';
import '../../core/widgets/marked_text.dart';
import '../../debug/debug_settings.dart';
import '../../engine/engine.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/game_session.dart';
import '../../state/ui_feedback.dart';

/// Close-up view of an item (PRD FR-03): a square image with its own layers
/// and hotspots, plus the item's name and description. Tapping outside the
/// image closes it.
class ExamineOverlay extends ConsumerWidget {
  const ExamineOverlay({required this.episodeId, super.key});

  final String episodeId;

  /// Minimum tap area on the physical screen (NFR-05).
  static const minTapSizeDp = 44.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = gameSessionProvider(episodeId);
    final session = ref.watch(provider).value;
    final itemId = session?.examinedItem;
    if (session == null || itemId == null) return const SizedBox.shrink();

    final notifier = ref.read(provider.notifier);
    void close() {
      ref.read(uiFeedbackProvider)(UiSound.close);
      notifier.closeExamine();
    }

    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final engine = session.engine;
    final item = engine.content.requireItem(itemId);
    final assets = session.episode.assets;
    final showOutlines = kDebugMode && ref.watch(showHotspotsProvider);

    return Material(
      color: StillroomPalette.ink.withValues(alpha: 0.92),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: close,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final landscape = constraints.maxWidth >= constraints.maxHeight;
            final side = landscape
                ? math.min(
                    constraints.maxHeight * 0.8,
                    constraints.maxWidth * 0.5,
                  )
                : math.min(
                    constraints.maxWidth * 0.85,
                    constraints.maxHeight * 0.55,
                  );
            final minTap = minTapSizeDp / side;

            final image = DecoratedBox(
              // A walnut frame with brass trim, like a specimen case.
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                border: Border.all(color: StillroomPalette.brass, width: 1.2),
                boxShadow: const [
                  BoxShadow(color: Color(0xAA000000), blurRadius: 24),
                ],
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) => notifier.tapExamine(
                  details.localPosition.dx / side,
                  details.localPosition.dy / side,
                  minWidth: minTap,
                  minHeight: minTap,
                ),
                child: SizedBox.square(
                  dimension: side,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ContentImage(
                        path: item.examine?.image ?? item.icon,
                        label: item.id,
                        assets: assets,
                      ),
                      for (final layer in engine.visibleExamineLayers(
                        session.game,
                        itemId,
                      ))
                        Positioned(
                          left: layer.rect.x * side,
                          top: layer.rect.y * side,
                          width: layer.rect.width * side,
                          height: layer.rect.height * side,
                          child: ContentImage(
                            path: layer.image,
                            label: layer.id,
                            assets: assets,
                          ),
                        ),
                      if (showOutlines)
                        CustomPaint(
                          painter: _OutlinePainter(
                            engine.visibleExamineHotspots(session.game, itemId),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );

            final text = SizedBox(
              width: landscape
                  ? math.max(
                      120,
                      math.min(320, constraints.maxWidth - side - 72),
                    )
                  : side,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contentText(
                      session.episode.strings,
                      language,
                      item.nameKey,
                    ),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  MarkedText(
                    contentText(
                      session.episode.strings,
                      language,
                      item.descKey,
                    ),
                    labelOf: (id) => session.wordLabel(language, id),
                    isNoted: session.game.words.contains,
                    onWord: notifier.noteWord,
                    notedColor: StillroomPalette.gaslight,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );

            return Stack(
              children: [
                Center(
                  child: Flex(
                    direction: landscape ? Axis.horizontal : Axis.vertical,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      image,
                      const SizedBox.square(dimension: 24),
                      text,
                    ],
                  ),
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      tooltip: l10n.closeExamine,
                      icon: const Icon(Icons.close),
                      onPressed: close,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OutlinePainter extends CustomPainter {
  _OutlinePainter(this.hotspots);

  final List<Hotspot> hotspots;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF4CFF7A);
    for (final h in hotspots) {
      canvas.drawRect(
        Rect.fromLTWH(
          h.rect.x * size.width,
          h.rect.y * size.height,
          h.rect.width * size.width,
          h.rect.height * size.height,
        ),
        stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_OutlinePainter old) => old.hotspots != hotspots;
}
