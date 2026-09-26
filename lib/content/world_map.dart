import 'dart:convert';

import 'asset_source.dart';

/// The coastlines of the map of tales (`assets/map/land.json`, built by
/// `tool/map/build_world_map.py` from Natural Earth, public domain).
final class WorldMap {
  const WorldMap(this.rings);

  /// Parses `{"rings": [[lon, lat, lon, lat, ...], ...]}`.
  factory WorldMap.fromJson(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    return WorldMap([
      for (final ring in json['rings'] as List<dynamic>)
        [
          for (var i = 0; i + 1 < (ring as List).length; i += 2)
            (
              lon: (ring[i] as num).toDouble(),
              lat: (ring[i + 1] as num).toDouble(),
            ),
        ],
    ]);
  }

  static const asset = 'assets/map/land.json';

  /// The map shows latitudes between these (Antarctica is left off).
  static const north = 84.0;
  static const south = -58.0;

  static Future<WorldMap> load(AssetSource source) async =>
      WorldMap.fromJson(await source.loadString(asset));

  /// Land outlines, each a closed ring of points.
  final List<List<({double lon, double lat})>> rings;
}
