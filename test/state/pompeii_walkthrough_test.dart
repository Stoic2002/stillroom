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

/// Plays "Pompeii, 79" start to finish through the real content, looking
/// through the lens where the tale needs it, and checks that the hinted
/// moves solve the tracing sheets.
void main() {
  const episode = 'pompeii_79';
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

  void look(double x, double y) {
    play.tapScene(x, y);
    readAll();
  }

  void lens(double x, double y) {
    play.tapLens(x, y);
    readAll();
  }

  void useOn(String item, double x, double y) {
    play
      ..tapInventoryItem(item)
      ..tapScene(x, y);
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

  test('the hinted moves lay the tracings together', () {
    final config = content().requirePuzzle('tracings').config as OverlayConfig;
    var sheets = config.start();
    // Figures three turns, words one; then each into the middle.
    for (var i = 0; i < 3; i++) {
      sheets = sheets.turn('people');
    }
    sheets = sheets.turn('words');
    for (final sheet in config.sheets) {
      final at = sheets.place(sheet.id);
      sheets = sheets
          .move(sheet.id, sheet.rect.x - at.x + 0.01, sheet.rect.y - at.y)
          .drop(sheet.id);
    }
    expect(sheets.isSolved, isTrue);
  });

  test('the episode can be completed', () {
    expect(now().game.sceneId, 'street');
    expect(stage(), 'stage:start');
    // No lens yet.
    expect(now().engine.lens(now().game), isNull);
    look(0.57, 0.5); // the diggers' board: 1748
    look(0.27, 0.65); // the ash bank

    // The hut: the lens, the shovel, and the papers.
    play.tapScene(0.77, 0.6);
    expect(now().game.sceneId, 'hut');
    expect(now().engine.lens(now().game), isNull, reason: 'no hut in 79');
    look(0.425, 0.58); // lens
    look(0.925, 0.6); // shovel
    expect(now().game.inventory, containsAll(['era_lens', 'shovel']));
    for (final (x, y) in [
      (0.17, 0.28),
      (0.77, 0.26),
      (0.88, 0.26),
      (0.81, 0.55),
    ]) {
      look(x, y);
    }
    expect(stage(), 'stage:dig');

    // The shovel digs the shop door out.
    play.takeExit('back');
    expect(now().engine.lens(now().game)?.scene, 'street_79');
    lens(0.17, 0.15); // the cloud over the mountain
    // With the shovel in hand, the ash bank is dug even through the lens:
    // looking happens in 79, acting in the present.
    play
      ..tapInventoryItem('shovel')
      ..tapLens(0.27, 0.65);
    readAll();
    expect(now().game.flags['door_dug'], isTrue);
    expect(stage(), 'stage:into_house');
    play.tapScene(0.26, 0.6);
    expect(now().game.sceneId, 'bakery');

    // The bakery: autumn in the store, the oven levered open, and through
    // the lens, the baker's stamp.
    look(0.92, 0.6);
    look(0.67, 0.4);
    expect(now().game.flags['oven_open'], isFalse);
    useOn('shovel', 0.67, 0.4);
    expect(now().game.flags['oven_open'], isTrue);
    look(0.67, 0.4); // the loaves
    lens(0.91, 0.58); // the basket
    expect(now().game.words, containsAll(['felix', 'autumn', 'bread']));

    // The atrium: the tracings, and through the lens the family leaving.
    play.tapScene(0.41, 0.5);
    expect(now().game.sceneId, 'atrium');
    look(0.3, 0.675);
    expect(now().game.inventory, contains('tracings'));
    expect(stage(), 'stage:trace');
    lens(0.29, 0.5); // the family at the door
    lens(0.5, 0.72); // stones in the basin
    // Nothing yet under the stair in the ruin; the lens shows why to look.
    look(0.87, 0.76);
    expect(now().game.secretFound, isFalse);
    lens(0.86, 0.75);
    look(0.87, 0.76);
    expect(now().game.secretFound, isTrue);
    expect(
      container.read(saveRepositoryProvider).keeperNote(episode),
      'pompeii_79.atrium.toy_note',
    );

    // The garden: the layers of the cut.
    play.tapScene(0.5, 0.4);
    expect(now().game.sceneId, 'garden');
    look(0.79, 0.55);
    lens(0.52, 0.15);

    // The drafting table in the hut.
    play
      ..takeExit('back')
      ..takeExit('back')
      ..takeExit('back')
      ..tapScene(0.77, 0.6);
    expect(now().game.sceneId, 'hut');
    useOn('tracings', 0.6, 0.68);
    expect(now().openPuzzle, 'tracings');
    play.solvePuzzle('tracings');
    readAll();
    expect(stage(), 'stage:write_label');

    // The label at the shrine.
    play
      ..takeExit('back')
      ..tapScene(0.26, 0.6)
      ..tapScene(0.41, 0.5)
      ..tapScene(0.13, 0.39);
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
      containsAll(['august_24', 'lava', 'vesuvius_gate', 'year_1748']),
      reason: 'the legend and the wrong gate are there to mislead',
    );
    for (final (i, answer) in label.answers.indexed) {
      deduction = deduction.fill(i, answer);
    }
    expect(deduction.isSolved, isTrue);
    play.solvePuzzle('jar_label');
    expect(now().currentText, 'pompeii_79.label.done');
    readAll();
    expect(now().game.completed, isTrue);
  });
}
