import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/engine/engine.dart';

import 'puzzle_types_test.dart' show parse, throwsAt;

void main() {
  group('strata', () {
    Map<String, Object?> find(String key, int year) => {
      'labelKey': key,
      'year': year,
    };
    Map<String, Object?> json() => {
      'layers': [
        {
          'labelKey': 'top',
          'finds': [find('yen', 1951)],
        },
        {
          'labelKey': 'fill',
          'finds': [find('eiraku', 1408)],
        },
        {
          'labelKey': 'late_ash',
          'burnt': true,
          'finds': [find('kanei', 1636)],
        },
        {
          'labelKey': 'fire',
          'burnt': true,
          'finds': [find('tile', 1400), find('eiraku', 1408)],
        },
        {
          'labelKey': 'sludge',
          'finds': [find('genpo', 1078)],
        },
      ],
      'fireYear': 1582,
      'fire': 3,
    };

    test('each layer dated by its finds and the layer beneath', () {
      final config = parse<StrataConfig>('strata', json());
      expect(
        [for (var i = 0; i < 5; i++) config.earliest(i)],
        [1951, 1636, 1636, 1408, 1078],
        reason: 'the fill holds only an old coin, but lies on later ash',
      );
      expect(config.years, [1078, 1400, 1408, 1636, 1951]);
      var state = config.start();
      state = state.date(1, 1408);
      expect(state.mistakes, 1);
      expect(state.judgeFire(3), StrataFire.undated);
      for (var i = 0; i < 5; i++) {
        state = state.date(i, config.earliest(i));
      }
      expect(state.allDated, isTrue);
      expect(state.judgeFire(4), StrataFire.notBurnt);
      expect(state.judgeFire(2), StrataFire.tooLate);
      state = state.markFire(2);
      expect(state.mistakes, 2);
      expect(state.isSolved, isFalse);
      state = state.markFire(3);
      expect(state.isSolved, isTrue);
    });

    test('the fire layer must be burnt and the only one old enough', () {
      final layers = (json()['layers']! as List).cast<Map<String, Object?>>();
      expect(
        () => parse<StrataConfig>('strata', {...json(), 'fire': 4}),
        throwsAt(r'$.config.fire'),
      );
      expect(
        () => parse<StrataConfig>('strata', {
          ...json(),
          'layers': [
            ...layers.take(4),
            {...layers[4], 'burnt': true},
          ],
        }),
        throwsAt(r'$.config.layers[4]'),
      );
    });
  });

  group('streets', () {
    Map<String, Object?> json() => {
      'columns': [
        for (final s in ['w', 'mid', 'e']) {'labelKey': s},
      ],
      'rows': [
        for (final s in ['n', 'mid', 's']) {'labelKey': s},
      ],
      'targets': [
        {
          'clueKey': 'old',
          'block': [0, 1],
        },
        {
          'clueKey': 'new',
          'block': [1, 0],
        },
      ],
    };

    test('mark each address in turn', () {
      final config = parse<StreetsConfig>('streets', json());
      var state = config.start();
      expect(state.current!.clueKey, 'old');
      state = state.mark(1, 0);
      expect(state.mistakes, 1);
      state = state.mark(0, 1).mark(1, 0);
      expect(state.isSolved, isTrue);
      expect(state.current, isNull);
    });

    test('a block must lie between the streets', () {
      expect(
        () => parse<StreetsConfig>('streets', {
          ...json(),
          'targets': [
            {
              'clueKey': 'old',
              'block': [2, 0],
            },
          ],
        }),
        throwsAt(r'$.config.targets[0].block'),
      );
    });
  });
}
