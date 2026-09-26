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

  @override
  Future<String> loadString(String path) => bundle.loadString(path);
}
