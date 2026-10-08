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

/// Plays "The Stillroom", the keeper's own tale, start to finish through
/// the real content, and checks that the solutions the hints give really
/// solve the puzzles.
void main() {
  const episode = 'stillroom_keeper';
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

  void useOn(String item, double x, double y) {
    play
      ..tapInventoryItem(item)
      ..tapScene(x, y);
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
    // The hands: each receipt to the hand that wrote it.
    final hands = content().requirePuzzle('hands').config as HandsConfig;
    var book = hands.start();
    for (final (i, r) in hands.receipts.indexed) {
      book = book.assign(i, r.hand);
    }
    expect(book.isSolved, isTrue);
    // A wrong one comes back on checking.
    var wrong = hands.start();
    for (final (i, r) in hands.receipts.indexed) {
      wrong = wrong.assign(
        i,
        i == 0 ? (r.hand + 1) % hands.hands.length : r.hand,
      );
    }
    expect(wrong.isSolved, isFalse);
    wrong = wrong.check();
    expect(wrong.assigned.containsKey(0), isFalse);
    expect(wrong.mistakes, 1);
    // The hand of the notes wrote the stillroom's receipts.
    final notes = hands.hands.indexWhere((h) => h.labelKey.endsWith('notes'));
    expect([
      for (final r in hands.receipts)
        if (r.hand == notes) r.labelKey.split('.').last,
    ], unorderedEquals(['rosewater', 'cordial', 'lavender']));

    // The still: water running, a gentle fire, the glass moved at the
    // cuts.
    final still = content().requirePuzzle('still').config as StillConfig;
    StillState run(int heat, {double lag = 0}) {
      var s = still.start().setWater(true).setHeat(heat);
      const dt = 1 / 30;
      while (s.end == StillEnd.running) {
        if (s.receiver == Cut.heads && s.run >= still.heads + lag) {
          s = s.moveGlass(Cut.heart);
        } else if (s.receiver == Cut.heart &&
            s.run >= still.heads + still.heart + lag) {
          s = s.moveGlass(Cut.tails);
        }
        s = s.tick(dt);
      }
      return s;
    }

    expect(run(1).end, StillEnd.kept);
    expect(run(1, lag: 0.3).end, StillEnd.kept, reason: 'a little late');
    expect(run(2).end, StillEnd.lost, reason: 'too hot: the cuts smear');
    expect(run(1, lag: 1.5).end, StillEnd.lost, reason: 'far too late');
    // No water: the worm runs hot.
    var dry = still.start().setHeat(1);
    for (var t = 0.0; t < 5; t += 0.1) {
      dry = dry.tick(0.1);
    }
    expect(dry.end, StillEnd.spoiled);

    // The lamp: each band recorded, laid oldest first.
    final lamp = content().requirePuzzle('spectrum').config as SpectrumConfig;
    var easel = lamp.start();
    expect(easel.tune(0.25).judge(), SpectrumShot.blurred);
    for (final band in lamp.bands) {
      easel = easel.tune(band.at + lamp.tolerance * 0.5).record();
    }
    expect(easel.allRecorded, isTrue);
    final wrongFirst = lamp.bands.indexWhere((b) => b.id == 'visible');
    expect(easel.lay(wrongFirst).laid, isEmpty);
    final byAge = [
      for (var age = 0; age < lamp.bands.length; age++)
        lamp.bands.indexWhere((b) => b.age == age),
    ];
    expect(
      [for (final i in byAge) lamp.bands[i].id],
      ['infrared', 'xray', 'uv', 'visible'],
    );
    for (final i in byAge) {
      easel = easel.lay(i);
    }
    expect(easel.isSolved, isTrue);
  });

  test('the stars found on the other shelves bring her letters', () async {
    // Seven notes found elsewhere (and one here, which does not count).
    final save = container.read(saveRepositoryProvider.notifier);
    for (final id in [
      'whitechapel_1888',
      'flannan_isles_1900',
      'pompeii_79',
      'bastille_1703',
      'gyeongju_771',
      'alamut_1256',
      'borobudur_1814',
      episode,
    ]) {
      save.recordKeeperNote(id, '$id.note');
    }
    container.invalidate(gameSessionProvider(episode));
    await container.read(gameSessionProvider(episode).future);
    final flags = now().game.flags;
    expect(flags['stars_3'], isTrue);
    expect(flags['stars_6'], isTrue);
    expect(flags['stars_9'], isFalse);
    expect(flags['stars_15'], isFalse);
  });

  test('the episode can be completed', () {
    expect(now().game.sceneId, 'behind');
    expect(stage(), 'stage:start');

    // Behind the shelves: the jars, the chapbook's legends, the lock.
    tap(0.5, 0.4);
    tap(0.23, 0.74);
    expect(now().game.words, containsAll(['witch', 'alchemist', 'ghost']));
    tap(0.885, 0.53);
    expect(now().game.flags['door_open'], isTrue);
    expect(stage(), 'stage:fire');

    // The study: the drafts, the coat, its lining.
    tap(0.89, 0.6);
    expect(now().game.sceneId, 'study');
    tap(0.26, 0.58);
    tap(0.77, 0.4);
    expect(now().game.inventory, contains('tinder'));
    tap(0.77, 0.4);
    expect(now().game.secretFound, isTrue);
    expect(
      container.read(saveRepositoryProvider).keeperNote(episode),
      'stillroom_keeper.study.coat_lining',
    );
    expect(now().game.flags['stars_3'], isFalse, reason: 'no stars yet');

    // The window turns through every tale to her house.
    tap(0.08, 0.4);
    expect(now().game.sceneId, 'window');
    tap(0.5, 0.4);
    for (var k = 0; k < 15; k++) {
      tap(0.82, 0.46);
    }
    expect(now().game.flags['view'], 15);
    tap(0.5, 0.4);
    expect(now().game.flags['read_house'], isFalse, reason: 'not yet');

    // The stillroom: the book's hands, the fire, the run.
    play
      ..takeExit('back')
      ..takeExit('back');
    expect(now().game.sceneId, 'behind');
    tap(0.1, 0.6);
    expect(now().game.sceneId, 'stillroom');
    tap(0.72, 0.57);
    solve('hands');
    expect(now().game.words, containsAll(['stillroom', 'the_girl']));
    tap(0.26, 0.6);
    expect(now().openPuzzle, isNull, reason: 'the furnace is cold');
    useOn('tinder', 0.26, 0.6);
    expect(now().game.flags['fire_lit'], isTrue);
    expect(stage(), 'stage:run');
    tap(0.26, 0.6);
    solve('still');
    expect(now().game.inventory, contains('spirit'));
    expect(stage(), 'stage:clean');

    // The portrait: cleaned, then looked through.
    play.takeExit('back');
    tap(0.89, 0.6);
    useOn('spirit', 0.5, 0.33);
    expect(now().game.flags['cleaned'], isTrue);
    expect(stage(), 'stage:lamp');
    tap(0.5, 0.33);
    solve('spectrum');
    expect(now().game.words, contains('hester_croft'));
    expect(stage(), 'stage:farewell');

    // She is there, and goes.
    tap(0.59, 0.56);
    expect(now().game.flags['she_went'], isTrue);
    tap(0.08, 0.4);
    tap(0.5, 0.4);
    expect(now().game.flags['read_house'], isTrue);
    expect(now().game.words, contains('her_own'));
    expect(stage(), 'stage:write_seal');

    // The seal: a receipt in her book, in your hand.
    play
      ..takeExit('back')
      ..takeExit('back');
    tap(0.1, 0.6);
    tap(0.72, 0.57);
    expect(now().openPuzzle, 'jar_label');
    final label =
        content().requirePuzzle('jar_label').config as DeductionConfig;
    expect(label.form, DeductionForm.receipt);
    var deduction = label.start(now().game);
    expect(deduction.available, containsAll(label.answers));
    expect(
      deduction.available,
      containsAll(['witch', 'alchemist', 'ghost', 'the_girl']),
      reason: 'the legends and the house book are there to mislead',
    );
    for (final (i, answer) in label.answers.indexed) {
      deduction = deduction.fill(i, answer);
    }
    expect(deduction.isSolved, isTrue);
    play.solvePuzzle('jar_label');
    expect(now().currentText, 'stillroom_keeper.label.done');
    readAll();
    expect(now().game.completed, isTrue);
  });
}
