import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/engine/engine.dart';

import 'puzzle_types_test.dart' show parse, throwsAt;

void main() {
  group('pour', () {
    // Two furnaces over columns 0 and 2, two cups under columns 0 and 2:
    //   straight | empty | straight
    //   straight | empty | straight
    Map<String, Object?> json({List<int> start = const [1, 0, 0, 0, 0, 0]}) => {
      'columns': 3,
      'furnaces': [0, 2],
      'cups': [0, 2],
      'tiles': [
        'straight:0',
        'empty',
        'straight:0',
        'straight:0',
        'empty',
        'straight:0',
      ],
      'start': start,
    };

    test('turning the scrambled piece back lets it pour', () {
      var state = parse<PourConfig>('pour', json()).start();
      expect(state.flow.isSolved, isFalse);
      expect(state.flow.leaks, isNotEmpty);
      state = state.pour();
      expect(state.isSolved, isFalse);
      expect(state.pours, 1);
      state = state.turn(0).pour();
      expect(state.isSolved, isTrue);
    });

    test('sand cannot be turned', () {
      final state = parse<PourConfig>('pour', json()).start();
      expect(state.turn(1).turns, state.turns);
    });

    test('a bend feeds one cup from a furnace beside it', () {
      // furnace over col 0; cup under col 1:
      //   bend(top,right) → turned so it opens top and right: turns 0
      //   then the piece to its right opens left and bottom: bend turns 2
      final config = parse<PourConfig>('pour', {
        'columns': 2,
        'furnaces': [0],
        'cups': [1],
        'tiles': ['bend:0', 'bend:2'],
        'start': [1, 0],
      });
      expect(config.start().flow.isSolved, isFalse);
      expect(config.flow([0, 2]).isSolved, isTrue);
      expect(config.flow([0, 2]).filled, {1});
    });

    test('the solved turns must pour, and the start must not', () {
      expect(
        () => parse<PourConfig>('pour', {
          ...json(),
          'tiles': [
            'straight:1',
            'empty',
            'straight:0',
            'straight:0',
            'empty',
            'straight:0',
          ],
        }),
        throwsAt(r'$.config.tiles'),
      );
      expect(
        () => parse<PourConfig>('pour', json(start: [0, 0, 0, 0, 0, 0])),
        throwsAt(r'$.config.start'),
      );
    });
  });

  group('resonance', () {
    ResonanceConfig config() => parse<ResonanceConfig>('resonance', {
      'depths': 5,
      'start': 0,
      'right': 3,
      'mark': 0.8,
    });

    test('only a strong pull over the right hollow reaches the mark', () {
      var state = config().startState();
      state = state.strike(1);
      expect(state.isSolved, isFalse, reason: 'too shallow');
      state = state.dig().dig();
      expect(state.strike(1).isSolved, isFalse, reason: 'one step off');
      state = state.dig();
      expect(state.depth, 3);
      expect(state.strike(0.6).isSolved, isFalse, reason: 'too gentle');
      expect(state.strike(0.3).lastRing, 0, reason: 'barely touches');
      expect(state.strike(0.9).isSolved, isTrue);
    });

    test('the hollow stays within its depths', () {
      final state = config().startState();
      expect(state.fill().depth, 0);
      var deep = state;
      for (var i = 0; i < 9; i++) {
        deep = deep.dig();
      }
      expect(deep.depth, 4);
    });

    test('the mark must beat every wrong depth', () {
      expect(
        () => parse<ResonanceConfig>('resonance', {
          'depths': 5,
          'start': 0,
          'right': 3,
          'mark': 0.7,
        }),
        throwsAt(r'$.config.mark'),
      );
    });
  });

  group('beat', () {
    BeatConfig config() => parse<BeatConfig>('beat', {
      'swell': [0.2, 0.45, 0.3, 0.55, 0.35, 0.9, 0.4, 0.25],
    });

    test('marking the deepest swell solves it; others are mistakes', () {
      var state = config().start().strike(1).strike(5);
      state = state.mark(3);
      expect(state.isSolved, isFalse);
      expect(state.mistakes, 1);
      state = state.mark(5);
      expect(state.isSolved, isTrue);
    });

    test('the deepest swell must stand out', () {
      expect(
        () => parse<BeatConfig>('beat', {
          'swell': [0.2, 0.8, 0.3, 0.55, 0.35, 0.9, 0.4, 0.25],
        }),
        throwsAt(r'$.config.swell[1]'),
      );
    });
  });
}
