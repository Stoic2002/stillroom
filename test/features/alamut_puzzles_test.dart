import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/content/content_loader.dart';
import 'package:stillroom/content/content_strings.dart';
import 'package:stillroom/content/file_asset_source.dart';
import 'package:stillroom/core/audio/ui_sound.dart';
import 'package:stillroom/engine/engine.dart';
import 'package:stillroom/features/puzzles/built_in_puzzle_widgets.dart';
import 'package:stillroom/features/puzzles/puzzle_view.dart';
import 'package:stillroom/l10n/generated/app_localizations.dart';

/// Alamut 1256's own puzzles: the sheets of Juvayni's account gathered by
/// their catchwords, the tanks dipped with a reed, and the colophon.
void main() {
  late EpisodeContent content;
  late StringTables strings;
  final widgets = builtInPuzzleWidgets();

  setUpAll(() async {
    final loader = ContentLoader(FileAssetSource(Directory.current));
    content = await loader.loadEpisode(
      'alamut_1256',
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
                episodeId: 'alamut_1256',
                sceneId: 'library',
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

  group('quire', () {
    testWidgets('swap sheets, turn them over, until every catchword meets', (
      tester,
    ) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'quire');
      final config = content.requirePuzzle('quire').config as QuireConfig;
      var state = config.start();
      expect(find.text('0 of 7 catchwords meet their pages'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'fits the phone');

      Future<void> tapPlace(int p) async {
        await tester.tap(find.byKey(ValueKey('quire_page_$p')));
        await tester.pump();
      }

      // The page tapped is read in full below.
      await tapPlace(0);
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('quire_reading'))).data,
        contentText(strings, 'en', config.leaves[state.leafAt(0)]),
      );
      expect(
        find.text('Tap another sheet to swap places, or turn this one over.'),
        findsOneWidget,
      );
      await tapPlace(0);

      // Nest each sheet at its depth, outermost first, as the hint says.
      for (var k = 0; k < config.sheets; k++) {
        if (state.order[k] == k) continue;
        await tapPlace(state.order.indexOf(k));
        await tapPlace(k);
        state = state.swap(state.order.indexOf(k), k);
      }
      for (var k = 0; k < config.sheets; k++) {
        if (!state.turned[k]) continue;
        await tapPlace(k);
        await tester.tap(find.byKey(const ValueKey('quire_turn')));
        await tester.pump();
        state = state.turn(k);
        if (!state.isSolved) await tapPlace(k);
      }
      expect(state.isSolved, isTrue);
      expect(find.text('7 of 7 catchwords meet their pages'), findsOneWidget);
      expect(sounds, contains(UiSound.catchword));
      expect(sounds.last, UiSound.solved);
      await tester.pump(const Duration(seconds: 1));
      expect(solved[0], 1);
    });

    test('every page begins with its own word, in every language', () {
      final config = content.requirePuzzle('quire').config as QuireConfig;
      for (final language in strings.keys) {
        final heads = [
          for (final key in config.leaves)
            catchword(contentText(strings, language, key)),
        ];
        expect(heads.every((h) => h.isNotEmpty), isTrue, reason: language);
        expect(heads.toSet(), hasLength(heads.length), reason: language);
        for (final key in config.leaves) {
          expect(
            markedWords(contentText(strings, language, key)),
            isEmpty,
            reason: 'a page shows no word marks ($language $key)',
          );
        }
      }
    });
  });

  group('dip', () {
    testWidgets('closing the tanks untouched disposes cleanly', (tester) async {
      await pumpPuzzle(tester, 'dip');
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });

    Future<void> dipTank(WidgetTester tester, int t, {double by = 400}) async {
      final tank = find.byKey(ValueKey('dip_tank_$t'));
      final top = tester.getRect(tank).topCenter.translate(0, 4);
      final gesture = await tester.startGesture(top);
      for (var k = 1; k <= 10; k++) {
        await gesture.moveTo(top.translate(0, by * k / 10));
        await tester.pump();
      }
      await gesture.up();
      // Watch it drip for a while.
      for (var k = 0; k < 30; k++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    testWidgets('lower the reed, watch it drip, name it, judge the stores', (
      tester,
    ) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'dip');
      final config = content.requirePuzzle('dip').config as DipConfig;
      expect(tester.takeException(), isNull, reason: 'fits the phone');
      expect(
        find.text(
          'Drag the reed down into a tank until it meets the surface, then '
          'let go and watch it drip.',
        ),
        findsOneWidget,
      );

      // Not deep enough: the reed never meets the surface.
      await dipTank(tester, 0, by: 20);
      expect(find.byKey(const ValueKey('dip_name_wine')), findsNothing);
      expect(sounds, isNot(contains(UiSound.reedTouch)));

      for (final (t, tank) in config.tanks.indexed) {
        await dipTank(tester, t);
        expect(sounds, contains(UiSound.reedTouch));
        expect(find.text('What drips from the reed?'), findsOneWidget);
        expect(
          find.text('Full to ${(tank.level * 100).round()}%'),
          findsOneWidget,
        );
        if (t == 0) {
          await tester.tap(find.byKey(const ValueKey('dip_name_milk')));
          await tester.pump();
          expect(find.text('It does not drip like that.'), findsOneWidget);
        }
        await tester.tap(find.byKey(ValueKey('dip_name_${tank.liquid.name}')));
        await tester.pump();
      }
      expect(
        sounds,
        containsAll([UiSound.drip, UiSound.dripSlow]),
        reason: 'thin and thick liquids drip their own ways',
      );
      expect(find.text('wine'), findsOneWidget);
      expect(find.text('honey'), findsOneWidget);
      expect(
        find.text('Every tank is named. Were the stores running low, or full?'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('dip_low')));
      await tester.pump();
      expect(
        find.text('Look again at how high each tank stands.'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('dip_full')));
      await tester.pump(const Duration(seconds: 1));
      expect(solved[0], 1);
      await tester.pump(const Duration(seconds: 7));
    });
  });

  group('colophon', () {
    testWidgets('the seal is written as a colophon', (tester) async {
      final config =
          content.requirePuzzle('jar_label').config as DeductionConfig;
      expect(config.form, DeductionForm.colophon);
      tester.view.physicalSize = const Size(1600, 900);
      final (solved, _) = await pumpPuzzle(
        tester,
        'jar_label',
        words: config.words.toSet(),
      );
      tester.view.physicalSize = const Size(1600, 900);
      await tester.pump();
      expect(find.text('Here the book ends'), findsOneWidget);
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
