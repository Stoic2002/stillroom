import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/engine/engine.dart';

import 'fixtures/test_episode.dart';

void main() {
  late GameEngine engine;
  late GameState start;

  setUp(() {
    engine = GameEngine(buildTestEpisode());
    start = engine.newGame();
  });

  GameState atDesk() => engine.takeExit(start, 'right').state;

  group('newGame', () {
    test('starts at startScene with declared flag defaults', () {
      expect(start.episodeId, 'test_room');
      expect(start.sceneId, 'room_north');
      expect(start.inventory, isEmpty);
      expect(start.flags, engine.content.config.flags);
      expect(start.solvedPuzzles, isEmpty);
      expect(start.completed, isFalse);
    });

    test('throws when startScene does not exist', () {
      final bad = GameEngine(
        buildTestEpisode(game: {...gameJson(), 'startScene': 'nowhere'}),
      );
      expect(bad.newGame, throwsA(isA<EngineException>()));
    });
  });

  group('conditions', () {
    test('flag, hasItem, everHadItem and puzzleSolved', () {
      final state = start.copyWith(
        inventory: ['lens'],
        everHadItems: {'lens', 'frame'},
        solvedPuzzles: {'drawer_lock'},
        flags: {...start.flags, 'clock_turns': 3},
      );
      expect(const FlagCondition('clock_turns', 3).isMet(state), isTrue);
      expect(const FlagCondition('clock_turns', 2).isMet(state), isFalse);
      expect(const FlagCondition('drawer_open', false).isMet(state), isTrue);
      expect(const HasItemCondition('lens').isMet(state), isTrue);
      expect(const HasItemCondition('frame').isMet(state), isFalse);
      expect(
        const HasItemCondition('frame', expected: false).isMet(state),
        isTrue,
      );
      expect(const EverHadItemCondition('frame').isMet(state), isTrue);
      expect(const PuzzleSolvedCondition('drawer_lock').isMet(state), isTrue);
    });

    test('empty condition list is always met; lists are AND', () {
      expect(<Condition>[].allMet(start), isTrue);
      expect(
        [
          const FlagCondition('drawer_open', false),
          const HasItemCondition('lens'),
        ].allMet(start),
        isFalse,
      );
    });

    test('undeclared flag throws', () {
      expect(
        () => const FlagCondition('ghost', true).isMet(start),
        throwsA(isA<EngineException>()),
      );
    });
  });

  group('navigation', () {
    test('takeExit by direction id changes scene', () {
      final result = engine.takeExit(start, 'right');
      expect(result.state.sceneId, 'desk');
      expect(
        result.events.single,
        isA<SceneChangedEvent>()
            .having((e) => e.from, 'from', 'room_north')
            .having((e) => e.to, 'to', 'desk'),
      );
    });

    test('hidden exit is a no-op', () {
      final result = engine.takeExit(start, 'door');
      expect(result.state, same(start));
      expect(result.events, isEmpty);
    });

    test('unknown exit throws', () {
      expect(
        () => engine.takeExit(start, 'left'),
        throwsA(isA<EngineException>()),
      );
    });

    test('visible exits and layers follow conditions', () {
      expect(engine.visibleExits(start).map((e) => e.id), ['right']);
      final wound = start.copyWith(
        flags: {...start.flags, 'music_box_wound': true},
      );
      expect(engine.visibleExits(wound).map((e) => e.id), ['right', 'door']);

      final desk = atDesk();
      expect(engine.visibleLayers(desk), isEmpty);
      final open = desk.copyWith(flags: {...desk.flags, 'drawer_open': true});
      expect(engine.visibleLayers(open).single.id, 'drawer_open_sprite');
    });
  });

  group('hotspots', () {
    test('tap runs onTap actions in order and emits events', () {
      final result = engine.tapHotspot(start, 'clock');
      expect(result.state.flags['saw_clock'], isTrue);
      expect(
        result.events.single,
        isA<ShowTextEvent>().having((e) => e.textKey, 'key', 'room.clock.look'),
      );
    });

    test('tap on a hidden hotspot is a no-op', () {
      final desk = atDesk().copyWith(
        flags: {...atDesk().flags, 'drawer_open': true},
      );
      final result = engine.tapHotspot(desk, 'drawer_locked');
      expect(result.state, same(desk));
      expect(result.events, isEmpty);
    });

    test('unknown hotspot throws', () {
      expect(
        () => engine.tapHotspot(start, 'drawer_locked'),
        throwsA(isA<EngineException>()),
      );
    });

    test('hitTest prefers the topmost hotspot, then exit areas', () {
      final hit = engine.hitTest(start, 0.53, 0.53);
      expect(hit, isA<HotspotHit>().having((h) => h.hotspot.id, 'id', 'frame'));

      final lens = engine.hitTest(start, 0.58, 0.58);
      expect(lens, isA<HotspotHit>().having((h) => h.hotspot.id, 'id', 'lens'));

      expect(engine.hitTest(start, 0.85, 0.5), isNull, reason: 'door hidden');
      final wound = start.copyWith(
        flags: {...start.flags, 'music_box_wound': true},
      );
      expect(
        engine.hitTest(wound, 0.85, 0.5),
        isA<ExitHit>().having((h) => h.exit.id, 'id', 'door'),
      );
      expect(engine.hitTest(start, 0.99, 0.99), isNull);
    });

    test('hitTest grows small areas to the minimum tap size', () {
      // clock is [0.1, 0.1, 0.2, 0.2]; 0.07 is outside it.
      expect(engine.hitTest(start, 0.07, 0.2), isNull);
      expect(
        engine.hitTest(start, 0.07, 0.2, minWidth: 0.3, minHeight: 0.3),
        isA<HotspotHit>().having((h) => h.hotspot.id, 'id', 'clock'),
      );
    });
  });

  group('inventory', () {
    test('pickItem adds once and records everHadItems', () {
      final picked = engine.tapHotspot(start, 'lens');
      expect(picked.state.inventory, ['lens']);
      expect(picked.state.everHadItems, {'lens'});
      expect(picked.events.single, isA<ItemPickedEvent>());

      final again = engine.runActions(picked.state, [
        const PickItemAction('lens'),
      ]);
      expect(again.state.inventory, ['lens']);
      expect(again.events, isEmpty);
    });

    test('everHadItem keeps a pickup spot hidden after the item is gone', () {
      final picked = engine.tapHotspot(start, 'lens').state;
      final removed = engine.runActions(picked, [
        const RemoveItemAction('lens'),
      ]).state;
      expect(removed.inventory, isEmpty);
      expect(
        engine.visibleHotspots(removed).map((h) => h.id),
        isNot(contains('lens')),
      );
    });

    test('combining works in either order and replaces both items', () {
      var state = engine.tapHotspot(start, 'lens').state;
      state = engine.tapHotspot(state, 'frame').state;

      final result = engine.combineItems(state, 'frame', 'lens');
      expect(result.state.inventory, ['magnifier']);
      expect(result.state.everHadItems, {'lens', 'frame', 'magnifier'});
      expect(
        result.events.last,
        isA<ItemsCombinedEvent>().having(
          (e) => e.result,
          'result',
          'magnifier',
        ),
      );
    });

    test('invalid combination leaves state unchanged', () {
      var state = engine.tapHotspot(start, 'lens').state;
      state = engine.runActions(state, [const PickItemAction('box')]).state;

      final result = engine.combineItems(state, 'lens', 'box');
      expect(result.state, same(state));
      expect(result.events.single, isA<CombinationFailedEvent>());
    });

    test('combining an item that is not held throws', () {
      expect(
        () => engine.combineItems(start, 'lens', 'frame'),
        throwsA(isA<EngineException>()),
      );
    });

    test('inventoryItems returns definitions in pickup order', () {
      var state = engine.tapHotspot(start, 'frame').state;
      state = engine.tapHotspot(state, 'lens').state;
      expect(engine.inventoryItems(state).map((i) => i.id), ['frame', 'lens']);
    });
  });

  group('the drawer and music box walkthrough', () {
    test('open puzzle, solve it, take the key, use it on the music box', () {
      var state = atDesk();

      final open = engine.tapHotspot(state, 'drawer_locked');
      expect(
        open.events.single,
        isA<OpenPuzzleEvent>().having((e) => e.puzzleId, 'id', 'drawer_lock'),
      );

      final solved = engine.solvePuzzle(state, 'drawer_lock');
      state = solved.state;
      expect(state.solvedPuzzles, {'drawer_lock'});
      expect(state.flags['drawer_open'], isTrue);
      expect(
        solved.events.single,
        isA<PuzzleSolvedEvent>(),
        reason: 'goToScene desk is a no-op while already at the desk',
      );

      expect(engine.visibleHotspots(state).map((h) => h.id), [
        'small_key',
        'music_box',
      ]);

      state = engine.tapHotspot(state, 'small_key').state;
      expect(state.inventory, ['small_key']);

      final used = engine.useItemOnHotspot(state, 'music_box', 'small_key');
      state = used.state;
      expect(state.inventory, isEmpty);
      expect(state.flags['music_box_wound'], isTrue);
      expect(used.events, [
        isA<ItemRemovedEvent>(),
        isA<PlaySoundEvent>().having((e) => e.soundId, 'sound', 'music_box'),
        isA<ShakeEvent>(),
      ]);
      expect(
        engine.visibleHotspots(state).map((h) => h.id),
        isNot(contains('small_key')),
        reason: 'the key was used up and must not respawn',
      );

      final ended = engine.tapHotspot(state, 'exit_door');
      expect(ended.state.completed, isTrue);
      expect(ended.events.single, isA<EpisodeEndedEvent>());
    });

    test('solving twice runs onSolved only once', () {
      final once = engine.solvePuzzle(start, 'drawer_lock');
      expect(once.state.sceneId, 'desk');
      final twice = engine.solvePuzzle(once.state, 'drawer_lock');
      expect(twice.state, same(once.state));
      expect(twice.events, isEmpty);
    });

    test('using an item the hotspot does not accept is rejected', () {
      var state = atDesk();
      state = engine.runActions(state, [const PickItemAction('lens')]).state;
      final result = engine.useItemOnHotspot(state, 'music_box', 'lens');
      expect(result.state, same(state));
      expect(
        result.events.single,
        isA<ItemRejectedEvent>()
            .having((e) => e.itemId, 'item', 'lens')
            .having((e) => e.hotspotId, 'hotspot', 'music_box'),
      );
    });

    test('hints are filtered by their conditions', () {
      expect(
        engine.availableHints(start, 'drawer_lock').map((h) => h.textKey),
        ['hint.drawer_lock.1', 'hint.drawer_lock.3'],
      );
      final sawClock = engine.tapHotspot(start, 'clock').state;
      expect(engine.availableHints(sawClock, 'drawer_lock'), hasLength(3));
    });
  });

  group('actions', () {
    test('setFlag rejects undeclared flags and wrong types', () {
      expect(
        () => engine.runActions(start, [const SetFlagAction('ghost', true)]),
        throwsA(isA<EngineException>()),
      );
      expect(
        () => engine.runActions(start, [const SetFlagAction('drawer_open', 1)]),
        throwsA(isA<EngineException>()),
      );
      expect(
        () => engine.runActions(start, [
          const SetFlagAction('clock_turns', true),
        ]),
        throwsA(isA<EngineException>()),
      );
      final state = engine.runActions(start, [
        const SetFlagAction('clock_turns', 4),
      ]).state;
      expect(state.flags['clock_turns'], 4);
    });

    test('goToScene to an unknown scene throws', () {
      expect(
        () => engine.runActions(start, [const GoToSceneAction('attic')]),
        throwsA(isA<EngineException>()),
      );
    });

    test('examineItem emits an event', () {
      final result = engine.runActions(start, [const ExamineItemAction('box')]);
      expect(
        result.events.single,
        isA<ExamineItemEvent>().having((e) => e.itemId, 'item', 'box'),
      );
    });

    test('examine hotspots run their actions', () {
      final items = itemsJson();
      (items['items']! as List<Object?>).add({
        'id': 'locket',
        'nameKey': 'k',
        'descKey': 'k',
        'icon': 'i.png',
        'examine': {
          'image': 'big.png',
          'hotspots': [
            {
              'id': 'clasp',
              'rect': [0.4, 0.4, 0.2, 0.2],
              'when': [
                {'everHadItem': 'note', 'equals': false},
              ],
              'onTap': [
                {'type': 'pickItem', 'item': 'note'},
              ],
            },
          ],
          'layers': [
            {
              'id': 'note_inside',
              'image': 'note.png',
              'rect': [0.4, 0.4, 0.2, 0.2],
              'when': [
                {'everHadItem': 'note', 'equals': false},
              ],
            },
          ],
        },
      });
      final engine = GameEngine(buildTestEpisode(items: items));
      final state = engine.newGame();
      expect(engine.visibleExamineHotspots(state, 'locket'), hasLength(1));
      expect(engine.visibleExamineLayers(state, 'locket'), hasLength(1));
      expect(engine.hitTestExamine(state, 'locket', 0.5, 0.5)?.id, 'clasp');
      expect(engine.hitTestExamine(state, 'locket', 0.1, 0.1), isNull);
      expect(
        engine.hitTestExamine(state, 'locket', 0.37, 0.5, minWidth: 0.3)?.id,
        'clasp',
      );
      final result = engine.tapExamineHotspot(state, 'locket', 'clasp');
      expect(result.state.inventory, ['note']);
      expect(engine.visibleExamineHotspots(result.state, 'locket'), isEmpty);
      expect(engine.visibleExamineLayers(result.state, 'locket'), isEmpty);
      expect(
        () => engine.tapExamineHotspot(state, 'lens', 'clasp'),
        throwsA(isA<EngineException>()),
      );
    });
  });

  group('reconcile', () {
    test('drops unknown ids and repairs flags after a content update', () {
      final saved = start.copyWith(
        sceneId: 'removed_scene',
        inventory: ['lens', 'removed_item'],
        everHadItems: {'lens', 'removed_item'},
        flags: {'drawer_open': true, 'clock_turns': true, 'removed_flag': 1},
        solvedPuzzles: {'drawer_lock', 'removed_puzzle'},
      );
      final fixed = engine.reconcile(saved);
      expect(fixed.sceneId, 'room_north');
      expect(fixed.inventory, ['lens']);
      expect(fixed.everHadItems, {'lens'});
      expect(fixed.flags, {
        'drawer_open': true,
        'music_box_wound': false,
        'saw_clock': false,
        'clock_turns': 0,
      });
      expect(fixed.solvedPuzzles, {'drawer_lock'});
    });

    test('rejects a save from another episode', () {
      expect(
        () => engine.reconcile(start.copyWith(episodeId: 'other')),
        throwsA(isA<EngineException>()),
      );
    });
  });
}
