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

void main() {
  late EpisodeContent content;
  final widgets = builtInPuzzleWidgets();

  // Loaded outside the widget tests' fake async zone (real file IO).
  setUpAll(() async {
    content = await ContentLoader(
      FileAssetSource(Directory.current),
    ).loadEpisode('test_room', ContentRegistries.withBuiltIns());
  });

  /// Pumps the widget for [puzzleId] on a 16:9 board; returns a counter of
  /// onSolved calls.
  Future<List<int>> pumpPuzzle(
    WidgetTester tester,
    String puzzleId, {
    List<String> inventory = const [],
    List<UiSound>? sounds,
  }) async {
    final solved = [0];
    final puzzle = content.requirePuzzle(puzzleId);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Center(
          child: SizedBox(
            width: 800,
            height: 450,
            child: widgets[puzzle.type]!(
              PuzzleViewContext(
                puzzle: puzzle,
                content: content,
                game: GameState(
                  episodeId: 'test_room',
                  sceneId: 'room_north',
                  inventory: inventory,
                ),
                assets: const {},
                onSolved: () => solved[0]++,
                feedback: (sound) => sounds?.add(sound),
              ),
            ),
          ),
        ),
      ),
    );
    return solved;
  }

  Future<void> expectSolvedAfterPause(
    WidgetTester tester,
    List<int> solved,
  ) async {
    await tester.pump(const Duration(milliseconds: 100));
    expect(solved.single, 0, reason: 'waits before reporting');
    await tester.pump(SolvesAfterPause.pause);
    expect(solved.single, 1);
  }

  testWidgets('codeLock: dial the code 3141', (tester) async {
    final solved = await pumpPuzzle(tester, 'drawer_lock');
    final next = find.byTooltip('Next symbol');
    expect(next, findsNWidgets(4));
    for (final (dial, times) in [(0, 3), (1, 1), (2, 4), (3, 1)]) {
      for (var i = 0; i < times; i++) {
        await tester.tap(next.at(dial));
      }
    }
    await tester.pump();
    expect(
      [
        for (var i = 0; i < 4; i++)
          tester.widget<Text>(find.byKey(ValueKey('dial_$i'))).data,
      ],
      ['3', '1', '4', '1'],
    );
    await expectSolvedAfterPause(tester, solved);

    // Input is ignored once solved.
    await tester.tap(next.first);
    await tester.pump(SolvesAfterPause.pause);
    expect(solved.single, 1);
  });

  testWidgets('moves answer with interface sounds', (tester) async {
    final sounds = <UiSound>[];
    await pumpPuzzle(tester, 'drawer_lock', sounds: sounds);
    await tester.tap(find.byTooltip('Next symbol').first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(sounds, [UiSound.dial]);

    sounds.clear();
    await pumpPuzzle(tester, 'window_panes', sounds: sounds);
    await tester.tap(find.byKey(const ValueKey('element_pane_1')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(sounds, [UiSound.mistake]);
  });

  testWidgets('codeLock: previous wraps to the last symbol', (tester) async {
    await pumpPuzzle(tester, 'drawer_lock');
    await tester.tap(find.byTooltip('Previous symbol').first);
    await tester.pump();
    expect(tester.widget<Text>(find.byKey(const ValueKey('dial_0'))).data, '9');
  });

  testWidgets('sequence: wrong order does not solve, right order does', (
    tester,
  ) async {
    final solved = await pumpPuzzle(tester, 'window_panes');
    Future<void> tap(String id) =>
        tester.tap(find.byKey(ValueKey('element_$id')));

    await tap('pane_1'); // wrong first step
    await tester.pump(SolvesAfterPause.pause * 2);
    expect(solved.single, 0);

    for (final id in ['pane_2', 'pane_4', 'pane_1', 'pane_3']) {
      await tap(id);
    }
    await expectSolvedAfterPause(tester, solved);
  });

  testWidgets('rotaryAlign: turning each ring to its target solves', (
    tester,
  ) async {
    final solved = await pumpPuzzle(tester, 'wall_rings');
    // Board 800×450 → rings span 405 px; 3 rings of 405/2/3.6 px each.
    final center = tester.getCenter(find.byKey(const ValueKey('ring_outer')));
    const ringWidth = 405 / 2 / 3.6;
    Future<void> tapRing(int ring, int times) async {
      final distance = 405 / 2 - ringWidth * (ring + 0.5);
      for (var i = 0; i < times; i++) {
        await tester.tapAt(center - Offset(0, distance));
        await tester.pump(const Duration(milliseconds: 250));
      }
    }

    await tapRing(0, 6); // outer 2 → 0, dragging middle 5 → 3
    await tapRing(1, 5); // middle 3 → 0
    await tapRing(2, 1);
    expect(solved.single, 0);
    await tapRing(2, 1); // inner 4 → 0
    await expectSolvedAfterPause(tester, solved);
  });

  testWidgets('slotPlacement: place every emblem, gem from inventory', (
    tester,
  ) async {
    final solved = await pumpPuzzle(tester, 'door_emblems', inventory: ['gem']);
    Future<void> place(String piece, String slot) async {
      await tester.tap(find.byKey(ValueKey('piece_$piece')));
      await tester.pump();
      await tester.tap(find.byKey(ValueKey('slot_$slot')));
      await tester.pump();
    }

    await place('sun', 'top');
    await place('moon', 'left');
    await place('star', 'right');
    expect(solved.single, 0);
    await place('gem', 'bottom');
    await expectSolvedAfterPause(tester, solved);
  });

  testWidgets('slotPlacement: the gem piece needs the gem item', (
    tester,
  ) async {
    await pumpPuzzle(tester, 'door_emblems');
    expect(find.byKey(const ValueKey('piece_gem')), findsNothing);
    expect(find.byKey(const ValueKey('piece_sun')), findsOneWidget);
  });
}
