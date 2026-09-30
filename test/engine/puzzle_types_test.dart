import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/engine/engine.dart';

import 'fixtures/test_episode.dart';

T parse<T extends PuzzleConfig>(String type, Map<String, Object?> config) {
  final registry = PuzzleTypeRegistry();
  registerBuiltInPuzzleTypes(registry);
  return registry.parseConfig(doc('p.json', {'type': type, 'config': config}))
      as T;
}

Matcher throwsAt(String path, [String message = '']) => throwsA(
  isA<ContentFormatException>()
      .having((e) => e.path, 'path', path)
      .having((e) => e.message, 'message', contains(message)),
);

void main() {
  group('codeLock', () {
    final config = parse<CodeLockConfig>('codeLock', {
      'slots': 3,
      'symbols': ['A', 'B', 'C'],
      'solution': ['C', 'A', 'B'],
    });

    test('starts on the first symbol and wraps both ways', () {
      var state = config.start();
      expect([for (var i = 0; i < 3; i++) state.symbolAt(i)], ['A', 'A', 'A']);
      state = state.rotate(0, -1);
      expect(state.symbolAt(0), 'C');
      state = state.rotate(0, 1).rotate(0, 1);
      expect(state.symbolAt(0), 'B');
    });

    test('is solved only when every dial matches', () {
      var state = config.start().rotate(0, 2);
      expect(state.isSolved, isFalse);
      state = state.rotate(2, 1);
      expect(state.isSolved, isTrue);
      expect(state.rotate(1, 1).isSolved, isFalse);
    });

    test('initial positions are honored', () {
      final withInitial = parse<CodeLockConfig>('codeLock', {
        'slots': 2,
        'symbols': ['0', '1'],
        'solution': ['1', '1'],
        'initial': ['1', '0'],
      });
      expect(withInitial.start().positions, [1, 0]);
    });

    test('rejects bad configs', () {
      expect(
        () => parse<CodeLockConfig>('codeLock', {
          'slots': 2,
          'symbols': ['0', '1'],
          'solution': ['1'],
        }),
        throwsAt(r'$.config.solution', 'expected 2'),
      );
      expect(
        () => parse<CodeLockConfig>('codeLock', {
          'slots': 1,
          'symbols': ['0', '1'],
          'solution': ['7'],
        }),
        throwsAt(r'$.config.solution[0]', 'not in symbols'),
      );
      expect(
        () => parse<CodeLockConfig>('codeLock', {
          'slots': 1,
          'symbols': ['0', '0'],
          'solution': ['0'],
        }),
        throwsAt(r'$.config.symbols', 'unique'),
      );
    });
  });

  group('sequence', () {
    final config = parse<SequenceConfig>('sequence', {
      'elements': [
        for (final id in ['a', 'b', 'c'])
          {
            'id': id,
            'rect': [0.1, 0.1, 0.1, 0.1],
          },
      ],
      'solution': ['b', 'a', 'b', 'c'],
    });

    test('correct taps progress, the last one solves', () {
      var state = config.start();
      SequenceOutcome outcome;
      for (final (id, expected) in [
        ('b', SequenceOutcome.progress),
        ('a', SequenceOutcome.progress),
        ('b', SequenceOutcome.progress),
        ('c', SequenceOutcome.solved),
      ]) {
        (state, outcome) = state.tap(id);
        expect(outcome, expected, reason: 'tap $id');
      }
      expect(state.isSolved, isTrue);
    });

    test('a wrong tap resets; it counts as step one if it matches', () {
      var (state, _) = config.start().tap('b');
      SequenceOutcome outcome;
      (state, outcome) = state.tap('c');
      expect(outcome, SequenceOutcome.mistake);
      expect(state.progress, 0);

      (state, _) = state.tap('b');
      (state, outcome) = state.tap('b'); // expected 'a'; 'b' restarts at 1
      expect(outcome, SequenceOutcome.mistake);
      expect(state.progress, 1);
    });

    test('solution must reference known elements', () {
      expect(
        () => parse<SequenceConfig>('sequence', {
          'elements': [
            {
              'id': 'a',
              'rect': [0, 0, 0.1, 0.1],
            },
          ],
          'solution': ['z'],
        }),
        throwsAt(r'$.config.solution[0]', 'unknown element'),
      );
    });

    test('element images are validator references', () {
      final withImage = parse<SequenceConfig>('sequence', {
        'elements': [
          {
            'id': 'a',
            'rect': [0, 0, 0.1, 0.1],
            'image': 'images/x.png',
          },
        ],
        'solution': ['a'],
      });
      expect(withImage.references, [const ContentRef.image('images/x.png')]);
    });
  });

  group('rotaryAlign', () {
    final config = parse<RotaryAlignConfig>('rotaryAlign', {
      'rings': [
        {
          'id': 'outer',
          'steps': 4,
          'initial': 3,
          'target': 0,
          'links': [
            {'ring': 'inner', 'steps': -1},
          ],
        },
        {'id': 'inner', 'steps': 6, 'initial': 1, 'target': 0},
      ],
    });

    test('turning steps clockwise and drags linked rings', () {
      var state = config.start();
      expect(state.positions, [3, 1]);
      state = state.turn(0);
      expect(state.positions, [0, 0], reason: 'outer wraps, inner -1');
      expect(state.isSolved, isTrue);
      expect(state.turnOf(1), 0);
      state = state.turn(1);
      expect(state.positions, [0, 1]);
      expect(state.turnOf(1), closeTo(1 / 6, 1e-9));
    });

    test('negative links wrap below zero', () {
      final state = config.start().turn(1).turn(0).turn(0);
      // inner: 1 → 2 → 1 → 0; outer: 3 → 0 → 1
      expect(state.positions, [1, 0]);
    });

    test('rejects bad rings', () {
      expect(
        () => parse<RotaryAlignConfig>('rotaryAlign', {
          'rings': [
            {'id': 'r', 'steps': 4, 'initial': 4, 'target': 0},
          ],
        }),
        throwsAt(r'$.config.rings[0].initial', '0–3'),
      );
      expect(
        () => parse<RotaryAlignConfig>('rotaryAlign', {
          'rings': [
            {
              'id': 'r',
              'steps': 4,
              'initial': 0,
              'target': 0,
              'links': [
                {'ring': 'ghost', 'steps': 1},
              ],
            },
          ],
        }),
        throwsAt(r'$.config.rings[0].links[0]', 'ghost'),
      );
    });
  });

  group('slotPlacement', () {
    final config = parse<SlotPlacementConfig>('slotPlacement', {
      'pieces': [
        {'id': 'sun'},
        {'id': 'moon'},
        {'id': 'gem', 'item': 'lens'},
      ],
      'slots': [
        for (final id in ['left', 'mid', 'right'])
          {
            'id': id,
            'rect': [0.1, 0.1, 0.1, 0.1],
          },
      ],
      'solution': {'left': 'sun', 'mid': 'gem', 'right': 'moon'},
      'initial': {'left': 'moon'},
    });
    const without = GameState(episodeId: 'e', sceneId: 's');
    const withLens = GameState(
      episodeId: 'e',
      sceneId: 's',
      inventory: ['lens'],
    );

    test('item pieces need the item; initial placement is applied', () {
      final state = config.start(without);
      expect(state.available, {'sun', 'moon'});
      expect(state.placed, {'left': 'moon'});
      expect(state.tray, ['sun']);
      expect(config.start(withLens).tray, ['sun', 'gem']);
    });

    test('place, swap, pick up, and solve', () {
      var state = config.start(withLens);
      // Move sun onto the occupied left slot: moon returns to the tray.
      state = state.selectPiece('sun').tapSlot('left');
      expect(state.placed, {'left': 'sun'});
      expect(state.tray, ['moon', 'gem']);

      state = state.selectPiece('moon').tapSlot('mid');
      state = state.selectPiece('gem').tapSlot('right');
      expect(state.isSolved, isFalse);

      // Pick up moon from mid and drop it on right: gem swaps into mid.
      state = state.tapSlot('mid');
      expect(state.selected, 'moon');
      state = state.tapSlot('right');
      expect(state.placed, {'left': 'sun', 'mid': 'gem', 'right': 'moon'});
      expect(state.isSolved, isTrue);
    });

    test('tapping the slot of the held piece puts it down; clearSlot', () {
      var state = config.start(without).tapSlot('left');
      expect(state.selected, 'moon');
      state = state.tapSlot('left');
      expect(state.selected, isNull);
      expect(state.clearSlot('left').tray, ['sun', 'moon']);
    });

    test('unavailable pieces cannot be selected', () {
      final state = config.start(without).selectPiece('gem');
      expect(state.selected, isNull);
    });

    test('references include piece items and images', () {
      expect(config.references, [const ContentRef.item('lens')]);
    });

    test('rejects bad assignments', () {
      Map<String, Object?> base(Map<String, Object?> solution) => {
        'pieces': [
          {'id': 'a'},
          {'id': 'b'},
        ],
        'slots': [
          {
            'id': 's1',
            'rect': [0, 0, 0.1, 0.1],
          },
          {
            'id': 's2',
            'rect': [0, 0, 0.1, 0.1],
          },
        ],
        'solution': solution,
      };
      expect(
        () => parse<SlotPlacementConfig>('slotPlacement', base({'s9': 'a'})),
        throwsAt(r'$.config.solution.s9', 'unknown slot'),
      );
      expect(
        () => parse<SlotPlacementConfig>(
          'slotPlacement',
          base({'s1': 'a', 's2': 'a'}),
        ),
        throwsAt(r'$.config.solution.s2', 'used twice'),
      );
    });
  });

  test('withBuiltIns registers every built-in type', () {
    expect(ContentRegistries.withBuiltIns().puzzleTypes.types, [
      'codeLock',
      'sequence',
      'rotaryAlign',
      'slotPlacement',
      'deduction',
      'reveal',
      'crank',
      'overlay',
      'clockHands',
      'thread',
      'rakingLight',
      'beamSweep',
      'swell',
      'roster',
      'keyring',
      'cipher',
      'sources',
      'pour',
      'resonance',
      'beat',
      'unwatched',
      'compose',
    ]);
  });
}
