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

/// Great Zimbabwe 1871's own puzzles: the breach laid back course by course,
/// Mauch's splinter named by the key, and the cartouche.
void main() {
  late EpisodeContent content;
  late StringTables strings;
  final widgets = builtInPuzzleWidgets();

  setUpAll(() async {
    final loader = ContentLoader(FileAssetSource(Directory.current));
    content = await loader.loadEpisode(
      'great_zimbabwe_1871',
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
                episodeId: 'great_zimbabwe_1871',
                sceneId: 'valley',
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

  group('courses', () {
    testWidgets(
      'lay each course, refused where it would split, then the band',
      (tester) async {
        final (solved, sounds) = await pumpPuzzle(tester, 'courses');
        final config = content.requirePuzzle('courses').config as CoursesConfig;
        expect(tester.takeException(), isNull, reason: 'fits the phone');
        expect(find.text('Course 1 of 3'), findsOneWidget);

        Future<void> lay(int block) async {
          await tester.tap(find.byKey(ValueKey('courses_block_$block')));
          await tester.pump();
        }

        final long = [
          for (final (i, l) in config.blocks.indexed)
            if (l == 4) i,
        ];
        final short = [
          for (final (i, l) in config.blocks.indexed)
            if (l == 2) i,
        ];
        // Long, long, short reach 10; another long would run to 14.
        await lay(long[0]);
        await lay(long[1]);
        await lay(short[0]);
        await lay(long[2]);
        expect(
          find.text('Too long: it would run past the gap.'),
          findsOneWidget,
        );
        expect(sounds.last, UiSound.mistake);
        for (var k = 0; k < 3; k++) {
          await tester.tap(find.byKey(const ValueKey('courses_take_back')));
          await tester.pump();
        }

        // The hint's way: short, long, long, short; three long; short, long,
        // long, short.
        final order = [
          short[0],
          long[0],
          long[1],
          short[1],
          long[2],
          long[3],
          long[4],
          short[2],
          long[5],
          long[6],
          short[3],
        ];
        for (final block in order) {
          await lay(block);
        }
        expect(sounds, contains(UiSound.blockLay));
        expect(
          find.text(
            'The chevron band: tap a slab to lean it the other way, until they '
            'lean in turn.',
          ),
          findsOneWidget,
        );

        // The band: tap each slab that breaks the zigzag.
        final wall = tester.getRect(find.byKey(const ValueKey('courses_wall')));
        final leans = [...config.chevrons];
        var expected = !leans[0];
        for (var k = 0; k < leans.length; k++) {
          expected = !expected;
          if (leans[k] == expected) continue;
          final slab = _slabCentre(wall, config, k);
          await tester.tapAt(slab);
          await tester.pump();
          leans[k] = expected;
        }
        expect(sounds.last, UiSound.solved);
        await tester.pump(const Duration(seconds: 1));
        expect(solved[0], 1);
      },
    );
  });

  group('identify', () {
    testWidgets(
      'a wrong end shows its note and goes back; the right one solves',
      (tester) async {
        final (solved, sounds) = await pumpPuzzle(tester, 'identify');
        expect(tester.takeException(), isNull, reason: 'fits the phone');
        expect(
          find.text('Look at the splinter. Which is true of it?'),
          findsOneWidget,
        );
        expect(
          find.textContaining('no pores, only even rows of small cells'),
          findsOneWidget,
        );

        Future<void> choose(int k) async {
          await tester.tap(find.byKey(ValueKey('identify_choice_$k')));
          await tester.pump();
        }

        // Mauch's way: no pores, reddish and scented: cedar.
        await choose(1);
        await choose(0);
        expect(
          find.textContaining('The key ends at: Cedar of Lebanon'),
          findsOneWidget,
        );
        expect(find.text('Back to where the path went wrong.'), findsOneWidget);
        expect(sounds.last, UiSound.mistake);
        expect(find.byKey(const ValueKey('identify_step_0')), findsOneWidget);
        expect(find.byKey(const ValueKey('identify_step_1')), findsNothing);

        // Pores, fine, scented.
        await choose(0);
        expect(sounds.last, UiSound.keyStep);
        await choose(0);
        await choose(0);
        expect(find.textContaining('Spirostachys africana'), findsOneWidget);
        expect(sounds.last, UiSound.solved);
        await tester.pump(const Duration(seconds: 1));
        expect(solved[0], 1);
      },
    );
  });

  group('cartouche', () {
    testWidgets('the seal is written in a map cartouche', (tester) async {
      final config =
          content.requirePuzzle('jar_label').config as DeductionConfig;
      expect(config.form, DeductionForm.cartouche);
      final (solved, _) = await pumpPuzzle(
        tester,
        'jar_label',
        words: config.words.toSet(),
      );
      tester.view.physicalSize = const Size(1600, 900);
      await tester.pump();
      expect(find.text('A new map of the interior'), findsOneWidget);
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

/// The centre of chevron slab [k] on a wall drawn in [wall] (as the view's
/// painter lays it out).
Offset _slabCentre(Rect wall, CoursesConfig config, int k) {
  final rows = config.courses + 2;
  final unit = [
    wall.width / config.width,
    wall.height / (rows * 1.1),
    40 * 1.6,
  ].reduce((a, b) => a < b ? a : b);
  final w = unit * config.width;
  final h = unit * 1.1 * rows;
  final left = wall.left + (wall.width - w) / 2;
  final top = wall.top + (wall.height - h) / 2;
  final slabW = w / config.chevrons.length;
  return Offset(left + slabW * (k + 0.5), top + unit * 0.55);
}
