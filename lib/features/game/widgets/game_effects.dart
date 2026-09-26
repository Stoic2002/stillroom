import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../content/audio_paths.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/audio/ui_sound.dart';
import '../../../engine/engine.dart';
import '../../../state/game_session.dart';
import '../../../state/services_providers.dart';
import '../../../state/settings_controller.dart';
import '../../../state/ui_feedback.dart';

/// The interface sound for one batch of engine events, if any: the most
/// telling one only, so a single tap never stacks several. A text box stays
/// quiet when the content plays its own sound.
UiSound? interfaceSoundFor(List<GameEvent> events) {
  bool any<T extends GameEvent>() => events.any((e) => e is T);
  if (any<ItemsCombinedEvent>()) return UiSound.combine;
  if (any<ItemPickedEvent>()) return UiSound.pickup;
  if (any<CombinationFailedEvent>() || any<ItemRejectedEvent>()) {
    return UiSound.reject;
  }
  if (any<OpenPuzzleEvent>() || any<ExamineItemEvent>()) return UiSound.open;
  if (any<SceneChangedEvent>()) return UiSound.step;
  if (any<ShowTextEvent>() && !any<PlaySoundEvent>()) return UiSound.page;
  return null;
}

/// Plays back the engine's audiovisual events: sound effects, scene music,
/// camera shake, haptics (respecting the settings), and the interface
/// sounds of pickups, combinations, and moves ([interfaceSoundFor]).
/// Renders nothing.
///
/// Missing audio files are silent placeholders (PRD §0 rule 2).
class GameEffects extends ConsumerStatefulWidget {
  const GameEffects({
    required this.episodeId,
    required this.onShake,
    super.key,
  });

  final String episodeId;

  /// Shakes the scene camera.
  final void Function(int durationMs, double strength) onShake;

  @override
  ConsumerState<GameEffects> createState() => _GameEffectsState();
}

class _GameEffectsState extends ConsumerState<GameEffects> {
  late final AudioService _audio = ref.read(audioServiceProvider);

  /// Asset path of the music playing, if any.
  String? _music;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(gameSessionProvider(widget.episodeId)).value;
      if (mounted && session != null) _updateMusic(session);
    });
  }

  @override
  void dispose() {
    if (_music != null) unawaited(_audio.stopMusic(ifPlaying: _music));
    super.dispose();
  }

  void _onUpdate(GameSessionState session) {
    final settings = ref.read(settingsControllerProvider);
    for (final event in session.events) {
      switch (event) {
        case PlaySoundEvent(:final soundId):
          final path = resolveSfx(soundId, session.episode.assets);
          if (path != null) {
            unawaited(_audio.playSfx(path, volume: settings.sfxVolume));
          }
        case ShakeEvent(:final durationMs, :final strength):
          widget.onShake(durationMs, strength);
          if (settings.vibration) unawaited(HapticFeedback.heavyImpact());
        case ItemRejectedEvent() || CombinationFailedEvent():
          if (settings.vibration) unawaited(HapticFeedback.lightImpact());
        default:
          break;
      }
    }
    final sound = interfaceSoundFor(session.events);
    if (sound != null) ref.read(uiFeedbackProvider)(sound);
    _updateMusic(session);
  }

  void _updateMusic(GameSessionState session) {
    final id = session.game.completed
        ? null
        : session.engine.currentMusic(session.game);
    final path = id == null ? null : resolveMusic(id, session.episode.assets);
    if (path == _music) return;
    _music = path;
    if (path == null) {
      unawaited(_audio.stopMusic());
    } else {
      unawaited(
        _audio.playMusic(
          path,
          volume: ref.read(settingsControllerProvider).musicVolume,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..listen(gameSessionProvider(widget.episodeId), (previous, next) {
        final session = next.value;
        if (session == null || session.revision == previous?.value?.revision) {
          return;
        }
        _onUpdate(session);
      })
      ..listen(settingsControllerProvider.select((s) => s.musicVolume), (
        _,
        volume,
      ) {
        if (_music != null) unawaited(_audio.setMusicVolume(volume));
      });
    return const SizedBox.shrink();
  }
}
