import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/engine/engine.dart';

import 'fixtures/test_episode.dart';
import 'puzzle_types_test.dart' show parse, throwsAt;

void main() {
  group('crank', () {
    test('winds forward, holds against turning back', () {
      var state = parse<CrankConfig>('crank', {'turns': 1}).start();
      state = state.turn(math.pi);
      expect(state.progress, closeTo(0.5, 1e-9));
      expect(identical(state.turn(-0.5), state), isTrue);
      state = state.turn(math.pi);
      expect(state.isSolved, isTrue);
    });

    test('counter-clockwise cranks wind the other way', () {
      final state = parse<CrankConfig>('crank', {
        'turns': 1,
        'clockwise': false,
      }).start();
      expect(state.turn(math.pi).wound, 0);
      expect(state.turn(-math.pi).progress, closeTo(0.5, 1e-9));
    });

    test('turns must be positive', () {
      expect(
        () => parse<CrankConfig>('crank', {'turns': 0}),
        throwsAt(r'$.config.turns'),
      );
    });
  });

  group('dark scenes', () {
    Map<String, Object?> darkRoom(Map<String, Object?> dark) => {
      ...roomNorthJson(),
      'dark': dark,
    };

    test('a scene is dark while its conditions hold', () {
      final engine = GameEngine(
        buildTestEpisode(
          scenes: [
            darkRoom({
              'when': [
                {'flag': 'saw_clock', 'equals': false},
              ],
              'radius': 0.2,
            }),
            deskJson(),
          ],
        ),
      );
      final start = engine.newGame();
      expect(engine.darkness(start)?.radius, 0.2);
      final lookedAtClock = engine.tapHotspot(start, 'clock').state;
      expect(engine.darkness(lookedAtClock), isNull);
    });

    test('without conditions it is always dark; radius has limits', () {
      final engine = GameEngine(
        buildTestEpisode(scenes: [darkRoom({}), deskJson()]),
      );
      expect(engine.darkness(engine.newGame())?.radius, 0.16);
      expect(
        () => buildTestEpisode(
          scenes: [
            darkRoom({'radius': 0.9}),
            deskJson(),
          ],
        ),
        throwsA(isA<ContentFormatException>()),
      );
    });
  });

  group('echoes', () {
    Map<String, Object?> roomWithEcho(Map<String, Object?> echo) => {
      ...roomNorthJson(),
      'echoes': [echo],
    };

    test('an echo may appear only while its conditions hold', () {
      final engine = GameEngine(
        buildTestEpisode(
          scenes: [
            roomWithEcho({
              'id': 'figure',
              'image': 'images/echo.png',
              'rect': [0.4, 0.3, 0.1, 0.3],
              'when': [
                {'flag': 'saw_clock', 'equals': true},
              ],
              'chance': 0.5,
              'drift': [0.1, 0],
            }),
            deskJson(),
          ],
        ),
      );
      final start = engine.newGame();
      expect(engine.possibleEchoes(start), isEmpty);
      final echo = engine
          .possibleEchoes(engine.tapHotspot(start, 'clock').state)
          .single;
      expect(echo.chance, 0.5);
      expect(echo.driftX, 0.1);
    });

    test('chance must be above 0 and at most 1', () {
      expect(
        () => buildTestEpisode(
          scenes: [
            roomWithEcho({
              'id': 'figure',
              'image': 'images/echo.png',
              'rect': [0.4, 0.3, 0.1, 0.3],
              'chance': 0,
            }),
            deskJson(),
          ],
        ),
        throwsA(isA<ContentFormatException>()),
      );
    });
  });
}
