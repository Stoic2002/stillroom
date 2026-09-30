import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/content/content_validator.dart';
import 'package:stillroom/engine/engine.dart';

import 'fixtures/test_episode.dart';
import 'puzzle_types_test.dart' show parse, throwsAt;

void main() {
  group('lens', () {
    /// room_north with a lens onto `room_then`, raised once the player
    /// holds the lens item.
    Map<String, Object?> roomWithLens({String scene = 'room_then'}) => {
      ...roomNorthJson(),
      'lens': {
        'scene': scene,
        'when': [
          {'hasItem': 'lens'},
        ],
        'radius': 0.25,
      },
    };

    Map<String, Object?> roomThen() => {
      'id': 'room_then',
      'background': 'images/scenes/room_then.png',
      'hotspots': [
        {
          'id': 'fresco',
          'rect': [0.3, 0.3, 0.2, 0.2],
          'onTap': [
            {'type': 'setFlag', 'flag': 'saw_clock', 'value': true},
            {'type': 'showText', 'key': 'then.fresco'},
          ],
        },
        {
          'id': 'hidden',
          'rect': [0.7, 0.7, 0.1, 0.1],
          'when': [
            {'flag': 'drawer_open', 'equals': true},
          ],
          'onTap': [
            {'type': 'showText', 'key': 'then.hidden'},
          ],
        },
      ],
      'layers': [
        {
          'id': 'always',
          'image': 'images/objects/a.png',
          'rect': [0.1, 0.1, 0.1, 0.1],
        },
        {
          'id': 'later',
          'image': 'images/objects/b.png',
          'rect': [0.1, 0.1, 0.1, 0.1],
          'when': [
            {'flag': 'saw_clock', 'equals': true},
          ],
        },
      ],
    };

    GameEngine engine() => GameEngine(
      buildTestEpisode(scenes: [roomWithLens(), deskJson(), roomThen()]),
    );

    test('the lens is there only while its conditions hold', () {
      final e = engine();
      final start = e.newGame();
      expect(e.lens(start), isNull);
      expect(e.lensScene(start), isNull);
      expect(e.visibleLensLayers(start), isEmpty);

      final holding = e.tapHotspot(start, 'lens').state;
      expect(e.lens(holding)?.radius, 0.25);
      expect(e.lensScene(holding)?.id, 'room_then');
      expect(e.visibleLensLayers(holding).map((l) => l.id), ['always']);
    });

    test('taps through the lens reach the other scene only', () {
      final e = engine();
      final holding = e.tapHotspot(e.newGame(), 'lens').state;
      expect(e.hitTestLens(holding, 0.35, 0.35)?.id, 'fresco');
      // room_north's clock is at this point, but the lens shows room_then.
      expect(e.hitTestLens(holding, 0.15, 0.15), isNull);
      // A hotspot of the other scene hides while its conditions fail.
      expect(e.hitTestLens(holding, 0.75, 0.75), isNull);

      final result = e.tapHotspot(holding, 'fresco', throughLens: true);
      expect(result.state.flags['saw_clock'], isTrue);
      expect(result.state.sceneId, 'room_north');
      expect(
        result.events.whereType<ShowTextEvent>().single.textKey,
        'then.fresco',
      );
      expect(e.visibleLensLayers(result.state).map((l) => l.id), [
        'always',
        'later',
      ]);
    });

    test('no lens, no tapping through it', () {
      final e = engine();
      expect(
        () => e.tapHotspot(e.newGame(), 'fresco', throughLens: true),
        throwsA(isA<EngineException>()),
      );
    });

    test('radius has limits', () {
      expect(
        () => buildTestEpisode(
          scenes: [
            {
              ...roomWithLens(),
              'lens': {'scene': 'room_then', 'radius': 0.6},
            },
            deskJson(),
            roomThen(),
          ],
        ),
        throwsA(isA<ContentFormatException>()),
      );
    });

    test('the validator checks where a lens looks', () {
      List<String> errors(List<Map<String, Object?>> scenes) => validateEpisode(
        buildTestEpisode(scenes: scenes),
        assets: const {},
        strings: const {'en': {}},
      ).where((i) => i.isError).map((i) => i.message).toList();

      expect(
        errors([roomWithLens(scene: 'nowhere'), deskJson()]),
        contains(contains('unknown scene "nowhere"')),
      );
      expect(
        errors([roomWithLens(scene: 'room_north'), deskJson()]),
        contains(contains('its own lens')),
      );
      expect(
        errors([
          roomWithLens(),
          deskJson(),
          {
            ...roomThen(),
            'lens': {'scene': 'desk'},
          },
        ]),
        contains(contains('has a lens of its own')),
      );
    });
  });

  group('overlay', () {
    Map<String, Object?> config({double snap = 0.05}) => {
      'sheets': [
        {
          'id': 'a',
          'image': 'images/a.png',
          'rect': [0.3, 0.1, 0.4, 0.8],
          'from': [0.0, 0.1],
        },
        {
          'id': 'b',
          'image': 'images/b.png',
          'rect': [0.3, 0.1, 0.4, 0.8],
          'from': [0.3, 0.1],
          'turns': 3,
        },
        {
          'id': 'base',
          'image': 'images/base.png',
          'rect': [0.3, 0.1, 0.4, 0.8],
        },
      ],
      'snap': snap,
    };

    test('sheets start where they are told, a sheet without from in place', () {
      final state = parse<OverlayConfig>('overlay', config()).start();
      expect(state.place('a').x, 0.0);
      expect(state.place('b').turns, 3);
      expect(state.isPlaced('base'), isTrue);
      expect(state.isPlaced('b'), isFalse, reason: 'in place but turned');
      expect(state.isSolved, isFalse);
    });

    test('a sheet let go close to its place, right way up, settles', () {
      var state = parse<OverlayConfig>('overlay', config()).start();
      state = state.move('a', 0.27, 0.02).drop('a');
      expect(state.isPlaced('a'), isTrue);
      expect(state.place('a').x, 0.3);
      expect(state.place('a').y, 0.1);
      // Settled sheets stay put.
      expect(identical(state.move('a', 0.2, 0), state), isTrue);
      expect(identical(state.turn('a'), state), isTrue);

      // Turned the wrong way, a sheet in the right spot does not settle.
      expect(identical(state.drop('b'), state), isTrue);
      state = state.turn('b');
      expect(state.place('b').turns, 0);
      state = state.drop('b');
      expect(state.isSolved, isTrue);
    });

    test('too far away, a sheet stays where it was dropped', () {
      var state = parse<OverlayConfig>('overlay', config()).start();
      state = state.move('a', 0.2, 0);
      expect(identical(state.drop('a'), state), isTrue);
      expect(state.place('a').x, closeTo(0.2, 1e-9));
    });

    test('a sheet keeps a strip on the board', () {
      final state = parse<OverlayConfig>(
        'overlay',
        config(),
      ).start().move('a', -5, 5);
      expect(state.place('a').x, closeTo(-0.28, 1e-9));
      expect(state.place('a').y, closeTo(0.76, 1e-9));
    });

    test('config errors', () {
      expect(
        () => parse<OverlayConfig>('overlay', {'sheets': <Object?>[]}),
        throwsAt(r'$.config.sheets'),
      );
      expect(
        () => parse<OverlayConfig>('overlay', {
          'sheets': [
            {
              'id': 'a',
              'image': 'i.png',
              'rect': [0.1, 0.1, 0.2, 0.2],
            },
          ],
        }),
        throwsAt(r'$.config.sheets', 'nothing to do'),
      );
      expect(
        () => parse<OverlayConfig>('overlay', {
          'sheets': [
            {
              'id': 'a',
              'image': 'i.png',
              'rect': [0.1, 0.1, 0.2, 0.2],
              'turns': 4,
            },
          ],
        }),
        throwsAt(r'$.config.sheets[0].turns'),
      );
      expect(
        () => parse<OverlayConfig>('overlay', config(snap: 0.5)),
        throwsAt(r'$.config.snap'),
      );
    });
  });

  group('lens hours', () {
    Map<String, Object?> game() => {
      ...gameJson(),
      'flags': {...(gameJson()['flags']! as Map<String, Object?>), 'hour': 0},
      'lensHours': {
        'flag': 'hour',
        'labels': ['h.morning', 'h.evening'],
      },
    };
    Map<String, Object?> then(String id) => {
      'id': id,
      'background': 'images/scenes/$id.png',
    };
    Map<String, Object?> room(List<String> scenes) => {
      ...roomNorthJson(),
      'lens': {'scenes': scenes},
    };

    test('the lens looks at the hour it is turned to', () {
      final e = GameEngine(
        buildTestEpisode(
          game: game(),
          scenes: [
            room(['morning', 'evening']),
            deskJson(),
            then('morning'),
            then('evening'),
          ],
        ),
      );
      var state = e.newGame();
      expect(e.lensHour(state), 0);
      expect(e.lensScene(state)?.id, 'morning');
      state = e.turnLensHour(state).state;
      expect(e.lensScene(state)?.id, 'evening');
      expect(state.flags['hour'], 1, reason: 'conditions can use it');
      state = e.turnLensHour(state).state;
      expect(e.lensScene(state)?.id, 'morning', reason: 'round again');
    });

    test('one scene per hour, and hours need lensHours', () {
      List<String> errors(Map<String, Object?> g, List<String> scenes) =>
          validateEpisode(
            buildTestEpisode(
              game: g,
              scenes: [
                room(scenes),
                deskJson(),
                for (final id in scenes.toSet()) then(id),
              ],
            ),
            assets: const {},
            strings: const {'en': {}},
          ).where((i) => i.isError).map((i) => i.message).toList();
      expect(
        errors(game(), ['a', 'b', 'c']),
        contains(contains('one scene per hour')),
      );
      expect(
        errors(gameJson(), ['a', 'b']),
        contains(contains('need lensHours')),
      );
    });
  });

  group('raking light', () {
    test('the marks show as the lamp nears the right side', () {
      final config = parse<RakingLightConfig>('rakingLight', {
        'surface': 's.png',
        'marks': 'm.png',
        'from': 290,
        'tolerance': 10,
      });
      var state = config.start();
      expect(state.lamp, 110, reason: 'opposite the right side');
      expect(state.clarity, 0);
      state = state.moveTo(305);
      expect(state.clarity, closeTo(0.75, 1e-9));
      expect(state.isSolved, isFalse);
      state = state.moveTo(-60);
      expect(state.isSolved, isTrue, reason: '-60 is 300: within 10 of 290');
    });

    test('config errors', () {
      expect(
        () => parse<RakingLightConfig>('rakingLight', {
          'surface': 's.png',
          'marks': 'm.png',
          'from': 360,
        }),
        throwsAt(r'$.config.from'),
      );
    });
  });
}
