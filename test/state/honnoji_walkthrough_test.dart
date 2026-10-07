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

/// Plays "Honnō-ji, 1582" start to finish through the real content, and
/// checks that the solutions the hints give really solve the puzzles.
void main() {
  const episode = 'honnoji_1582';
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
    // The section, from the top: 1951, 1636, 1636, 1610, 1408, 1078; the
    // fill holds only an old coin but lies on the later ash. The fire is
    // the fifth layer, the later black one too young.
    final strata = content().requirePuzzle('strata').config as StrataConfig;
    expect(
      [for (var i = 0; i < strata.layers.length; i++) strata.earliest(i)],
      [1951, 1636, 1636, 1610, 1408, 1078],
    );
    expect(strata.fire, 4);
    var section = strata.start();
    for (var i = 0; i < strata.layers.length; i++) {
      section = section.date(i, strata.earliest(i));
    }
    expect(section.judgeFire(2), StrataFire.tooLate, reason: 'the decoy');
    section = section.markFire(4);
    expect(section.isSolved, isTrue);

    // The streets: east of Aburanokōji between Rokkaku and Takoyakushi;
    // east of Teramachi just south of Oike.
    final streets = content().requirePuzzle('streets').config as StreetsConfig;
    String name(String key) => now().episode.strings['en']![key]!;
    final old = streets.targets[0];
    expect(name(streets.columns[old.column]), 'Aburanokōji');
    expect(name(streets.rows[old.row]), 'Rokkaku');
    expect(name(streets.rows[old.row + 1]), startsWith('Takoyakushi'));
    final moved = streets.targets[1];
    expect(name(streets.columns[moved.column]), 'Teramachi');
    expect(name(streets.rows[moved.row]), 'Oike');
    var map = streets.start();
    for (final t in streets.targets) {
      map = map.mark(t.column, t.row);
    }
    expect(map.isSolved, isTrue);
  });

  test('the episode can be completed', () {
    expect(now().game.sceneId, 'dig');
    expect(stage(), 'stage:start');

    // The marker, the trench under its tarp, the sieves.
    tap(0.14, 0.7);
    tap(0.5, 0.66);
    expect(now().openPuzzle, isNull, reason: 'the block not yet checked');
    tap(0.84, 0.68);

    // The office: the map waits for the addresses.
    tap(0.87, 0.4);
    expect(now().game.sceneId, 'office');
    tap(0.5, 0.64);
    expect(now().openPuzzle, isNull);
    tap(0.69, 0.25);
    tap(0.15, 0.37);
    play.takeExit('back');

    // Today's Honnō-ji at Teramachi: the hall, the memorial, the leaflet,
    // the guide's tale.
    tap(0.5, 0.42);
    expect(now().game.sceneId, 'teramachi');
    tap(0.5, 0.3);
    tap(0.16, 0.5);
    tap(0.78, 0.66);
    expect(now().game.words, containsAll(['teramachi', 'date_1591']));
    tap(0.72, 0.4);
    expect(now().game.words, contains('escaped'));
    play.takeExit('back');

    // The finds room: the chronicle.
    tap(0.24, 0.35);
    expect(now().game.sceneId, 'finds');
    tap(0.15, 0.45);
    tap(0.4, 0.62);
    expect(now().game.words, contains('akechi'));
    expect(stage(), 'stage:office');
    tap(0.56, 0.59);
    expect(now().currentText, isNull, reason: 'no tile on the cloth yet');
    play.takeExit('back');

    // The streets.
    tap(0.87, 0.4);
    tap(0.5, 0.64);
    solve('streets');
    expect(stage(), 'stage:dig');
    play.takeExit('back');

    // The section.
    tap(0.5, 0.66);
    solve('strata');
    expect(now().game.words, contains('fire'));
    expect(stage(), 'stage:frois');

    // The tile, Fróis, the later papers.
    tap(0.24, 0.35);
    tap(0.56, 0.59);
    expect(now().currentText, isNull);
    tap(0.72, 0.62);
    expect(now().game.words, contains('nothing'));
    expect(stage(), 'stage:later');
    tap(0.66, 0.3);
    expect(
      now().game.words,
      containsAll(['hideyoshi', 'ieyasu', 'court', 'statue']),
    );
    expect(stage(), 'stage:write_seal');
    play.takeExit('back');

    // The keeper's slip behind the memorial.
    tap(0.5, 0.42);
    tap(0.16, 0.5);
    expect(now().game.secretFound, isTrue);
    expect(
      container.read(saveRepositoryProvider).keeperNote(episode),
      'honnoji_1582.teramachi.keeper_note',
    );
    play.takeExit('back');

    // The seal: the stone marker.
    tap(0.14, 0.7);
    expect(now().openPuzzle, 'jar_label');
    final label =
        content().requirePuzzle('jar_label').config as DeductionConfig;
    expect(label.form, DeductionForm.marker);
    var deduction = label.start(now().game);
    expect(
      deduction.available,
      containsAll(label.answers),
      reason: 'every answer was noted on the way',
    );
    expect(
      deduction.available,
      containsAll(['escaped', 'hideyoshi', 'statue', 'teramachi']),
      reason: 'the legends are there to mislead',
    );
    for (final (i, answer) in label.answers.indexed) {
      deduction = deduction.fill(i, answer);
    }
    expect(deduction.isSolved, isTrue);
    play.solvePuzzle('jar_label');
    expect(now().currentText, 'honnoji_1582.label.done');
    readAll();
    expect(now().game.completed, isTrue);
  });
}
