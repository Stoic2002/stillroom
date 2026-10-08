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

/// Plays "Alamut, 1256" start to finish through the real content, and
/// checks that the solutions the hints give really solve the puzzles.
void main() {
  const episode = 'alamut_1256';
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

  void tap(double x, double y) {
    play.tapScene(x, y);
    readAll();
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
    // The quire: from the outside in, pages 1 and 8, 2 and 7, 3 and 6, 4
    // and 5, none turned over.
    final quire = content().requirePuzzle('quire').config as QuireConfig;
    expect(quire.leaves, hasLength(8));
    var sheets = quire.start();
    expect(sheets.links, lessThan(3), reason: 'it starts well scrambled');
    for (var k = 0; k < quire.sheets; k++) {
      sheets = sheets.swap(sheets.order.indexOf(k), k);
    }
    for (var k = 0; k < quire.sheets; k++) {
      if (sheets.turned[k]) sheets = sheets.turn(k);
    }
    expect(sheets.isSolved, isTrue);
    expect(
      [for (var p = 0; p < 8; p++) sheets.leafAt(p)],
      [0, 1, 2, 3, 4, 5, 6, 7],
    );

    // The tanks: wine, vinegar, honey, water, left to right; and full.
    final dip = content().requirePuzzle('dip').config as DipConfig;
    expect(
      [for (final t in dip.tanks) t.liquid],
      [DipLiquid.wine, DipLiquid.vinegar, DipLiquid.honey, DipLiquid.water],
    );
    expect(
      dip.names.map((n) => n.liquid),
      contains(DipLiquid.milk),
      reason: "Polo's milk is offered, to mislead",
    );
    var tanks = dip.start();
    for (final (t, tank) in dip.tanks.indexed) {
      tanks = tanks.dip(t).name(t, tank.liquid);
    }
    expect(tanks.judge(full: true).isSolved, isTrue);
    expect(dip.storesFull, isTrue);
  });

  test('the episode can be completed', () {
    expect(now().game.sceneId, 'gate_court');
    expect(stage(), 'stage:start');

    // The storerooms are locked until the commander's keys are found.
    tap(0.09, 0.6);
    expect(now().game.sceneId, 'gate_court', reason: 'locked');

    // The order at the gate.
    tap(0.29, 0.53);
    expect(now().game.words, contains('date_1256'));
    expect(stage(), 'stage:tower');

    // The tower: Hasan's bare room, Polo's book, the keys.
    tap(0.69, 0.58);
    expect(now().game.sceneId, 'tower');
    tap(0.25, 0.77);
    expect(now().game.words, containsAll(['hasan', 'date_1090']));
    tap(0.5, 0.75);
    expect(
      now().game.words,
      containsAll(['polo', 'garden', 'date_1262', 'three_years']),
    );
    tap(0.71, 0.36);
    tap(0.335, 0.37);
    expect(now().game.flags['took_keys'], isTrue);
    expect(stage(), 'stage:stores');
    play.takeExit('back');

    // The storerooms: the tunnel waits on the count of the stores.
    tap(0.09, 0.6);
    expect(now().game.sceneId, 'storerooms');
    tap(0.88, 0.42);
    expect(now().game.sceneId, 'storerooms', reason: 'the count first');
    tap(0.42, 0.73);
    solve('dip');
    expect(stage(), 'stage:library');

    // The library.
    tap(0.88, 0.42);
    expect(now().game.sceneId, 'library');
    tap(0.73, 0.45);
    expect(now().game.flags['read_later'], isFalse, reason: 'not there yet');
    tap(0.8, 0.83);
    expect(now().game.words, containsAll(['tusi', 'hulagu']));
    tap(0.49, 0.79);
    solve('quire');
    expect(now().game.words, containsAll(['library', 'juvayni']));
    expect(stage(), 'stage:later');
    tap(0.73, 0.45);
    expect(now().game.words, contains('hashish'));
    expect(stage(), 'stage:write_seal');

    // The keeper's slip under the astrolabe's empty throne.
    tap(0.52, 0.45);
    expect(now().game.secretFound, isTrue);
    expect(
      container.read(saveRepositoryProvider).keeperNote(episode),
      'alamut_1256.library.keeper_note',
    );
    play.takeExit('back');
    expect(now().game.sceneId, 'storerooms');
    play.takeExit('back');
    expect(now().game.sceneId, 'gate_court');

    // The seal: the colophon at the gate.
    tap(0.29, 0.53);
    expect(now().openPuzzle, 'jar_label');
    final label =
        content().requirePuzzle('jar_label').config as DeductionConfig;
    expect(label.form, DeductionForm.colophon);
    var deduction = label.start(now().game);
    expect(
      deduction.available,
      containsAll(label.answers),
      reason: 'every answer was noted on the way',
    );
    expect(
      deduction.available,
      containsAll(['garden', 'hulagu', 'date_1262']),
      reason: 'the legend and the near misses are there to mislead',
    );
    for (final (i, answer) in label.answers.indexed) {
      deduction = deduction.fill(i, answer);
    }
    expect(deduction.isSolved, isTrue);
    play.solvePuzzle('jar_label');
    expect(now().currentText, 'alamut_1256.label.done');
    readAll();
    expect(now().game.completed, isTrue);
  });
}
