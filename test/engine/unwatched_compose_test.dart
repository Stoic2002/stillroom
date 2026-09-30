import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/engine/engine.dart';

import 'puzzle_types_test.dart' show parse, throwsAt;

void main() {
  group('unwatched', () {
    Map<String, Object?> json() => {
      'items': [
        for (final id in ['a', 'b', 'c', 'd']) {'id': id, 'labelKey': 'k.$id'},
      ],
      'start': ['a', 'b'],
      'rounds': [
        {'add': 'c', 'at': 1},
        {
          'add': 'd',
          'at': 0,
          'move': [3, 1],
        },
      ],
    };

    test('each look away adds one; only the new one is found', () {
      var state = parse<UnwatchedConfig>('unwatched', json()).startState();
      expect(state.added, isNull);
      expect(state.tap('a').mistakes, 0, reason: 'nothing to find yet');
      state = state.lookAway();
      expect(state.shelf, ['a', 'c', 'b']);
      expect(state.lookAway().shelf, state.shelf, reason: 'find it first');
      state = state.tap('a');
      expect(state.mistakes, 1);
      state = state.tap('c');
      expect(state.round, 1);
      state = state.lookAway();
      // d goes in at 0, then the last moves to 1.
      expect(state.shelf, ['d', 'b', 'a', 'c']);
      state = state.tap('d');
      expect(state.isSolved, isTrue);
    });

    test('an addition must not be on the shelf already', () {
      expect(
        () => parse<UnwatchedConfig>('unwatched', {
          ...json(),
          'rounds': [
            {'add': 'a', 'at': 0},
          ],
        }),
        throwsAt(r'$.config.rounds[0].add'),
      );
    });
  });

  group('compose', () {
    ComposeConfig config() => parse<ComposeConfig>('compose', {
      'text': 'RED ROSE',
      'reversed': ['R', 'E'],
      'extra': ['P'],
    });

    test('the case holds every letter once, plus the wrong-way twins', () {
      final sorts = config().sortCase;
      expect(sorts, hasLength(6 + 2));
      expect(sorts.toSet(), hasLength(sorts.length));
      expect(sorts, contains(const Sort('R', wrongWay: true)));
    });

    test('a wrongly cut sort prints wrong; set right, it solves', () {
      var state = config().start();
      for (final l in 'RED ROS'.split('')) {
        state = state.set(Sort(l));
      }
      state = state.set(const Sort('E', wrongWay: true));
      expect(state.isFull, isTrue);
      expect(state.isSolved, isFalse);
      expect(state.wrong, {7});
      state = state.takeOut().set(const Sort('E'));
      expect(state.isSolved, isTrue);
    });

    test('letters that look the same in a mirror cannot be reversed', () {
      expect(
        () => parse<ComposeConfig>('compose', {
          'text': 'TOM',
          'reversed': ['O'],
        }),
        throwsAt(r'$.config.reversed[0]'),
      );
    });
  });
}
