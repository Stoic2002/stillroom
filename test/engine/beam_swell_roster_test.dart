import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/engine/engine.dart';

import 'puzzle_types_test.dart' show parse, throwsAt;

void main() {
  group('beamSweep', () {
    // The pivot at the centre; one target straight right, one straight down.
    BeamSweepConfig config() => parse<BeamSweepConfig>('beamSweep', {
      'pivot': [0.5, 0.5],
      'period': 8,
      'spread': 0.2,
      'targets': [
        {
          'id': 'right',
          'rect': [0.8, 0.45, 0.1, 0.1],
        },
        {
          'id': 'below',
          'rect': [0.45, 0.8, 0.1, 0.1],
          'labelKey': 'below.label',
        },
      ],
    });

    test('the beam turns clockwise from pointing right', () {
      final c = config();
      expect(c.isLit(c.target('right'), 0), isTrue);
      expect(c.isLit(c.target('below'), 0), isFalse);
      // A quarter turn later it points down.
      expect(c.isLit(c.target('below'), 2), isTrue);
      expect(c.isLit(c.target('right'), 2), isFalse);
      // And round again.
      expect(c.isLit(c.target('right'), 8), isTrue);
    });

    test('a lit target is found; a dark one is a miss', () {
      var state = config().start();
      state = state.tap('below', 0);
      expect(state.found, isEmpty);
      expect(state.misses, 1);
      state = state.tap('below', 2).tap('right', 8.05);
      expect(state.found, {'right', 'below'});
      expect(state.isSolved, isTrue);
    });

    test('the board aspect bends the angles to what is on screen', () {
      final c = parse<BeamSweepConfig>('beamSweep', {
        'pivot': [0.0, 0.0],
        'period': 8,
        'spread': 0.05,
        'targets': [
          {
            'id': 'corner',
            'rect': [0.95, 0.95, 0.05, 0.05],
          },
        ],
      });
      // Down the diagonal of a square board is 45°: 1 s into an 8 s turn.
      expect(c.isLit(c.targets.single, 1, aspect: 1), isTrue);
      // On a wide board the same corner is flatter, reached sooner.
      expect(c.isLit(c.targets.single, 1, aspect: 16 / 9), isFalse);
    });

    test('ids are unique and rects stay on the board', () {
      expect(
        () => parse<BeamSweepConfig>('beamSweep', {
          'pivot': [0.5, 0.5],
          'targets': [
            {
              'id': 'a',
              'rect': [0.9, 0.9, 0.2, 0.2],
            },
          ],
        }),
        throwsAt(r'$.config.targets[0].rect'),
      );
    });
  });

  group('swell', () {
    // Six steps; waves every 2 s reaching 2, 1, then a great sea (6).
    SwellConfig config() => parse<SwellConfig>('swell', {
      'steps': 6,
      'stepSeconds': 0.5,
      'interval': 2,
      'pattern': [2, 1, 6],
    });

    test('one step per tap, no faster than a step takes', () {
      var state = config().start();
      state = state.stepDown(0.1);
      expect(state.position, 1);
      state = state.stepDown(0.3);
      expect(state.position, 1, reason: 'still on the way down');
      state = state.stepDown(0.6);
      expect(state.position, 2);
    });

    test('a wave that reaches the step sends the player back up', () {
      var state = config().start();
      for (final t in [0.0, 0.5, 1.0, 1.5]) {
        state = state.stepDown(t);
      }
      expect(state.position, 4);
      // The first wave (reach 2) covers steps 5 and 6: step 4 stays dry.
      state = state.advance(2.1);
      expect(state.position, 4);
      expect(state.lastBreak, (index: 0, reach: 2, caught: false));
      state = state.stepDown(2.2); // onto step 5
      // The second wave (reach 1) covers only the bottom step.
      state = state.advance(4.1);
      expect(state.position, 5);
      // The great sea at 6 s covers every step but the top.
      state = state.advance(6.1);
      expect(state.position, 0);
      expect(state.caught, 1);
      expect(state.lastBreak?.caught, isTrue);
    });

    test('going down right after the great sea reaches the bottom', () {
      var state = config().start().advance(6.05);
      for (var i = 0; i < 6; i++) {
        state = state.stepDown(6.05 + i * 0.5);
      }
      expect(state.isSolved, isTrue);
      expect(state.caught, 0);
    });

    test('waves loop through the pattern', () {
      final c = config();
      expect([for (var i = 0; i < 6; i++) c.reach(i)], [2, 1, 6, 2, 1, 6]);
      expect(c.isGreat(2), isTrue);
      expect(c.breakTime(0), 2);
      expect(c.nextWave(4.5), 2);
    });

    test('a wave cannot reach past the top', () {
      expect(
        () => parse<SwellConfig>('swell', {
          'steps': 4,
          'pattern': [1, 5],
        }),
        throwsAt(r'$.config.pattern[1]'),
      );
    });
  });

  group('roster', () {
    RosterConfig config() => parse<RosterConfig>('roster', {
      'rows': [
        {'id': 'a', 'labelKey': 'row.a'},
        {'id': 'b', 'labelKey': 'row.b'},
      ],
      'columns': [
        {
          'id': 'wore',
          'labelKey': 'col.wore',
          'options': [
            {'id': 'coat', 'labelKey': 'opt.coat'},
            {'id': 'shirt', 'labelKey': 'opt.shirt'},
          ],
        },
      ],
      'solution': {
        'a': {'wore': 'coat'},
        'b': {'wore': 'shirt'},
      },
    });

    test('cells step through their options and round again', () {
      var state = config().start();
      expect(state.pick('a', 'wore'), isNull);
      state = state.cycle('a', 'wore');
      expect(state.pick('a', 'wore'), 'coat');
      state = state.cycle('a', 'wore');
      expect(state.pick('a', 'wore'), 'shirt');
      state = state.cycle('a', 'wore');
      expect(state.pick('a', 'wore'), 'coat');
    });

    test('checked once full: how many rows are wrong, then solved', () {
      var state = config().start().cycle('a', 'wore');
      expect(state.isComplete, isFalse);
      state = state.cycle('b', 'wore'); // b: coat, wrong
      expect(state.isComplete, isTrue);
      expect(state.wrongRows, 1);
      expect(state.isSolved, isFalse);
      state = state.cycle('b', 'wore');
      expect(state.isSolved, isTrue);
    });

    test('the solution names every row and a real option', () {
      expect(
        () => parse<RosterConfig>('roster', {
          'rows': [
            {'id': 'a', 'labelKey': 'row.a'},
            {'id': 'b', 'labelKey': 'row.b'},
          ],
          'columns': [
            {
              'id': 'wore',
              'labelKey': 'col.wore',
              'options': [
                {'id': 'coat', 'labelKey': 'opt.coat'},
                {'id': 'shirt', 'labelKey': 'opt.shirt'},
              ],
            },
          ],
          'solution': {
            'a': {'wore': 'coat'},
            'b': {'wore': 'cape'},
          },
        }),
        throwsAt(r'$.config.solution.b.wore'),
      );
    });

    test('every text it shows is a content reference', () {
      expect(
        config().references.map((r) => r.id),
        containsAll(['row.a', 'col.wore', 'opt.shirt']),
      );
    });
  });
}
