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

/// Whitechapel 1891's own puzzles: the file that grows when no one is
/// looking, her name set in mirrored type, and the seal on the file's cover.
void main() {
  late EpisodeContent content;
  late StringTables strings;
  final widgets = builtInPuzzleWidgets();

  setUpAll(() async {
    final loader = ContentLoader(FileAssetSource(Directory.current));
    content = await loader.loadEpisode(
      'whitechapel_1891',
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
                episodeId: 'whitechapel_1891',
                sceneId: 'file_room',
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

  group('unwatched', () {
    testWidgets('looking away adds a file; only the new one counts', (
      tester,
    ) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'unwatched');
      final config =
          content.requirePuzzle('unwatched').config as UnwatchedConfig;
      expect(find.text('Look away, then look back.'), findsOneWidget);
      expect(find.text('New files found: 0 of 6'), findsOneWidget);

      Future<void> lookAway() async {
        await tester.tap(find.byKey(const ValueKey('unwatched_look')));
        await tester.pumpAndSettle();
      }

      await lookAway();
      expect(sounds.first, UiSound.lampGutter);
      expect(
        find.text('Something on the shelf is new. Find it.'),
        findsOneWidget,
      );
      // An old file is not it.
      await tester.tap(find.byKey(const ValueKey('unwatched_item_kelly')));
      await tester.pump();
      expect(sounds.last, UiSound.mistake);
      expect(find.text('That one was already there.'), findsOneWidget);

      for (final round in config.rounds) {
        if (round != config.rounds.first) await lookAway();
        await tester.tap(find.byKey(ValueKey('unwatched_item_${round.add}')));
        await tester.pump();
      }
      expect(sounds.last, UiSound.solved);
      await tester.pump(const Duration(seconds: 2));
      expect(solved[0], 1);
    });
  });

  group('compose', () {
    testWidgets('a wrong-way sort prints backwards; the right ones solve', (
      tester,
    ) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'compose');
      final config = content.requirePuzzle('compose').config as ComposeConfig;
      expect(
        find.text('Set her name from the case. Type is cut in mirror.'),
        findsOneWidget,
      );
      Future<void> set(String key) async {
        await tester.tap(find.byKey(ValueKey('compose_sort_$key')));
        await tester.pump();
      }

      // All but the last letter, then a wrong-way S.
      final letters = config.text.split('');
      for (final l in letters.take(letters.length - 1)) {
        await set(l == ' ' ? 'space' : l);
      }
      await set('S_wrong');
      expect(sounds.last, UiSound.mistake);
      expect(find.text('The proof reads wrong somewhere.'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('compose_back')));
      await tester.pump();
      await set('S');
      expect(sounds, contains(UiSound.typeSort));
      expect(sounds.last, UiSound.solved);
      await tester.pump(const Duration(seconds: 2));
      expect(solved[0], 1);
    });
  });

  group('docket', () {
    testWidgets('the seal is written on a police file cover', (tester) async {
      final config =
          content.requirePuzzle('jar_label').config as DeductionConfig;
      final (solved, _) = await pumpPuzzle(
        tester,
        'jar_label',
        words: config.words.toSet(),
      );
      expect(find.text('Metropolitan Police'), findsOneWidget);
      expect(find.text('Criminal Investigation Department'), findsOneWidget);
      expect(find.byKey(const ValueKey('blank_2')), findsOneWidget);
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
