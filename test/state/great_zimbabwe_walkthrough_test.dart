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

/// Plays "Great Zimbabwe, 1871" start to finish through the real content, and
/// checks that the solutions the hints give really solve the puzzles.
void main() {
  const episode = 'great_zimbabwe_1871';
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
    // The courses: short, long, long, short; three long; short, long, long,
    // short. The only way.
    final courses = content().requirePuzzle('courses').config as CoursesConfig;
    final solution = courses.solution()!;
    expect(
      [
        for (final c in solution) [for (final i in c) courses.blocks[i]],
      ],
      [
        [2, 4, 4, 2],
        [4, 4, 4],
        [2, 4, 4, 2],
      ],
    );
    var wall = courses.start();
    for (final c in solution) {
      for (final i in c) {
        wall = wall.lay(i);
      }
    }
    expect(wall.coursesDone, isTrue);
    expect(wall.mistakes, 0);
    // The band: lean in turn, starting either way.
    for (var k = 0; k < courses.chevrons.length; k++) {
      if (wall.leans[k] != (k.isEven == !courses.chevrons[0])) {
        wall = wall.tilt(k);
      }
    }
    expect(wall.isSolved, isTrue);

    // Laying the largest that fits, course by course, runs out of long
    // blocks: the pile asks for a plan.
    var greedy = courses.start();
    for (var step = 0; step < 20 && !greedy.coursesDone; step++) {
      final options = [
        for (final (i, l) in courses.blocks.indexed)
          if (greedy.judge(i) == CoursesLay.laid) (i, l),
      ]..sort((a, b) => b.$2.compareTo(a.$2));
      if (options.isEmpty) break;
      greedy = greedy.lay(options.first.$1);
    }
    expect(greedy.coursesDone, isFalse);

    // The key: pores, fine, scented.
    final key = content().requirePuzzle('identify').config as IdentifyConfig;
    var path = key.begin();
    for (final k in [0, 0, 0]) {
      path = path.choose(k);
    }
    expect(path.isSolved, isTrue);
    expect(path.mistakes, 0);
    // Mauch's way ends at cedar.
    expect(key.begin().choose(1).choose(0).wrongEnd, 'cedar');
  });

  test('the episode can be completed', () {
    expect(now().game.sceneId, 'valley');
    expect(stage(), 'stage:start');

    // The entrance is choked until the breach is laid back.
    tap(0.55, 0.62);
    expect(now().game.sceneId, 'valley', reason: 'blocked');

    // The camp: the notebook, the pencil; the splinter waits.
    tap(0.9, 0.6);
    expect(now().game.sceneId, 'camp');
    tap(0.38, 0.5);
    expect(
      now().game.words,
      containsAll([
        'mauch',
        'ophir',
        'solomon',
        'bc10',
        'phoenicians',
        'sheba',
      ]),
    );
    tap(0.51, 0.5);
    expect(now().game.words, contains('cedar'));
    tap(0.66, 0.49);
    expect(now().openPuzzle, isNull, reason: 'the lintel not seen yet');
    expect(stage(), 'stage:wall');
    play.takeExit('back');

    // The breach.
    tap(0.35, 0.45);
    solve('courses');
    expect(stage(), 'stage:lintel');

    // The enclosure: the tower, the lintel.
    tap(0.55, 0.62);
    expect(now().game.sceneId, 'enclosure');
    tap(0.62, 0.4);
    tap(0.4, 0.74);
    expect(now().game.flags['saw_lintel'], isTrue);
    expect(stage(), 'stage:wood');
    tap(0.83, 0.64);
    expect(now().game.flags['read_report'], isFalse, reason: 'not yet');
    play.takeExit('back');

    // The camp: the splinter under the lens.
    tap(0.9, 0.6);
    tap(0.66, 0.49);
    solve('identify');
    expect(now().game.words, contains('tambootie'));
    expect(stage(), 'stage:report');
    play.takeExit('back');

    // The enclosure: what the archaeologists found.
    tap(0.55, 0.62);
    tap(0.83, 0.64);
    expect(now().game.words, containsAll(['shona', 'c11']));
    expect(stage(), 'stage:birds');
    play.takeExit('back');

    // The hill: the birds, and what became of them.
    tap(0.05, 0.5);
    expect(now().game.sceneId, 'hill');
    tap(0.4, 0.3);
    tap(0.18, 0.7);
    expect(now().game.words, contains('rhodes'));
    expect(stage(), 'stage:write_seal');
    play.takeExit('back');

    // The keeper's slip under the fig's roots.
    tap(0.7, 0.2);
    expect(now().game.secretFound, isTrue);
    expect(
      container.read(saveRepositoryProvider).keeperNote(episode),
      'great_zimbabwe_1871.valley.keeper_note',
    );

    // The seal: the cartouche on the wall.
    tap(0.54, 0.22);
    expect(now().openPuzzle, 'jar_label');
    final label =
        content().requirePuzzle('jar_label').config as DeductionConfig;
    expect(label.form, DeductionForm.cartouche);
    var deduction = label.start(now().game);
    expect(
      deduction.available,
      containsAll(label.answers),
      reason: 'every answer was noted on the way',
    );
    expect(
      deduction.available,
      containsAll(['sheba', 'cedar', 'bc10']),
      reason: 'the legend and the near misses are there to mislead',
    );
    for (final (i, answer) in label.answers.indexed) {
      deduction = deduction.fill(i, answer);
    }
    expect(deduction.isSolved, isTrue);
    play.solvePuzzle('jar_label');
    expect(now().currentText, 'great_zimbabwe_1871.label.done');
    readAll();
    expect(now().game.completed, isTrue);
  });
}
