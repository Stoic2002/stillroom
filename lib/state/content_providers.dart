import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../content/asset_source.dart';
import '../content/content_loader.dart';
import '../content/content_validator.dart';
import '../content/episode_catalog.dart';
import '../content/flutter_asset_source.dart';
import '../content/world_map.dart';
import '../engine/engine.dart';

part 'content_providers.g.dart';

@Riverpod(keepAlive: true)
AssetSource assetSource(Ref ref) => FlutterAssetSource(rootBundle);

@Riverpod(keepAlive: true)
ContentLoader contentLoader(Ref ref) =>
    ContentLoader(ref.watch(assetSourceProvider));

/// Action and puzzle types known to the content parser.
@Riverpod(keepAlive: true)
ContentRegistries contentRegistries(Ref ref) =>
    ContentRegistries.withBuiltIns();

/// Whether to validate content on load. On in debug builds (PRD §6.1).
@Riverpod(keepAlive: true)
bool validateContent(Ref ref) => kDebugMode;

/// Jars on the shelf. Debug-only episodes (the test room) are hidden in
/// release builds. Kept for the whole run: it is small and never changes.
@Riverpod(keepAlive: true)
Future<List<EpisodeEntry>> episodeCatalog(Ref ref) async {
  final entries = await ref.watch(contentLoaderProvider).catalog();
  final showDebug = ref.watch(validateContentProvider);
  return [
    for (final e in entries)
      if (showDebug || !e.debugOnly) e,
  ];
}

/// The coastlines for the map of tales.
@Riverpod(keepAlive: true)
Future<WorldMap> worldMap(Ref ref) =>
    WorldMap.load(ref.watch(assetSourceProvider));

/// Every bundled asset path, to choose between art and placeholders.
@riverpod
Future<Set<String>> bundledAssets(Ref ref) =>
    ref.watch(assetSourceProvider).listAssets();

/// String tables for UI outside a running episode (e.g. jar labels).
@riverpod
Future<StringTables> contentStrings(Ref ref) =>
    ref.watch(contentLoaderProvider).loadStringTables();

/// An episode's content plus what the presentation needs to render it.
final class LoadedEpisode {
  const LoadedEpisode({
    required this.content,
    required this.assets,
    required this.strings,
    this.warnings = const [],
  });

  final EpisodeContent content;

  /// Every bundled asset path; used to pick real art or a placeholder.
  final Set<String> assets;
  final StringTables strings;

  /// Validation warnings (e.g. missing art). Empty when validation is off.
  final List<ContentIssue> warnings;
}

/// Loads an episode. With validation on, content errors throw
/// [ContentValidationException] so they are fixed before anything renders.
@riverpod
Future<LoadedEpisode> loadedEpisode(Ref ref, String episodeId) async {
  final loader = ref.watch(contentLoaderProvider);
  final content = await loader.loadEpisode(
    episodeId,
    ref.watch(contentRegistriesProvider),
  );
  final assets = await loader.source.listAssets();
  final strings = await loader.loadStringTables();

  var warnings = const <ContentIssue>[];
  if (ref.watch(validateContentProvider)) {
    final issues = validateEpisode(content, assets: assets, strings: strings);
    final errors = issues.where((i) => i.isError).toList();
    if (errors.isNotEmpty) throw ContentValidationException(errors);
    warnings = issues;
    for (final w in warnings) {
      debugPrint('Content $w');
    }
  }
  return LoadedEpisode(
    content: content,
    assets: assets,
    strings: strings,
    warnings: warnings,
  );
}
