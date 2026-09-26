/// Plays game audio (PRD §6.3: third-party audio behind an interface).
/// Paths are full asset paths, e.g. `assets/audio/sfx/door.ogg`.
abstract interface class AudioService {
  Future<void> playSfx(String assetPath, {required double volume});

  /// Loops [assetPath]; replaces any music already playing.
  Future<void> playMusic(String assetPath, {required double volume});

  Future<void> setMusicVolume(double volume);

  /// Stops the music; with [ifPlaying], only while that file is what plays
  /// (another screen may have started its own music since).
  Future<void> stopMusic({String? ifPlaying});
}

/// Plays nothing, for tests.
final class SilentAudioService implements AudioService {
  const SilentAudioService();

  @override
  Future<void> playSfx(String assetPath, {required double volume}) async {}

  @override
  Future<void> playMusic(String assetPath, {required double volume}) async {}

  @override
  Future<void> setMusicVolume(double volume) async {}

  @override
  Future<void> stopMusic({String? ifPlaying}) async {}
}
