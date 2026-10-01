import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/engine/engine.dart';

import 'puzzle_types_test.dart' show parse, throwsAt;

void main() {
  group('courses', () {
    Map<String, Object?> json() => {
      'width': 6,
      'base': [3, 3],
      'courses': 2,
      'blocks': [2, 4, 4, 2],
      'chevrons': [true, true, false, true],
    };

    test('lay course by course, joints never over joints, then the band', () {
      final config = parse<CoursesConfig>('courses', json());
      expect(CoursesConfig.joints([2, 4]), {2});
      var state = config.start();
      expect(state.current, 0);
      expect(state.below, {3});
      expect(state.judge(1), CoursesLay.laid, reason: '4 ends at 4, not 3');

      // A 2 then a 2 would leave the course short; a 4 after a 4 runs past.
      state = state.lay(1);
      expect(state.filled, 4);
      expect(state.judge(2), CoursesLay.tooLong);
      state = state.lay(2);
      expect(state.mistakes, 1);
      state = state.lay(0);
      expect(state.laid, [
        [1, 0],
      ]);
      expect(state.current, 1);
      expect(state.below, {4});

      // The next course may not have a joint at 4.
      expect(state.judge(3), CoursesLay.laid);
      state = state.lay(3);
      expect(state.judge(2), CoursesLay.laid);
      state = state.takeBack();
      expect(state.laid, [
        [1, 0],
      ]);
      expect(state.judge(2), CoursesLay.joint, reason: 'a 4 first ends at 4');
      state = state.lay(3);
      expect(state.isUsed(1), isTrue);
      expect(state.lay(1), same(state), reason: 'already laid');
      state = state.lay(2);
      expect(state.coursesDone, isTrue);
      expect(state.isSolved, isFalse, reason: 'the band still zigzags wrong');

      state = state.tilt(0);
      expect(state.leans, [false, true, false, true]);
      expect(state.isSolved, isTrue);
      expect(state.tilt(1), same(state));
    });

    test('a joint over a joint is a mistake', () {
      final config = parse<CoursesConfig>('courses', {
        ...json(),
        'base': [2, 4],
      });
      var state = config.start();
      expect(state.judge(0), CoursesLay.joint);
      state = state.lay(0);
      expect(state.mistakes, 1);
      expect(state.laid, isEmpty);
    });

    test('the band may not start true, and the pile must be layable', () {
      expect(
        () => parse<CoursesConfig>('courses', {
          ...json(),
          'chevrons': [true, false, true, false],
        }),
        throwsAt(r'$.config.chevrons'),
      );
      expect(
        () => parse<CoursesConfig>('courses', {
          ...json(),
          'base': [2, 2, 2],
          'blocks': [2, 2, 2, 2, 2, 2],
        }),
        throwsAt(r'$.config.blocks'),
      );
      expect(
        () => parse<CoursesConfig>('courses', {
          ...json(),
          'blocks': [2, 4, 4],
        }),
        throwsAt(r'$.config.blocks'),
      );
      expect(
        () => parse<CoursesConfig>('courses', {
          ...json(),
          'base': [3, 2],
        }),
        throwsAt(r'$.config.base'),
      );
    });
  });

  group('identify', () {
    Map<String, Object?> json() => {
      'start': 'pores',
      'couplets': [
        {
          'id': 'pores',
          'choices': [
            {'textKey': 'pores', 'to': 'size'},
            {'textKey': 'no_pores', 'to': 'cedar'},
          ],
        },
        {
          'id': 'size',
          'choices': [
            {'textKey': 'fine', 'to': 'scent'},
            {'textKey': 'large', 'to': 'other'},
          ],
        },
        {
          'id': 'scent',
          'choices': [
            {'textKey': 'scented', 'to': 'tambootie'},
            {'textKey': 'plain', 'to': 'borer'},
          ],
        },
      ],
      'names': [
        for (final n in ['cedar', 'other', 'borer', 'tambootie'])
          {'id': n, 'nameKey': n, 'noteKey': '${n}_note'},
      ],
      'answer': 'tambootie',
    };

    test('a wrong end goes back to where the path turned wrong', () {
      final config = parse<IdentifyConfig>('identify', json());
      expect(config.pathTo('tambootie'), ['pores', 'size', 'scent']);
      var state = config.begin();
      expect(state.couplet, 'pores');

      state = state.choose(1);
      expect(state.wrongEnd, 'cedar');
      expect(state.mistakes, 1);
      expect(state.couplet, 'pores');

      state = state.choose(0).choose(0);
      expect(state.couplet, 'scent');
      expect(state.wrongEnd, isNull);
      state = state.choose(1);
      expect(state.wrongEnd, 'borer');
      expect(state.couplet, 'scent', reason: 'the wrong turn was the last');

      state = state.choose(0);
      expect(state.isSolved, isTrue);
      expect(state.mistakes, 2);
      expect(state.choose(1), same(state));
    });

    test('the key must be a tree', () {
      expect(
        () => parse<IdentifyConfig>('identify', {
          ...json(),
          'couplets': [
            ...(json()['couplets']! as List).take(2),
            {
              'id': 'scent',
              'choices': [
                {'textKey': 'scented', 'to': 'tambootie'},
                {'textKey': 'plain', 'to': 'size'},
              ],
            },
          ],
        }),
        throwsAt(r'$.config.couplets'),
      );
      expect(
        () => parse<IdentifyConfig>('identify', {...json(), 'answer': 'size'}),
        throwsAt(r'$.config.answer'),
      );
      expect(
        () => parse<IdentifyConfig>('identify', {
          ...json(),
          'names': [
            ...(json()['names']! as List),
            {'id': 'lost', 'nameKey': 'lost', 'noteKey': 'lost'},
          ],
        }),
        throwsAt(r'$.config.couplets'),
      );
    });
  });
}
