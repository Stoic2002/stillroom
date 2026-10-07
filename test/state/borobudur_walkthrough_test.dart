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

/// Plays "Borobudur, 1814" start to finish through the real content, and
/// checks that the solutions the hints give really solve the puzzles.
void main() {
  const episode = 'borobudur_1814';
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
    // The niches: every statue on the side its hands belong to.
    final niches = content().requirePuzzle('mudra').config as MudraConfig;
    var gallery = niches.start();
    for (final (i, m) in niches.statues.indexed) {
      final place = niches.places.indexWhere((p) => p.mudra == m);
      gallery = gallery.set(i, place);
    }
    expect(gallery.isSolved, isTrue);
    expect(gallery.mistakes, 0);

    // The casing: each deed with its fruit, as the old text pairs them.
    final casing = content().requirePuzzle('casing').config as CasingConfig;
    String name(int i) =>
        now().episode.strings['en']![casing.panels[i].labelKey]!;
    var wall = casing.start();
    for (var pair = 0; pair < casing.panels.length ~/ 2; pair++) {
      final both = [
        for (var i = 0; i < casing.panels.length; i++)
          if (casing.panels[i].pair == pair) i,
      ];
      wall = wall.lift(both[0]).lift(both[1]);
    }
    expect(wall.isSolved, isTrue);
    expect(wall.mismatches, 0);
    final killing = casing.panels.indexWhere(
      (p) => p.labelKey.endsWith('killing'),
    );
    final shortLife = casing.panels.indexWhere(
      (p) => p.labelKey.endsWith('short_life'),
    );
    expect(casing.panels[killing].pair, casing.panels[shortLife].pair);
    expect(name(shortLife), 'A short life');
  });

  test('the episode can be completed', () {
    expect(now().game.sceneId, 'foot');
    expect(stage(), 'stage:start');

    // The foot: the camera; the casing waits for the old texts.
    tap(0.63, 0.78);
    tap(0.85, 0.6);
    expect(now().openPuzzle, isNull);

    // The rest house: the Babad, Raffles's papers; the leaves wait.
    tap(0.1, 0.85);
    expect(now().game.sceneId, 'house');
    tap(0.35, 0.61);
    expect(now().game.words, contains('babad'));
    tap(0.5, 0.61);
    expect(
      now().game.words,
      containsAll(['raffles', 'cornelius', 'date_1814']),
    );
    tap(0.65, 0.61);
    expect(now().openPuzzle, isNull);
    expect(stage(), 'stage:gallery');
    play.takeExit('back');

    // The gallery: the reliefs, the guide, the fallen Buddhas.
    tap(0.5, 0.45);
    expect(now().game.sceneId, 'gallery');
    tap(0.08, 0.25);
    tap(0.09, 0.6);
    tap(0.5, 0.47);
    expect(now().game.sceneId, 'gallery', reason: 'the stairs wait');
    tap(0.5, 0.7);
    solve('mudra');
    expect(stage(), 'stage:karma');

    // Up to the round terraces.
    tap(0.5, 0.47);
    expect(now().game.sceneId, 'stupas');
    tap(0.5, 0.7);
    tap(0.5, 0.25);
    tap(0.8, 0.37);
    play
      ..takeExit('back')
      ..takeExit('back');
    expect(now().game.sceneId, 'foot');

    // The rest house: the old text of deeds, the inscriptions.
    tap(0.1, 0.85);
    tap(0.4, 0.69);
    tap(0.59, 0.69);
    expect(now().game.words, contains('sailendra'));
    expect(stage(), 'stage:casing_stage');
    play.takeExit('back');

    // The casing at the foot.
    tap(0.85, 0.6);
    solve('casing');
    expect(now().game.words, contains('foot'));
    expect(stage(), 'stage:later');

    // The later papers; the keeper's slip among the plates.
    tap(0.1, 0.85);
    tap(0.13, 0.4);
    expect(now().game.words, containsAll(['gunadharma', 'lake', 'merapi']));
    expect(stage(), 'stage:write_seal');
    tap(0.77, 0.6);
    expect(now().game.secretFound, isTrue);
    expect(
      container.read(saveRepositoryProvider).keeperNote(episode),
      'borobudur_1814.house.keeper_note',
    );

    // The seal: the palm leaves.
    tap(0.65, 0.61);
    expect(now().openPuzzle, 'jar_label');
    final label =
        content().requirePuzzle('jar_label').config as DeductionConfig;
    expect(label.form, DeductionForm.lontar);
    var deduction = label.start(now().game);
    expect(
      deduction.available,
      containsAll(label.answers),
      reason: 'every answer was noted on the way',
    );
    expect(
      deduction.available,
      containsAll(['raffles', 'gunadharma', 'lake', 'merapi']),
      reason: 'the legends are there to mislead',
    );
    for (final (i, answer) in label.answers.indexed) {
      deduction = deduction.fill(i, answer);
    }
    expect(deduction.isSolved, isTrue);
    play.solvePuzzle('jar_label');
    expect(now().currentText, 'borobudur_1814.label.done');
    readAll();
    expect(now().game.completed, isTrue);
  });
}
