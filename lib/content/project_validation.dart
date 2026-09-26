import '../engine/engine.dart';
import 'asset_source.dart';
import 'content_loader.dart';
import 'content_validator.dart';
import 'episode_catalog.dart';

/// Validates every episode listed in `episodes.json` (PRD §9). Loading
/// failures (bad JSON, unknown fields, ...) are reported as errors instead of
/// thrown. Shared by `tool/validate_content.dart` and the test suite.
///
/// With [pubspec] (the text of `pubspec.yaml`), also reports asset folders
/// that contain files but are not registered, since Flutter would not bundle
/// them.
Future<List<ContentIssue>> validateProject(
  AssetSource source, {
  String? pubspec,
  ContentRegistries? registries,
}) async {
  final loader = ContentLoader(source);
  final issues = <ContentIssue>[];
  final assets = await source.listAssets();

  final List<EpisodeEntry> catalog;
  final StringTables strings;
  try {
    catalog = await loader.catalog();
    strings = await loader.loadStringTables();
  } on ContentFormatException catch (e) {
    return [_formatError(e)];
  }
  for (final entry in catalog) {
    final at = 'episodes.json › ${entry.id}';
    for (final key in [entry.titleKey, ?entry.teaserKey]) {
      final missing = [
        for (final MapEntry(key: locale, value: table) in strings.entries)
          if (!table.containsKey(key)) locale,
      ];
      if (missing.isNotEmpty) {
        issues.add(
          ContentIssue(
            IssueSeverity.error,
            at,
            'text key "$key" missing in ${missing.join(', ')}',
          ),
        );
      }
    }
    final jar = entry.jarImage;
    if (jar != null && !assets.contains('assets/$jar')) {
      issues.add(
        ContentIssue(
          IssueSeverity.warning,
          at,
          'image "$jar" not found; a jar is drawn instead',
        ),
      );
    }
  }
  final episodeIds = [
    for (final e in catalog)
      if (e.playable) e.id,
  ];
  if (episodeIds.isEmpty) {
    issues.add(
      const ContentIssue(
        IssueSeverity.error,
        ContentLoader.episodesIndex,
        'no episodes listed',
      ),
    );
  }

  for (final id in episodeIds) {
    try {
      final content = await loader.loadEpisode(
        id,
        registries ?? ContentRegistries.withBuiltIns(),
      );
      for (final issue in validateEpisode(
        content,
        assets: assets,
        strings: strings,
      )) {
        issues.add(
          ContentIssue(
            issue.severity,
            '$id › ${issue.location}',
            issue.message,
          ),
        );
      }
    } on ContentFormatException catch (e) {
      issues.add(_formatError(e));
    }
  }

  if (pubspec != null) {
    for (final folder in unregisteredAssetFolders(pubspec, assets)) {
      issues.add(
        ContentIssue(
          IssueSeverity.error,
          'pubspec.yaml',
          'folder "$folder" has files but is not listed under flutter.assets',
        ),
      );
    }
  }
  return issues;
}

/// Folders under `assets/` holding files but missing from [pubspec]'s asset
/// list (Flutter does not include subfolders automatically). Dotfiles such
/// as `.gitkeep` are ignored.
List<String> unregisteredAssetFolders(String pubspec, Set<String> assets) {
  final folders = {
    for (final path in assets)
      if (!path.split('/').last.startsWith('.'))
        path.substring(0, path.lastIndexOf('/') + 1),
  };
  return [
    for (final folder in folders.toList()..sort())
      if (!pubspec.contains('- $folder')) folder,
  ];
}

ContentIssue _formatError(ContentFormatException e) =>
    ContentIssue(IssueSeverity.error, '${e.source} ${e.path}', e.message);
