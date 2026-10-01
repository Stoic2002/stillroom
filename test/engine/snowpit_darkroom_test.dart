import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/engine/engine.dart';

import 'puzzle_types_test.dart' show parse, throwsAt;

void main() {
  group('snowpit', () {
    Map<String, Object?> json() => {
      'layers': [
        {'thickness': 10, 'hardness': 'fist'},
        {'thickness': 30, 'hardness': 'oneFinger'},
        {'thickness': 5, 'hardness': 'fist'},
        {'thickness': 5, 'hardness': 'knife'},
        {'thickness': 20, 'hardness': 'fourFingers'},
      ],
      'weak': 2,
      'breakTap': 14,
    };

    test(
      'push to learn each layer, mark the weak one, tap until it breaks',
      () {
        final config = parse<SnowpitConfig>('snowpit', json());
        expect(config.goesIn(1, SnowHardness.fist), isFalse);
        expect(config.goesIn(1, SnowHardness.oneFinger), isTrue);
        expect(config.goesIn(1, SnowHardness.knife), isTrue);
        var state = config.start();
        expect(state.judge(2), SnowpitMark.untested);

        // One finger goes into layer 1 but four fingers do not: one finger.
        state = state.push(1, SnowHardness.oneFinger);
        expect(state.known(1), isFalse, reason: 'four fingers not tried');
        state = state.push(1, SnowHardness.fourFingers);
        expect(state.known(1), isTrue);
        state = state.push(2, SnowHardness.fist);
        expect(state.known(2), isTrue, reason: 'a fist is the largest');
        state = state.push(0, SnowHardness.fist);
        expect(state.judge(1), SnowpitMark.notSofter);
        state = state.mark(1);
        expect(state.mistakes, 1);
        expect(state.marked, isNull);

        // The crust over the soft layer below it: a distractor.
        state = state
            .push(3, SnowHardness.knife)
            .push(3, SnowHardness.pencil)
            .push(4, SnowHardness.fourFingers)
            .push(4, SnowHardness.fist);
        expect(state.allKnown, isTrue);
        state = state.mark(4);
        expect(state.marked, 4);
        for (var k = 0; k < 14; k++) {
          state = state.tap();
        }
        expect(state.broken, 2, reason: 'the column broke higher up');
        expect(state.isSolved, isFalse);
        expect(state.mistakes, 2);
        expect(state.tap(), same(state));

        state = state.mark(2);
        expect(state.taps, 0, reason: 'a fresh column');
        for (var k = 0; k < 13; k++) {
          state = state.tap();
        }
        expect(state.broken, isNull);
        state = state.tap();
        expect(state.isSolved, isTrue);
        expect(state.mistakes, 2);
      },
    );

    test('a column above the weak layer never breaks', () {
      final config = parse<SnowpitConfig>('snowpit', {
        ...json(),
        'layers': [
          {'thickness': 10, 'hardness': 'pencil'},
          {'thickness': 30, 'hardness': 'fourFingers'},
          {'thickness': 5, 'hardness': 'knife'},
          {'thickness': 5, 'hardness': 'fist'},
        ],
        'weak': 3,
      });
      var state = config.start();
      for (final (i, t) in [
        (0, SnowHardness.pencil),
        (0, SnowHardness.oneFinger),
        (1, SnowHardness.fourFingers),
        (1, SnowHardness.fist),
      ]) {
        state = state.push(i, t);
      }
      state = state.mark(1);
      for (var k = 0; k < 40; k++) {
        state = state.tap();
      }
      expect(state.taps, SnowpitType.taps);
      expect(state.spent, isTrue);
      expect(state.broken, isNull);
    });

    test('the weak layer is softer than the one above', () {
      expect(
        () => parse<SnowpitConfig>('snowpit', {...json(), 'weak': 1}),
        throwsAt(r'$.config.weak'),
      );
      expect(
        () => parse<SnowpitConfig>('snowpit', {...json(), 'breakTap': 31}),
        throwsAt(r'$.config.breakTap'),
      );
      expect(
        () => parse<SnowpitConfig>('snowpit', {
          ...json(),
          'layers': [
            {'thickness': 10, 'hardness': 'slush'},
            {'thickness': 10, 'hardness': 'fist'},
            {'thickness': 10, 'hardness': 'fist'},
          ],
        }),
        throwsAt(r'$.config.layers[0].hardness'),
      );
    });
  });

  group('darkroom', () {
    Map<String, Object?> json() => {
      'strip': [2, 4, 8, 16, 32],
      'frames': [
        {'image': 'a.png', 'captionKey': 'a', 'exposure': 2},
        {'image': 'b.png', 'captionKey': 'b', 'exposure': 1},
      ],
    };

    test('print each frame at its band; others spoil', () {
      final config = parse<DarkroomConfig>('darkroom', json());
      var state = config.start();
      expect(state.tone(0, 0), -2);
      expect(state.tone(0, 3), 1);
      state = state.print(0, 3);
      expect(state.spoiled, (0, 3));
      expect(state.mistakes, 1);
      state = state.print(0, 2);
      expect(state.printed, {0});
      expect(state.spoiled, isNull);
      expect(state.print(0, 2), same(state), reason: 'already printed');
      state = state.print(1, 1);
      expect(state.isSolved, isTrue);
    });

    test('a frame is never right at the strip ends', () {
      expect(
        () => parse<DarkroomConfig>('darkroom', {
          ...json(),
          'frames': [
            {'image': 'a.png', 'captionKey': 'a', 'exposure': 4},
          ],
        }),
        throwsAt(r'$.config.frames[0].exposure'),
      );
      expect(
        () => parse<DarkroomConfig>('darkroom', {
          ...json(),
          'strip': [2, 8, 4],
        }),
        throwsAt(r'$.config.strip[2]'),
      );
    });
  });
}
