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

/// Borobudur 1814's own puzzles: the fallen Buddhas set back by their
/// hands, the casing over the hidden reliefs, and the palm leaves.
void main() {
  late EpisodeContent content;
  late StringTables strings;
  final widgets = builtInPuzzleWidgets();

  setUpAll(() async {
    final loader = ContentLoader(FileAssetSource(Directory.current));
    content = await loader.loadEpisode(
      'borobudur_1814',
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
                episodeId: 'borobudur_1814',
                sceneId: 'gallery',
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

  group('mudra', () {
    testWidgets('pick a statue, then the place its hands belong to', (
      tester,
    ) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'mudra');
      final config = content.requirePuzzle('mudra').config as MudraConfig;
      expect(tester.takeException(), isNull, reason: 'fits the phone');
      // A meditating Buddha to the east: wrong.
      final first = config.statues.first;
      expect(first, Mudra.meditation);
      await tester.tap(find.byKey(const ValueKey('mudra_statue_0')));
      await tester.tap(find.byKey(const ValueKey('mudra_place_earth')));
      await tester.pump();
      expect(sounds.last, UiSound.mistake);
      for (final (i, m) in config.statues.indexed) {
        await tester.tap(find.byKey(ValueKey('mudra_statue_$i')));
        await tester.tap(find.byKey(ValueKey('mudra_place_${m.name}')));
        await tester.pump();
      }
      expect(sounds, contains(UiSound.nicheSet));
      await tester.pump(const Duration(seconds: 3));
      expect(solved[0], 1);
    });
  });

  group('casing', () {
    testWidgets('lift two at a time; pairs stay, the rest go back', (
      tester,
    ) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'casing');
      final config = content.requirePuzzle('casing').config as CasingConfig;
      expect(tester.takeException(), isNull, reason: 'fits the phone');
      Future<void> lift(int i) async {
        await tester.tap(find.byKey(ValueKey('casing_stone_$i')));
        await tester.pump();
      }

      await lift(0);
      expect(sounds.last, UiSound.stoneLift);
      final other = config.panels.indexWhere(
        (p) => p.pair != config.panels[0].pair,
      );
      await lift(other);
      expect(sounds.last, UiSound.mistake);
      expect(find.textContaining('Not a deed and its fruit'), findsOneWidget);
      for (var pair = 0; pair < config.panels.length ~/ 2; pair++) {
        final both = [
          for (var i = 0; i < config.panels.length; i++)
            if (config.panels[i].pair == pair) i,
        ];
        await lift(both[0]);
        await lift(both[1]);
      }
      expect(sounds, contains(UiSound.pairFound));
      await tester.pump(const Duration(seconds: 3));
      expect(solved[0], 1);
    });
  });

  group('lontar', () {
    testWidgets('the seal is cut into the palm leaves', (tester) async {
      final config =
          content.requirePuzzle('jar_label').config as DeductionConfig;
      expect(config.form, DeductionForm.lontar);
      final (solved, _) = await pumpPuzzle(
        tester,
        'jar_label',
        words: config.words.toSet(),
      );
      tester.view.physicalSize = const Size(1600, 900);
      await tester.pump();
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
