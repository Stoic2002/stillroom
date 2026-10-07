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

/// The Franklin expedition 1845's own puzzles: the Victory Point note
/// turned to read its margins, the sonar survey off the peninsula, and
/// the Admiralty form.
void main() {
  late EpisodeContent content;
  late StringTables strings;
  final widgets = builtInPuzzleWidgets();

  setUpAll(() async {
    final loader = ContentLoader(FileAssetSource(Directory.current));
    content = await loader.loadEpisode(
      'franklin_1845',
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
    // About the frame a puzzle gets on the developer's phone.
    tester.view.physicalSize = const Size(731, 411);
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
                episodeId: 'franklin_1845',
                sceneId: 'survey',
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

  group('margins', () {
    testWidgets('turn the sheet and tap the passage that answers', (
      tester,
    ) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'margins');
      expect(tester.takeException(), isNull, reason: 'fits the phone');
      expect(find.textContaining('deserted?'), findsOneWidget);
      Future<void> tapPassage(int i) async {
        await tester.tap(find.byKey(ValueKey('margins_passage_$i')));
        await tester.pump();
      }

      // The 1847 "All well", upright from the start: a wrong answer.
      await tapPassage(1);
      expect(sounds.last, UiSound.mistake);
      // The 1848 hand up the right side, before turning: unreadable.
      await tapPassage(3);
      expect(sounds.last, UiSound.reject);
      await tester.tap(find.byKey(const ValueKey('margins_right')));
      await tester.pumpAndSettle();
      expect(sounds.last, UiSound.sheetTurn);
      await tapPassage(3);
      expect(sounds.last, UiSound.place);
      await tester.tap(find.byKey(const ValueKey('margins_right')));
      await tester.pumpAndSettle();
      await tapPassage(4);
      await tester.tap(find.byKey(const ValueKey('margins_right')));
      await tester.pumpAndSettle();
      await tapPassage(5);
      await tester.pump(const Duration(seconds: 3));
      expect(solved[0], 1);
    });
  });

  group('sonar', () {
    testWidgets('run lanes, a season spent, then the wreck', (tester) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'sonar');
      final config = content.requirePuzzle('sonar').config as SonarConfig;
      expect(tester.takeException(), isNull, reason: 'fits the phone');
      Future<void> cell(int c, int r) async {
        await tester.tap(find.byKey(ValueKey('sonar_cell_${c}_$r')));
        await tester.pump();
      }

      // Three lanes far north: the season is spent.
      for (final r in [0, 1, 2]) {
        await cell(0, r);
        expect(sounds.last, UiSound.laneRun);
      }
      await cell(0, 4);
      expect(sounds.last, UiSound.reject, reason: 'no hours left');
      expect(find.byKey(const ValueKey('sonar_next')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('sonar_next')));
      await tester.pump();
      // The lane by the island; a rock in it first, then the wreck.
      await cell(0, config.wreckRow);
      await cell(8, config.wreckRow);
      expect(sounds.last, UiSound.mistake);
      expect(
        find.text('A rock: a round echo, a short shadow.'),
        findsOneWidget,
      );
      await cell(config.wreckColumn, config.wreckRow);
      expect(sounds.last, UiSound.echoMark);
      await tester.pump(const Duration(seconds: 3));
      expect(solved[0], 1);
    });
  });

  group('admiralty', () {
    testWidgets('the seal is written into the Admiralty form', (tester) async {
      final config =
          content.requirePuzzle('jar_label').config as DeductionConfig;
      expect(config.form, DeductionForm.admiralty);
      final (solved, _) = await pumpPuzzle(
        tester,
        'jar_label',
        words: config.words.toSet(),
      );
      tester.view.physicalSize = const Size(1600, 900);
      await tester.pump();
      expect(find.textContaining('Whoever finds this paper'), findsOneWidget);
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
