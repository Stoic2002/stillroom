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

/// Plays "the Franklin expedition, 1845" start to finish through the real content, and
/// checks that the solutions the hints give really solve the puzzles.
void main() {
  const episode = 'franklin_1845';
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
    // The note: the 1848 hand up the right side, upside down along the
    // top, down the left side.
    final note = content().requirePuzzle('margins').config as MarginsConfig;
    var sheet = note.start();
    expect(sheet.answer(1).mistakes, 1, reason: '"All well" is the trap');
    sheet = sheet.rotate(1).answer(3).rotate(1).answer(4).rotate(1).answer(5);
    expect(sheet.isSolved, isTrue);

    // The survey: the sixth lane from the top, the long echo.
    final sonar = content().requirePuzzle('sonar').config as SonarConfig;
    expect(sonar.wreckRow, 5);
    var survey = sonar.start().runLane(5);
    survey = survey.mark(sonar.wreckColumn, sonar.wreckRow);
    expect(survey.isSolved, isTrue);
    // The north, toward Victory Point, holds nothing but rock and scour.
    for (var c = 0; c < sonar.columns; c++) {
      expect(sonar.echoAt(c, 0), isNot(SonarEcho.wreck));
    }
  });

  test('the episode can be completed', () {
    expect(now().game.sceneId, 'deck');
    expect(stage(), 'stage:start');

    // The deck: the ice chart, the shore.
    tap(0.14, 0.47);
    tap(0.9, 0.37);

    // The survey room: the note, Hall's chart; the sonar waits.
    tap(0.23, 0.6);
    expect(now().game.sceneId, 'survey');
    tap(0.57, 0.62);
    solve('margins');
    expect(
      now().game.words,
      containsAll(['date_1848', 'date_1847', 'victory_point']),
    );
    tap(0.4, 0.62);
    tap(0.5, 0.4);
    expect(now().openPuzzle, isNull, reason: 'the stories first');
    expect(stage(), 'stage:hall');
    play.takeExit('back');

    // Gjoa Haven: the elders' stories, the wall map.
    tap(0.68, 0.45);
    expect(now().game.sceneId, 'hall');
    tap(0.5, 0.65);
    expect(now().game.words, contains('ugjulik'));
    tap(0.4, 0.3);
    tap(0.655, 0.3);
    expect(stage(), 'stage:island');
    play.takeExit('back');

    // The sonar still waits for word from the islands.
    tap(0.23, 0.6);
    tap(0.5, 0.4);
    expect(now().openPuzzle, isNull);
    play.takeExit('back');

    // The island: the pintle.
    tap(0.5, 0.55);
    expect(now().game.sceneId, 'island');
    tap(0.06, 0.78);
    tap(0.83, 0.58);
    tap(0.54, 0.63);
    expect(now().game.flags['found_pintle'], isTrue);
    expect(stage(), 'stage:survey');
    play.takeExit('back');

    // The survey.
    tap(0.23, 0.6);
    tap(0.5, 0.4);
    solve('sonar');
    expect(now().game.words, contains('erebus'));
    expect(stage(), 'stage:later');
    tap(0.13, 0.35);
    expect(now().game.words, containsAll(['lead', 'crushed', 'terror']));
    expect(stage(), 'stage:write_seal');
    play.takeExit('back');

    // The keeper's slip behind the drum.
    tap(0.68, 0.45);
    tap(0.655, 0.3);
    expect(now().game.secretFound, isTrue);
    expect(
      container.read(saveRepositoryProvider).keeperNote(episode),
      'franklin_1845.hall.keeper_note',
    );
    play.takeExit('back');

    // The seal: the Admiralty form on the chart table.
    tap(0.23, 0.6);
    tap(0.68, 0.62);
    expect(now().openPuzzle, 'jar_label');
    final label =
        content().requirePuzzle('jar_label').config as DeductionConfig;
    expect(label.form, DeductionForm.admiralty);
    var deduction = label.start(now().game);
    expect(
      deduction.available,
      containsAll(label.answers),
      reason: 'every answer was noted on the way',
    );
    expect(
      deduction.available,
      containsAll(['date_1847', 'victory_point', 'terror', 'crushed']),
      reason: 'the near misses and the legends are there to mislead',
    );
    for (final (i, answer) in label.answers.indexed) {
      deduction = deduction.fill(i, answer);
    }
    expect(deduction.isSolved, isTrue);
    play.solvePuzzle('jar_label');
    expect(now().currentText, 'franklin_1845.label.done');
    readAll();
    expect(now().game.completed, isTrue);
  });
}
