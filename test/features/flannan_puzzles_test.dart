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

/// Flannan's own puzzles: the beam over the island, the swell at the west
/// landing, and the roster by the kitchen door.
void main() {
  late EpisodeContent content;
  late StringTables strings;
  final widgets = builtInPuzzleWidgets();
  const board = Size(1600, 900);

  setUpAll(() async {
    final loader = ContentLoader(FileAssetSource(Directory.current));
    content = await loader.loadEpisode(
      'flannan_isles_1900',
      ContentRegistries.withBuiltIns(),
    );
    strings = await loader.loadStringTables();
  });

  Future<(List<int>, List<UiSound>)> pumpPuzzle(
    WidgetTester tester,
    String puzzleId,
  ) async {
    final solved = [0];
    final sounds = <UiSound>[];
    final puzzle = content.requirePuzzle(puzzleId);
    tester.view.physicalSize = board;
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
              game: const GameState(
                episodeId: 'flannan_isles_1900',
                sceneId: 'lamp_room',
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

  /// Runs the widget's clock on to [seconds] after it started.
  Future<void> runTo(WidgetTester tester, double seconds, [double? now]) =>
      tester.pump(
        Duration(microseconds: ((seconds - (now ?? 0)) * 1e6).round()),
      );

  group('beamSweep', () {
    testWidgets('tapping each thing while lit finds it; in the dark, misses', (
      tester,
    ) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'beam');
      final config = content.requirePuzzle('beam').config as BeamSweepConfig;
      const aspect = 1600 / 900;
      expect(
        find.text('Watch the beam. Tap what it shows while it is lit.'),
        findsOneWidget,
      );
      await tester.pump();
      var now = 0.0;
      // A moment when [target] is well inside the beam, after [from].
      double litAfter(BeamTarget target, double from) {
        for (var t = from; t < from + config.period * 2; t += 0.02) {
          if (config.isLit(target, t - 0.1, aspect: aspect) &&
              config.isLit(target, t + 0.1, aspect: aspect)) {
            return t;
          }
        }
        fail('${target.id} is never lit');
      }

      Offset centre(BeamTarget t) => boardRect(t.rect, board).center;

      // In the dark: a miss.
      final first = config.targets.first;
      var dark = now;
      while (config.isLit(first, dark, aspect: aspect) ||
          config.isLit(first, dark + 0.1, aspect: aspect)) {
        dark += 0.05;
      }
      await runTo(tester, dark, now);
      now = dark;
      await tester.tapAt(centre(first));
      await tester.pump();
      expect(sounds.last, UiSound.reject);
      expect(find.text('Too dark there. Wait for the beam.'), findsOneWidget);

      for (final target in config.targets) {
        final t = litAfter(target, now);
        await runTo(tester, t, now);
        now = t;
        await tester.tapAt(centre(target));
        await tester.pump();
      }
      expect(sounds.where((s) => s == UiSound.place), hasLength(3));
      expect(sounds.last, UiSound.solved);
      await tester.pump(SolvesAfterPause.pause);
      expect(solved.single, 1);
    });
  });

  group('swell', () {
    testWidgets('caught low on the steps, the sea sends you back up', (
      tester,
    ) async {
      final (_, sounds) = await pumpPuzzle(tester, 'swell');
      final config = content.requirePuzzle('swell').config as SwellConfig;
      await tester.pump();
      // Go four steps down and stay there: the small waves fall short,
      // the first bigger one (reach 3) catches you.
      final catcher = [
        for (var i = 0; i < config.pattern.length; i++)
          if (config.reach(i) >= config.steps - 3) i,
      ].first;
      var now = 0.0;
      for (var i = 0; i < 4; i++) {
        await tester.tapAt(const Offset(800, 450));
        await runTo(tester, now + config.stepSeconds + 0.01, now);
        now += config.stepSeconds + 0.01;
      }
      expect(sounds, isNot(contains(UiSound.mistake)));
      await runTo(tester, config.breakTime(catcher) + 0.1, now);
      expect(sounds, contains(UiSound.mistake));
      expect(
        find.text('The sea drives you back up the steps.'),
        findsOneWidget,
      );
    });

    testWidgets('going down right after the great sea reaches the bottom', (
      tester,
    ) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'swell');
      final config = content.requirePuzzle('swell').config as SwellConfig;
      final great = [
        for (var i = 0; i < config.pattern.length; i++)
          if (config.isGreat(i)) i,
      ].first;
      await tester.pump();
      // Wait at the top for the great sea: its roar comes first.
      var now = config.breakTime(great) - 1.0;
      await runTo(tester, now);
      expect(sounds, contains(UiSound.greatSea));
      final after = config.breakTime(great) + 0.05;
      await runTo(tester, after, now);
      now = after;
      for (var i = 0; i < config.steps; i++) {
        await tester.tapAt(const Offset(800, 450));
        await runTo(tester, now + config.stepSeconds + 0.01, now);
        now += config.stepSeconds + 0.01;
      }
      expect(sounds, contains(UiSound.solved));
      expect(sounds, isNot(contains(UiSound.mistake)));
      await tester.pump(SolvesAfterPause.pause);
      expect(solved.single, 1);
    });
  });

  group('roster', () {
    testWidgets('a full board says how many rows are wrong; right, it solves', (
      tester,
    ) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'roster');
      final config = content.requirePuzzle('roster').config as RosterConfig;
      expect(find.text('Tap a box to change it.'), findsOneWidget);
      expect(find.text('James Ducat'), findsOneWidget);

      /// Taps the cell until it shows [option].
      Future<void> cycleTo(String row, String column, String option) async {
        final options = config.columns
            .firstWhere((c) => c.id == column)
            .options;
        final label =
            strings['en']![options.firstWhere((o) => o.id == option).labelKey]!;
        final cell = find.byKey(ValueKey('roster_${row}_$column'));
        for (var i = 0; i <= options.length; i++) {
          if (find
              .descendant(of: cell, matching: find.text(label))
              .evaluate()
              .isNotEmpty) {
            return;
          }
          await tester.tap(cell);
          await tester.pump();
        }
        fail('$row/$column never shows $option');
      }

      // Everyone set to the first option: posts right for Ducat only.
      for (final row in config.rows) {
        for (final column in config.columns) {
          await tester.tap(
            find.byKey(ValueKey('roster_${row.id}_${column.id}')),
          );
          await tester.pump();
        }
      }
      expect(sounds.last, UiSound.mistake);
      expect(find.textContaining('rows do not fit'), findsOneWidget);
      expect(solved.single, 0);

      // Now fill it in right, from what was found.
      for (final row in config.rows) {
        for (final column in config.columns) {
          await cycleTo(
            row.id,
            column.id,
            config.solution[row.id]![column.id]!,
          );
        }
      }
      expect(sounds.last, UiSound.solved);
      await tester.pump(SolvesAfterPause.pause);
      expect(solved.single, 1);
    });
  });
}
