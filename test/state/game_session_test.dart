import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/content/asset_source.dart';
import 'package:stillroom/content/content_validator.dart';
import 'package:stillroom/content/file_asset_source.dart';
import 'package:stillroom/core/services/hint_gate.dart';
import 'package:stillroom/core/storage/key_value_store.dart';
import 'package:stillroom/engine/engine.dart';
import 'package:stillroom/state/content_providers.dart';
import 'package:stillroom/state/game_session.dart';
import 'package:stillroom/state/save_repository.dart';
import 'package:stillroom/state/services_providers.dart';
import 'package:stillroom/state/storage_providers.dart';

/// Serves the real assets, optionally replacing some files.
final class _PatchedSource implements AssetSource {
  _PatchedSource(this.inner, this.patches);

  final AssetSource inner;
  final Map<String, String> patches;

  @override
  Future<Set<String>> listAssets() async => {
    ...await inner.listAssets(),
    ...patches.keys,
  };

  @override
  Future<String> loadString(String path) async =>
      patches[path] ?? await inner.loadString(path);
}

void main() {
  const episode = 'test_room';
  final files = FileAssetSource(Directory.current);

  ProviderContainer containerWith(
    AssetSource source, {
    KeyValueStore? store,
    HintGate gate = const FreeHintGate(),
  }) {
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        assetSourceProvider.overrideWithValue(source),
        keyValueStoreProvider.overrideWithValue(store ?? MemoryKeyValueStore()),
        hintGateProvider.overrideWithValue(gate),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<GameSessionState> start(ProviderContainer container) async {
    container.listen(gameSessionProvider(episode), (_, _) {});
    return container.read(gameSessionProvider(episode).future);
  }

  GameSessionState current(ProviderContainer c) =>
      c.read(gameSessionProvider(episode)).requireValue;

  test('starts a new game at startScene with validation warnings', () async {
    final container = containerWith(files);
    final session = await start(container);
    expect(session.game.sceneId, 'room_north');
    expect(session.revision, 0);
    expect(
      session.episode.warnings.map((w) => w.message),
      contains(contains('placeholder')),
    );
  });

  test('tapping a hotspot runs it through the engine', () async {
    final container = containerWith(files);
    await start(container);
    final notifier = container.read(gameSessionProvider(episode).notifier);

    // The desk area in room_north.
    notifier.tapScene(0.5, 0.7);
    final session = current(container);
    expect(session.game.sceneId, 'desk');
    expect(session.revision, 1);
    expect(session.events.single, isA<SceneChangedEvent>());
  });

  test('tapping empty space changes nothing', () async {
    final container = containerWith(files);
    await start(container);
    container.read(gameSessionProvider(episode).notifier).tapScene(0.02, 0.02);
    expect(current(container).revision, 0);
  });

  test('the minimum tap area makes small hotspots reachable', () async {
    final container = containerWith(files);
    await start(container);
    final notifier = container.read(gameSessionProvider(episode).notifier)
      ..debugJumpToScene('desk')
      ..tapScene(0.5, 0.7) // drawer: opens the code lock
      ..solvePuzzle('drawer_lock');
    expect(current(container).game.flags['drawer_open'], isTrue);

    // box is [0.44, 0.66, 0.12, 0.12]; 0.435 is just outside it.
    notifier.tapScene(0.435, 0.72, minWidth: 0.14, minHeight: 0.14);
    expect(current(container).game.inventory, ['box']);
  });

  group('autosave and resume (M5)', () {
    test('every state change is saved; a new session resumes it', () async {
      final store = MemoryKeyValueStore();
      final first = containerWith(files, store: store);
      await start(first);
      first.read(gameSessionProvider(episode).notifier)
        ..tapScene(0.83, 0.24) // clock: sets saw_clock
        ..dismissText()
        ..takeExit('right');
      await first.read(saveRepositoryProvider.notifier).flush();
      expect(store.values, contains(SaveRepository.storageKey));

      final second = containerWith(files, store: store);
      final resumed = await start(second);
      expect(resumed.game.sceneId, 'room_east');
      expect(resumed.game.flags['saw_clock'], isTrue);
      expect(second.read(saveRepositoryProvider).continueEpisodeId, episode);
    });

    test('UI-only changes (selection, text) are not written', () async {
      final store = MemoryKeyValueStore();
      final container = containerWith(files, store: store);
      await start(container);
      container
          .read(gameSessionProvider(episode).notifier)
          .tapScene(0.02, 0.02);
      await container.read(saveRepositoryProvider.notifier).flush();
      expect(store.values, isEmpty);
    });

    test('startNew drops the saved progress for that episode', () async {
      final store = MemoryKeyValueStore();
      final first = containerWith(files, store: store);
      await start(first);
      first.read(gameSessionProvider(episode).notifier).takeExit('right');
      first.read(saveRepositoryProvider.notifier).startNew(episode);
      await first.read(saveRepositoryProvider.notifier).flush();

      final second = containerWith(files, store: store);
      expect((await start(second)).game.sceneId, 'room_north');
    });

    test('a completed episode is kept as completed but starts fresh', () async {
      final store = MemoryKeyValueStore();
      final first = containerWith(files, store: store);
      final session = await start(first);
      first
          .read(gameSessionProvider(episode).notifier)
          .debugJumpToScene('room_south');
      // Finish directly through the engine's action list.
      first
          .read(saveRepositoryProvider.notifier)
          .saveEpisode(
            session.engine.runActions(session.game, [
              const EndEpisodeAction(),
            ]).state,
          );
      final save = first.read(saveRepositoryProvider);
      expect(save.isCompleted(episode), isTrue);
      expect(save.continueEpisodeId, isNull);
      await first.read(saveRepositoryProvider.notifier).flush();

      final second = containerWith(files, store: store);
      expect((await start(second)).game.completed, isFalse);
    });
  });

  group('hints (M6)', () {
    test('stage hints outside puzzles, puzzle hints inside', () async {
      final container = containerWith(files);
      await start(container);
      final notifier = container.read(gameSessionProvider(episode).notifier);
      expect(notifier.currentHints()?.key, 'stage:find_key');

      notifier
        ..debugJumpToScene('desk')
        ..tapScene(0.5, 0.7); // opens drawer_lock
      expect(notifier.currentHints()?.key, 'puzzle:drawer_lock');
    });

    test('revealing goes through the HintGate and is saved', () async {
      final store = MemoryKeyValueStore();
      final container = containerWith(files, store: store);
      await start(container);
      final notifier = container.read(gameSessionProvider(episode).notifier);

      expect(await notifier.revealNextHint(), isTrue);
      expect(current(container).game.revealedHints, {'stage:find_key': 1});
      expect(
        notifier.currentHints()!.shown.single.textKey,
        'hint.stage.find_key.1',
      );

      await container.read(saveRepositoryProvider.notifier).flush();
      final resumed = await start(containerWith(files, store: store));
      expect(resumed.game.revealedHints, {'stage:find_key': 1});
    });

    test('a gate that refuses reveals nothing', () async {
      final gate = _RecordingGate(allow: false);
      final container = containerWith(files, gate: gate);
      await start(container);
      final notifier = container.read(gameSessionProvider(episode).notifier);
      expect(await notifier.revealNextHint(), isFalse);
      expect(current(container).game.revealedHints, isEmpty);
      expect(gate.requests.single.groupKey, 'stage:find_key');
      expect(gate.requests.single.level, 1);
    });
  });

  group('puzzles (M4)', () {
    late ProviderContainer container;
    late GameSession notifier;

    setUp(() async {
      container = containerWith(files);
      await start(container);
      notifier = container.read(gameSessionProvider(episode).notifier);
    });

    test('openPuzzle opens the screen and blocks the scene', () {
      notifier
        ..debugJumpToScene('desk')
        ..tapScene(0.5, 0.7);
      final session = current(container);
      expect(session.openPuzzle, 'drawer_lock');
      expect(session.events.single, isA<OpenPuzzleEvent>());

      notifier.takeExit('back');
      expect(
        current(container).game.sceneId,
        'desk',
        reason: 'exits are blocked while a puzzle is open',
      );
    });

    test('solving runs onSolved and closes the screen', () {
      notifier
        ..debugJumpToScene('room_west')
        ..tapScene(0.5, 0.3) // window: opens window_panes
        ..solvePuzzle('window_panes');
      final session = current(container);
      expect(session.openPuzzle, isNull);
      expect(session.game.solvedPuzzles, {'window_panes'});
      expect(session.game.inventory, ['gem']);
      expect(session.currentText, 'test_room.window.solved');

      // Solved: the window now only describes itself.
      notifier
        ..dismissText()
        ..tapScene(0.5, 0.3);
      expect(current(container).openPuzzle, isNull);
      expect(current(container).currentText, 'test_room.window.look');
    });

    test(
      'closing leaves the puzzle unsolved; solving another id is ignored',
      () {
        notifier
          ..debugJumpToScene('desk')
          ..tapScene(0.5, 0.7)
          ..solvePuzzle('wall_rings');
        expect(current(container).game.solvedPuzzles, isEmpty);

        notifier.closePuzzle();
        final session = current(container);
        expect(session.openPuzzle, isNull);
        expect(session.game.solvedPuzzles, isEmpty);
      },
    );

    test('the door needs the emblems and the key', () {
      notifier
        ..debugJumpToScene('room_south')
        ..tapScene(0.5, 0.4); // emblem panel on the door
      expect(current(container).openPuzzle, 'door_emblems');
      notifier.solvePuzzle('door_emblems');
      expect(current(container).currentText, 'test_room.door.emblems_set');
    });
  });

  group('inventory and text (M3)', () {
    late ProviderContainer container;
    late GameSession notifier;

    setUp(() async {
      container = containerWith(files);
      await start(container);
      notifier = container.read(gameSessionProvider(episode).notifier);
    });

    /// Picks up frame and lens in room_east.
    void collectLensAndFrame() {
      notifier
        ..debugJumpToScene('room_east')
        ..tapScene(0.12, 0.37) // ring dial: opens wall_rings
        ..solvePuzzle('wall_rings')
        ..tapScene(0.12, 0.62) // frame, in the niche the rings opened
        ..tapScene(0.65, 0.50) // lamp switch: dim
        ..tapScene(0.65, 0.50) // lamp switch: bright
        ..tapScene(0.83, 0.55); // lens, visible once the lamp is on
      expect(current(container).game.inventory, ['frame', 'lens']);
    }

    void openDrawer() {
      notifier
        ..debugJumpToScene('desk')
        ..tapScene(0.5, 0.7)
        ..solvePuzzle('drawer_lock');
    }

    test('tapping a slot selects it, tapping again deselects', () {
      collectLensAndFrame();
      notifier.tapInventoryItem('lens');
      expect(current(container).selectedItem, 'lens');
      notifier.tapInventoryItem('lens');
      expect(current(container).selectedItem, isNull);
    });

    test('selecting A then B combines them', () {
      collectLensAndFrame();
      notifier
        ..tapInventoryItem('lens')
        ..tapInventoryItem('frame');
      final session = current(container);
      expect(session.game.inventory, ['magnifier']);
      expect(session.selectedItem, isNull);
      expect(session.events.last, isA<ItemsCombinedEvent>());
    });

    test('a failed combination gives feedback and selects B', () {
      collectLensAndFrame();
      openDrawer();
      notifier
        ..tapScene(0.5, 0.72) // box
        ..tapInventoryItem('lens')
        ..tapInventoryItem('box');
      final session = current(container);
      expect(session.game.inventory, ['frame', 'lens', 'box']);
      expect(session.selectedItem, 'box');
      expect(session.events.single, isA<CombinationFailedEvent>());
    });

    test('using an item: rejected keeps it selected, success clears it', () {
      collectLensAndFrame();
      notifier
        ..tapInventoryItem('lens')
        ..tapInventoryItem('frame')
        ..debugJumpToScene('room_north')
        ..tapInventoryItem('magnifier')
        ..tapScene(0.83, 0.24); // clock does not accept it
      var session = current(container);
      expect(session.events.single, isA<ItemRejectedEvent>());
      expect(session.selectedItem, 'magnifier');

      notifier.tapScene(0.5, 0.25); // painting
      session = current(container);
      expect(session.game.flags['saw_hidden_mark'], isTrue);
      expect(session.selectedItem, isNull);
      expect(session.currentText, 'test_room.painting.magnified');
    });

    test('text blocks scene taps until dismissed', () {
      notifier.tapScene(0.83, 0.24); // clock: setFlag + showText
      expect(current(container).currentText, 'test_room.clock.look');

      notifier.tapScene(0.5, 0.7); // desk, ignored while text is up
      expect(current(container).game.sceneId, 'room_north');

      notifier.dismissText();
      expect(current(container).currentText, isNull);
      notifier.tapScene(0.5, 0.7);
      expect(current(container).game.sceneId, 'desk');
    });

    test('examineItem action opens the examine view', () {
      notifier
        ..debugJumpToScene('room_west')
        ..tapScene(0.59, 0.73); // note: pickItem + examineItem
      final session = current(container);
      expect(session.game.inventory, ['note']);
      expect(session.examinedItem, 'note');
      notifier.closeExamine();
      expect(current(container).examinedItem, isNull);
    });

    test('examine hotspots and layers work inside the close-up', () {
      openDrawer();
      notifier
        ..tapScene(0.5, 0.72) // box
        ..examineItem('box');
      final engine = current(container).engine;
      expect(
        engine.visibleExamineLayers(current(container).game, 'box'),
        isEmpty,
      );

      notifier.tapExamine(0.5, 0.4); // lid
      final opened = current(container).game;
      expect(opened.flags['box_open'], isTrue);
      expect(engine.visibleExamineLayers(opened, 'box').map((l) => l.id), [
        'lid_open',
        'key_in_box',
      ]);

      notifier.tapScene(0.5, 0.7); // scene is covered while examining
      expect(current(container).game.flags['drawer_open'], isTrue);
      expect(current(container).openPuzzle, isNull);

      notifier.tapExamine(0.5, 0.6); // key inside
      final session = current(container);
      expect(session.game.inventory, ['box', 'small_key']);
      expect(session.currentText, 'test_room.box.key_found');
      expect(session.examinedItem, 'box');
    });

    test('restart clears selection, examine view, and text', () {
      notifier
        ..tapScene(0.83, 0.24)
        ..debugRestart();
      final session = current(container);
      expect(session.texts, isEmpty);
      expect(session.selectedItem, isNull);
      expect(session.examinedItem, isNull);
    });
  });

  test('exits, scene jumps, and restart', () async {
    final container = containerWith(files);
    await start(container);
    final notifier = container.read(gameSessionProvider(episode).notifier)
      ..takeExit('right');
    expect(current(container).game.sceneId, 'room_east');

    notifier.debugJumpToScene('room_west');
    expect(current(container).game.sceneId, 'room_west');

    notifier.debugRestart();
    expect(current(container).game.sceneId, 'room_north');
    expect(current(container).events, isEmpty);
  });

  test('content errors surface as a load error', () async {
    const scene = 'assets/content/episodes/test_room/scenes/room_north.json';
    final container = containerWith(
      _PatchedSource(files, {
        scene: (await files.loadString(
          scene,
        )).replaceFirst('"to": "room_west"', '"to": "attic"'),
      }),
    );
    container.listen(gameSessionProvider(episode), (_, _) {});
    await expectLater(
      container.read(gameSessionProvider(episode).future),
      throwsA(
        isA<ContentValidationException>().having(
          (e) => e.issues.single.message,
          'message',
          'unknown scene "attic"',
        ),
      ),
    );
  });
}

final class _RecordingGate implements HintGate {
  _RecordingGate({required this.allow});

  final bool allow;
  final List<HintUnlockRequest> requests = [];

  @override
  Future<bool> unlock(HintUnlockRequest request) async {
    requests.add(request);
    return allow;
  }
}
