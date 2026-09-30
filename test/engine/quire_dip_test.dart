import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/engine/engine.dart';

import 'puzzle_types_test.dart' show parse, throwsAt;

void main() {
  group('quire', () {
    Map<String, Object?> json() => {
      'leaves': ['l0', 'l1', 'l2', 'l3', 'l4', 'l5'],
      'start': [
        {'sheet': 2, 'turned': false},
        {'sheet': 0, 'turned': true},
        {'sheet': 1, 'turned': false},
      ],
    };

    test('sheets nest: one leaf near the front, its partner near the back', () {
      final config = parse<QuireConfig>('quire', json());
      expect(config.sheets, 3);
      var state = config.start();
      // Outermost sheet 2 (leaves 2 and 3), then sheet 0 turned (5, 0),
      // then sheet 1 (1, 4) at the centre.
      expect([for (var p = 0; p < 6; p++) state.leafAt(p)], [2, 5, 1, 4, 0, 3]);
      expect(state.isSolved, isFalse);
      expect(state.links, 0);

      state = state.swap(0, 1);
      expect(state.order, [0, 2, 1]);
      expect(state.moves, 1);
      expect(state.leafAt(0), 5, reason: 'sheet 0 is still turned over');
      state = state.turn(0);
      expect(state.leafAt(0), 0);
      expect(state.leafAt(5), 5);
      expect(state.linked(0), isFalse);
      state = state.swap(1, 2);
      expect([for (var p = 0; p < 6; p++) state.leafAt(p)], [0, 1, 2, 3, 4, 5]);
      expect(state.isSolved, isTrue);
      expect(state.swap(0, 1), same(state), reason: 'solved stays solved');
      expect(state.turn(1), same(state));
    });

    test('the start may not already read through', () {
      expect(
        () => parse<QuireConfig>('quire', {
          ...json(),
          'start': [
            {'sheet': 0, 'turned': false},
            {'sheet': 1, 'turned': false},
            {'sheet': 2, 'turned': false},
          ],
        }),
        throwsAt(r'$.config.start'),
      );
    });

    test('an even number of leaves, each sheet laid once', () {
      expect(
        () => parse<QuireConfig>('quire', {
          ...json(),
          'leaves': ['a', 'b', 'c', 'd', 'e'],
        }),
        throwsAt(r'$.config.leaves'),
      );
      expect(
        () => parse<QuireConfig>('quire', {
          ...json(),
          'start': [
            {'sheet': 2, 'turned': false},
            {'sheet': 2, 'turned': true},
            {'sheet': 1, 'turned': false},
          ],
        }),
        throwsAt(r'$.config.start[1].sheet'),
      );
      expect(
        () => parse<QuireConfig>('quire', {
          ...json(),
          'start': [
            {'sheet': 2, 'turned': false},
          ],
        }),
        throwsAt(r'$.config.start'),
      );
    });

    test('a catchword is the first word, or two characters without spaces', () {
      expect(catchword('From among them, I took'), 'From');
      expect(catchword('  «Its books» were'), 'Its');
      expect(catchword("Hasan's life"), "Hasan's");
      expect(catchword('그 책들은'), '그');
      expect(catchword('書物は長年'), '書物');
      expect(catchword('藏书多年'), '藏书');
      expect(catchword('…'), '');
    });
  });

  group('dip', () {
    Map<String, Object?> json() => {
      'tanks': [
        {'liquid': 'honey', 'level': 0.8},
        {'liquid': 'vinegar', 'level': 0.7},
      ],
      'names': [
        {'liquid': 'honey', 'labelKey': 'honey'},
        {'liquid': 'vinegar', 'labelKey': 'vinegar'},
        {'liquid': 'milk', 'labelKey': 'milk'},
      ],
    };

    test('dip, name each tank, then judge the stores', () {
      final config = parse<DipConfig>('dip', json());
      expect(config.storesFull, isTrue);
      var state = config.start();
      expect(
        state.name(0, DipLiquid.honey),
        same(state),
        reason: 'not dipped yet',
      );
      state = state.dip(0).name(0, DipLiquid.milk);
      expect(state.mistakes, 1);
      state = state.name(0, DipLiquid.honey);
      expect(state.named, {0: DipLiquid.honey});
      expect(state.judge(full: true), same(state), reason: 'not all named');
      state = state.dip(1).name(1, DipLiquid.vinegar);
      expect(state.allNamed, isTrue);
      state = state.judge(full: false);
      expect(state.mistakes, 2);
      expect(state.isSolved, isFalse);
      state = state.judge(full: true);
      expect(state.isSolved, isTrue);
    });

    test('a low tank means the stores were running low', () {
      final config = parse<DipConfig>('dip', {
        ...json(),
        'tanks': [
          {'liquid': 'honey', 'level': 0.8},
          {'liquid': 'vinegar', 'level': 0.2},
        ],
      });
      expect(config.storesFull, isFalse);
    });

    test('every tank named, and one name more to mislead', () {
      expect(
        () => parse<DipConfig>('dip', {
          ...json(),
          'names': [
            {'liquid': 'honey', 'labelKey': 'honey'},
            {'liquid': 'milk', 'labelKey': 'milk'},
            {'liquid': 'water', 'labelKey': 'water'},
          ],
        }),
        throwsAt(r'$.config.names'),
      );
      expect(
        () => parse<DipConfig>('dip', {
          ...json(),
          'names': [
            {'liquid': 'honey', 'labelKey': 'honey'},
            {'liquid': 'vinegar', 'labelKey': 'vinegar'},
          ],
        }),
        throwsAt(r'$.config.names'),
      );
      expect(
        () => parse<DipConfig>('dip', {
          ...json(),
          'tanks': [
            {'liquid': 'honey', 'level': 0.8},
            {'liquid': 'honey', 'level': 0.7},
          ],
        }),
        throwsAt(r'$.config.tanks'),
      );
      expect(
        () => parse<DipConfig>('dip', {
          ...json(),
          'tanks': [
            {'liquid': 'honey', 'level': 1.2},
            {'liquid': 'vinegar', 'level': 0.7},
          ],
        }),
        throwsAt(r'$.config.tanks[0].level'),
      );
      expect(
        () => parse<DipConfig>('dip', {
          ...json(),
          'tanks': [
            {'liquid': 'mead', 'level': 0.8},
            {'liquid': 'vinegar', 'level': 0.7},
          ],
        }),
        throwsAt(r'$.config.tanks[0].liquid'),
      );
    });
  });
}
