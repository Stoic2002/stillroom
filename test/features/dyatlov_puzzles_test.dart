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

/// Dyatlov Pass 1959's own puzzles: the snow pit read layer by layer and
/// its column tapped until it breaks, the last frames printed, and the
/// route book.
void main() {
  late EpisodeContent content;
  late StringTables strings;
  final widgets = builtInPuzzleWidgets();

  setUpAll(() async {
    final loader = ContentLoader(FileAssetSource(Directory.current));
    content = await loader.loadEpisode(
      'dyatlov_1959',
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
                episodeId: 'dyatlov_1959',
                sceneId: 'slope',
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

  group('snowpit', () {
    testWidgets('push to learn the layers, mark, tap until the column breaks', (
      tester,
    ) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'snowpit');
      final config = content.requirePuzzle('snowpit').config as SnowpitConfig;
      expect(tester.takeException(), isNull, reason: 'fits the phone');
      final wall = tester.getRect(find.byKey(const ValueKey('snowpit_wall')));
      final tops = <double>[];
      {
        var y = wall.top;
        // Same layout as the view: thin layers get a least height.
        const least = 30.0;
        final total = wall.height;
        final sum = config.layers.fold(0, (a, l) => a + l.thickness);
        final thin = [
          for (final l in config.layers) total * l.thickness / sum < least,
        ];
        final thickSum = [
          for (final (i, l) in config.layers.indexed)
            if (!thin[i]) l.thickness,
        ].fold(0, (a, b) => a + b);
        final rest = total - least * thin.where((t) => t).length;
        for (final (i, l) in config.layers.indexed) {
          final h = thin[i] ? least : rest * l.thickness / thickSum;
          tops.add(y + h / 2);
          y += h;
        }
      }

      Future<void> pick(int i) async {
        await tester.tapAt(Offset(wall.center.dx, tops[i]));
        await tester.pump();
      }

      Future<void> push(SnowHardness t) async {
        await tester.tap(find.byKey(ValueKey('snowpit_tool_${t.name}')));
        await tester.pump();
      }

      // Learn every layer: the largest that goes in, and the next larger.
      for (final (i, layer) in config.layers.indexed) {
        await pick(i);
        await push(layer.hardness);
        if (layer.hardness.index > 0) {
          await push(SnowHardness.values[layer.hardness.index - 1]);
        }
      }
      expect(find.textContaining('will not go in'), findsOneWidget);
      expect(sounds, contains(UiSound.snowPush));

      // The crust's soft layer below: a column there breaks higher up.
      await pick(5);
      await tester.tap(find.byKey(const ValueKey('snowpit_mark')));
      await tester.pump();
      for (var k = 0; k < config.breakTap; k++) {
        await tester.tap(find.byKey(const ValueKey('snowpit_tap')));
        await tester.pump();
      }
      expect(
        find.text('It broke on another layer, higher up. Mark that one.'),
        findsOneWidget,
      );
      expect(sounds, contains(UiSound.columnBreak));

      // The thin soft layer under the wind slab.
      await pick(config.weak);
      await tester.tap(find.byKey(const ValueKey('snowpit_mark')));
      await tester.pump();
      for (var k = 0; k < config.breakTap; k++) {
        await tester.tap(find.byKey(const ValueKey('snowpit_tap')));
        await tester.pump();
      }
      expect(sounds.last, UiSound.columnBreak);
      await tester.pump(const Duration(seconds: 1));
      expect(solved[0], 1);
    });
  });

  group('darkroom', () {
    testWidgets('a band too short spoils the paper; the right bands print', (
      tester,
    ) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'darkroom');
      final config = content.requirePuzzle('darkroom').config as DarkroomConfig;
      expect(tester.takeException(), isNull, reason: 'fits the phone');
      expect(
        find.text('Pick a frame. On its test strip, tap the band to print at.'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('darkroom_band_0')));
      await tester.pump();
      expect(
        find.text('Too short: grey and empty. The paper is spoiled.'),
        findsOneWidget,
      );
      expect(sounds.last, UiSound.mistake);
      for (final (f, frame) in config.frames.indexed) {
        await tester.tap(find.byKey(ValueKey('darkroom_frame_$f')));
        await tester.pump();
        await tester.tap(
          find.byKey(ValueKey('darkroom_band_${frame.exposure}')),
        );
        await tester.pump();
      }
      expect(find.textContaining('digging into the slope'), findsOneWidget);
      expect(sounds, contains(UiSound.enlarger));
      expect(sounds.last, UiSound.solved);
      await tester.pump(const Duration(seconds: 1));
      expect(solved[0], 1);
    });
  });

  group('routebook', () {
    testWidgets('the seal is the route book\'s last entry', (tester) async {
      final config =
          content.requirePuzzle('jar_label').config as DeductionConfig;
      expect(config.form, DeductionForm.routebook);
      final (solved, _) = await pumpPuzzle(
        tester,
        'jar_label',
        words: config.words.toSet(),
      );
      tester.view.physicalSize = const Size(1600, 900);
      await tester.pump();
      expect(find.text('Route book'), findsOneWidget);
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
