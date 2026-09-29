import 'dart:convert';

import 'package:flutter/services.dart';

import 'asset_source.dart';

/// Reads bundled assets through Flutter's [AssetBundle].
final class FlutterAssetSource implements AssetSource {
  FlutterAssetSource(this.bundle);

  final AssetBundle bundle;
  Set<String>? _assets;

  @override
  Future<Set<String>> listAssets() async => _assets ??=
      (await AssetManifest.loadFromAssetBundle(bundle)).listAssets().toSet();

  /// Decodes here rather than through [AssetBundle.loadString], which hands
  /// files over 50 KB (the larger string tables) to a background isolate:
  /// slower for files this small, and never finishing in widget tests.
  @override
  Future<String> loadString(String path) async {
    final data = await bundle.load(path);
    return utf8.decode(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
  }
}
