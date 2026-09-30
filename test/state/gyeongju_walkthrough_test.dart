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

/// Plays "Gyeongju, 771" start to finish through the real content, and
/// checks that the solutions the hints give really solve the puzzles.
void main() {
  const episode = 'gyeongju_771';
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
    // The pour: left furnace down, right, down; middle straight down;
    // right furnace down, left, down. The rest as they lie.
    final pour = content().requirePuzzle('pour').config as PourConfig;
    var channels = pour.start();
    expect(channels.pour().isSolved, isFalse, reason: 'scrambled at first');
    final wanted = [for (final t in pour.tiles) t.turns];
    for (final path in [
      [0, 5, 6, 11],
      [2, 7, 12],
      [4, 9, 8, 13],
    ]) {
      for (final i in path) {
        while (channels.turns[i] != wanted[i]) {
          channels = channels.turn(i);
        }
      }
    }
    expect(channels.pour().isSolved, isTrue);

    // The hollow: dig three times from the start, pull all the way.
    final resonance =
        content().requirePuzzle('resonance').config as ResonanceConfig;
    var hollow = resonance.startState();
    expect(hollow.strike(1).isSolved, isFalse);
    hollow = hollow.dig().dig().dig();
    expect(hollow.strike(0.5).isSolved, isFalse, reason: 'too gentle');
    expect(hollow.strike(1).isSolved, isTrue);

    // The cry: the lower left of the rim, of eight places clockwise from
    // the top.
    final beat = content().requirePuzzle('beat').config as BeatConfig;
    expect(beat.places, 8);
    expect(beat.deepest, 5, reason: 'the lower left');
  });

  test('the episode can be completed', () {
    expect(now().game.sceneId, 'yard');
    expect(stage(), 'stage:start');

    // The pavilion is empty until the bell is cast.
    tap(0.5, 0.36);
    expect(now().game.sceneId, 'yard');

    // The founders' board.
    tap(0.29, 0.55);
    expect(now().game.words, contains('park_jong_il'));

    // The shed: the rope, the 1925 story.
    tap(0.115, 0.59);
    expect(now().game.sceneId, 'founders_shed');
    tap(0.47, 0.32);
    tap(0.21, 0.67);
    expect(now().game.words, containsAll(['emille', 'child', 'date_1925']));
    tap(0.75, 0.64);
    expect(now().game.inventory, contains('striker_rope'));
    expect(stage(), 'stage:start', reason: 'the bell is not cast yet');
    play.takeExit('back');

    // The monks' hall: the draft; Hulbert's book.
    tap(0.84, 0.56);
    expect(now().game.sceneId, 'monks_hall');
    tap(0.49, 0.57);
    expect(
      now().game.words,
      containsAll(['kim_pil_o', 'seongdeok', 'date_771']),
    );
    tap(0.78, 0.64);
    expect(now().game.words, contains('seoul'));
    play.takeExit('back');

    // The pit: pour the bell.
    tap(0.51, 0.81);
    expect(now().game.sceneId, 'casting_pit');
    tap(0.5, 0.56);
    solve('pour');
    expect(stage(), 'stage:tie_rope');
    play.takeExit('back');

    // The pavilion: tie the rope, ring the bell.
    tap(0.5, 0.36);
    expect(now().game.sceneId, 'pavilion');
    tap(0.45, 0.3);
    expect(now().openPuzzle, isNull, reason: 'not struck yet');
    tap(0.2, 0.4);
    expect(now().openPuzzle, isNull, reason: 'one rope only');
    play
      ..tapInventoryItem('striker_rope')
      ..tapScene(0.2, 0.4);
    readAll();
    expect(now().game.flags['rope_tied'], isTrue);
    expect(now().game.inventory, isNot(contains('striker_rope')));
    expect(stage(), 'stage:ring_bell');
    tap(0.2, 0.4);
    solve('resonance');
    expect(now().game.words, contains('hollow'));
    expect(stage(), 'stage:find_cry');

    // The 1998 report, then the cry under the rim.
    tap(0.8, 0.74);
    expect(now().game.flags['read_report'], isTrue);
    tap(0.57, 0.49); // the celestials on the bell
    expect(now().openPuzzle, isNull);
    tap(0.45, 0.3);
    solve('beat');
    expect(now().game.words, contains('beat'));
    expect(stage(), 'stage:write_seal');

    // The keeper's slip behind the founders' board.
    play.takeExit('back');
    tap(0.29, 0.55);
    expect(now().game.secretFound, isTrue);
    expect(
      container.read(saveRepositoryProvider).keeperNote(episode),
      'gyeongju_771.yard.keeper_note',
    );

    // The seal: a rubbing from the bronze.
    tap(0.5, 0.36);
    tap(0.45, 0.3);
    expect(now().openPuzzle, 'jar_label');
    final label =
        content().requirePuzzle('jar_label').config as DeductionConfig;
    expect(label.form, DeductionForm.rubbing);
    var deduction = label.start(now().game);
    expect(
      deduction.available,
      containsAll(label.answers),
      reason: 'every answer was noted on the way',
    );
    expect(
      deduction.available,
      containsAll(['child', 'emille', 'seoul', 'kim_pil_o', 'hollow']),
      reason: 'the legend and the near misses are there to mislead',
    );
    for (final (i, answer) in label.answers.indexed) {
      deduction = deduction.fill(i, answer);
    }
    expect(deduction.isSolved, isTrue);
    play.solvePuzzle('jar_label');
    expect(now().currentText, 'gyeongju_771.label.done');
    readAll();
    expect(now().game.completed, isTrue);
  });
}
