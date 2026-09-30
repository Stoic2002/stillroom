import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/content/episode_catalog.dart';
import 'package:stillroom/content/world_map.dart';
import 'package:stillroom/engine/engine.dart';

import '../engine/fixtures/test_episode.dart';

EpisodeEntry entry(Map<String, Object?> json) =>
    EpisodeEntry.fromJson(doc('episodes.json', {'titleKey': 't', ...json}));

void main() {
  test('defaults: bottom shelf, open from the start, no series', () {
    final e = entry({'id': 'a'});
    expect(e.shelf, 1);
    expect(e.unlockAfter, 0);
    expect(e.series, isNull);
  });

  test('rejects shelf < 1 and negative unlockAfter', () {
    expect(
      () => entry({'id': 'a', 'shelf': 0}),
      throwsA(isA<ContentFormatException>()),
    );
    expect(
      () => entry({'id': 'a', 'unlockAfter': -1}),
      throwsA(isA<ContentFormatException>()),
    );
  });

  group('ShelfProgress', () {
    final catalog = [
      entry({'id': 'easy_a', 'series': 'london'}),
      entry({'id': 'easy_b'}),
      entry({'id': 'sealed', 'comingSoon': true}),
      entry({'id': 'debug', 'debugOnly': true}),
      entry({'id': 'mid', 'shelf': 2, 'unlockAfter': 2}),
      entry({'id': 'hard', 'shelf': 3, 'unlockAfter': 3, 'series': 'london'}),
    ];
    EpisodeEntry byId(String id) => catalog.firstWhere((e) => e.id == id);

    test('only finished, playable, non-debug tales count', () {
      final progress = ShelfProgress(catalog, {'easy_a', 'debug', 'sealed'});
      expect(progress.distilled, 1);
    });

    test('jars open once enough tales are distilled', () {
      var progress = ShelfProgress(catalog, {'easy_a'});
      expect(progress.isUnlocked(byId('easy_b')), isTrue);
      expect(progress.isUnlocked(byId('mid')), isFalse);
      expect(progress.remaining(byId('mid')), 1);
      expect(progress.remaining(byId('hard')), 2);

      progress = ShelfProgress(catalog, {'easy_a', 'easy_b'});
      expect(progress.isUnlocked(byId('mid')), isTrue);
      expect(progress.remaining(byId('mid')), 0);
      expect(progress.isUnlocked(byId('hard')), isFalse);
    });

    test('unlockAll opens every jar, whatever is distilled', () {
      final progress = ShelfProgress(catalog, {}, unlockAll: true);
      expect(progress.isUnlocked(byId('mid')), isTrue);
      expect(progress.isUnlocked(byId('hard')), isTrue);
      expect(progress.remaining(byId('hard')), 0);
      expect(progress.distilled, 0);
    });

    test('shelves are listed top (hardest) down, jars in catalog order', () {
      final shelves = ShelfProgress(catalog, {}).shelvesTopDown;
      expect(shelves.map((s) => s.$1), [3, 2, 1]);
      expect(shelves.last.$2.map((e) => e.id), [
        'easy_a',
        'easy_b',
        'sealed',
        'debug',
      ]);
    });
  });

  test('place is [latitude, longitude] within range', () {
    EpisodeEntry parsePlace(Object place) => EpisodeEntry.fromJson(
      JsonReader.root({
        'id': 'e',
        'titleKey': 't',
        'place': place,
      }, source: 'episodes.json'),
    );
    expect(parsePlace([51.5, -0.1]).place, (lat: 51.5, lon: -0.1));
    expect(() => parsePlace([95, 0]), throwsA(isA<ContentFormatException>()));
  });

  test('the bundled world map loads its coastlines', () {
    final map = WorldMap.fromJson(
      File('assets/map/land.json').readAsStringSync(),
    );
    expect(map.rings.length, greaterThan(50));
    expect(
      map.rings.every(
        (ring) => ring.every(
          (p) => p.lat >= WorldMap.south && p.lat <= WorldMap.north,
        ),
      ),
      isTrue,
    );
  });
}
