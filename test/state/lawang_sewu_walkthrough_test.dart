import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/content/file_asset_source.dart';
import 'package:stillroom/core/storage/key_value_store.dart';
import 'package:stillroom/engine/engine.dart';
import 'package:stillroom/state/content_providers.dart';
import 'package:stillroom/state/game_session.dart';
import 'package:stillroom/state/storage_providers.dart';

/// Plays "Semarang, 1945" start to finish through the real content, and
/// checks that the solutions the hints give really solve the puzzles.
void main() {
  const episode = 'lawang_sewu_1945';
  late ProviderContainer container;
  late GameSession play;

  GameSessionState now() =>
      container.read(gameSessionProvider(episode)).requireValue;
  String? stage() => play.currentHints()?.key;
  EpisodeContent content() => now().engine.content;

  void readAll() {
    while (now().currentText != null) {
      play.dismissText();
    }
  }

  void solve(String puzzle) {
    expect(now().openPuzzle, puzzle);
    play.solvePuzzle(puzzle);
    readAll();
  }

  setUp(() async {
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        assetSourceProvider.overrideWithValue(
          FileAssetSource(Directory.current),
        ),
        keyValueStoreProvider.overrideWithValue(MemoryKeyValueStore()),
      ],
    );
    addTearDown(container.dispose);
    container.listen(gameSessionProvider(episode), (_, _) {});
    await container.read(gameSessionProvider(episode).future);
    play = container.read(gameSessionProvider(episode).notifier);
  });

  test('the hinted solutions solve each puzzle', () {
    T config<T extends PuzzleConfig>(String id) =>
        content().requirePuzzle(id).config as T;

    var timetable = config<SequenceConfig>('timetable').start();
    for (final id in ['samarang', 'alastua', 'brumbung', 'tanggung']) {
      (timetable, _) = timetable.tap(id);
    }
    expect(timetable.isSolved, isTrue);

    // N-I-S in Morse: −·  ··  ···
    var telegraph = config<SequenceConfig>('telegraph').start();
    for (final id in ['dash', 'dot', 'dot', 'dot', 'dot', 'dot', 'dot']) {
      (telegraph, _) = telegraph.tap(id);
    }
    expect(telegraph.isSolved, isTrue);

    var clock = config<CodeLockConfig>('station_clock').start();
    for (final (slot, turns) in [(0, 1), (1, 5), (2, 1), (3, 0)]) {
      for (var i = 0; i < turns; i++) {
        clock = clock.rotate(slot, 1);
      }
    }
    expect(clock.isSolved, isTrue, reason: '15 October = 1510');

    var lockerDoor = config<CodeLockConfig>('locker_door').start();
    for (final (slot, turns) in [(0, 9), (1, 2), (2, 8)]) {
      for (var i = 0; i < turns; i++) {
        lockerDoor = lockerDoor.rotate(slot, 1);
      }
    }
    expect(lockerDoor.isSolved, isTrue, reason: '928 doors');

    // Outer 5, middle 5, inner 5 (hint.stained_glass.3).
    var glass = config<RotaryAlignConfig>('stained_glass').start();
    for (final ring in [0, 1, 2]) {
      for (var i = 0; i < 5; i++) {
        glass = glass.turn(ring);
      }
    }
    expect(glass.isSolved, isTrue);
  });

  test('the episode can be completed', () {
    expect(now().game.sceneId, 'landing');
    expect(stage(), 'stage:read_the_ledger');

    // 1907 office: ledger, timetable, telegraph, lamp oil.
    play
      ..takeExit('left')
      ..tapScene(0.21, 0.51); // door marked 1907
    expect(now().game.sceneId, 'office_1907');
    play.tapScene(0.26, 0.52); // ledger
    readAll();
    expect(now().examinedItem, 'ledger');
    play.tapExamine(0.3, 0.5); // read page 0
    expect(now().currentText, 'lawang_sewu_1945.ledger.page_0');
    readAll();
    play.tapExamine(0.84, 0.5); // turn the page
    expect(now().game.flags['ledger_page'], 1);
    play.closeExamine();

    play.tapScene(0.73, 0.28); // timetable board
    solve('timetable');
    expect(now().game.inventory, contains('ticket_punch'));
    expect(stage(), 'stage:send_the_telegram');

    play.tapScene(0.70, 0.69); // telegraph
    solve('telegraph');
    expect(now().game.flags['telegram_sent'], isTrue);
    expect(now().game.inventory, contains('telegraph_key'));

    play.tapScene(0.10, 0.22); // oil can on the shelf
    expect(now().game.inventory, contains('lamp_oil'));

    // 1945 window: calendar and cap.
    play
      ..takeExit('back')
      ..takeExit('back')
      ..takeExit('right')
      ..tapScene(0.21, 0.51); // door marked 1945, now open
    expect(now().game.sceneId, 'window_1945');
    play.tapScene(0.77, 0.26); // calendar
    readAll();
    expect(now().game.flags['saw_calendar'], isTrue);
    play.tapScene(0.36, 0.74); // cap
    readAll();
    expect(now().game.inventory, contains('driver_cap'));

    // Station clock → lantern; lantern + oil.
    play
      ..takeExit('back')
      ..takeExit('back')
      ..tapScene(0.14, 0.28); // clock
    solve('station_clock');
    play.tapScene(0.14, 0.47); // lantern in the clock's niche
    readAll();
    play
      ..tapInventoryItem('lantern')
      ..tapInventoryItem('lamp_oil');
    expect(now().game.inventory, contains('lit_lantern'));
    expect(stage(), 'stage:light_the_cellar');

    // 1942 cellar: light it, take the whistle.
    play
      ..takeExit('left')
      ..tapScene(0.79, 0.51); // door marked 1942
    expect(now().game.sceneId, 'cellar_1942');
    play.tapScene(0.49, 0.82);
    expect(
      now().game.inventory,
      isNot(contains('whistle')),
      reason: 'nothing can be found in the dark',
    );
    readAll();
    play
      ..tapInventoryItem('lit_lantern')
      ..tapScene(0.5, 0.4);
    readAll();
    expect(now().game.flags['cellar_lit'], isTrue);
    play.tapScene(0.49, 0.82); // whistle
    readAll();
    expect(now().game.inventory, contains('whistle'));
    expect(stage(), 'stage:return_belongings');

    // Locker room: door code, then the five lockers.
    play
      ..takeExit('back')
      ..takeExit('back')
      ..takeExit('right')
      ..tapScene(0.79, 0.51); // locker room door
    solve('locker_door');
    play.tapScene(0.79, 0.51); // now an open door
    expect(now().game.sceneId, 'lockers');
    play.tapScene(0.5, 0.45);
    final lockers =
        content().requirePuzzle('lockers').config as SlotPlacementConfig;
    expect(lockers.start(now().game).available, hasLength(5));
    solve('lockers');
    expect(now().game.flags['belongings_returned'], isTrue);
    expect(now().game.inventory, isNot(contains('whistle')));
    expect(stage(), 'stage:light_the_glass');

    // The stained glass: the ending.
    play
      ..takeExit('back')
      ..takeExit('back')
      ..tapScene(0.5, 0.26); // stained glass
    expect(now().openPuzzle, 'stained_glass');
    play.solvePuzzle('stained_glass');
    expect(now().currentText, 'lawang_sewu_1945.landing.glass_solved');
    readAll();
    expect(now().game.completed, isTrue);
  });
}
