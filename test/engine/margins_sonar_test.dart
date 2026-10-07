import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/engine/engine.dart';

import 'puzzle_types_test.dart' show parse, throwsAt;

void main() {
  group('margins', () {
    Map<String, Object?> json() => {
      'passages': [
        {
          'textKey': 'all_well',
          'rect': [0.2, 0.3, 0.6, 0.3],
          'turn': 0,
        },
        {
          'textKey': 'deserted',
          'rect': [0.84, 0.1, 0.16, 0.8],
          'turn': 1,
        },
        {
          'textKey': 'died',
          'rect': [0.1, 0.0, 0.8, 0.16],
          'turn': 2,
          'printed': false,
        },
      ],
      'questions': [
        {'questionKey': 'when_deserted', 'passage': 1},
        {'questionKey': 'when_died', 'passage': 2},
      ],
    };

    test('turn the sheet to read, then answer in turn', () {
      final config = parse<MarginsConfig>('margins', json());
      var state = config.start();
      expect(state.readable(0), isTrue);
      expect(state.judge(1), MarginsAnswer.unreadable);
      expect(state.answer(1).mistakes, 0, reason: 'only a nudge');
      state = state.answer(0);
      expect(state.mistakes, 1, reason: '"All well" is not the answer');
      state = state.rotate(1);
      expect(state.readable(1), isTrue);
      expect(state.readable(0), isFalse);
      state = state.answer(1);
      expect(state.answered, 1);
      state = state.rotate(-3).rotate(2);
      expect(state.turn, 0);
      state = state.rotate(2).answer(2);
      expect(state.isSolved, isTrue);
    });

    test('a passage must lie on the sheet, each question its own', () {
      final passages = (json()['passages']! as List)
          .cast<Map<String, Object?>>();
      expect(
        () => parse<MarginsConfig>('margins', {
          ...json(),
          'passages': [
            ...passages.take(2),
            {
              ...passages[2],
              'rect': [0.5, 0.5, 0.6, 0.2],
            },
          ],
        }),
        throwsAt(r'$.config.passages[2].rect'),
      );
      expect(
        () => parse<MarginsConfig>('margins', {
          ...json(),
          'questions': [
            {'questionKey': 'a', 'passage': 1},
            {'questionKey': 'b', 'passage': 1},
          ],
        }),
        throwsAt(r'$.config.questions'),
      );
    });
  });

  group('sonar', () {
    Map<String, Object?> json() => {
      'columns': 8,
      'rows': 5,
      'hours': 2,
      'wreck': {'column': 3, 'row': 3, 'length': 2},
      'rocks': [
        [1, 3],
        [6, 0],
      ],
      'scours': [
        [5, 3],
      ],
      'marks': [
        {
          'labelKey': 'cape',
          'at': [7.5, 2],
        },
      ],
    };

    test('run lanes, read the echoes, mark the wreck', () {
      final config = parse<SonarConfig>('sonar', json());
      var state = config.start();
      expect(state.mark(3, 3).mistakes, 0, reason: 'not run yet');
      state = state.runLane(0);
      expect(state.hoursLeft, 1);
      expect(state.echoAt(6, 0), SonarEcho.rock);
      expect(state.runLane(0).hoursLeft, 1, reason: 'run already');
      state = state.runLane(1);
      expect(state.spent, isTrue);
      expect(state.runLane(3), same(state), reason: 'no hours left');
      state = state.nextSeason();
      expect(state.mistakes, 1);
      expect(state.seasons, 2);
      expect(state.hoursLeft, 2);
      state = state.runLane(3);
      expect(state.judge(1, 3), SonarJudge.rock);
      expect(state.judge(5, 3), SonarJudge.scour);
      expect(state.judge(0, 3), SonarJudge.nothing);
      state = state.mark(5, 3);
      expect(state.mistakes, 2);
      state = state.mark(4, 3);
      expect(state.isSolved, isTrue);
    });

    test('the wreck and the echoes lie in the grid, apart', () {
      expect(
        () => parse<SonarConfig>('sonar', {
          ...json(),
          'wreck': {'column': 7, 'row': 3, 'length': 2},
        }),
        throwsAt(r'$.config.wreck'),
      );
      expect(
        () => parse<SonarConfig>('sonar', {
          ...json(),
          'rocks': [
            [4, 3],
          ],
        }),
        throwsAt(r'$.config.rocks[0]'),
      );
    });
  });
}
