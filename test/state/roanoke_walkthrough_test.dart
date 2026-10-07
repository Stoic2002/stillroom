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

/// Plays "Roanoke, 1590" start to finish through the real content, and
/// checks that the solutions the hints give really solve the puzzles.
void main() {
  const episode = 'roanoke_1590';
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
    // The chart: Croatoan ten miles south five times, the main ten miles
    // west five times; the chart has north on the right.
    final chart = content().requirePuzzle('dividers').config as DividersConfig;
    expect(chart.north, 90);
    var walk = chart.start().setSpan(10).setHeading(Heading.s);
    for (var i = 0; i < 5; i++) {
      walk = walk.step();
    }
    expect(walk.judge(), DividersMark.found);
    walk = walk.mark().setHeading(Heading.w);
    for (var i = 0; i < 5; i++) {
      walk = walk.step();
    }
    expect(walk.mark().isSolved, isTrue);
    // Walking south as if north were up goes down the chart into the sea.
    var wrong = chart.start().setSpan(10).setHeading(Heading.e);
    for (var i = 0; i < 5; i++) {
      wrong = wrong.step();
    }
    expect(wrong.judge(), DividersMark.nothing);

    // The core: it starts at 1579; the narrowest run is 1587 to 1589.
    final rings = content().requirePuzzle('rings').config as RingsConfig;
    expect(rings.yearOf(0), 1579);
    expect(rings.yearOf(rings.narrowest), 1587);
    expect(rings.yearOf(rings.narrowest + rings.run - 1), 1589);
    final dated = rings.start().slide(rings.offset).check();
    expect(dated.mark(rings.narrowest).isSolved, isTrue);
  });

  test('the episode can be completed', () {
    expect(now().game.sceneId, 'shore');
    expect(stage(), 'stage:start');

    // The shore: the burnt grass, the footprints, the boat, the trumpet.
    tap(0.46, 0.55);
    tap(0.42, 0.8);
    tap(0.62, 0.75);
    tap(0.67, 0.64);

    // The hill: CRO on a tree; the view south.
    tap(0.1, 0.7);
    expect(now().game.sceneId, 'hill');
    tap(0.3, 0.55);
    tap(0.7, 0.43);
    play.takeExit('back');

    // The fort: the palisade, the post.
    tap(0.32, 0.52);
    expect(now().game.sceneId, 'fort');
    tap(0.2, 0.5);
    tap(0.57, 0.45);
    expect(now().game.words, contains('croatoan'));
    expect(stage(), 'stage:chests');

    // The chests: the pit, the chart.
    tap(0.9, 0.68);
    expect(now().game.sceneId, 'chests');
    tap(0.5, 0.55);
    tap(0.64, 0.72);
    expect(now().game.flags['found_chart'], isTrue);
    expect(stage(), 'stage:ship');
    play
      ..takeExit('back')
      ..takeExit('back');
    expect(now().game.sceneId, 'shore');

    // The ship: the chart waits for the journal.
    tap(0.61, 0.38);
    expect(now().game.sceneId, 'ship');
    tap(0.45, 0.62);
    expect(now().openPuzzle, isNull, reason: 'the journal first');
    tap(0.8, 0.72);
    expect(now().currentText, isNull);
    tap(0.2, 0.64);
    expect(now().game.words, contains('cross'));
    tap(0.45, 0.62);
    solve('dividers');
    expect(stage(), 'stage:core');

    // The later papers on the chest; the core.
    tap(0.8, 0.72);
    expect(now().game.words, contains('site_x'));
    tap(0.64, 0.61);
    solve('rings');
    expect(now().game.words, contains('drought'));
    expect(stage(), 'stage:later');
    tap(0.28, 0.3);
    expect(
      now().game.words,
      containsAll([
        'dare_stones',
        'white_doe',
        'spanish',
        'massacre',
        'vanished',
      ]),
    );
    expect(stage(), 'stage:write_seal');
    play.takeExit('back');

    // The keeper's slip in the trumpet's bell.
    tap(0.67, 0.64);
    expect(now().game.secretFound, isTrue);
    expect(
      container.read(saveRepositoryProvider).keeperNote(episode),
      'roanoke_1590.shore.keeper_note',
    );

    // The seal: the post at the fort.
    tap(0.32, 0.52);
    tap(0.57, 0.45);
    expect(now().openPuzzle, 'jar_label');
    final label =
        content().requirePuzzle('jar_label').config as DeductionConfig;
    expect(label.form, DeductionForm.post);
    var deduction = label.start(now().game);
    expect(
      deduction.available,
      containsAll(label.answers),
      reason: 'every answer was noted on the way',
    );
    expect(
      deduction.available,
      containsAll(['vanished', 'dare_stones', 'site_x']),
      reason: 'the legends are there to mislead',
    );
    for (final (i, answer) in label.answers.indexed) {
      deduction = deduction.fill(i, answer);
    }
    expect(deduction.isSolved, isTrue);
    play.solvePuzzle('jar_label');
    expect(now().currentText, 'roanoke_1590.label.done');
    readAll();
    expect(now().game.completed, isTrue);
  });
}
