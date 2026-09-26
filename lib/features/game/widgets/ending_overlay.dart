import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/stillroom_palette.dart';
import '../../../core/widgets/atmosphere.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../state/game_session.dart';

/// Closing screen after `endEpisode` (PRD FR-12): the tale is distilled and
/// returns to its jar. Waits until queued text has been read, then fades in
/// and offers the way back to the menu.
class EndingOverlay extends ConsumerWidget {
  const EndingOverlay({required this.episodeId, super.key});

  final String episodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(gameSessionProvider(episodeId)).value;
    final visible =
        session != null &&
        session.game.completed &&
        session.currentText == null;
    if (!visible) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeIn,
      builder: (context, opacity, child) =>
          Opacity(opacity: opacity, child: child),
      child: Material(
        color: StillroomPalette.ink,
        child: Atmosphere(
          vignette: 0.95,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.water_drop_outlined,
                  size: 36,
                  color: StillroomPalette.oxbloodBright,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.episodeComplete,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 32),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: Text(l10n.backToMenu),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
