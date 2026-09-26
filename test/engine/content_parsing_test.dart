import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/engine/engine.dart';

import 'fixtures/test_episode.dart';

Matcher throwsContentError({String? path, String? message}) => throwsA(
  isA<ContentFormatException>()
      .having((e) => e.path, 'path', path ?? anything)
      .having((e) => e.message, 'message', contains(message ?? '')),
);

void main() {
  group('EpisodeContent.parse', () {
    test('parses the PRD example shape', () {
      final content = buildTestEpisode();

      expect(content.id, 'test_room');
      expect(content.config.startScene, 'room_north');
      expect(content.config.flags, {
        'drawer_open': false,
        'music_box_wound': false,
        'saw_clock': false,
        'clock_turns': 0,
      });
      expect(content.config.logicalWidth, 1920);
      expect(content.config.logicalHeight, 1080);
      expect(content.config.orientation, ScreenOrientation.landscape);
      expect(content.config.sceneTransitionMs, 400);

      final desk = content.scenes['desk']!;
      expect(desk.hotspots.map((h) => h.id), [
        'drawer_locked',
        'small_key',
        'music_box',
        'exit_door',
      ]);
      expect(
        desk.hotspot('drawer_locked')!.rect,
        const NormalizedRect(0.42, 0.61, 0.18, 0.12),
      );
      expect(desk.hotspot('small_key')!.when, hasLength(2));
      expect(desk.hotspot('music_box')!.useFor('small_key')!.actions, [
        isA<RemoveItemAction>(),
        isA<SetFlagAction>(),
        isA<PlaySoundAction>(),
        isA<ShakeAction>()
            .having((a) => a.durationMs, 'durationMs', 300)
            .having((a) => a.strength, 'strength', 0.5),
      ]);
      expect(desk.layers.single.image, 'images/objects/drawer_open.png');
      expect(desk.exits.single.id, 'back');
      expect(desk.exits.single.direction, ExitDirection.back);

      final puzzle = content.puzzles['drawer_lock']!;
      expect(puzzle.config, isA<TestCodeConfig>());
      expect((puzzle.config as TestCodeConfig).solution, ['3', '1', '4', '1']);
      expect(puzzle.hints.map((h) => h.textKey), [
        'hint.drawer_lock.1',
        'hint.drawer_lock.2',
        'hint.drawer_lock.3',
      ]);

      expect(content.items, hasLength(6));
      expect(content.combinationFor('frame', 'lens')!.result, 'magnifier');
    });

    test('reads orientation from game.json', () {
      final content = buildTestEpisode(
        game: {...gameJson(), 'orientation': 'portrait'},
      );
      expect(content.config.orientation, ScreenOrientation.portrait);
    });

    test('parses item examine views', () {
      final items = itemsJson();
      (items['items']! as List<Object?>).add({
        'id': 'locket',
        'nameKey': 'item.locket.name',
        'descKey': 'item.locket.desc',
        'icon': 'images/items/locket.png',
        'examine': {
          'image': 'images/items/locket_big.png',
          'hotspots': [
            {
              'id': 'clasp',
              'rect': [0.4, 0.4, 0.2, 0.2],
              'onTap': [
                {'type': 'pickItem', 'item': 'note'},
              ],
            },
          ],
        },
      });
      final content = buildTestEpisode(items: items);
      final examine = content.items['locket']!.examine!;
      expect(examine.image, 'images/items/locket_big.png');
      expect(examine.hotspot('clasp')!.onTap.single, isA<PickItemAction>());
    });
  });

  group('format errors name the file and path', () {
    test('unknown action type', () {
      final desk = deskJson();
      ((desk['hotspots']! as List<Object?>)[2]!
          as Map<String, Object?>)['onTap'] = [
        {'type': 'explode'},
      ];
      expect(
        () => buildTestEpisode(scenes: [roomNorthJson(), desk]),
        throwsA(
          isA<ContentFormatException>()
              .having((e) => e.source, 'source', 'scenes/1.json')
              .having((e) => e.path, 'path', r'$.hotspots[2].onTap[0].type')
              .having((e) => e.message, 'message', contains('explode')),
        ),
      );
    });

    test('unknown field (typo)', () {
      final desk = deskJson();
      final hotspot =
          (desk['hotspots']! as List<Object?>)[0]! as Map<String, Object?>;
      hotspot['onTAp'] = hotspot.remove('onTap');
      expect(
        () => buildTestEpisode(scenes: [roomNorthJson(), desk]),
        throwsContentError(
          path: r'$.hotspots[0].onTAp',
          message: 'unknown field',
        ),
      );
    });

    test('rect with the wrong number of values', () {
      final desk = deskJson();
      ((desk['hotspots']! as List<Object?>)[0]!
          as Map<String, Object?>)['rect'] = [
        0.1,
        0.2,
        0.3,
      ];
      expect(
        () => buildTestEpisode(scenes: [roomNorthJson(), desk]),
        throwsContentError(path: r'$.hotspots[0].rect', message: 'exactly 4'),
      );
    });

    test('condition with two subjects', () {
      final desk = deskJson();
      ((desk['hotspots']! as List<Object?>)[0]!
          as Map<String, Object?>)['when'] = [
        {'flag': 'drawer_open', 'hasItem': 'lens', 'equals': true},
      ];
      expect(
        () => buildTestEpisode(scenes: [roomNorthJson(), desk]),
        throwsContentError(
          path: r'$.hotspots[0].when[0]',
          message: 'exactly one',
        ),
      );
    });

    test('flag condition needs a bool or int', () {
      final desk = deskJson();
      ((desk['hotspots']! as List<Object?>)[0]!
          as Map<String, Object?>)['when'] = [
        {'flag': 'drawer_open', 'equals': 'yes'},
      ];
      expect(
        () => buildTestEpisode(scenes: [roomNorthJson(), desk]),
        throwsContentError(path: r'$.hotspots[0].when[0].equals'),
      );
    });

    test('duplicate hotspot id within a scene', () {
      final desk = deskJson();
      final hotspots = desk['hotspots']! as List<Object?>;
      hotspots.add(hotspots.first);
      expect(
        () => buildTestEpisode(scenes: [roomNorthJson(), desk]),
        throwsContentError(message: 'duplicate id "drawer_locked"'),
      );
    });

    test('duplicate scene id across files', () {
      expect(
        () => buildTestEpisode(scenes: [roomNorthJson(), roomNorthJson()]),
        throwsContentError(message: 'duplicate id "room_north"'),
      );
    });

    test('exit without direction needs an id', () {
      final room = roomNorthJson();
      ((room['exits']! as List<Object?>)[1]! as Map<String, Object?>).remove(
        'id',
      );
      expect(
        () => buildTestEpisode(scenes: [room, deskJson()]),
        throwsContentError(path: r'$.exits[1].id'),
      );
    });

    test('unknown puzzle type', () {
      expect(
        () => buildTestEpisode(
          puzzles: [
            {...drawerLockJson(), 'type': 'crossword'},
          ],
        ),
        throwsContentError(path: r'$.type', message: 'crossword'),
      );
    });

    test('more than three hints', () {
      final puzzle = drawerLockJson();
      (puzzle['hints']! as List<Object?>).add({'key': 'hint.drawer_lock.4'});
      expect(
        () => buildTestEpisode(puzzles: [puzzle]),
        throwsContentError(path: r'$.hints', message: 'at most 3'),
      );
    });

    test('flag default must be bool or int', () {
      expect(
        () => buildTestEpisode(
          game: {
            ...gameJson(),
            'flags': {'drawer_open': 'no'},
          },
        ),
        throwsContentError(path: r'$.flags.drawer_open'),
      );
    });

    test('duplicate combination in either order', () {
      final items = itemsJson();
      (items['combinations']! as List<Object?>).add({
        'a': 'frame',
        'b': 'lens',
        'result': 'box',
      });
      expect(
        () => buildTestEpisode(items: items),
        throwsContentError(message: 'duplicate combination'),
      );
    });

    test('shake strength outside 0–1', () {
      final registry = ActionRegistry();
      registerBuiltInActions(registry);
      expect(
        () => registry.parse(doc('x.json', {'type': 'shake', 'strength': 2})),
        throwsContentError(path: r'$.strength'),
      );
    });
  });

  group('registries', () {
    test('custom action types can be registered without engine changes', () {
      final registries = testRegistries();
      registries.actions.register(
        'log',
        (json) => _LogAction(json.string('msg')),
      );
      final action = registries.actions.parse(
        doc('x.json', {'type': 'log', 'msg': 'hi'}),
      );
      expect(action, isA<_LogAction>().having((a) => a.msg, 'msg', 'hi'));
    });

    test('registering a type twice is an error', () {
      final registries = testRegistries();
      expect(
        () =>
            registries.actions.register('goToScene', GoToSceneAction.fromJson),
        throwsArgumentError,
      );
      expect(
        () => registries.puzzleTypes.register(TestCodePuzzleType()),
        throwsArgumentError,
      );
    });
  });
}

final class _LogAction implements GameAction {
  const _LogAction(this.msg);

  final String msg;

  @override
  String get type => 'log';

  @override
  Iterable<ContentRef> get references => const [];

  @override
  void apply(ActionContext context) {}
}
