/// Where content audio lives: sound ids map to `assets/audio/sfx/<id>.<ext>`
/// and music ids to `assets/audio/music/<id>.<ext>`.
library;

const audioExtensions = ['ogg', 'mp3', 'wav'];

String sfxAssetPath(String soundId, String extension) =>
    'assets/audio/sfx/$soundId.$extension';

String musicAssetPath(String musicId, String extension) =>
    'assets/audio/music/$musicId.$extension';

/// The bundled file for sound [soundId], or `null` if there is none (a
/// silent placeholder).
String? resolveSfx(String soundId, Set<String> assets) =>
    _first(audioExtensions.map((ext) => sfxAssetPath(soundId, ext)), assets);

/// The bundled file for music [musicId], or `null` if there is none.
String? resolveMusic(String musicId, Set<String> assets) =>
    _first(audioExtensions.map((ext) => musicAssetPath(musicId, ext)), assets);

String? _first(Iterable<String> candidates, Set<String> assets) {
  for (final path in candidates) {
    if (assets.contains(path)) return path;
  }
  return null;
}
