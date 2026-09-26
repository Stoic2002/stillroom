import 'dart:io';

import 'asset_source.dart';

/// Reads assets straight from the project's `assets/` folder on disk, for the
/// content validator CLI and tests.
///
/// Unlike the app bundle, this sees every file on disk, including ones in
/// folders not registered in `pubspec.yaml`.
final class FileAssetSource implements AssetSource {
  FileAssetSource(this.projectRoot);

  final Directory projectRoot;
  Set<String>? _assets;

  @override
  Future<Set<String>> listAssets() async => _assets ??= _scan();

  Set<String> _scan() {
    final assets = Directory('${projectRoot.path}/assets');
    if (!assets.existsSync()) return {};
    final prefix = '${projectRoot.path}/';
    return {
      for (final entity in assets.listSync(recursive: true))
        if (entity is File)
          entity.path.substring(prefix.length).replaceAll(r'\', '/'),
    };
  }

  @override
  Future<String> loadString(String path) =>
      File('${projectRoot.path}/$path').readAsString();
}
