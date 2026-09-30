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

/// Plays "Bastille, 1703" start to finish through the real content, and
/// checks that the solutions the hints give really solve the puzzles.
void main() {
  const episode = 'bastille_1703';
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
    // The lower door: one key fits as it hangs.
    final lower = content().requirePuzzle('door_lower').config as KeyringConfig;
    expect(lower.fits('b', flipped: false), isTrue);
    // The upper door: the third key, turned over, and not the right way up.
    final upper = content().requirePuzzle('door_upper').config as KeyringConfig;
    final third = upper.keys[2].id;
    expect(upper.fits(third, flipped: false), isFalse);
    var ring = upper.start().select(third).tryKey();
    expect(ring.isSolved, isFalse);
    ring = ring.flip().tryKey();
    expect(ring.isSolved, isTrue, reason: 'the third key, turned over');

    // The cipher reads as the last hint says; 330 309 stays unread.
    final cipher = content().requirePuzzle('cipher').config as CipherConfig;
    expect(cipher.unknown, {'330', '309'});
    var letter = cipher.start();
    for (var i = 0; i < cipher.groups.length; i++) {
      if (cipher.key.containsKey(cipher.groups[i])) {
        letter = letter.match(i, cipher.groups[i]);
      }
    }
    expect(letter.isSolved, isTrue);
    expect(
      [for (var i = 0; i < 11; i++) letter.textAt(i)].join('-'),
      'Bu-lon-de-Pi-gne-rol-les-en-ne-mi-s',
    );

    // The file: five papers of the time, three told after.
    final file = content().requirePuzzle('file').config as SourcesConfig;
    expect([
      for (final c in file.cards)
        if (c.tray == 'time') c.id,
    ], hasLength(5));
    expect(
      {
        for (final c in file.cards)
          if (c.tray == 'after') c.id,
      },
      {'voltaire', 'dumas', 'bazeries'},
    );
  });

  test('the episode can be completed', () {
    expect(now().game.sceneId, 'courtyard');
    expect(stage(), 'stage:start');

    // The street gate is barred until du Junca's journal is read.
    tap(0.91, 0.59);
    expect(now().game.sceneId, 'courtyard');

    // The turnkey's keys, then up the Bertaudière.
    tap(0.245, 0.51);
    expect(now().game.inventory, contains('key_ring'));
    expect(stage(), 'stage:climb_tower');
    tap(0.14, 0.6);
    expect(now().game.sceneId, 'tower_stair');
    tap(0.685, 0.24); // the upper door: first, the one in front
    expect(now().openPuzzle, isNull);
    tap(0.255, 0.53);
    solve('door_lower');
    tap(0.685, 0.24);
    solve('door_upper');
    tap(0.685, 0.24);
    expect(now().game.sceneId, 'cell');

    // The mask, and Voltaire's iron.
    tap(0.5, 0.56);
    expect(now().game.flags['saw_mask'], isTrue);
    tap(0.75, 0.475);
    expect(now().game.words, contains('iron'));

    // Du Junca's journal and Bazeries's worksheet.
    play
      ..takeExit('back')
      ..takeExit('back');
    expect(now().game.sceneId, 'courtyard');
    tap(0.425, 0.61);
    expect(now().game.sceneId, 'junca_room');
    tap(0.45, 0.59);
    expect(now().game.flags['read_journal'], isTrue);
    expect(now().game.words, containsAll(['black_velvet', 'date_19nov']));
    tap(0.77, 0.37);
    expect(now().game.inventory, contains('worksheet'));
    expect(stage(), 'stage:find_register');

    // The governor's desk: the letter of 1669, the letter in numbers.
    play.takeExit('back');
    tap(0.65, 0.6);
    expect(now().game.sceneId, 'governor_office');
    tap(0.69, 0.56);
    expect(now().openPuzzle, isNull, reason: 'the file is not complete yet');
    tap(0.35, 0.57);
    expect(now().game.words, containsAll(['eustache_dauger', 'valet']));
    expect(now().game.words, contains('date_1669'));
    expect(stage(), 'stage:read_cipher');
    tap(0.525, 0.57);
    solve('cipher');
    expect(now().game.words, contains('bulonde'));

    // Saint-Paul: the register.
    play.takeExit('back');
    tap(0.91, 0.59);
    expect(now().game.sceneId, 'saint_paul');
    tap(0.49, 0.59);
    expect(now().game.words, containsAll(['marchioly', 'mattioli']));
    tap(0.78, 0.66);
    expect(now().game.words, contains('twin'));
    expect(stage(), 'stage:sort_file');

    // The file, sorted.
    play.takeExit('back');
    tap(0.65, 0.6);
    tap(0.69, 0.56);
    solve('file');
    expect(stage(), 'stage:write_seal');

    // Between the pages for November, the keeper's slip.
    play.takeExit('back');
    tap(0.425, 0.61);
    tap(0.45, 0.59);
    expect(now().game.secretFound, isTrue);
    expect(
      container.read(saveRepositoryProvider).keeperNote(episode),
      'bastille_1703.junca.keeper_note',
    );

    // Back to the cell: the seal.
    play.takeExit('back');
    tap(0.14, 0.6);
    tap(0.685, 0.24);
    expect(now().game.sceneId, 'cell');
    tap(0.5, 0.56);
    expect(now().openPuzzle, 'jar_label');
    final label =
        content().requirePuzzle('jar_label').config as DeductionConfig;
    expect(label.form, DeductionForm.order);
    var deduction = label.start(now().game);
    expect(
      deduction.available,
      containsAll(label.answers),
      reason: 'every answer was noted on the way',
    );
    expect(
      deduction.available,
      containsAll(['iron', 'mattioli', 'twin', 'bulonde']),
      reason: 'the legends are there to mislead',
    );
    for (final (i, answer) in label.answers.indexed) {
      deduction = deduction.fill(i, answer);
    }
    expect(deduction.isSolved, isTrue);
    play.solvePuzzle('jar_label');
    expect(now().currentText, 'bastille_1703.label.done');
    readAll();
    expect(now().game.completed, isTrue);
  });
}
