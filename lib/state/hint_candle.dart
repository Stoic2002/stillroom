import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../content/episode_catalog.dart';
import '../core/services/hint_gate.dart';
import '../core/services/hint_pacing.dart';
import '../engine/engine.dart';
import 'content_providers.dart';

part 'hint_candle.g.dart';

@Riverpod(keepAlive: true)
HintPacing hintPacing(Ref ref) => const HintPacing();

/// The hint candles of one episode: how long each hint group (a stage or a
/// puzzle) has burned since its last hint was read. The game screen burns
/// the current group's candle while the player is playing.
///
/// Kept in memory only: after the app restarts, the candles start again.
@Riverpod(keepAlive: true)
class HintCandle extends _$HintCandle {
  var _shelf = 1;

  @override
  Map<String, Duration> build(String episodeId) {
    ref.listen(episodeCatalogProvider, (_, catalog) {
      for (final entry in catalog.value ?? const <EpisodeEntry>[]) {
        if (entry.id == episodeId) _shelf = entry.shelf;
      }
    }, fireImmediately: true);
    return const {};
  }

  /// The wait before hint [level] (1-based) of a group.
  Duration waitFor(int level) =>
      ref.read(hintPacingProvider).waitFor(level: level, shelf: _shelf);

  /// How far the candle for the next hint of [group] has burned, 0 to 1.
  double progress(HintGroup group) => _progress(group.key, group.revealed + 1);

  /// Whether hint [level] of [groupKey] may be read.
  bool isLit(String groupKey, int level) => _progress(groupKey, level) >= 1;

  double _progress(String groupKey, int level) {
    final wait = waitFor(level);
    if (wait <= Duration.zero) return 1;
    final burned = state[groupKey] ?? Duration.zero;
    return (burned.inMilliseconds / wait.inMilliseconds).clamp(0.0, 1.0);
  }

  void burn(String groupKey, Duration time) =>
      state = {...state, groupKey: (state[groupKey] ?? Duration.zero) + time};

  /// A hint was read: the next one needs a fresh candle.
  void snuff(String groupKey) => state = {...state}..remove(groupKey);

  /// Debug tool: the current candle burns down at once.
  void debugLight(String groupKey) => burn(groupKey, const Duration(hours: 1));
}

/// Allows a hint once its candle has burned down, then lights a new one.
/// A later ad or purchase gate (monetization is on hold) can wrap this to
/// skip the wait.
final class CandleHintGate implements HintGate {
  const CandleHintGate(this._ref);

  final Ref _ref;

  @override
  Future<bool> unlock(HintUnlockRequest request) async {
    final candle = _ref.read(hintCandleProvider(request.episodeId).notifier);
    if (!candle.isLit(request.groupKey, request.level)) return false;
    candle.snuff(request.groupKey);
    return true;
  }
}
