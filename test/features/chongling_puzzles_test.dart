import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/content/content_loader.dart';
import 'package:stillroom/content/file_asset_source.dart';
import 'package:stillroom/core/audio/ui_sound.dart';
import 'package:stillroom/engine/engine.dart';
import 'package:stillroom/features/puzzles/built_in_puzzle_widgets.dart';
import 'package:stillroom/features/puzzles/puzzle_view.dart';
import 'package:stillroom/l10n/generated/app_localizations.dart';

/// Beijing 1908's own puzzles: the hair measured segment by segment, the
/// robe under the probe, and the seal in vermilion.
void main() {
  late EpisodeContent content;
  late StringTables strings;
  final widgets = builtInPuzzleWidgets();

  setUpAll(() async {
    final loader = ContentLoader(FileAssetSource(Directory.current));
    content = await loader.loadEpisode(
      'chongling_1908',
      ContentRegistries.withBuiltIns(),
    );
    strings = await loader.loadStringTables();
  });

  Future<(List<int>, List<UiSound>)> pumpPuzzle(
    WidgetTester tester,
    String puzzleId, {
    Set<String> words = const {},
  }) async {
    final solved = [0];
    final sounds = <UiSound>[];
    final puzzle = content.requirePuzzle(puzzleId);
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: widgets[puzzle.type]!(
            PuzzleViewContext(
              puzzle: puzzle,
              content: content,
              game: GameState(
                episodeId: 'chongling_1908',
                sceneId: 'site_lab',
                words: words,
              ),
              assets: const {},
              strings: strings,
              onSolved: () => solved[0]++,
              feedback: sounds.add,
            ),
          ),
        ),
      ),
    );
    return (solved, sounds);
  }

  group('strand', () {
    testWidgets('measure, run out, start over, mark, name the curve', (
      tester,
    ) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'strand');
      final config = content.requirePuzzle('strand').config as StrandConfig;
      expect(
        find.text(
          "Tap a segment to measure it. Find each strand's highest reading "
          'and mark it.',
        ),
        findsOneWidget,
      );
      expect(find.text('7 readings left'), findsNWidgets(2));
      Future<void> tapKey(String key) async {
        await tester.tap(find.byKey(ValueKey(key)));
        await tester.pump();
      }

      // Seven readings on strand I, none of them its highest.
      for (final i in [0, 1, 2, 3, 4, 5, 6]) {
        await tapKey('strand_0_$i');
      }
      expect(sounds, contains(UiSound.geiger));
      expect(find.text('No readings left'), findsOneWidget);
      await tapKey('strand_0_9');
      expect(sounds.last, UiSound.reject);
      expect(
        find.text('No reactor time left on this sample. Take a new one.'),
        findsOneWidget,
      );
      // Marking a measured segment that is not the highest.
      await tapKey('strand_0_6');
      await tapKey('strand_mark');
      expect(sounds.last, UiSound.mistake);
      expect(
        find.text('Not the highest. A neighbour may read higher.'),
        findsOneWidget,
      );

      await tapKey('strand_new_0');
      expect(sounds.last, UiSound.sample);
      for (var s = 0; s < config.strands.length; s++) {
        await tapKey('strand_${s}_${config.peak(s)}');
        await tapKey('strand_mark');
        expect(sounds.last, UiSound.note);
      }
      expect(
        find.text('How does the arsenic run along the hair?'),
        findsOneWidget,
      );
      await tapKey('strand_steady');
      expect(sounds.last, UiSound.mistake);
      await tapKey('strand_peak');
      expect(sounds.last, UiSound.solved);
      await tester.pump(const Duration(seconds: 2));
      expect(solved[0], 1);
    });
  });

  group('scan', () {
    testWidgets('faint through the outer robe; the inner shows each place', (
      tester,
    ) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'scan');
      final config = content.requirePuzzle('scan').config as ScanConfig;
      final board = tester.getRect(find.byKey(const ValueKey('scan_board')));
      Future<void> markAt(double x, double y) async {
        await tester.tapAt(
          board.topLeft + Offset(board.width * x, board.height * y),
        );
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('scan_mark')));
        await tester.pump();
      }

      expect(find.text('Places marked: 0 of 4'), findsOneWidget);
      final stomach = config.spots.first;
      await markAt(stomach.x, stomach.y);
      expect(sounds, contains(UiSound.probeTick));
      expect(sounds.last, UiSound.reject);
      expect(
        find.text(
          'The needle stirs, but not into the red. Too faint through this '
          'cloth?',
        ),
        findsOneWidget,
      );
      await markAt(0.1, 0.9);
      expect(sounds.last, UiSound.mistake);
      expect(find.text('The needle hardly moves here.'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('scan_layer_inner')));
      await tester.pump();
      await markAt(stomach.x, stomach.y);
      expect(sounds.last, UiSound.note);
      expect(find.text('Marked: the stomach'), findsOneWidget);
      await markAt(stomach.x, stomach.y);
      expect(find.text('Already marked.'), findsOneWidget);
      for (final spot in config.spots.skip(1)) {
        await markAt(spot.x, spot.y);
      }
      expect(sounds.last, UiSound.solved);
      await tester.pump(const Duration(seconds: 2));
      expect(solved[0], 1);
    });
  });

  group('vermilion', () {
    testWidgets('the seal is written in vermilion on imperial yellow', (
      tester,
    ) async {
      final config =
          content.requirePuzzle('jar_label').config as DeductionConfig;
      final (solved, _) = await pumpPuzzle(
        tester,
        'jar_label',
        words: config.words.toSet(),
      );
      expect(find.text('In vermilion'), findsOneWidget);
      for (final answer in config.answers) {
        await tester.tap(find.byKey(ValueKey('word_$answer')));
        await tester.pump();
      }
      await tester.tap(find.text('Distil'));
      await tester.pump(const Duration(seconds: 3));
      expect(solved[0], 1);
    });
  });
}
