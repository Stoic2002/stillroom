import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/engine.dart';
import '../state/game_session.dart';
import '../state/hint_candle.dart';
import '../state/save_repository.dart';
import 'debug_settings.dart';

/// Developer panel (debug builds only, PRD §9): hotspot outlines, live
/// state, scene jumper, restart, content warnings, and an event log.
///
/// Labels are plain English on purpose: this is a dev tool, not player UI.
class DebugOverlay extends ConsumerStatefulWidget {
  const DebugOverlay({required this.episodeId, super.key});

  final String episodeId;

  @override
  ConsumerState<DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends ConsumerState<DebugOverlay> {
  static const _maxLog = 40;

  bool _open = false;
  final List<String> _log = [];

  @override
  Widget build(BuildContext context) {
    final provider = gameSessionProvider(widget.episodeId);
    ref.listen(provider, (previous, next) {
      final session = next.value;
      if (session == null || session.revision == previous?.value?.revision) {
        return;
      }
      setState(() {
        for (final event in session.events) {
          _log.insert(0, describeEvent(event));
        }
        if (_log.length > _maxLog) _log.removeRange(_maxLog, _log.length);
      });
    });

    final session = ref.watch(provider).value;
    return Stack(
      children: [
        if (_open && session != null)
          Align(
            alignment: Alignment.centerRight,
            child: _Panel(
              session: session,
              log: _log,
              notifier: ref.read(provider.notifier),
            ),
          ),
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: IconButton.filledTonal(
              icon: Icon(_open ? Icons.close : Icons.bug_report),
              onPressed: () => setState(() => _open = !_open),
            ),
          ),
        ),
      ],
    );
  }
}

class _Panel extends ConsumerWidget {
  const _Panel({
    required this.session,
    required this.log,
    required this.notifier,
  });

  final GameSessionState session;
  final List<String> log;
  final GameSession notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = session.game;
    final content = session.engine.content;
    final warnings = session.episode.warnings;
    const heading = TextStyle(fontWeight: FontWeight.bold, fontSize: 13);
    const body = TextStyle(fontSize: 12, fontFamily: 'monospace');

    return Material(
      color: const Color(0xE6101010),
      child: SizedBox(
        width: 360,
        child: SafeArea(
          left: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 56, 12, 12),
            children: [
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Show hotspots'),
                value: ref.watch(showHotspotsProvider),
                onChanged: (_) =>
                    ref.read(showHotspotsProvider.notifier).toggle(),
              ),
              Text('Scene: ${game.sceneId}', style: heading),
              Wrap(
                spacing: 6,
                children: [
                  for (final id in content.scenes.keys)
                    ActionChip(
                      label: Text(id, style: body),
                      onPressed: id == game.sceneId
                          ? null
                          : () => notifier.debugJumpToScene(id),
                    ),
                ],
              ),
              TextButton.icon(
                icon: const Icon(Icons.local_fire_department_outlined),
                label: const Text('Light the hint candle'),
                onPressed: () {
                  final group = notifier.currentHints();
                  if (group == null) return;
                  ref
                      .read(hintCandleProvider(session.game.episodeId).notifier)
                      .debugLight(group.key);
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.restart_alt),
                label: const Text('Restart episode'),
                onPressed: notifier.debugRestart,
              ),
              TextButton.icon(
                icon: const Icon(Icons.delete_forever_outlined),
                label: const Text('Reset save (all episodes)'),
                onPressed: () {
                  ref.read(saveRepositoryProvider.notifier).clearAll();
                  notifier.debugRestart();
                },
              ),
              const Divider(),
              const Text('Inventory', style: heading),
              Text(
                game.inventory.isEmpty ? '—' : game.inventory.join(', '),
                style: body,
              ),
              const Text('Ever had', style: heading),
              Text(
                game.everHadItems.isEmpty ? '—' : game.everHadItems.join(', '),
                style: body,
              ),
              const Text('Solved puzzles', style: heading),
              Text(
                game.solvedPuzzles.isEmpty
                    ? '—'
                    : game.solvedPuzzles.join(', '),
                style: body,
              ),
              Text('Completed: ${game.completed}', style: heading),
              const Divider(),
              const Text('Flags', style: heading),
              for (final MapEntry(:key, :value) in game.flags.entries)
                Text('$key = $value', style: body),
              const Divider(),
              const Text('Events (newest first)', style: heading),
              if (log.isEmpty) const Text('—', style: body),
              for (final line in log) Text(line, style: body),
              const Divider(),
              Text('Content warnings (${warnings.length})', style: heading),
              for (final w in warnings)
                Text('${w.location}: ${w.message}', style: body),
            ],
          ),
        ),
      ),
    );
  }
}

String describeEvent(GameEvent event) => switch (event) {
  SceneChangedEvent(:final from, :final to) => 'scene $from → $to',
  ItemPickedEvent(:final itemId) => 'picked $itemId',
  ItemRemovedEvent(:final itemId) => 'removed $itemId',
  ItemsCombinedEvent(:final first, :final second, :final result) =>
    'combined $first + $second → $result',
  CombinationFailedEvent(:final first, :final second) =>
    'no combination $first + $second',
  ItemRejectedEvent(:final itemId, :final hotspotId) =>
    '$itemId rejected by $hotspotId',
  ShowTextEvent(:final textKey) => 'showText $textKey',
  OpenPuzzleEvent(:final puzzleId) => 'openPuzzle $puzzleId',
  PuzzleSolvedEvent(:final puzzleId) => 'solved $puzzleId',
  ExamineItemEvent(:final itemId) => 'examine $itemId',
  PlaySoundEvent(:final soundId) => 'playSound $soundId',
  ShakeEvent(:final durationMs, :final strength) =>
    'shake ${durationMs}ms × $strength',
  EpisodeEndedEvent() => 'episode ended',
  _ => event.runtimeType.toString(),
};
