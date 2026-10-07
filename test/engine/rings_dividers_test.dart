import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/engine/engine.dart';

import 'puzzle_types_test.dart' show parse, throwsAt;

void main() {
  group('rings', () {
    final master = [
      0.8, 0.7, 0.9, 0.2, 0.6, 0.8, 0.5, 0.9, 0.7, 0.6, //
      0.3, 0.1, 0.15, 0.6, 0.8, 0.7,
    ];
    Map<String, Object?> json({int offset = 8}) => {
      'startYear': 1580,
      'master': master,
      'core': [for (var i = 8; i < 14; i++) master[i]],
      'offset': offset,
      'run': 2,
    };

    test('slide, check, then mark the narrowest run', () {
      final config = parse<RingsConfig>('rings', json());
      expect(config.lastOffset, 10);
      expect(config.narrowest, 3, reason: '0.1 and 0.15');
      expect(config.yearOf(config.narrowest), 1591);
      var state = config.start();
      state = state.mark(3);
      expect(state.marked, isFalse, reason: 'not dated yet');
      state = state.slide(3).check();
      expect(state.dated, isFalse);
      expect(state.mistakes, 1);
      state = state.slide(99);
      expect(state.position, 10, reason: 'held on the master');
      state = state.slide(8).check();
      expect(state.dated, isTrue);
      expect(state.slide(2).position, 8, reason: 'fixed once dated');
      state = state.mark(2);
      expect(state.mistakes, 2);
      state = state.mark(3);
      expect(state.isSolved, isTrue);
    });

    test('the core must match in one place only', () {
      expect(
        () => parse<RingsConfig>('rings', {
          ...json(),
          'master': [for (var i = 0; i < 16; i++) 0.5],
          'core': [for (var i = 0; i < 6; i++) 0.5],
        }),
        throwsAt(r'$.config.offset'),
      );
      expect(
        () => parse<RingsConfig>('rings', json(offset: 12)),
        throwsAt(r'$.config.offset'),
      );
    });
  });

  group('dividers', () {
    Map<String, Object?> json() => {
      'milesAcross': 100,
      'aspect': 0.5,
      'north': 90,
      'origin': [0.8, 0.5],
      'spans': [10, 25],
      'tolerance': 3,
      'places': [
        {
          'labelKey': 'south',
          'at': [0.3, 0.5],
        },
        {
          'labelKey': 'west',
          'at': [0.8, 0.0],
        },
        {
          'labelKey': 'east',
          'at': [0.8, 0.9],
        },
      ],
      'targets': [
        {'clueKey': 'go_south', 'place': 0},
        {'clueKey': 'go_west', 'place': 1},
      ],
    };

    test('north on the right: south walks left, west walks up', () {
      final config = parse<DividersConfig>('dividers', json());
      var state = config.start();
      expect(state.judge(), DividersMark.unset);
      state = state.setSpan(10).setHeading(Heading.n).step();
      expect(state.standing.x, closeTo(0.9, 1e-9), reason: 'north is right');
      // Two steps east: down the chart, onto another place.
      state = state.setHeading(Heading.e).step().step();
      expect(state.judge(), DividersMark.elsewhere);
      state = state.mark();
      expect(state.mistakes, 1);
      state = state.setSpan(25).setHeading(Heading.s).step().step();
      expect(state.judge(), DividersMark.found);
      state = state.mark();
      expect(state.found, 1);
      expect(state.steps, 0, reason: 'the next walk starts at Roanoke');
      state = state.setSpan(10).setHeading(Heading.w).step();
      expect(state.judge(), DividersMark.nothing);
      state = state.setSpan(25).step();
      expect(state.mark().isSolved, isTrue);
    });

    test('every target must be reachable', () {
      expect(
        () => parse<DividersConfig>('dividers', {
          ...json(),
          'places': [
            {
              'labelKey': 'nowhere',
              'at': [0.33, 0.27],
            },
            {
              'labelKey': 'west',
              'at': [0.8, 0.1],
            },
          ],
        }),
        throwsAt(r'$.config.targets[0]'),
      );
    });
  });
}
