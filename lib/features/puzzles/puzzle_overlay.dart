import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/ui_sound.dart';
import '../../core/theme/stillroom_palette.dart';
import '../../core/widgets/atmosphere.dart';
import '../../core/widgets/content_image.dart';
import '../../core/widgets/scene_frame.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/game_session.dart';
import '../../state/ui_feedback.dart';
import 'puzzle_view.dart';

/// Full-screen puzzle (PRD FR-04), opened by the `openPuzzle` action. The
/// board has the scene's aspect ratio; the widget for the puzzle's type
/// comes from [widgets].
class PuzzleOverlay extends ConsumerWidget {
  const PuzzleOverlay({
    required this.episodeId,
    required this.widgets,
    super.key,
  });

  final String episodeId;
  final PuzzleWidgetRegistry widgets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = gameSessionProvider(episodeId);
    final session = ref.watch(provider).value;
    final puzzleId = session?.openPuzzle;
    if (session == null || puzzleId == null) return const SizedBox.shrink();

    final notifier = ref.read(provider.notifier);
    final content = session.engine.content;
    final puzzle = content.requirePuzzle(puzzleId);
    final builder = widgets[puzzle.type];
    final config = content.config;

    return Material(
      color: StillroomPalette.ink,
      child: Stack(
        fit: StackFit.expand,
        children: [
          SceneFrame(
            logicalWidth: config.logicalWidth,
            logicalHeight: config.logicalHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Atmosphere(
                  child: ContentImage(
                    path: puzzle.background ?? '',
                    label: puzzle.id,
                    assets: session.episode.assets,
                    background: true,
                  ),
                ),
                if (builder != null)
                  // Keyed by puzzle id: every opening starts fresh.
                  KeyedSubtree(
                    key: ValueKey(puzzleId),
                    child: builder(
                      PuzzleViewContext(
                        puzzle: puzzle,
                        content: content,
                        game: session.game,
                        assets: session.episode.assets,
                        strings: session.episode.strings,
                        onSolved: () => notifier.solvePuzzle(puzzleId),
                        feedback: ref.read(uiFeedbackProvider).call,
                      ),
                    ),
                  )
                else if (kDebugMode)
                  Center(
                    child: Text('No widget for puzzle type "${puzzle.type}"'),
                  ),
              ],
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                tooltip: AppLocalizations.of(context).closePuzzle,
                icon: const Icon(Icons.close),
                onPressed: () {
                  ref.read(uiFeedbackProvider)(UiSound.close);
                  notifier.closePuzzle();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
