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

/// Plays "Beijing, 1908" start to finish through the real content, and
/// checks that the solutions the hints give really solve the puzzles.
void main() {
  const episode = 'chongling_1908';
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
    // The hair: strand I highest at its 10th segment, strand II at its 6th.
    final strand = content().requirePuzzle('strand').config as StrandConfig;
    expect([strand.peak(0), strand.peak(1)], [9, 5]);
    var hair = strand.start();
    for (final (s, i) in [(0, 9), (1, 5)]) {
      hair = hair.measure(s, i).mark(s, i);
    }
    expect(hair.choose(StrandCurve.peak).isSolved, isTrue);
    // A search that halves towards the higher side finds each peak within
    // the budget.
    for (var s = 0; s < strand.strands.length; s++) {
      final readings = strand.strands[s];
      var (lo, hi) = (0, readings.length - 1);
      final used = <int>{};
      while (lo < hi) {
        final mid = (lo + hi) ~/ 2;
        used.addAll([mid, mid + 1]);
        if (readings[mid] < readings[mid + 1]) {
          lo = mid + 1;
        } else {
          hi = mid;
        }
      }
      expect(lo, strand.peak(s));
      expect(used.length, lessThanOrEqualTo(strand.measurements));
    }

    // The robe: every place reads clear on the inner garment, none on the
    // outer.
    final scan = content().requirePuzzle('scan').config as ScanConfig;
    var robe = scan.start();
    expect(scan.layers[robe.layer].id, 'outer');
    for (final spot in scan.spots) {
      expect(robe.judge(spot.x, spot.y), ScanMark.faint);
    }
    robe = robe.show(1);
    for (final spot in scan.spots) {
      robe = robe.mark(spot.x, spot.y);
    }
    expect(robe.isSolved, isTrue);
    expect(robe.mistakes, 0);
  });

  test('the episode can be completed', () {
    expect(now().game.sceneId, 'stele_court');
    expect(stage(), 'stage:start');

    // Nothing opens before the notice is read.
    tap(0.5, 0.66);
    expect(now().game.sceneId, 'stele_court', reason: 'the crypt is barred');
    tap(0.89, 0.56);
    expect(now().game.sceneId, 'stele_court', reason: 'the lab is locked');

    tap(0.27, 0.58);
    expect(now().game.words, contains('date_1938'));
    expect(stage(), 'stage:crypt');

    // The crypt: the 1980 record.
    tap(0.5, 0.66);
    expect(now().game.sceneId, 'crypt');
    tap(0.5, 0.58);
    tap(0.82, 0.55);
    expect(now().game.words, contains('date_1980'));
    expect(stage(), 'stage:hair');
    play.takeExit('back');

    // The archive: the court's word, the physicians, Qu's memoir.
    tap(0.09, 0.55);
    expect(now().game.sceneId, 'archive');
    tap(0.25, 0.63);
    tap(0.49, 0.63);
    tap(0.72, 0.63);
    expect(now().game.words, containsAll(['illness', 'date_1908', 'stomach']));
    tap(0.81, 0.34);
    expect(now().game.flags['read_rumour'], isFalse, reason: 'not yet');
    play.takeExit('back');

    // The work-room: the hair, then the robe, then the report.
    tap(0.89, 0.56);
    expect(now().game.sceneId, 'site_lab');
    tap(0.62, 0.62);
    expect(now().openPuzzle, isNull, reason: 'the hair first');
    tap(0.23, 0.55);
    solve('strand');
    expect(now().game.words, contains('arsenic'));
    expect(stage(), 'stage:robe');
    tap(0.62, 0.62);
    solve('scan');
    expect(stage(), 'stage:report');
    tap(0.9, 0.28);
    expect(now().game.words, contains('mg_201'));
    expect(stage(), 'stage:rumour');
    play.takeExit('back');

    // The archive again: rumour, and no record of a hand.
    tap(0.09, 0.55);
    tap(0.81, 0.34);
    expect(
      now().game.words,
      containsAll(['cixi', 'yuan_shikai', 'li_lianying', 'unknown']),
    );
    expect(stage(), 'stage:write_seal');
    play.takeExit('back');

    // The keeper's slip in the burner.
    tap(0.68, 0.7);
    expect(now().game.secretFound, isTrue);
    expect(
      container.read(saveRepositoryProvider).keeperNote(episode),
      'chongling_1908.court.keeper_note',
    );

    // The seal: the vermilion sheet at the stele.
    tap(0.5, 0.35);
    expect(now().openPuzzle, 'jar_label');
    final label =
        content().requirePuzzle('jar_label').config as DeductionConfig;
    expect(label.form, DeductionForm.vermilion);
    var deduction = label.start(now().game);
    expect(
      deduction.available,
      containsAll(label.answers),
      reason: 'every answer was noted on the way',
    );
    expect(
      deduction.available,
      containsAll(['cixi', 'date_1980', 'stomach']),
      reason: 'the legend and the near misses are there to mislead',
    );
    for (final (i, answer) in label.answers.indexed) {
      deduction = deduction.fill(i, answer);
    }
    expect(deduction.isSolved, isTrue);
    play.solvePuzzle('jar_label');
    expect(now().currentText, 'chongling_1908.label.done');
    readAll();
    expect(now().game.completed, isTrue);
  });
}
