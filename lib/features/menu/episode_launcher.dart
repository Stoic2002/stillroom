import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/routing/app_routes.dart';
import '../../state/save_repository.dart';

/// Starts [episodeId] from scratch: drops its saved progress (and a corrupt
/// save, which cannot be continued anyway), then opens the game.
Future<void> startEpisode(
  BuildContext context,
  WidgetRef ref,
  String episodeId,
) async {
  final repository = ref.read(saveRepositoryProvider.notifier);
  if (ref.read(saveRepositoryProvider).isCorrupted) repository.clearAll();
  repository.startNew(episodeId);
  await Navigator.of(context).pushNamed(AppRoutes.game, arguments: episodeId);
}

/// Resumes [episodeId] from the save slot.
Future<void> continueEpisode(BuildContext context, String episodeId) =>
    Navigator.of(context).pushNamed(AppRoutes.game, arguments: episodeId);
