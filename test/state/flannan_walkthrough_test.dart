import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/content/file_asset_source.dart';
import 'package:stillroom/core/storage/key_value_store.dart';
import 'package:stillroom/engine/engine.dart';
import 'package:stillroom/state/content_providers.dart';
import 'package:stillroom/state/game_session.dart';
import 'package:stillroom/state/save_repository.dart';
import 'package:stillroom/state/storage_providers.dart';

/// Plays "Flannan Isles, 1900" start to finish through the real content, and
/// checks that the solutions the hints give really solve the puzzles.
void main() {
  const episode = 'flannan_isles_1900';
  late ProviderContainer container;
  late GameSession play;

  GameSessionState now() =>
      container.read(gameSessionProvider(episode)).requireValue;
  String? stage() => play.currentHints()?.key;
  EpisodeContent content() => now().engine.content;

  void readAll() {
    for (var key = now().currentText; key != null; key = now().currentText) {
      markedWords(now().episode.strings['en']![key]!).forEach(play.noteWord);
      play.dismissText();
    }
  }

  void solve(String puzzle) {
    expect(now().openPuzzle, puzzle);
    play.solvePuzzle(puzzle);
    readAll();
  }

  void useOn(String item, double x, double y) => play
    ..tapInventoryItem(item)
    ..tapScene(x, y);

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
    var crank = (content().requirePuzzle('clockwork').config as CrankConfig)
        .start();
    crank = crank.turn(-math.pi); // the ratchet holds
    expect(crank.wound, 0);
    for (var i = 0; i < 16; i++) {
      crank = crank.turn(math.pi / 2);
    }
    expect(crank.isSolved, isTrue, reason: 'four turns clockwise');
  });

  test('the episode can be completed', () {
    expect(now().game.sceneId, 'east_landing');
    expect(stage(), 'stage:open_gate');
    expect(now().engine.darkness(now().game), isNull);

    // The gate: its latch lifts.
    play.tapScene(0.6, 0.4); // plaque
    readAll();
    play.tapScene(0.51, 0.49); // gate
    readAll();
    expect(now().game.flags['gate_open'], isTrue);
    play.tapScene(0.51, 0.49); // through the open gate
    expect(now().game.sceneId, 'yard');
    expect(stage(), 'stage:light_lantern');

    // Without a light, the store and the tower stay shut.
    play.tapScene(0.35, 0.6);
    expect(now().game.sceneId, 'yard');
    readAll();

    // The quarters: the log, the slate, the hooks, the legend; a lantern.
    play.tapScene(0.15, 0.56);
    expect(now().game.sceneId, 'kitchen');
    for (final (x, y) in [
      (0.5, 0.6),
      (0.62, 0.28),
      (0.75, 0.35),
      (0.39, 0.28),
    ]) {
      play.tapScene(x, y);
      readAll();
    }
    play
      ..tapScene(0.195, 0.495) // matches
      ..tapScene(0.855, 0.7) // lantern
      ..tapInventoryItem('hand_lantern')
      ..tapInventoryItem('matches');
    expect(now().game.inventory, contains('lit_lantern'));
    expect(stage(), 'stage:climb_tower');

    // The oil store is dark: search it by lantern light.
    play
      ..takeExit('back')
      ..tapScene(0.35, 0.6);
    expect(now().game.sceneId, 'oil_store');
    expect(now().engine.darkness(now().game)?.radius, 0.15);
    play
      ..tapScene(0.75, 0.625) // winding handle
      ..tapScene(0.5, 0.8); // paraffin (a red herring)
    expect(now().game.inventory, containsAll(['crank_handle', 'paraffin']));

    // The dark stair: the key, the secret, the lamp-room door.
    play
      ..takeExit('back')
      ..tapScene(0.59, 0.51);
    expect(now().game.sceneId, 'stair');
    play.tapScene(0.745, 0.4); // key
    expect(now().game.inventory, contains('lamp_key'));
    play.tapScene(0.19, 0.51); // the fourth hook
    readAll();
    expect(now().game.secretFound, isTrue);
    expect(
      container.read(saveRepositoryProvider).keeperNote(episode),
      'flannan_isles_1900.stair.hook_note',
    );
    useOn('lamp_key', 0.5, 0.2);
    readAll();
    play.tapScene(0.5, 0.2); // up
    expect(now().game.sceneId, 'lamp_room');
    expect(stage(), 'stage:wind_clockwork');

    // The lamp won't be lit before the lens can turn; wind the clockwork.
    useOn('lit_lantern', 0.5, 0.42);
    expect(now().currentText, 'flannan_isles_1900.lamp.need_wind');
    readAll();
    useOn('paraffin', 0.5, 0.42);
    expect(now().currentText, 'flannan_isles_1900.lamp.full');
    readAll();
    useOn('crank_handle', 0.15, 0.66);
    solve('clockwork');
    useOn('lit_lantern', 0.5, 0.42);
    readAll();
    expect(now().game.flags['lamp_lit'], isTrue);
    play.tapScene(0.82, 0.61); // the legend's pages
    readAll();
    expect(stage(), 'stage:watch_beam');

    // The gallery: the beam over the island shows the way west.
    play.tapScene(0.94, 0.5);
    readAll();
    expect(now().openPuzzle, 'beam');
    solve('beam');
    expect(now().game.flags['path_seen'], isTrue);
    expect(stage(), 'stage:go_west');

    // The yard: the rail dragged off the path west.
    play
      ..takeExit('back')
      ..takeExit('back')
      ..tapScene(0.88, 0.67);
    expect(now().game.sceneId, 'yard', reason: 'the rail is still there');
    readAll();
    expect(now().game.flags['rail_moved'], isTrue);
    expect(stage(), 'stage:go_down');
    play.tapScene(0.88, 0.67);
    expect(now().game.sceneId, 'west_landing');
    play.tapScene(0.2, 0.6); // railings
    readAll();
    play.tapScene(0.55, 0.27); // the plate where the rope box stood
    readAll();
    expect(now().game.words, isNot(contains('great_sea')));

    // Down the steps between the waves.
    play.tapScene(0.6, 0.7);
    readAll();
    expect(now().openPuzzle, 'swell');
    final swell = content().requirePuzzle('swell').config as SwellConfig;
    final great = [
      for (var i = 0; i < swell.pattern.length; i++)
        if (swell.isGreat(i)) i,
    ].first;
    var down = swell.start().advance(swell.breakTime(great) + 0.05);
    for (var i = 0; i < swell.steps; i++) {
      down = down.stepDown(
        swell.breakTime(great) + 0.05 + i * swell.stepSeconds,
      );
    }
    expect(down.isSolved, isTrue, reason: 'right after the great sea');
    solve('swell');
    expect(now().game.words, contains('great_sea'));
    expect(stage(), 'stage:who_went');

    // The hooks by the kitchen door: who went, how, and when.
    play
      ..takeExit('back')
      ..tapScene(0.15, 0.56);
    expect(now().game.sceneId, 'kitchen');
    play.tapScene(0.8, 0.3);
    readAll();
    expect(now().openPuzzle, 'roster');
    final roster = content().requirePuzzle('roster').config as RosterConfig;
    var board = roster.start();
    for (final row in roster.rows) {
      for (final column in roster.columns) {
        while (board.pick(row.id, column.id) !=
            roster.solution[row.id]![column.id]) {
          board = board.cycle(row.id, column.id);
        }
      }
    }
    expect(board.isSolved, isTrue);
    solve('roster');
    expect(stage(), 'stage:write_label');

    // Back to the lamp: the jar's label.
    play
      ..takeExit('back')
      ..tapScene(0.59, 0.51) // tower
      ..tapScene(0.5, 0.2) // up
      ..tapScene(0.5, 0.42); // lamp
    readAll();
    expect(now().openPuzzle, 'jar_label');
    final label =
        content().requirePuzzle('jar_label').config as DeductionConfig;
    var deduction = label.start(now().game);
    expect(
      deduction.available,
      containsAll(label.answers),
      reason: 'every answer was noted on the way',
    );
    expect(
      deduction.available,
      containsAll(['chair', 'meal', 'storm_log', 'date_13dec']),
      reason: 'the legend and the log are there to mislead',
    );
    // The seal starts written the legend's way: wrong in three places.
    expect(deduction.filled, hasLength(label.answers.length));
    expect(deduction.check(), isA<DeductionWrong>());
    expect([
      for (final (i, answer) in label.answers.indexed)
        if (deduction.filled[i] != answer) i,
    ], hasLength(3));
    for (final (i, answer) in label.answers.indexed) {
      deduction = deduction.fill(i, answer);
    }
    expect(deduction.isSolved, isTrue);
    play.solvePuzzle('jar_label');
    expect(now().currentText, 'flannan_isles_1900.label.done');
    readAll();
    expect(now().game.completed, isTrue);
  });
}
