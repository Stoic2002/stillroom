import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/engine/engine.dart';

import 'puzzle_types_test.dart' show parse, throwsAt;

void main() {
  group('mudra', () {
    Map<String, Object?> json() => {
      'statues': ['earth', 'meditation', 'earth', 'wheel'],
      'places': [
        {'labelKey': 'east', 'mudra': 'earth', 'slots': 2},
        {'labelKey': 'west', 'mudra': 'meditation', 'slots': 1},
        {'labelKey': 'stupa', 'mudra': 'wheel', 'slots': 1},
      ],
    };

    test('each statue goes where its hands belong', () {
      final config = parse<MudraConfig>('mudra', json());
      var state = config.start();
      expect(state.judge(0, 1), MudraSet.wrong);
      state = state.set(0, 1);
      expect(state.mistakes, 1);
      state = state.set(0, 0).set(2, 0);
      expect(state.filled(0), 2);
      state = state.set(1, 1).set(3, 2);
      expect(state.isSolved, isTrue);
    });

    test('the slots must match the statues', () {
      final places = (json()['places']! as List).cast<Map<String, Object?>>();
      expect(
        () => parse<MudraConfig>('mudra', {
          ...json(),
          'places': [
            {...places[0], 'slots': 1},
            ...places.skip(1),
          ],
        }),
        throwsAt(r'$.config.places[0]'),
      );
      expect(
        () => parse<MudraConfig>('mudra', {
          ...json(),
          'statues': ['earth', 'wave', 'earth', 'wheel'],
        }),
        throwsAt(r'$.config.statues[1]'),
      );
    });
  });

  group('casing', () {
    Map<String, Object?> json() => {
      'columns': 2,
      'panels': [
        {'labelKey': 'anger', 'pair': 0},
        {'labelKey': 'poverty', 'pair': 1, 'fruit': true},
        {'labelKey': 'stinginess', 'pair': 1},
        {'labelKey': 'ugliness', 'pair': 0, 'fruit': true},
      ],
    };

    test('two at a time; a deed and its fruit are kept', () {
      final config = parse<CasingConfig>('casing', json());
      expect(config.rows, 2);
      var state = config.start();
      expect(state.judge(0), CasingLift.first);
      state = state.lift(0);
      expect(state.judge(0), CasingLift.none, reason: 'out already');
      expect(state.judge(1), CasingLift.noPair);
      state = state.lift(1);
      expect(state.mismatches, 1);
      expect(state.open, [0, 1]);
      // The next lift puts those two back first.
      state = state.lift(2);
      expect(state.open, [2]);
      state = state.lift(1);
      expect(state.kept, {1, 2});
      state = state.lift(0).lift(3);
      expect(state.isSolved, isTrue);
    });

    test('every pair needs one deed and one fruit', () {
      expect(
        () => parse<CasingConfig>('casing', {
          ...json(),
          'panels': [
            {'labelKey': 'a', 'pair': 0},
            {'labelKey': 'b', 'pair': 0},
            {'labelKey': 'c', 'pair': 1},
            {'labelKey': 'd', 'pair': 1, 'fruit': true},
          ],
        }),
        throwsAt(r'$.config.panels'),
      );
    });
  });
}
