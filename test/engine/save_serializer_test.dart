import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/engine/engine.dart';

void main() {
  const serializer = SaveSerializer();

  const state = GameState(
    episodeId: 'test_room',
    sceneId: 'desk',
    inventory: ['lens', 'small_key'],
    everHadItems: {'lens', 'small_key', 'frame'},
    flags: {'drawer_open': true, 'clock_turns': 3},
    solvedPuzzles: {'drawer_lock'},
  );
  const file = SaveFile(
    lastEpisodeId: 'test_room',
    episodes: {'test_room': state},
  );

  test('round-trips a save file', () {
    final encoded = serializer.encode(file);
    final json = jsonDecode(encoded) as Map<String, dynamic>;
    expect(json['schemaVersion'], SaveFile.currentSchemaVersion);

    final decoded = serializer.decode(encoded);
    expect(
      decoded,
      isA<SaveDecoded>()
          .having((d) => d.file, 'file', file)
          .having((d) => d.migratedFrom, 'migratedFrom', isNull),
    );
  });

  test('an empty save decodes to no episodes', () {
    final decoded = serializer.decode('{"schemaVersion": 1}');
    expect(
      decoded,
      isA<SaveDecoded>().having((d) => d.file, 'file', const SaveFile()),
    );
  });

  group('corrupt saves are reported, never thrown', () {
    for (final (name, raw) in [
      ('not JSON', '{"schemaVersion": 1,'),
      ('not an object', '[1, 2]'),
      ('missing schemaVersion', '{"episodes": {}}'),
      ('schemaVersion not an int', '{"schemaVersion": "1"}'),
      ('newer schema', '{"schemaVersion": 99}'),
      ('wrong field type', '{"schemaVersion": 1, "episodes": []}'),
      (
        'bad nested state',
        '{"schemaVersion": 1, "episodes": {"a": {"episodeId": "a", "sceneId": 5}}}',
      ),
      (
        'null flag value',
        '{"schemaVersion": 1, "episodes": {"a": {"episodeId": "a", "sceneId": "s", "flags": {"f": null}}}}',
      ),
    ]) {
      test(name, () {
        expect(serializer.decode(raw), isA<SaveCorrupted>());
      });
    }
  });

  group('migrations', () {
    test('run in order from the saved version to the current one', () {
      final serializer = SaveSerializer(
        currentVersion: 3,
        migrations: {
          1: (json) => {...json, 'lastEpisodeId': 'from_v1'},
          2: (json) => {
            ...json,
            'lastEpisodeId': '${json['lastEpisodeId']}_v2',
          },
        },
      );
      final decoded = serializer.decode('{"schemaVersion": 1}');
      expect(
        decoded,
        isA<SaveDecoded>()
            .having((d) => d.file.lastEpisodeId, 'last', 'from_v1_v2')
            .having((d) => d.file.schemaVersion, 'version', 3)
            .having((d) => d.migratedFrom, 'migratedFrom', 1),
      );
    });

    test('a missing migration step is reported as corrupt', () {
      const serializer = SaveSerializer(currentVersion: 2);
      expect(serializer.decode('{"schemaVersion": 1}'), isA<SaveCorrupted>());
    });
  });
}
