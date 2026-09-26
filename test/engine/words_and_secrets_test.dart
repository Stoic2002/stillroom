import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/content/content_validator.dart';
import 'package:stillroom/engine/engine.dart';

import 'fixtures/test_episode.dart';
import 'puzzle_types_test.dart' show parse, throwsAt;

Map<String, Object?> gameWithWords({Map<String, Object?>? secret}) => {
  ...gameJson(),
  'words': [
    {'id': 'bucks_row', 'labelKey': 'word.bucks_row', 'kind': 'place'},
    {'id': 'nichols', 'labelKey': 'word.nichols', 'kind': 'name'},
    {'id': 'north', 'labelKey': 'word.north', 'kind': 'thing', 'given': true},
  ],
  'secret': ?secret,
};

void main() {
  group('markup', () {
    test('splits plain runs and marked words', () {
      final parts = parseMarkup('Found in [[bucks_row]], at dawn.');
      expect(parts, hasLength(3));
      expect((parts[0] as PlainPart).text, 'Found in ');
      expect((parts[1] as WordPart).wordId, 'bucks_row');
      expect((parts[2] as PlainPart).text, ', at dawn.');
      expect(markedWords('[[a]] and [[b]] and [[a]]'), {'a', 'b'});
      expect(
        plainText('in [[bucks_row]]', (id) => "Buck's Row"),
        "in Buck's Row",
      );
    });
  });

  group('words', () {
    final engine = GameEngine(buildTestEpisode(game: gameWithWords()));

    test('given words are known from the start', () {
      expect(engine.newGame().words, {'north'});
    });

    test('noting a word adds it once and says so', () {
      final first = engine.noteWord(engine.newGame(), 'bucks_row');
      expect(first.state.words, {'north', 'bucks_row'});
      expect(first.events.single, isA<WordNotedEvent>());
      final again = engine.noteWord(first.state, 'bucks_row');
      expect(again.events, isEmpty);
      expect(
        () => engine.noteWord(first.state, 'nope'),
        throwsA(isA<EngineException>()),
      );
    });

    test('reconcile drops unknown words and adds given ones', () {
      const saved = GameState(
        episodeId: 'test_room',
        sceneId: 'room_north',
        words: {'bucks_row', 'gone'},
      );
      expect(engine.reconcile(saved).words, {'bucks_row', 'north'});
    });

    test('wordNoted condition', () {
      final condition = Condition.fromJson(
        doc('c.json', {'wordNoted': 'nichols'}),
      );
      final state = engine.newGame();
      expect(condition.isMet(state), isFalse);
      expect(condition.isMet(engine.noteWord(state, 'nichols').state), isTrue);
    });
  });

  group('secret', () {
    final engine = GameEngine(
      buildTestEpisode(
        game: gameWithWords(
          secret: {
            'when': [
              {'flag': 'saw_clock', 'equals': true},
            ],
            'noteKey': 'keeper.note',
          },
        ),
      ),
    );

    test('is found the moment its conditions hold, once', () {
      final start = engine.newGame();
      expect(start.secretFound, isFalse);
      final result = engine.tapHotspot(start, 'clock'); // sets saw_clock
      expect(result.state.secretFound, isTrue);
      expect(
        result.events.whereType<SecretFoundEvent>().single.noteKey,
        'keeper.note',
      );
      final again = engine.tapHotspot(result.state, 'clock');
      expect(again.events.whereType<SecretFoundEvent>(), isEmpty);
    });

    test('a secret needs at least one condition', () {
      expect(
        () => buildTestEpisode(
          game: gameWithWords(secret: {'when': <Object>[], 'noteKey': 'k'}),
        ),
        throwsA(isA<ContentFormatException>()),
      );
    });
  });

  group('deduction', () {
    final config = parse<DeductionConfig>('deduction', {
      'sentences': [
        {
          'textKey': 's1',
          'blanks': ['nichols', 'bucks_row'],
        },
        {
          'textKey': 's2',
          'blanks': ['north'],
        },
      ],
      'words': ['nichols', 'bucks_row', 'north', 'chapman'],
      'nearMiss': 1,
    });

    GameState noted(Set<String> words) =>
        GameState(episodeId: 'e', sceneId: 's', words: words);

    test('the bank holds only noted words, in bank order', () {
      final state = config.start(noted({'north', 'chapman', 'nichols'}));
      expect(state.available, ['nichols', 'north', 'chapman']);
      expect(state.fill(0, 'bucks_row').filled, isEmpty);
    });

    test('verdicts: incomplete, near miss, wrong, solved', () {
      var state = config.start(
        noted({'nichols', 'bucks_row', 'north', 'chapman'}),
      );
      expect(state.check(), isA<DeductionIncomplete>());
      state = state.fill(0, 'chapman').fill(1, 'bucks_row').fill(2, 'north');
      expect((state.check() as DeductionWrong).wrong, 1);
      state = state.fill(1, 'north');
      expect((state.check() as DeductionWrong).wrong, isNull);
      state = state.fill(0, 'nichols').fill(1, 'bucks_row');
      expect(state.check(), isA<DeductionSolved>());
      expect(state.isSolved, isTrue);
      expect(state.clear(2).check(), isA<DeductionIncomplete>());
      expect(config.firstBlankOf(1), 2);
    });

    test('answers must be in the bank', () {
      expect(
        () => parse<DeductionConfig>('deduction', {
          'sentences': [
            {
              'textKey': 's1',
              'blanks': ['x'],
            },
          ],
          'words': ['y'],
        }),
        throwsAt(r'$.config.sentences[0].blanks[0]', '"x" is not in words'),
      );
    });
  });

  group('reveal', () {
    final config = parse<RevealConfig>('reveal', {
      'style': 'wipe',
      'hidden': 'images/h.png',
      'area': [0.25, 0.25, 0.5, 0.5],
      'threshold': 0.5,
      'brush': 0.1,
    });

    test('strokes uncover the area until the threshold', () {
      var state = config.start();
      expect(state.progress, 0);
      state = state.stroke(0.05, 0.05, aspect: 1); // outside the area
      expect(state.progress, 0);
      for (var x = 0.3; x <= 0.7; x += 0.05) {
        state = state.stroke(x, 0.4, aspect: 1);
      }
      expect(state.progress, greaterThan(0.2));
      expect(state.isSolved, isFalse);
      for (var x = 0.3; x <= 0.7; x += 0.05) {
        state = state.stroke(x, 0.6, aspect: 1);
      }
      expect(state.isSolved, isTrue);
      expect(state.uncoverAll().progress, 1);
    });

    test('the same stroke twice changes nothing', () {
      final once = config.start().stroke(0.5, 0.5, aspect: 1);
      expect(identical(once.stroke(0.5, 0.5, aspect: 1), once), isTrue);
    });

    test('style must be wipe or rub', () {
      expect(
        () => parse<RevealConfig>('reveal', {
          'style': 'scratch',
          'hidden': 'h.png',
          'area': [0, 0, 1, 1],
        }),
        throwsAt(r'$.config.style', 'expected wipe or rub'),
      );
    });
  });

  group('validation', () {
    List<ContentIssue> validate(
      Map<String, Map<String, String>> strings, {
      List<Map<String, Object?>>? puzzles,
    }) => validateEpisode(
      buildTestEpisode(game: gameWithWords(), puzzles: puzzles),
      assets: const {},
      strings: strings,
    ).where((i) => i.isError).toList();

    Map<String, String> base() => {
      'word.bucks_row': "Buck's Row",
      'word.nichols': 'Mary Ann Nichols',
      'word.north': 'north',
    };

    test('an unsolvable deduction and a mismatched template are errors', () {
      final issues = validate(
        {
          'en': {...base(), 's1': '{1} was found.'},
        },
        puzzles: [
          {
            'id': 'label',
            'type': 'deduction',
            'config': {
              'sentences': [
                {
                  'textKey': 's1',
                  'blanks': ['nichols', 'bucks_row'],
                },
              ],
              'words': ['nichols', 'bucks_row'],
            },
          },
        ],
      ).map((i) => i.message).join('\n');
      expect(issues, contains('must hold {1}…{2} once each'));
      expect(issues, contains('a deduction answer that is neither given'));
    });
  });
}
