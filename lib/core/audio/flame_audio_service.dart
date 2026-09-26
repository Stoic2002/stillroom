import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

import 'audio_service.dart';

/// [AudioService] on `flame_audio`. Music pauses while the app is in the
/// background (handled by `Bgm`).
final class FlameAudioService implements AudioService {
  FlameAudioService() {
    // Our paths already start with assets/.
    FlameAudio.updatePrefix('');
  }

  bool _bgmReady = false;

  /// The music file playing, if any.
  String? _current;

  /// Interface sounds (short, played on every touch) are kept loaded in
  /// Android's low-latency SoundPool, one player each: playing is just
  /// "start from the top". Low latency holds no MediaPlayer, of which
  /// Android allows only a few at once (too many fail with error -19).
  final Map<String, Future<AudioPlayer?>> _quick = {};

  static bool _isQuick(String assetPath) =>
      assetPath.startsWith('assets/audio/ui/');

  Future<AudioPlayer?> _quickPlayer(String assetPath) =>
      _quick[assetPath] ??= () async {
        final player = AudioPlayer()..audioCache = FlameAudio.audioCache;
        try {
          await player.setReleaseMode(ReleaseMode.stop);
          await player.setPlayerMode(PlayerMode.lowLatency);
          await player.setSource(AssetSource(assetPath));
          return player;
        } on Object catch (e) {
          debugPrint('Sound failed to load: $assetPath: $e');
          unawaited(player.dispose());
          return null;
        }
      }();

  @override
  Future<void> preload(Iterable<String> assetPaths) async {
    // One at a time, so loading them never stalls a frame.
    for (final path in assetPaths) {
      if (_isQuick(path)) {
        await _quickPlayer(path);
      } else {
        // Story sounds are longer and rarer: copy the file out of the
        // bundle now, so the first play needn't.
        try {
          await FlameAudio.audioCache.load(path);
        } on Object catch (e) {
          debugPrint('Sound failed to load: $path: $e');
        }
      }
    }
  }

  @override
  Future<void> playSfx(String assetPath, {required double volume}) async {
    if (volume <= 0) return;
    if (_isQuick(assetPath)) {
      final player = await _quickPlayer(assetPath);
      if (player == null) return;
      try {
        await player.stop();
        await player.setVolume(volume);
        await player.resume();
      } on Object catch (e) {
        debugPrint('Sound failed: $assetPath: $e');
      }
      return;
    }
    // A one-off player, released as soon as the sound ends.
    final player = AudioPlayer()..audioCache = FlameAudio.audioCache;
    try {
      await player.setReleaseMode(ReleaseMode.release);
      unawaited(
        player.onPlayerComplete.first.then<void>(
          (_) => player.dispose(),
          onError: (Object _) {},
        ),
      );
      await player.play(
        AssetSource(assetPath),
        volume: volume,
        mode: PlayerMode.mediaPlayer,
      );
    } on Object catch (e) {
      debugPrint('Sound failed: $assetPath: $e');
      unawaited(player.dispose());
    }
  }

  @override
  Future<void> playMusic(String assetPath, {required double volume}) async {
    // Already playing: keep going rather than restart.
    if (assetPath == _current) return;
    _current = assetPath;
    try {
      if (!_bgmReady) {
        await FlameAudio.bgm.initialize();
        _bgmReady = true;
      }
      await FlameAudio.bgm.play(assetPath, volume: volume);
    } on Object catch (e) {
      debugPrint('Music failed: $assetPath: $e');
    }
  }

  @override
  Future<void> setMusicVolume(double volume) async {
    if (!_bgmReady) return;
    await FlameAudio.bgm.audioPlayer.setVolume(volume);
  }

  @override
  Future<void> stopMusic({String? ifPlaying}) async {
    if (ifPlaying != null && ifPlaying != _current) return;
    _current = null;
    await FlameAudio.bgm.stop();
  }
}
