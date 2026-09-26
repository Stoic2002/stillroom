import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/content/asset_source.dart';
import 'package:stillroom/content/content_loader.dart';
import 'package:stillroom/content/file_asset_source.dart';
import 'package:stillroom/content/project_validation.dart';
import 'package:stillroom/engine/engine.dart';

/// The content validator run as a test (PRD §9, §11): the real content in
/// assets/ must have no errors. Same check as tool/validate_content.dart.
void main() {
  final source = FileAssetSource(Directory.current);

  test('bundled content passes the validator', () async {
    final issues = await validateProject(
      source,
      pubspec: File('pubspec.yaml').readAsStringSync(),
    );
    final errors = [
      for (final i in issues)
        if (i.isError) '$i',
    ];
    expect(errors, isEmpty);
  });

  test('both languages are present', () async {
    final strings = await ContentLoader(source).loadStringTables();
    expect(strings.keys, containsAll(['en', 'id']));
  });

  test('test_room starts in room_north and links its scenes', () async {
    final content = await ContentLoader(
      source,
    ).loadEpisode('test_room', ContentRegistries.withBuiltIns());
    expect(content.config.startScene, 'room_north');
    expect(content.scenes.keys, containsAll(['room_north', 'desk']));
  });

  group('validateProject reports instead of throwing', () {
    test('a malformed file', () async {
      const path = 'assets/content/episodes/test_room/items.json';
      final issues = await validateProject(
        _Patched(source, {path: '{"items": [], "extra": 1}'}),
      );
      expect(
        issues.where((i) => i.isError).map((i) => '$i'),
        contains(allOf(contains(path), contains('unknown field'))),
      );
    });

    test('an unregistered asset folder', () {
      expect(
        unregisteredAssetFolders('    - assets/content/\n', {
          'assets/content/episodes.json',
          'assets/images/new_episode/wall.png',
          'assets/images/empty/.gitkeep',
        }),
        ['assets/images/new_episode/'],
      );
    });
  });
}

final class _Patched implements AssetSource {
  _Patched(this.inner, this.patches);

  final AssetSource inner;
  final Map<String, String> patches;

  @override
  Future<Set<String>> listAssets() async => {
    ...await inner.listAssets(),
    ...patches.keys,
  };

  @override
  Future<String> loadString(String path) async =>
      patches[path] ?? await inner.loadString(path);
}
