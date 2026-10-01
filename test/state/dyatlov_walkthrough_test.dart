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

/// Plays "Dyatlov Pass, 1959" start to finish through the real content, and
/// checks that the solutions the hints give really solve the puzzles.
void main() {
  const episode = 'dyatlov_1959';
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
    // The pit: two layers softer than the one above; the column shows the
    // one under the wind slab, the third from the top, breaking in the
    // elbow taps.
    final pit = content().requirePuzzle('snowpit').config as SnowpitConfig;
    expect(pit.weak, 2);
    expect(pit.breakTap, inInclusiveRange(11, 20));
    final softUnderHard = [
      for (var i = 1; i < pit.layers.length; i++)
        if (pit.layers[i].hardness.index < pit.layers[i - 1].hardness.index) i,
    ];
    expect(softUnderHard, [2, 5], reason: 'one true weak layer, one decoy');
    var state = pit.start();
    for (final (i, layer) in pit.layers.indexed) {
      state = state.push(i, layer.hardness);
      if (layer.hardness.index > 0) {
        state = state.push(i, SnowHardness.values[layer.hardness.index - 1]);
      }
    }
    expect(state.allKnown, isTrue);
    state = state.mark(2);
    for (var k = 0; k < pit.breakTap; k++) {
      state = state.tap();
    }
    expect(state.isSolved, isTrue);

    // The darkroom: frames one and four at 8 s, two at 4, three at 16.
    final room = content().requirePuzzle('darkroom').config as DarkroomConfig;
    expect(
      [for (final f in room.frames) room.strip[f.exposure]],
      [8, 4, 16, 8],
    );
    var prints = room.start();
    for (final (f, frame) in room.frames.indexed) {
      prints = prints.print(f, frame.exposure);
    }
    expect(prints.isSolved, isTrue);
  });

  test('the episode can be completed', () {
    expect(now().game.sceneId, 'slope');
    expect(stage(), 'stage:start');

    // The tent, the tracks.
    tap(0.47, 0.6);
    tap(0.6, 0.85);
    expect(now().game.words, contains('cedar'));
    expect(stage(), 'stage:camp');
    tap(0.7, 0.58);
    expect(now().openPuzzle, isNull, reason: 'no kit yet');

    // The cedar.
    tap(0.92, 0.8);
    expect(now().game.sceneId, 'cedar');
    tap(0.47, 0.3);
    tap(0.62, 0.8);
    tap(0.66, 0.46);
    expect(now().game.flags['found_note'], isFalse, reason: 'not yet');
    play.takeExit('back');

    // The search camp: the case file, the rumours, the cameras.
    tap(0.05, 0.6);
    expect(now().game.sceneId, 'camp');
    tap(0.92, 0.47);
    expect(now().game.sceneId, 'camp', reason: 'nothing to take to Ivdel yet');
    tap(0.28, 0.58);
    expect(now().game.words, containsAll(['otorten', 'natural_force']));
    tap(0.12, 0.3);
    expect(now().game.words, containsAll(['mansi', 'aliens', 'weapons']));
    tap(0.51, 0.59);
    expect(stage(), 'stage:films');

    // The darkroom in Ivdel.
    tap(0.92, 0.47);
    expect(now().game.sceneId, 'darkroom');
    tap(0.49, 0.57);
    solve('darkroom');
    expect(now().game.words, contains('cut'));
    expect(stage(), 'stage:pit');
    play.takeExit('back');
    play.takeExit('back');
    expect(now().game.sceneId, 'slope');

    // The pit.
    tap(0.7, 0.58);
    solve('snowpit');
    expect(now().game.words, contains('slab'));
    expect(stage(), 'stage:later');

    // The papers from the future.
    tap(0.05, 0.6);
    tap(0.68, 0.63);
    expect(now().game.words, containsAll(['radiation', 'yeti']));
    expect(stage(), 'stage:write_seal');
    play.takeExit('back');

    // The keeper's slip in the cedar's broken branch.
    tap(0.92, 0.8);
    tap(0.66, 0.46);
    expect(now().game.secretFound, isTrue);
    expect(
      container.read(saveRepositoryProvider).keeperNote(episode),
      'dyatlov_1959.cedar.keeper_note',
    );
    play.takeExit('back');

    // The seal: the route book in the camp.
    tap(0.05, 0.6);
    tap(0.47, 0.72);
    expect(now().openPuzzle, 'jar_label');
    final label =
        content().requirePuzzle('jar_label').config as DeductionConfig;
    expect(label.form, DeductionForm.routebook);
    var deduction = label.start(now().game);
    expect(
      deduction.available,
      containsAll(label.answers),
      reason: 'every answer was noted on the way',
    );
    expect(
      deduction.available,
      containsAll(['aliens', 'yeti', 'natural_force']),
      reason: 'the legends are there to mislead',
    );
    for (final (i, answer) in label.answers.indexed) {
      deduction = deduction.fill(i, answer);
    }
    expect(deduction.isSolved, isTrue);
    play.solvePuzzle('jar_label');
    expect(now().currentText, 'dyatlov_1959.label.done');
    readAll();
    expect(now().game.completed, isTrue);
  });
}
