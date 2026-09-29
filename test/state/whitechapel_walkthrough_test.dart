import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/content/file_asset_source.dart';
import 'package:stillroom/core/storage/key_value_store.dart';
import 'package:stillroom/engine/engine.dart';
import 'package:stillroom/state/content_providers.dart';
import 'package:stillroom/state/game_session.dart';
import 'package:stillroom/state/save_repository.dart';
import 'package:stillroom/state/storage_providers.dart';

/// Plays "Whitechapel, 1888" start to finish through the real content, so a
/// content change that makes the episode unwinnable fails here.
void main() {
  const episode = 'whitechapel_1888';

  test('the episode can be completed', () async {
    final container = ProviderContainer(
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
    final play = container.read(gameSessionProvider(episode).notifier);
    GameSessionState now() =>
        container.read(gameSessionProvider(episode)).requireValue;
    String? stage() => play.currentHints()?.key;

    /// Reads every queued text like a careful player: notes each
    /// underlined word first.
    void readAll() {
      for (var key = now().currentText; key != null; key = now().currentText) {
        final text = now().episode.strings['en']![key]!;
        markedWords(text).forEach(play.noteWord);
        play.dismissText();
      }
    }

    void solve(String puzzle) {
      expect(now().openPuzzle, puzzle);
      play.solvePuzzle(puzzle);
      readAll();
    }

    expect(now().game.sceneId, 'room_north');
    expect(stage(), 'stage:open_drawer');

    // 1. The desk drawer: its clock-face lock, set to the stopped clock.
    final drawer =
        now().engine.content.requirePuzzle('desk_drawer').config
            as ClockHandsConfig;
    expect(
      drawer.start().pointHour(3).pointMinute(40).isSolved,
      isTrue,
      reason: 'the hint: III and VIII, 3:40',
    );
    play.tapScene(0.7, 0.69); // desk (exit area)
    expect(now().game.sceneId, 'desk');
    play.tapScene(0.5, 0.77); // drawer
    solve('desk_drawer');
    expect(
      now().game.inventory,
      containsAll(['matches', 'letter', 'name_card_nichols']),
    );
    expect(stage(), 'stage:light_candles');

    // 2. The candles on the mantel, lit with the matches.
    play
      ..takeExit('back')
      ..takeExit('right')
      ..tapInventoryItem('matches')
      ..tapScene(0.5, 0.42); // candles
    readAll();
    expect(now().game.flags['candles_ready'], isTrue);
    expect(now().game.inventory, contains('name_card_chapman'));

    // 3. The street map by the window: the red thread, oldest first.
    final thread =
        now().engine.content.requirePuzzle('street_thread').config
            as ThreadConfig;
    var wool = thread.start();
    wool = wool.reach('bucks_row').reach('berner_street');
    expect(wool.path, isEmpty, reason: 'a wrong pin snaps the thread');
    for (final pin in thread.solution) {
      wool = wool.reach(pin);
    }
    expect(wool.isSolved, isTrue);
    play
      ..takeExit('left')
      ..tapScene(0.27, 0.35); // window (exit area)
    expect(now().game.sceneId, 'window');
    play.tapScene(0.73, 0.42); // street map
    solve('street_thread');
    expect(
      now().game.inventory,
      containsAll(['name_card_stride', 'name_card_eddowes']),
    );

    // 4. Lens from the coat + brass frame from the floor = magnifier.
    play
      ..takeExit('back')
      ..takeExit('left') // room_west
      ..tapScene(0.65, 0.85) // brass frame
      ..takeExit('left') // room_south
      ..tapScene(0.8, 0.4); // coat pocket
    readAll();
    play
      ..tapInventoryItem('lens')
      ..tapInventoryItem('brass_frame');
    expect(now().game.inventory, contains('magnifier'));

    // 5. Read the faded paper on the desk with it.
    play
      ..takeExit('right') // room_west
      ..takeExit('right') // room_north
      ..tapScene(0.7, 0.69) // desk
      ..tapInventoryItem('magnifier')
      ..tapScene(0.67, 0.27); // faded paper
    readAll();
    expect(now().game.inventory, contains('name_card_kelly'));
    expect(stage(), 'stage:write_label');

    // 6. Each card names her and says where she was found (read in the
    // close-up view).
    for (final n in ['nichols', 'chapman', 'stride', 'eddowes', 'kelly']) {
      final desc = now()
          .episode
          .strings['en']!['item.whitechapel_1888.name_card_$n.desc']!;
      markedWords(desc).forEach(play.noteWord);
    }

    // 7. The clippings give the streets too.
    play
      ..takeExit('back')
      ..tapScene(0.25, 0.28); // clippings
    readAll();
    play.takeExit('back');

    // 8. Wipe the fog on the window (not needed, but it helps).
    play
      ..tapScene(0.27, 0.35) // window
      ..tapScene(0.2, 0.5); // fog
    readAll();
    solve('window_fog');

    // 9. The secret: look into the hearth twice, brush the ash aside.
    play
      ..takeExit('back')
      ..takeExit('right') // room_east
      ..tapScene(0.5, 0.8); // hearth
    readAll();
    expect(now().game.secretFound, isFalse);
    play.tapScene(0.5, 0.8);
    solve('hearth_ash');
    expect(now().game.secretFound, isTrue);
    expect(
      container.read(saveRepositoryProvider).keeperNote(episode),
      'whitechapel_1888.keeper.note',
    );

    // 10. The frames on the west wall are the jar's label: a ledger of
    // five dates, a name and a place under each.
    play
      ..takeExit('right') // room_south
      ..tapScene(0.5, 0.5); // the door stays shut
    readAll();
    expect(now().game.completed, isFalse);
    play
      ..takeExit('right') // room_west
      ..tapScene(0.5, 0.33); // frames
    readAll();
    expect(now().openPuzzle, 'jar_label');
    final label =
        now().engine.content.requirePuzzle('jar_label').config
            as DeductionConfig;
    var deduction = label.start(now().game);
    expect(
      deduction.available,
      containsAll(label.answers),
      reason: 'every answer was noted on the way',
    );
    for (final (i, answer) in label.answers.indexed) {
      deduction = deduction.fill(i, answer);
    }
    expect(deduction.isSolved, isTrue);
    play.solvePuzzle('jar_label');
    readAll();
    expect(now().game.flags['names_restored'], isTrue);
    expect(now().game.inventory, isNot(contains('name_card_kelly')));
    expect(stage(), 'stage:leave');

    // 11. The door lets the keeper go.
    play
      ..takeExit('left') // room_south
      ..tapScene(0.5, 0.5);
    readAll();
    expect(now().game.completed, isTrue);
    expect(container.read(saveRepositoryProvider).isCompleted(episode), isTrue);
  });
}
