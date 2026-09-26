import 'dart:convert';

import '../engine/engine.dart';
import 'asset_source.dart';
import 'episode_catalog.dart';

/// Content string tables keyed by locale code, then by text key.
typedef StringTables = Map<String, Map<String, String>>;

/// Loads episodes and string tables from `assets/content/`.
///
/// Episode files are discovered from the asset list, so adding a scene or
/// puzzle only needs a new JSON file (plus its folder in `pubspec.yaml`).
final class ContentLoader {
  ContentLoader(this.source);

  static const contentRoot = 'assets/content';
  static const episodesIndex = '$contentRoot/episodes.json';
  static const stringsDir = '$contentRoot/strings/';

  final AssetSource source;

  /// The shelf, in menu order, from `episodes.json`.
  Future<List<EpisodeEntry>> catalog() async {
    final json = await _readJson(episodesIndex);
    json.allowOnly({'episodes'});
    final entries = [
      for (final e in json.objects('episodes')) EpisodeEntry.fromJson(e),
    ];
    final ids = <String>{};
    for (final e in entries) {
      if (!ids.add(e.id)) json.fail('duplicate id "${e.id}"', 'episodes');
    }
    return entries;
  }

  /// Ids of the episodes that have content (not `comingSoon`), in order.
  Future<List<String>> episodeIds() async => [
    for (final e in await catalog())
      if (e.playable) e.id,
  ];

  Future<EpisodeContent> loadEpisode(
    String episodeId,
    ContentRegistries registries,
  ) async {
    final dir = episodeDir(episodeId);
    final assets = await source.listAssets();
    List<String> jsonFilesIn(String subdir) =>
        assets
            .where((p) => p.startsWith('$dir$subdir/') && p.endsWith('.json'))
            .toList()
          ..sort();

    return EpisodeContent.parse(
      id: episodeId,
      game: await _readJson('${dir}game.json'),
      items: await _readJson('${dir}items.json'),
      scenes: [for (final p in jsonFilesIn('scenes')) await _readJson(p)],
      puzzles: [for (final p in jsonFilesIn('puzzles')) await _readJson(p)],
      registries: registries,
    );
  }

  /// Every `strings/<locale>.json` table.
  Future<StringTables> loadStringTables() async {
    final assets = await source.listAssets();
    final paths = assets
        .where((p) => p.startsWith(stringsDir) && p.endsWith('.json'))
        .toList();
    return {
      for (final path in paths)
        path.substring(stringsDir.length, path.length - '.json'.length):
            _stringTable(await _readJson(path)),
    };
  }

  static String episodeDir(String episodeId) =>
      '$contentRoot/episodes/$episodeId/';

  Map<String, String> _stringTable(JsonReader json) => {
    for (final key in json.json.keys) key: json.string(key),
  };

  Future<JsonReader> _readJson(String path) async {
    if (!(await source.listAssets()).contains(path)) {
      throw ContentFormatException(
        path,
        r'$',
        'file not found (is its folder listed under assets in pubspec.yaml?)',
      );
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(await source.loadString(path));
    } on FormatException catch (e) {
      throw ContentFormatException(path, r'$', 'invalid JSON: ${e.message}');
    }
    return JsonReader.root(decoded, source: path);
  }
}
