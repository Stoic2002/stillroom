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

  group('clock hands', () {
    testWidgets('dragging the hands to 3:40 opens the drawer', (tester) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'desk_drawer');
      expect(find.text('Drag the hands round the dial.'), findsOneWidget);
      final dial = tester.getRect(find.byKey(const ValueKey('clock_hands')));
      final c = dial.center;
      final r = dial.shortestSide * 0.3;
      Offset at(double turn) =>
          c +
          Offset(math.sin(turn * 2 * math.pi), -math.cos(turn * 2 * math.pi)) *
              r;

      // The minute hand starts at twelve: grab it there, swing it to VIII.
      final minute = await tester.startGesture(at(0.01));
      for (var t = 0.02; t <= 40 / 60; t += 0.02) {
        await minute.moveTo(at(t));
      }
      await minute.moveTo(at(40 / 60));
      await minute.up();
      // The hour hand also starts at twelve, now alone there: grab it and
      // bring it round to III.
      final hour = await tester.startGesture(at(0.99));
      for (var t = 0.0; t <= 0.25; t += 0.02) {
        await hour.moveTo(at(t));
      }
      await hour.moveTo(at(0.25));
      await hour.up();
      await tester.pump(const Duration(milliseconds: 100));
      expect(sounds, contains(UiSound.dial));
      expect(sounds.last, UiSound.solved);
      await tester.pump(SolvesAfterPause.pause);
      expect(solved.single, 1);
    });
  });

  group('thread', () {
    testWidgets('a wrong pin snaps the thread; the right order solves it', (
      tester,
    ) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'street_thread');
      final config =
          content.requirePuzzle('street_thread').config as ThreadConfig;
      final board = tester.getRect(find.byKey(const ValueKey('thread')));
      Offset pin(String id) {
        final p = config.pin(id);
        return board.topLeft + Offset(p.x * board.width, p.y * board.height);
      }

      await tester.tapAt(pin('bucks_row'));
      await tester.tapAt(pin('mitre_square'));
      await tester.pump();
      expect(sounds.last, UiSound.mistake);

      // Drag the thread through every pin, oldest first.
      final drag = await tester.startGesture(pin(config.solution.first));
      for (final id in config.solution.skip(1)) {
        await drag.moveTo(pin(id));
      }
      await drag.up();
      await tester.pump(const Duration(milliseconds: 100));
      expect(sounds.last, UiSound.solved);
      await tester.pump(SolvesAfterPause.pause);
      expect(solved.single, 1);
    });
  });

  group('label forms', () {
    testWidgets('a ledger: a heading per row, a blank per column', (
      tester,
    ) async {
      await pumpPuzzle(tester, 'jar_label', words: {'nichols', 'bucks_row'});
      expect(find.text('Her name'), findsOneWidget);
      expect(find.text('Where she was found'), findsOneWidget);
      expect(find.text('31 August 1888'), findsOneWidget);
      expect(find.byKey(const ValueKey('blank_9')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('word_nichols')));
      await tester.pump();
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('blank_0')),
          matching: find.text('Mary Ann Nichols'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a correction starts written, wrong in places', (tester) async {
      final flannan = await tester.runAsync(
        () => ContentLoader(
          FileAssetSource(Directory.current),
        ).loadEpisode('flannan_isles_1900', ContentRegistries.withBuiltIns()),
      );
      content = flannan!;
      final (_, sounds) = await pumpPuzzle(
        tester,
        'jar_label',
        words: {'date_15dec'},
      );
      expect(find.text('13 December'), findsOneWidget);
      await tester.tap(find.text('Distil'));
      await tester.pump();
      expect(sounds.last, UiSound.mistake, reason: 'written, but wrong');
      await tester.tap(find.byKey(const ValueKey('blank_0')));
      await tester.tap(find.byKey(const ValueKey('word_date_15dec')));
      await tester.pump();
      expect(find.text('13 December'), findsNothing);
    });

    testWidgets('a telegram and a board show their sentences', (tester) async {
      final loader = ContentLoader(FileAssetSource(Directory.current));
      content = (await tester.runAsync(
        () => loader.loadEpisode(
          'lawang_sewu_1945',
          ContentRegistries.withBuiltIns(),
        ),
      ))!;
      await pumpPuzzle(tester, 'jar_label');
      expect(find.text('TELEGRAM'), findsOneWidget);
      expect(find.byKey(const ValueKey('blank_0')), findsOneWidget);

      content = (await tester.runAsync(
        () =>
            loader.loadEpisode('pompeii_79', ContentRegistries.withBuiltIns()),
      ))!;
      await tester.pumpWidget(const SizedBox());
      await pumpPuzzle(tester, 'jar_label');
      expect(find.byKey(const ValueKey('blank_2')), findsOneWidget);
      expect(tester.takeException(), isNull);
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

  group('overlay', () {
    testWidgets('turning and laying the tracings together solves it', (
      tester,
    ) async {
      final pompeii = await tester.runAsync(
        () => ContentLoader(
          FileAssetSource(Directory.current),
        ).loadEpisode('pompeii_79', ContentRegistries.withBuiltIns()),
      );
      content = pompeii!;
      final (solved, sounds) = await pumpPuzzle(tester, 'tracings');
      expect(find.text('Drag the pieces. Tap one to turn it.'), findsOneWidget);
      final config = content.requirePuzzle('tracings').config as OverlayConfig;
      final board = tester.getRect(find.byType(Scaffold));

      // A corner no other sheet covers at the start (top right).
      Offset corner(String id) =>
          tester.getTopRight(find.byKey(ValueKey('sheet_$id'))) +
          const Offset(-30, 30);

      Future<void> turn(String id, int times) async {
        for (var i = 0; i < times; i++) {
          await tester.tapAt(corner(id));
          await tester.pump(const Duration(milliseconds: 300));
        }
      }

      Future<void> layDown(String id) async {
        final sheet = config.sheets.firstWhere((s) => s.id == id);
        final at = tester.getTopLeft(find.byKey(ValueKey('sheet_$id')));
        final target = Offset(
          board.left + sheet.rect.x * board.width,
          board.top + sheet.rect.y * board.height,
        );
        await tester.dragFrom(corner(id), target - at);
        await tester.pump(const Duration(milliseconds: 300));
      }

      // Words first: a turned sheet comes to the top.
      await turn('words', 1);
      await turn('people', 3);
      await turn('gate', 2);
      expect(sounds.where((s) => s == UiSound.turn), hasLength(6));
      // Topmost first, so each drag grabs the sheet it means to.
      for (final id in ['gate', 'people', 'words', 'boat']) {
        await layDown(id);
      }
      expect(sounds.where((s) => s == UiSound.place), hasLength(4));
      expect(sounds.last, UiSound.solved);
      await tester.pump(SolvesAfterPause.pause);
      expect(solved.single, 1);
    });
  });
}
