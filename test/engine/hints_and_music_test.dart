import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/engine/engine.dart';

import 'fixtures/test_episode.dart';

void main() {
  Map<String, Object?> gameWithStages() => {
    ...gameJson(),
    'music': 'ambience',
    'hintStages': [
      {
        'id': 'late',
        'when': [
          {'flag': 'drawer_open', 'equals': true},
        ],
        'hints': [
          {'key': 'hint.late.1'},
        ],
      },
      {
        'id': 'early',
        'hints': [
          {'key': 'hint.early.1'},
          {
            'key': 'hint.early.2',
            'when': [
              {'flag': 'saw_clock', 'equals': true},
            ],
          },
          {'key': 'hint.early.3'},
        ],
      },
    ],
  };

  late GameEngine engine;
  late GameState start;

  setUp(() {
    final desk = deskJson()..['music'] = 'desk_theme';
    engine = GameEngine(
      buildTestEpisode(game: gameWithStages(), scenes: [roomNorthJson(), desk]),
    );
    start = engine.newGame();
  });

  group('hint stages', () {
    test('the first stage whose conditions hold is current', () {
      expect(engine.hintGroup(start)?.key, 'stage:early');
      final later = start.copyWith(
        flags: {...start.flags, 'drawer_open': true},
      );
      expect(engine.hintGroup(later)?.key, 'stage:late');
    });

    test('hints are revealed one by one among the available ones', () {
      var group = engine.hintGroup(start)!;
      expect(group.available.map((h) => h.textKey), [
        'hint.early.1',
        'hint.early.3',
      ]);
      expect(group.shown, isEmpty);

      var state = engine.revealNextHint(start, group);
      group = engine.hintGroup(state)!;
      expect(group.shown.single.textKey, 'hint.early.1');

      state = engine.revealNextHint(state, group);
      group = engine.hintGroup(state)!;
      expect(group.canRevealMore, isFalse);
      expect(engine.revealNextHint(state, group), same(state));
      expect(state.revealedHints, {'stage:early': 2});
    });

    test('puzzle hints are a group of their own', () {
      final group = engine.hintGroup(start, puzzleId: 'drawer_lock')!;
      expect(group.key, 'puzzle:drawer_lock');
      expect(group.available, hasLength(2));
    });

    test('no stages and no puzzle means no hints', () {
      final plain = GameEngine(buildTestEpisode());
      expect(plain.hintGroup(plain.newGame()), isNull);
    });

    test('stage parsing rejects duplicates and too many hints', () {
      final dup = gameWithStages();
      (dup['hintStages']! as List<Object?>).add({
        'id': 'early',
        'hints': [
          {'key': 'k'},
        ],
      });
      expect(
        () => buildTestEpisode(game: dup),
        throwsA(isA<ContentFormatException>()),
      );
    });

    test('reconcile keeps hint progress only for groups that still exist', () {
      final saved = start.copyWith(
        revealedHints: {
          'stage:early': 1,
          'stage:gone': 2,
          'puzzle:drawer_lock': 1,
          'puzzle:gone': 3,
        },
      );
      expect(engine.reconcile(saved).revealedHints, {
        'stage:early': 1,
        'puzzle:drawer_lock': 1,
      });
    });
  });

  test('music: scene overrides the episode default', () {
    expect(engine.currentMusic(start), 'ambience');
    final atDesk = engine.takeExit(start, 'right').state;
    expect(engine.currentMusic(atDesk), 'desk_theme');
  });

  test('old saves without revealedHints still load', () {
    final state = GameState.fromJson({'episodeId': 'e', 'sceneId': 's'});
    expect(state.revealedHints, isEmpty);
  });
}
