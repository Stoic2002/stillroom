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

  @override
  Future<void> playSfx(String assetPath, {required double volume}) async {
    if (volume <= 0) return;
    try {
      final player = await FlameAudio.play(assetPath, volume: volume);
      unawaited(player.onPlayerComplete.first.then((_) => player.dispose()));
    } on Object catch (e) {
      debugPrint('Sound failed: $assetPath: $e');
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
