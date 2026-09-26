import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/content/content_loader.dart';
import 'package:stillroom/content/file_asset_source.dart';
import 'package:stillroom/core/audio/ui_sound.dart';
import 'package:stillroom/engine/engine.dart';
import 'package:stillroom/features/puzzles/built_in_puzzle_widgets.dart';
import 'package:stillroom/features/puzzles/puzzle_view.dart';
import 'package:stillroom/l10n/generated/app_localizations.dart';

/// The deduction and reveal screens, on Whitechapel's own puzzles.
void main() {
  late EpisodeContent content;
  late StringTables strings;
  final widgets = builtInPuzzleWidgets();

  setUpAll(() async {
    final loader = ContentLoader(FileAssetSource(Directory.current));
    content = await loader.loadEpisode(
      'whitechapel_1888',
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
                episodeId: 'whitechapel_1888',
                sceneId: 'room_south',
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

  group('deduction', () {
    DeductionConfig config() =>
        content.requirePuzzle('jar_label').config as DeductionConfig;

    testWidgets('only noted words are offered', (tester) async {
      await pumpPuzzle(tester, 'jar_label', words: {'nichols', 'bucks_row'});
      expect(find.byKey(const ValueKey('word_nichols')), findsOneWidget);
      expect(find.byKey(const ValueKey('word_kelly')), findsNothing);
    });

    testWidgets(
      'with nothing noted, the player is told where words come from',
      (tester) async {
        await pumpPuzzle(tester, 'jar_label');
        expect(find.textContaining('underlined words'), findsOneWidget);
      },
    );

    testWidgets('filling every blank right distils the label', (tester) async {
      final (solved, sounds) = await pumpPuzzle(
        tester,
        'jar_label',
        words: config().words.toSet(),
      );
      await tester.tap(find.text('Distil'));
      await tester.pump();
      expect(find.text('Some blanks are still empty.'), findsOneWidget);

      // The first blank is selected; each word moves on to the next blank.
      for (final answer in config().answers) {
        await tester.tap(find.byKey(ValueKey('word_$answer')));
        await tester.pump();
      }
      await tester.tap(find.text('Distil'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(sounds.last, UiSound.solved);
      await tester.pump(SolvesAfterPause.pause);
      expect(solved.single, 1);
    });

    testWidgets('a near miss says how many are wrong', (tester) async {
      await pumpPuzzle(tester, 'jar_label', words: config().words.toSet());
      final answers = [...config().answers]..[0] = 'chapman';
      for (final answer in answers) {
        await tester.tap(find.byKey(ValueKey('word_$answer')));
        await tester.pump();
      }
      await tester.tap(find.text('Distil'));
      await tester.pump();
      expect(find.text('One of these is not right yet.'), findsOneWidget);

      // Tapping the wrong blank twice empties it for another word.
      await tester.tap(find.byKey(const ValueKey('blank_0')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('blank_0')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('word_nichols')));
      await tester.tap(find.text('Distil'));
      await tester.pump();
      expect(find.text('One of these is not right yet.'), findsNothing);
    });
  });

  group('reveal', () {
    testWidgets('wiping across the pane uncovers it and solves', (
      tester,
    ) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'window_fog');
      expect(find.text('Wipe it with your finger.'), findsOneWidget);
      final box = tester.getRect(find.byKey(const ValueKey('reveal_cover')));
      for (var row = 0.25; row <= 0.75; row += 0.05) {
        final gesture = await tester.startGesture(
          box.topLeft + Offset(box.width * 0.15, box.height * row),
        );
        for (var x = 0.15; x <= 0.85; x += 0.05) {
          await gesture.moveTo(
            box.topLeft + Offset(box.width * x, box.height * row),
          );
        }
        await gesture.up();
      }
      await tester.pump(const Duration(milliseconds: 100));
      expect(sounds, contains(UiSound.wipe));
      expect(sounds.last, UiSound.solved);
      await tester.pump(SolvesAfterPause.pause);
      expect(solved.single, 1);
    });
  });

  group('sequence', () {
    testWidgets('each candle lights the moment it is lit in order', (
      tester,
    ) async {
      await pumpPuzzle(tester, 'candles');
      const lit = ValueKey('images/objects/whitechapel_1888/candle_lit.png');
      expect(find.byKey(lit), findsNothing);
      await tester.tap(find.byKey(const ValueKey('element_bucks_row')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(lit), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('element_hanbury_street')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(lit), findsNWidgets(2));

      // A wrong candle puts them all out.
      await tester.tap(find.byKey(const ValueKey('element_millers_court')));
      await tester.pumpAndSettle();
      expect(find.byKey(lit), findsNothing);
    });
  });

  group('telegraph tape', () {
    testWidgets('the marks tapped so far show on a tape', (tester) async {
      final lawang = await tester.runAsync(
        () => ContentLoader(
          FileAssetSource(Directory.current),
        ).loadEpisode('lawang_sewu_1945', ContentRegistries.withBuiltIns()),
      );
      content = lawang!;
      await pumpPuzzle(tester, 'telegraph');
      Text tape() => tester.widget<Text>(
        find.descendant(
          of: find.byKey(const ValueKey('sequence_tape')),
          matching: find.byType(Text),
        ),
      );
      expect(tape().data, '');
      await tester.tap(find.byKey(const ValueKey('element_dash')));
      await tester.tap(find.byKey(const ValueKey('element_dot')));
      await tester.pump();
      expect(tape().data, '−  ·');
    });
  });

  group('crank', () {
    testWidgets('winding round and round solves it', (tester) async {
      final flannan = await tester.runAsync(
        () => ContentLoader(
          FileAssetSource(Directory.current),
        ).loadEpisode('flannan_isles_1900', ContentRegistries.withBuiltIns()),
      );
      content = flannan!;
      final (solved, sounds) = await pumpPuzzle(tester, 'clockwork');
      expect(find.text('Turn the handle round and round.'), findsOneWidget);
      final box = tester.getRect(find.byKey(const ValueKey('crank')));
      final center = box.center;
      final radius = box.shortestSide * 0.3;
      final gesture = await tester.startGesture(center + Offset(radius, 0));
      for (var step = 1; step <= 4 * 24 + 4; step++) {
        final angle = step * math.pi / 12;
        await gesture.moveTo(
          center + Offset(math.cos(angle), math.sin(angle)) * radius,
        );
      }
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        sounds.where((s) => s == UiSound.dial),
        hasLength(greaterThan(10)),
      );
      expect(sounds.last, UiSound.solved);
      await tester.pump(SolvesAfterPause.pause);
      expect(solved.single, 1);
    });
  });
}
