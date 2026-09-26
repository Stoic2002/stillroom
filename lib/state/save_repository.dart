import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../engine/engine.dart';
import 'storage_providers.dart';

part 'save_repository.g.dart';

/// The save slot as the app sees it.
final class SaveSnapshot {
  const SaveSnapshot(this.file, {this.corruptionReason});

  final SaveFile file;

  /// Set when the stored save could not be read (NFR-06). The unreadable
  /// data stays in storage until the player starts over.
  final String? corruptionReason;

  bool get isCorrupted => corruptionReason != null;

  GameState? episode(String episodeId) => file.episodes[episodeId];

  /// The episode "Continue" resumes: the last one played, if unfinished.
  String? get continueEpisodeId {
    final id = file.lastEpisodeId;
    if (id == null) return null;
    final state = file.episodes[id];
    return state == null || state.completed ? null : id;
  }

  /// Finished at least once, even if since started over.
  bool isCompleted(String episodeId) =>
      file.distilled.contains(episodeId) ||
      (file.episodes[episodeId]?.completed ?? false);

  /// The text key of the keeper's note found in [episodeId], if any.
  String? keeperNote(String episodeId) => file.keeperNotes[episodeId];
}

/// The single save slot (PRD FR-09): loaded once at start-up, written on
/// every meaningful change. Writes are queued so they land in order.
@Riverpod(keepAlive: true)
class SaveRepository extends _$SaveRepository {
  static const storageKey = 'save';
  static const serializer = SaveSerializer();

  Future<void> _pending = Future.value();

  @override
  SaveSnapshot build() {
    final raw = ref.watch(keyValueStoreProvider).getString(storageKey);
    if (raw == null) return const SaveSnapshot(SaveFile());
    return switch (serializer.decode(raw)) {
      SaveDecoded(:final file) => SaveSnapshot(file),
      SaveCorrupted(:final reason) => SaveSnapshot(
        const SaveFile(),
        corruptionReason: reason,
      ),
    };
  }

  /// Stores the latest state of an episode and marks it as last played.
  void saveEpisode(GameState game) {
    final file = state.file;
    _write(
      file.copyWith(
        lastEpisodeId: game.episodeId,
        episodes: {...file.episodes, game.episodeId: game},
        distilled: game.completed
            ? {...file.distilled, game.episodeId}
            : file.distilled,
      ),
    );
  }

  /// Keeps the keeper's note found in [episodeId] for the shelf.
  void recordKeeperNote(String episodeId, String noteKey) {
    if (state.file.keeperNotes[episodeId] == noteKey) return;
    _write(
      state.file.copyWith(
        keeperNotes: {...state.file.keeperNotes, episodeId: noteKey},
      ),
    );
  }

  /// Drops an episode's progress before a new game of it.
  void startNew(String episodeId) {
    _write(
      state.file.copyWith(
        lastEpisodeId: episodeId,
        episodes: {...state.file.episodes}..remove(episodeId),
      ),
    );
  }

  /// Deletes all progress (settings are kept).
  void clearAll() {
    state = const SaveSnapshot(SaveFile());
    _enqueue(() => ref.read(keyValueStoreProvider).remove(storageKey));
  }

  /// Completes when every queued write has finished.
  Future<void> flush() => _pending;

  void _write(SaveFile file) {
    state = SaveSnapshot(file);
    final raw = serializer.encode(file);
    _enqueue(() => ref.read(keyValueStoreProvider).setString(storageKey, raw));
  }

  void _enqueue(Future<void> Function() write) {
    _pending = _pending
        .then((_) => write())
        .catchError((Object e) => debugPrint('Save write failed: $e'));
  }
}
