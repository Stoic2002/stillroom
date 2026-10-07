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

  /// Lays every sheet of an overlay puzzle in place after [turns] quarter
  /// turns each, as the hints say.
  bool layDown(String puzzle, Map<String, int> turns) {
    final config = content().requirePuzzle(puzzle).config as OverlayConfig;
    var sheets = config.start();
    for (final MapEntry(key: id, value: n) in turns.entries) {
      for (var i = 0; i < n; i++) {
        sheets = sheets.turn(id);
      }
    }
    for (final sheet in config.sheets) {
      final at = sheets.place(sheet.id);
      sheets = sheets
          .move(sheet.id, sheet.rect.x - at.x + 0.01, sheet.rect.y - at.y)
          .drop(sheet.id);
    }
    return sheets.isSolved;
  }

  test('the hinted moves solve the fresco, the tablet and the tracings', () {
    expect(
      layDown('fresco', {
        'piece_1': 3,
        'piece_2': 2,
        'piece_4': 1,
        'piece_5': 2,
        'piece_6': 3,
      }),
      isTrue,
    );
    expect(layDown('tracings', {'people': 3, 'words': 1, 'gate': 2}), isTrue);
    final tablet =
        content().requirePuzzle('wax_tablet').config as RakingLightConfig;
    var light = tablet.start();
    expect(light.isSolved, isFalse);
    expect(light.clarity, 0, reason: 'the lamp starts on the wrong side');
    // "To the left of the tablet, a little above the middle."
    light = light.moveTo(290);
    expect(light.isSolved, isTrue);
  });

  test('the lens turns through the hours where the house changes', () {
    play
      ..tapScene(0.77, 0.6) // hut
      ..tapScene(0.587, 0.56); // lens
    readAll();
    play
      ..takeExit('back')
      ..tapScene(0.925, 0.6);
    expect(now().engine.lensHour(now().game), 0);
    play.turnLensHour();
    expect(now().engine.lensHour(now().game), 1);
    play
      ..turnLensHour()
      ..turnLensHour();
    expect(now().engine.lensHour(now().game), 0, reason: 'round again');
  });

  test('the episode can be completed', () {
    expect(now().game.sceneId, 'street');
    expect(stage(), 'stage:start');
    expect(now().engine.lens(now().game), isNull);
    look(0.57, 0.5); // the diggers' board: 1748

    // The hut: the lens, the shovel, and the papers.
    play.tapScene(0.77, 0.6);
    expect(now().game.sceneId, 'hut');
    expect(now().engine.lens(now().game), isNull, reason: 'no hut in 79');
    look(0.587, 0.56); // lens
    look(0.175, 0.6); // shovel
    expect(now().game.inventory, containsAll(['era_lens', 'shovel']));
    for (final (x, y) in [
      (0.33, 0.33),
      (0.627, 0.32),
      (0.71, 0.32),
      (0.72, 0.56),
    ]) {
      look(x, y);
    }
    expect(stage(), 'stage:dig');

    // The shovel digs the shop door out, even with the lens raised: acting
    // happens in the present.
    play.takeExit('back');
    expect(now().engine.lensScene(now().game)?.id, 'street_79');
    lens(0.17, 0.15); // the cloud over the mountain
    play
      ..tapInventoryItem('shovel')
      ..tapLens(0.27, 0.65);
    readAll();
    expect(now().game.flags['door_dug'], isTrue);
    play.tapScene(0.26, 0.6);
    expect(now().game.sceneId, 'bakery');

    // The bakery: autumn in the store, the oven levered open, the stamp.
    look(0.92, 0.6);
    useOn('shovel', 0.67, 0.4);
    look(0.67, 0.4); // the loaves
    lens(0.91, 0.58); // the basket
    expect(now().game.words, containsAll(['felix', 'autumn', 'bread']));

    // The atrium: the shrine's painted panel lies in pieces.
    play.tapScene(0.41, 0.5);
    expect(now().game.sceneId, 'atrium');
    expect(stage(), 'stage:fresco');
    // Through the lens in the morning the panel is whole: the picture to
    // rebuild it by.
    expect(now().engine.lensScene(now().game)?.id, 'atrium_79_morning');
    lens(0.13, 0.35);
    look(0.13, 0.4); // the shrine: the pieces
    expect(now().openPuzzle, 'fresco');
    play.solvePuzzle('fresco');
    readAll();
    expect(stage(), 'stage:find_key');

    // A loose stone, but no key yet: nobody has watched it hidden.
    look(0.13, 0.4);
    expect(now().game.inventory, isNot(contains('arca_key')));
    // Noon: the cloud over the roof. Afternoon: the woman at the shrine.
    play.turnLensHour();
    expect(now().engine.lensScene(now().game)?.id, 'atrium_79_noon');
    lens(0.5, 0.1);
    play.turnLensHour();
    expect(now().engine.lensScene(now().game)?.id, 'atrium_79');
    lens(0.1, 0.4); // she hides the key
    lens(0.3, 0.55); // the family at the door
    lens(0.5, 0.72); // stones in the basin
    look(0.13, 0.4); // press where she pressed
    expect(now().game.inventory, contains('arca_key'));
    expect(stage(), 'stage:open_arca');

    // The strongbox, and in it the wax tablets.
    useOn('arca_key', 0.67, 0.58);
    expect(now().game.inventory, contains('wax_tablet'));
    expect(stage(), 'stage:read_tablet');

    // The secret: through the lens a clay horse is hidden under the stair.
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

    // In the hut, the lamp reads the wax.
    play
      ..takeExit('back')
      ..takeExit('back')
      ..takeExit('back')
      ..tapScene(0.77, 0.6);
    expect(now().game.sceneId, 'hut');
    useOn('wax_tablet', 0.81, 0.55);
    expect(now().openPuzzle, 'wax_tablet');
    play.solvePuzzle('wax_tablet');
    readAll();
    expect(now().game.words, containsAll(['felix', 'marina_gate']));
    expect(stage(), 'stage:find_drawing');

    // The child's drawing by the door: the diggers traced it.
    play
      ..takeExit('back')
      ..tapScene(0.26, 0.6)
      ..tapScene(0.41, 0.5);
    look(0.3, 0.4);
    look(0.3, 0.635); // the draughtsman's tube
    expect(now().game.inventory, contains('tracings'));
    expect(stage(), 'stage:trace');

    // The drawing, laid together on the drafting table.
    play
      ..takeExit('back')
      ..takeExit('back')
      ..tapScene(0.77, 0.6);
    useOn('tracings', 0.45, 0.75);
    expect(now().openPuzzle, 'tracings');
    play.solvePuzzle('tracings');
    readAll();
    expect(stage(), 'stage:seal');

    // The seal at the shrine.
    play
      ..takeExit('back')
      ..tapScene(0.26, 0.6)
      ..tapScene(0.41, 0.5)
      ..tapScene(0.13, 0.4);
    expect(now().openPuzzle, 'jar_label');
    final label =
        content().requirePuzzle('jar_label').config as DeductionConfig;
    expect(label.answers, hasLength(3), reason: 'a short seal, not a form');
    var deduction = label.start(now().game);
    expect(deduction.available, containsAll(label.answers));
    expect(
      deduction.available,
      containsAll(['vesuvius_gate', 'lava', 'year_1748']),
      reason: 'the wrong gate and the legend are there to mislead',
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
