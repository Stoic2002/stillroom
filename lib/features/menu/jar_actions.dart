import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/episode_catalog.dart';
import '../../core/audio/ui_sound.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/stillroom_palette.dart';
import '../../core/widgets/keeper_star.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/save_repository.dart';
import '../../state/ui_feedback.dart';
import 'episode_launcher.dart';

/// The player picked a jar, on the shelf or as a pin on the map: a locked
/// jar says how many more tales it needs; an open one offers to open,
/// continue, or start over.
Future<void> pickJar(
  BuildContext context,
  WidgetRef ref,
  EpisodeEntry entry, {
  required ShelfProgress progress,
  required String Function(String key) text,
}) {
  if (!progress.isUnlocked(entry)) {
    ref.read(uiFeedbackProvider)(UiSound.reject);
    return _showLocked(
      context,
      text(entry.titleKey),
      progress.remaining(entry),
    );
  }
  ref.read(uiFeedbackProvider)(UiSound.tap);
  return _open(context, ref, entry, text);
}

enum _JarChoice { resume, restart }

Future<void> _showLocked(BuildContext context, String title, int remaining) {
  final l10n = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.jarLockedTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontStyle: FontStyle.italic)),
          const SizedBox(height: 8),
          Text(l10n.jarLocked(remaining)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionClose),
        ),
      ],
    ),
  );
}

/// Opens a jar: resumes or restarts an unfinished tale, otherwise starts
/// it (a finished tale starts over).
Future<void> _open(
  BuildContext context,
  WidgetRef ref,
  EpisodeEntry entry,
  String Function(String key) text,
) async {
  final l10n = AppLocalizations.of(context);
  final save = ref.read(saveRepositoryProvider);
  // A tale started over after it was distilled is unfinished too.
  final unfinished = save.episode(entry.id)?.completed == false;
  final teaser = entry.teaserKey;
  final note = save.keeperNote(entry.id);

  final choice = await showDialog<_JarChoice>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(text(entry.titleKey)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              unfinished
                  ? l10n.jarUnfinished
                  : (teaser == null ? '' : text(teaser)),
            ),
            if (note != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const KeeperStar(),
                  const SizedBox(width: 8),
                  Text(
                    l10n.keeperNoteTitle,
                    style: const TextStyle(
                      fontFamily: AppTheme.smallCaps,
                      color: StillroomPalette.gaslight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                text(note),
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        if (unfinished) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(_JarChoice.restart),
            child: Text(l10n.actionStartOver),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_JarChoice.resume),
            child: Text(l10n.actionContinue),
          ),
        ] else
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_JarChoice.restart),
            child: Text(l10n.actionOpenJar),
          ),
      ],
    ),
  );
  if (!context.mounted || choice == null) return;
  switch (choice) {
    case _JarChoice.resume:
      await continueEpisode(context, ref, entry.id);
    case _JarChoice.restart:
      await startEpisode(context, ref, entry.id);
  }
}
