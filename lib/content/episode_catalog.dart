import 'dart:math' as math;

import '../engine/engine.dart';

/// A point on the map of tales, in degrees.
typedef MapPlace = ({double lat, double lon});

/// One jar on the Stillroom shelf: an entry of `episodes.json`.
final class EpisodeEntry {
  const EpisodeEntry({
    required this.id,
    required this.titleKey,
    this.teaserKey,
    this.jarImage,
    this.comingSoon = false,
    this.debugOnly = false,
    this.shelf = 1,
    this.unlockAfter = 0,
    this.series,
    this.place,
  });

  /// ```json
  /// { "id": "whitechapel_1888", "titleKey": "episode.whitechapel_1888.title",
  ///   "teaserKey": "...", "jarImage": "images/ui/jar_whitechapel.png" }
  /// { "id": "sealed_1", "titleKey": "episode.sealed.title", "comingSoon": true }
  /// { "id": "test_room", "titleKey": "...", "debugOnly": true }
  /// ```
  /// `shelf` (default 1) is the difficulty tier, bottom = easiest;
  /// `unlockAfter` (default 0) is how many tales must be distilled first;
  /// `series` links tales of one topic (e.g. two Whitechapel jars);
  /// `place` is `[latitude, longitude]` of the tale, its pin on the map.
  factory EpisodeEntry.fromJson(JsonReader json) {
    json.allowOnly({
      'id',
      'titleKey',
      'teaserKey',
      'jarImage',
      'comingSoon',
      'debugOnly',
      'shelf',
      'unlockAfter',
      'series',
      'place',
    });
    final shelf = json.optionalInt('shelf') ?? 1;
    if (shelf < 1) json.fail('must be >= 1', 'shelf');
    final unlockAfter = json.optionalInt('unlockAfter') ?? 0;
    if (unlockAfter < 0) json.fail('must be >= 0', 'unlockAfter');
    MapPlace? place;
    if (json.has('place')) {
      final [lat, lon] = json.numbers('place', length: 2);
      if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
        json.fail('expected [latitude, longitude]', 'place');
      }
      place = (lat: lat, lon: lon);
    }
    return EpisodeEntry(
      id: json.string('id'),
      titleKey: json.string('titleKey'),
      teaserKey: json.optionalString('teaserKey'),
      jarImage: json.optionalString('jarImage'),
      comingSoon: json.optionalBool('comingSoon') ?? false,
      debugOnly: json.optionalBool('debugOnly') ?? false,
      shelf: shelf,
      unlockAfter: unlockAfter,
      series: json.optionalString('series'),
      place: place,
    );
  }

  final String id;

  /// Label on the jar, e.g. "Whitechapel, 1888".
  final String titleKey;

  /// One line shown when the jar is picked up.
  final String? teaserKey;

  /// Final jar art; a jar is drawn in code until it exists.
  final String? jarImage;

  /// A sealed jar with no content yet; it has no episode folder.
  final bool comingSoon;

  /// Only listed in debug builds (e.g. the feature test room).
  final bool debugOnly;

  /// Difficulty tier; higher shelves hold harder tales.
  final int shelf;

  /// Distilled tales needed before this jar can be opened.
  final int unlockAfter;

  /// Tales of one topic share a series id and a ribbon on the shelf.
  final String? series;

  /// Where the tale happened; jars without one have no pin on the map.
  final MapPlace? place;

  bool get playable => !comingSoon;
}

/// Which jars the player may open, given the tales they have distilled.
/// Pure logic, so the rules are testable apart from the UI.
final class ShelfProgress {
  ShelfProgress(this.catalog, Set<String> completed)
    : distilled = catalog
          .where((e) => e.playable && !e.debugOnly && completed.contains(e.id))
          .length;

  final List<EpisodeEntry> catalog;

  /// Finished tales that count towards unlocking (debug jars don't).
  final int distilled;

  bool isUnlocked(EpisodeEntry entry) => distilled >= entry.unlockAfter;

  /// Tales still to distil before [entry] opens.
  int remaining(EpisodeEntry entry) =>
      math.max(0, entry.unlockAfter - distilled);

  /// Shelves from the top (hardest) down, each in catalog order.
  List<(int, List<EpisodeEntry>)> get shelvesTopDown {
    final byShelf = <int, List<EpisodeEntry>>{};
    for (final e in catalog) {
      (byShelf[e.shelf] ??= []).add(e);
    }
    final tiers = byShelf.keys.toList()..sort((a, b) => b.compareTo(a));
    return [for (final t in tiers) (t, byShelf[t]!)];
  }
}
