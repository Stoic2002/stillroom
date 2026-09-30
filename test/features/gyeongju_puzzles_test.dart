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

/// Gyeongju's own puzzles: the pour, the hollow under the bell, the cry
/// round its rim, and the seal taken as an ink rubbing.
void main() {
  late EpisodeContent content;
  late StringTables strings;
  final widgets = builtInPuzzleWidgets();

  setUpAll(() async {
    final loader = ContentLoader(FileAssetSource(Directory.current));
    content = await loader.loadEpisode(
      'gyeongju_771',
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
                episodeId: 'gyeongju_771',
                sceneId: 'pavilion',
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

  group('pour', () {
    testWidgets('a scrambled pour spills; turned right, the mould fills', (
      tester,
    ) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'pour');
      final config = content.requirePuzzle('pour').config as PourConfig;
      expect(
        find.text('Turn the channels, then open the furnaces.'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('pour_button')));
      await tester.pump();
      expect(sounds.last, UiSound.mistake);
      expect(
        find.text(
          'The bronze runs out into the sand. The furnaces are closed again.',
        ),
        findsOneWidget,
      );
      // Sand cannot be turned.
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.byKey(const ValueKey('pour_tile_10')));
      await tester.pump();
      expect(sounds.last, UiSound.reject);

      final start = config.start().turns;
      for (final (i, tile) in config.tiles.indexed) {
        if (!tile.kind.turns) continue;
        var turns = start[i];
        while (turns != tile.turns) {
          await tester.tap(find.byKey(ValueKey('pour_tile_$i')));
          await tester.pump();
          turns = (turns + 1) % 4;
        }
      }
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byKey(const ValueKey('pour_button')));
      await tester.pump();
      expect(sounds, contains(UiSound.pour));
      expect(sounds.last, UiSound.solved);
      await tester.pump(const Duration(seconds: 2));
      expect(solved[0], 1);
    });
  });

  group('resonance', () {
    testWidgets('only a full pull over the right hollow rings long enough', (
      tester,
    ) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'resonance');
      final striker = find.byKey(const ValueKey('resonance_striker'));

      // Barely pulled: the log hardly touches the bell.
      await tester.drag(striker, const Offset(-40, 0));
      await tester.pump();
      expect(
        find.text('Too gentle: the log barely touches the bronze.'),
        findsOneWidget,
      );

      // A full pull over the wrong hollow: it rings, but not for long.
      await tester.drag(striker, const Offset(-600, 0));
      await tester.pump();
      expect(sounds.last, UiSound.bellStrike);
      expect(find.text('The ring dies away before the mark.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const ValueKey('resonance_deeper')));
        await tester.pump();
      }
      await tester.drag(striker, const Offset(-600, 0));
      await tester.pump();
      expect(sounds.last, UiSound.solved);
      await tester.pump(const Duration(seconds: 3));
      expect(solved[0], 1);
    });
  });

  group('beat', () {
    testWidgets('each place rings its own swell; the deepest is marked', (
      tester,
    ) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'beat');
      final config = content.requirePuzzle('beat').config as BeatConfig;
      expect(
        find.text(
          'Strike the rim. Find where the ring swells deepest, and mark it.',
        ),
        findsOneWidget,
      );
      for (var i = 0; i < config.places; i++) {
        await tester.tap(find.byKey(ValueKey('beat_place_$i')));
        await tester.pump();
        expect(sounds.last, UiSound.forSwell(config.swell[i]));
      }
      expect(
        [
          for (final s in config.swell)
            if (UiSound.forSwell(s) == UiSound.beatDeep) s,
        ],
        hasLength(1),
        reason: 'only one place sounds the deepest swell',
      );

      // The last place struck (7) is not it.
      await tester.tap(find.byKey(const ValueKey('beat_mark')));
      await tester.pump();
      expect(sounds.last, UiSound.mistake);
      expect(find.text('Not here: somewhere it swells deeper.'), findsOne);

      await tester.tap(find.byKey(ValueKey('beat_place_${config.deepest}')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('beat_mark')));
      await tester.pump();
      expect(sounds.last, UiSound.solved);
      await tester.pump(const Duration(seconds: 3));
      expect(solved[0], 1);
    });
  });

  group('rubbing', () {
    testWidgets('the seal is an ink rubbing with one sentence', (tester) async {
      final config =
          content.requirePuzzle('jar_label').config as DeductionConfig;
      final (solved, _) = await pumpPuzzle(
        tester,
        'jar_label',
        words: config.words.toSet(),
      );
      expect(find.text('A rubbing from the bronze'), findsOneWidget);
      expect(find.byKey(const ValueKey('blank_2')), findsOneWidget);
      expect(find.byKey(const ValueKey('blank_3')), findsNothing);
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
