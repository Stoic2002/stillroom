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

/// Plays "Whitechapel, 1891" start to finish through the real content, and
/// checks that the solutions the hints give really solve the puzzles.
void main() {
  const episode = 'whitechapel_1891';
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
    // Her name, each letter from the mirrored sort, a quad for the space.
    final compose = content().requirePuzzle('compose').config as ComposeConfig;
    var stick = compose.start();
    for (final l in compose.text.split('')) {
      stick = stick.set(Sort(l));
    }
    expect(stick.isSolved, isTrue);
    expect(compose.sortCase, contains(const Sort('R', wrongWay: true)));

    // The file grows in the order the hint gives, into date order.
    final file = content().requirePuzzle('unwatched').config as UnwatchedConfig;
    expect(file.start, hasLength(5));
    expect(
      [for (final r in file.rounds) r.add],
      ['smith', 'tabram', 'mylett', 'mckenzie', 'pinchin', 'coles'],
    );
    var shelf = file.startState();
    for (final r in file.rounds) {
      shelf = shelf.lookAway().tap(r.add);
    }
    expect(shelf.isSolved, isTrue);
    expect(shelf.shelf, [
      'smith',
      'tabram',
      'nichols',
      'chapman',
      'stride',
      'eddowes',
      'kelly',
      'mylett',
      'mckenzie',
      'pinchin',
      'coles',
    ]);
  });

  test('the episode can be completed', () {
    expect(now().game.sceneId, 'leman_street');
    expect(stage(), 'stage:start');

    // Nothing opens before the night's entry is read.
    tap(0.91, 0.5);
    expect(now().game.sceneId, 'leman_street');
    tap(0.08, 0.54);
    expect(now().game.sceneId, 'leman_street', reason: 'the file is locked');

    tap(0.48, 0.57);
    expect(
      now().game.words,
      containsAll(['frances_coles', 'swallow_gardens', 'date_13feb']),
    );
    expect(stage(), 'stage:find_ticket');

    // The arch, and the hat's ticket.
    tap(0.91, 0.5);
    expect(now().game.sceneId, 'swallow_gardens');
    tap(0.5, 0.4);
    tap(0.89, 0.6);
    expect(now().game.sceneId, 'swallow_gardens', reason: 'the cab waits');
    tap(0.51, 0.75);
    expect(now().game.flags['saw_ticket'], isTrue);
    expect(stage(), 'stage:milliner');

    // The milliner's.
    tap(0.09, 0.58);
    expect(now().game.sceneId, 'milliner');
    tap(0.5, 0.6);
    expect(now().game.words, contains('sadler'));
    expect(stage(), 'stage:set_name');
    play.takeExit('back');

    // The press room: the letter; her name set.
    tap(0.89, 0.6);
    expect(now().game.sceneId, 'press_room');
    tap(0.76, 0.37);
    expect(now().game.words, contains('jack'));
    tap(0.49, 0.54);
    solve('compose');
    expect(stage(), 'stage:grow_file');
    play
      ..takeExit('back')
      ..takeExit('back');

    // Back at the station: the charge sheet; the file room opens.
    expect(now().game.sceneId, 'leman_street');
    tap(0.7, 0.59);
    tap(0.08, 0.54);
    expect(now().game.sceneId, 'file_room');
    tap(0.5, 0.71);
    expect(now().game.words, contains('emma_smith'));
    tap(0.5, 0.39);
    solve('unwatched');
    expect(now().game.words, contains('eleven'));
    expect(stage(), 'stage:write_seal');

    // Macnaghten's five, and the keeper's slip.
    tap(0.77, 0.7);
    expect(
      now().game.words,
      containsAll(['five', 'mary_ann_nichols', 'mary_jane_kelly']),
    );
    tap(0.5, 0.71);
    expect(now().game.secretFound, isTrue);
    expect(
      container.read(saveRepositoryProvider).keeperNote(episode),
      'whitechapel_1891.file.keeper_note',
    );

    // The seal: the file's cover.
    play.takeExit('back');
    tap(0.48, 0.57);
    expect(now().openPuzzle, 'jar_label');
    final label =
        content().requirePuzzle('jar_label').config as DeductionConfig;
    expect(label.form, DeductionForm.docket);
    var deduction = label.start(now().game);
    expect(
      deduction.available,
      containsAll(label.answers),
      reason: 'every answer was noted on the way',
    );
    expect(
      deduction.available,
      containsAll(['five', 'jack', 'sadler', 'mary_jane_kelly']),
      reason: 'the legend and the near misses are there to mislead',
    );
    for (final (i, answer) in label.answers.indexed) {
      deduction = deduction.fill(i, answer);
    }
    expect(deduction.isSolved, isTrue);
    play.solvePuzzle('jar_label');
    expect(now().currentText, 'whitechapel_1891.label.done');
    readAll();
    expect(now().game.completed, isTrue);
  });
}
