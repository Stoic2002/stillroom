import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/engine/engine.dart';

import 'puzzle_types_test.dart' show parse, throwsAt;

void main() {
  group('strand', () {
    Map<String, Object?> json() => {
      'strands': [
        {
          'readings': [1, 2, 4, 9, 5, 3, 2, 1],
        },
        {
          'readings': [1, 1, 2, 3, 4, 8, 3, 2],
        },
      ],
      'measurements': 4,
      'curve': 'peak',
    };

    test('measure within the budget, mark the peaks, name the curve', () {
      final config = parse<StrandConfig>('strand', json());
      expect(config.peak(0), 3);
      expect(config.peak(1), 5);
      var state = config.start();
      expect(state.left(0), 4);
      state = state.measure(0, 1).measure(0, 5).measure(0, 1);
      expect(state.left(0), 2, reason: 'a segment is measured once');
      expect(state.mark(0, 3), same(state), reason: 'not measured yet');
      state = state.mark(0, 5);
      expect(state.mistakes, 1);
      state = state.measure(0, 2).measure(0, 4).measure(0, 3);
      expect(state.measured[0], {1, 5, 2, 4}, reason: 'out of time');
      state = state.newSample(0);
      expect(state.samples, 1);
      expect(state.left(0), 4);
      state = state.measure(0, 3).mark(0, 3);
      expect(state.found, [true, false]);
      expect(state.choose(StrandCurve.peak).answered, isFalse);
      state = state.measure(1, 5).mark(1, 5);
      expect(state.allFound, isTrue);
      state = state.choose(StrandCurve.steady);
      expect(state.mistakes, 2);
      expect(state.isSolved, isFalse);
      state = state.choose(StrandCurve.peak);
      expect(state.isSolved, isTrue);
    });

    test('a strand needs one clear highest reading', () {
      expect(
        () => parse<StrandConfig>('strand', {
          ...json(),
          'strands': [
            {
              'readings': [1, 9, 2, 9, 1, 1],
            },
          ],
        }),
        throwsAt(r'$.config.strands[0].readings'),
      );
    });

    test('the budget must leave something to search', () {
      expect(
        () => parse<StrandConfig>('strand', {...json(), 'measurements': 8}),
        throwsAt(r'$.config.measurements'),
      );
      expect(
        () => parse<StrandConfig>('strand', {...json(), 'curve': 'flat'}),
        throwsAt(r'$.config.curve'),
      );
    });
  });

  group('scan', () {
    Map<String, Object?> json() => {
      'layers': [
        {'id': 'outer', 'labelKey': 'k.outer', 'scale': 0.4},
        {'id': 'inner', 'labelKey': 'k.inner', 'scale': 1},
      ],
      'spots': [
        {
          'id': 'a',
          'labelKey': 'k.a',
          'at': [0.3, 0.3],
          'radius': 0.1,
          'strength': 0.8,
        },
        {
          'id': 'b',
          'labelKey': 'k.b',
          'at': [0.7, 0.6],
          'radius': 0.1,
          'strength': 0.9,
        },
      ],
      'background': 0.05,
    };

    test('the inner layer reads high where the spots are', () {
      final config = parse<ScanConfig>('scan', json());
      expect(config.reading(1, 0.3, 0.3), closeTo(0.85, 0.01));
      expect(config.reading(0, 0.3, 0.3), lessThan(ScanType.clear));
      expect(config.reading(1, 0.05, 0.95), closeTo(0.05, 0.01));
      var state = config.start();
      expect(state.judge(0.3, 0.3), ScanMark.faint, reason: 'outer only');
      expect(state.mark(0.3, 0.3), same(state));
      state = state.mark(0.05, 0.95);
      expect(state.mistakes, 1);
      state = state.show(1).mark(0.31, 0.29);
      expect(state.found, {'a'});
      expect(state.judge(0.3, 0.3), ScanMark.again);
      state = state.mark(0.7, 0.62);
      expect(state.isSolved, isTrue);
    });

    test('every spot must read clear on the strongest layer', () {
      expect(
        () => parse<ScanConfig>('scan', {...json(), 'background': 0.6}),
        throwsAt(r'$.config.background'),
      );
      final weak = json();
      (weak['spots']! as List<Object?>)[0] = {
        'id': 'a',
        'labelKey': 'k.a',
        'at': [0.3, 0.3],
        'radius': 0.1,
        'strength': 0.2,
      };
      expect(
        () => parse<ScanConfig>('scan', weak),
        throwsAt(r'$.config.spots[0]'),
      );
      expect(
        () => parse<ScanConfig>('scan', {
          ...json(),
          'layers': [
            {'id': 'outer', 'labelKey': 'k.outer', 'scale': 0.4},
          ],
        }),
        throwsAt(r'$.config.layers'),
      );
    });
  });
}
