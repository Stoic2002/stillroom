import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/content/content_loader.dart';
import 'package:stillroom/content/file_asset_source.dart';
import 'package:stillroom/core/audio/ui_sound.dart';
import 'package:stillroom/engine/engine.dart';
import 'package:stillroom/features/puzzles/built_in_puzzle_widgets.dart';
import 'package:stillroom/features/puzzles/puzzle_view.dart';
import 'package:stillroom/features/puzzles/rings/rings_view.dart';
import 'package:stillroom/l10n/generated/app_localizations.dart';

/// Roanoke 1590's own puzzles: the cypress core cross-dated and its
/// driest run marked, White's chart walked with the dividers, and the
/// carved post.
void main() {
  late EpisodeContent content;
  late StringTables strings;
  final widgets = builtInPuzzleWidgets();

  setUpAll(() async {
    final loader = ContentLoader(FileAssetSource(Directory.current));
    content = await loader.loadEpisode(
      'roanoke_1590',
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
                episodeId: 'roanoke_1590',
                sceneId: 'ship',
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

  group('rings', () {
    testWidgets('slide the core until it matches, then mark the run', (
      tester,
    ) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'rings');
      final config = content.requirePuzzle('rings').config as RingsConfig;
      expect(tester.takeException(), isNull, reason: 'fits the phone');
      for (final key in ['rings_left', 'rings_right', 'rings_check']) {
        final r = tester.getRect(find.byKey(ValueKey(key)));
        expect(r.bottom, lessThanOrEqualTo(411), reason: '$key on screen');
      }
      // A check where it does not match.
      await tester.tap(find.byKey(const ValueKey('rings_check')));
      await tester.pump();
      expect(sounds.last, UiSound.mistake);
      // Drag the core along: a ring's width per step.
      final strip = tester.getRect(find.byKey(const ValueKey('rings_core')));
      final slot = strip.width / config.master.length;
      final gesture = await tester.startGesture(
        Offset(strip.left + slot * 3, strip.center.dy),
      );
      await gesture.moveBy(Offset(slot * 10, 0));
      await gesture.moveBy(Offset(slot * 5, 0));
      await gesture.up();
      await tester.pump();
      expect(sounds, contains(UiSound.coreSlide));
      // Then the arrows, to the place it fits.
      final state = tester.state(find.byType(RingsView));
      expect(state, isNotNull);
      for (var i = 0; i < 40; i++) {
        await tester.tap(find.byKey(const ValueKey('rings_left')));
      }
      await tester.pump();
      for (var i = 0; i < config.offset; i++) {
        await tester.tap(find.byKey(const ValueKey('rings_right')));
      }
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('rings_check')));
      await tester.pump();
      expect(find.byKey(const ValueKey('rings_mark')), findsOneWidget);
      // The bracket from the start of the core to the driest run.
      await tester.tap(find.byKey(const ValueKey('rings_mark')));
      await tester.pump();
      expect(sounds.last, UiSound.mistake);
      for (var i = 0; i < config.narrowest; i++) {
        await tester.tap(find.byKey(const ValueKey('rings_right')));
      }
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('rings_mark')));
      await tester.pump(const Duration(seconds: 3));
      expect(solved[0], 1);
      expect(find.text('1587–1589'), findsOneWidget);
    });
  });

  group('dividers', () {
    testWidgets('open, turn, walk and mark each place', (tester) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'dividers');
      expect(tester.takeException(), isNull, reason: 'fits the phone');
      for (final key in [
        'dividers_step',
        'dividers_back',
        'dividers_mark',
        'dividers_heading_sw',
        'dividers_span_25',
      ]) {
        final r = tester.getRect(find.byKey(ValueKey(key)));
        expect(r.bottom, lessThanOrEqualTo(411), reason: '$key on screen');
        expect(r.right, lessThanOrEqualTo(731), reason: '$key on screen');
      }
      // Stepping before the dividers are set.
      await tester.tap(find.byKey(const ValueKey('dividers_step')));
      await tester.pump();
      expect(sounds.last, UiSound.reject);
      Future<void> walk(String heading, int steps) async {
        await tester.tap(find.byKey(const ValueKey('dividers_span_10')));
        await tester.tap(find.byKey(ValueKey('dividers_heading_$heading')));
        for (var i = 0; i < steps; i++) {
          await tester.tap(find.byKey(const ValueKey('dividers_step')));
        }
        await tester.pump();
      }

      // South as if north were up: down the chart, into the sea.
      await walk('e', 5);
      await tester.tap(find.byKey(const ValueKey('dividers_mark')));
      await tester.pump();
      expect(sounds.last, UiSound.mistake);
      await walk('s', 5);
      expect(sounds, contains(UiSound.dividerStep));
      await tester.tap(find.byKey(const ValueKey('dividers_mark')));
      await tester.pump();
      expect(sounds.last, UiSound.place);
      await walk('w', 5);
      await tester.tap(find.byKey(const ValueKey('dividers_mark')));
      await tester.pump(const Duration(seconds: 3));
      expect(solved[0], 1);
    });
  });

  group('post', () {
    testWidgets('the seal is cut into the palisade post', (tester) async {
      final config =
          content.requirePuzzle('jar_label').config as DeductionConfig;
      expect(config.form, DeductionForm.post);
      final (solved, _) = await pumpPuzzle(
        tester,
        'jar_label',
        words: config.words.toSet(),
      );
      tester.view.physicalSize = const Size(1600, 900);
      await tester.pump();
      expect(find.text('The secret token'), findsOneWidget);
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
