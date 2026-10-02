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

/// Honnō-ji 1582's own puzzles: the moat's section dated layer by layer
/// and the fire's layer found, the addresses marked on the street grid,
/// and the stone marker.
void main() {
  late EpisodeContent content;
  late StringTables strings;
  final widgets = builtInPuzzleWidgets();

  setUpAll(() async {
    final loader = ContentLoader(FileAssetSource(Directory.current));
    content = await loader.loadEpisode(
      'honnoji_1582',
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
                episodeId: 'honnoji_1582',
                sceneId: 'dig',
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

  group('strata', () {
    testWidgets('read finds, date each layer, find the fire', (tester) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'strata');
      final config = content.requirePuzzle('strata').config as StrataConfig;
      expect(tester.takeException(), isNull, reason: 'fits the phone');
      for (final key in [
        for (var i = 0; i < config.layers.length; i++) 'strata_layer_$i',
        for (final year in config.years) 'strata_year_$year',
        'strata_fire',
      ]) {
        final rect = tester.getRect(find.byKey(ValueKey(key)));
        expect(
          const Rect.fromLTWH(0, 0, 731, 411).contains(rect.bottomRight),
          isTrue,
          reason: '$key on screen',
        );
      }

      // A find read.
      await tester.tap(find.byKey(const ValueKey('strata_find_1_0')));
      await tester.pump();
      expect(find.textContaining('Eiraku'), findsWidgets);
      expect(sounds.last, UiSound.findLift);

      // The fill dated by its own coin alone: wrong, it lies on later ash.
      await tester.tap(find.byKey(const ValueKey('strata_layer_1')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('strata_year_1408')));
      await tester.pump();
      expect(sounds.last, UiSound.mistake);

      // Each layer by its earliest year, from the top; the picked layer
      // moves down by itself.
      await tester.tap(find.byKey(const ValueKey('strata_layer_0')));
      await tester.pump();
      for (var i = 0; i < config.layers.length; i++) {
        await tester.tap(
          find.byKey(ValueKey('strata_year_${config.earliest(i)}')),
        );
        await tester.pump();
        expect(sounds.last, UiSound.strataTag);
      }
      expect(find.text('Not before 1636'), findsNWidgets(2));

      // The later black layer: too young.
      await tester.tap(find.byKey(const ValueKey('strata_layer_2')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('strata_fire')));
      await tester.pump();
      expect(sounds.last, UiSound.mistake);
      expect(solved[0], 0);

      await tester.tap(find.byKey(ValueKey('strata_layer_${config.fire}')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('strata_fire')));
      await tester.pump(const Duration(seconds: 3));
      expect(solved[0], 1);
    });
  });

  group('streets', () {
    testWidgets('each address names one block', (tester) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'streets');
      final config = content.requirePuzzle('streets').config as StreetsConfig;
      expect(tester.takeException(), isNull, reason: 'fits the phone');
      final block = tester.getRect(
        find.byKey(const ValueKey('streets_block_0_0')),
      );
      expect(block.width, greaterThanOrEqualTo(40), reason: 'easy to tap');
      expect(find.textContaining('Rokkaku-Aburanokōji'), findsOneWidget);

      // The block west of the right one.
      final old = config.targets[0];
      await tester.tap(
        find.byKey(ValueKey('streets_block_${old.column + 1}_${old.row}')),
      );
      await tester.pump();
      expect(sounds.last, UiSound.mistake);

      await tester.tap(
        find.byKey(ValueKey('streets_block_${old.column}_${old.row}')),
      );
      await tester.pump();
      expect(sounds.last, UiSound.streetMark);
      expect(find.textContaining('Teramachi-Oike'), findsOneWidget);
      final moved = config.targets[1];
      await tester.tap(
        find.byKey(ValueKey('streets_block_${moved.column}_${moved.row}')),
      );
      await tester.pump(const Duration(seconds: 3));
      expect(solved[0], 1);
    });
  });

  group('marker', () {
    testWidgets('the seal is cut into the stone marker', (tester) async {
      final config =
          content.requirePuzzle('jar_label').config as DeductionConfig;
      expect(config.form, DeductionForm.marker);
      final (solved, _) = await pumpPuzzle(
        tester,
        'jar_label',
        words: config.words.toSet(),
      );
      tester.view.physicalSize = const Size(1600, 900);
      await tester.pump();
      expect(find.text('Historic site'), findsOneWidget);
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
