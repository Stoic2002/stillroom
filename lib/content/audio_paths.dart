/// Where content audio lives: sound ids map to `assets/audio/sfx/<id>.<ext>`
/// and music ids to `assets/audio/music/<id>.<ext>`.
library;

import '../engine/engine.dart';

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

/// Every sound id the episode's actions can play, to load them ahead.
Set<String> soundIdsOf(EpisodeContent content) {
  final ids = <String>{};
  void scan(Iterable<GameAction> actions) {
    for (final action in actions) {
      for (final ref in action.references) {
        if (ref.kind == RefKind.sound) ids.add(ref.id);
      }
    }
  }

  void hotspots(Iterable<Hotspot> list) {
    for (final h in list) {
      scan(h.onTap);
      for (final use in h.onUseItem) {
        scan(use.actions);
      }
    }
  }

  for (final scene in content.scenes.values) {
    hotspots(scene.hotspots);
  }
  for (final item in content.items.values) {
    hotspots(item.examine?.hotspots ?? const []);
  }
  for (final puzzle in content.puzzles.values) {
    scan(puzzle.onSolved);
  }
  return ids;
}
