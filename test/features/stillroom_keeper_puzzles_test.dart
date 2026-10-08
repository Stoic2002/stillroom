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

/// The keeper's own puzzles: the receipt book's hands, the still, the
/// portrait under the conservator's lamp, and the receipt that seals it.
void main() {
  late EpisodeContent content;
  late StringTables strings;
  final widgets = builtInPuzzleWidgets();

  setUpAll(() async {
    final loader = ContentLoader(FileAssetSource(Directory.current));
    content = await loader.loadEpisode(
      'stillroom_keeper',
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
                episodeId: 'stillroom_keeper',
                sceneId: 'stillroom',
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

  group('hands', () {
    testWidgets('pick a receipt, then the hand; check sends wrong ones back', (
      tester,
    ) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'hands');
      expect(tester.takeException(), isNull, reason: 'fits the phone');
      final config = content.requirePuzzle('hands').config as HandsConfig;
      Future<void> sort(int receipt, int hand) async {
        await tester.tap(find.byKey(ValueKey('hands_receipt_$receipt')));
        await tester.tap(find.byKey(ValueKey('hands_hand_$hand')));
        await tester.pump();
      }

      // One put wrong, the rest right: checking sends the wrong one back.
      for (final (i, r) in config.receipts.indexed) {
        await sort(i, i == 0 ? (r.hand + 1) % config.hands.length : r.hand);
      }
      await tester.tap(find.byKey(const ValueKey('hands_check')));
      await tester.pump();
      expect(sounds.last, UiSound.mistake);
      expect(find.textContaining('came back'), findsOneWidget);
      await sort(0, config.receipts[0].hand);
      await tester.tap(find.byKey(const ValueKey('hands_check')));
      await tester.pump(const Duration(seconds: 1));
      expect(solved.single, 1);
    });
  });

  group('still', () {
    testWidgets('no water with the fire lit spoils the run', (tester) async {
      await pumpPuzzle(tester, 'still');
      expect(tester.takeException(), isNull, reason: 'fits the phone');
      await tester.tap(find.byKey(const ValueKey('still_fire_1')));
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.byKey(const ValueKey('still_reset')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('still_reset')));
      await tester.pump();
      expect(find.byKey(const ValueKey('still_reset')), findsNothing);
    });

    testWidgets('a gentle run, the glass moved at the cuts, keeps the heart', (
      tester,
    ) async {
      final (solved, _) = await pumpPuzzle(tester, 'still');
      final config = content.requirePuzzle('still').config as StillConfig;
      await tester.tap(find.byKey(const ValueKey('still_water_true')));
      await tester.tap(find.byKey(const ValueKey('still_fire_1')));
      await tester.pump();
      // At a gentle fire the cuts come at known times.
      final rate = config.rates[1];
      var t = 0.0;
      var moved = 0;
      while (solved.single == 0 && t < 30) {
        await tester.pump(const Duration(milliseconds: 50));
        t += 0.05;
        if (moved == 0 && t * rate >= config.heads + 0.1) {
          await tester.tap(find.byKey(const ValueKey('still_glass_heart')));
          moved = 1;
        } else if (moved == 1 &&
            t * rate >= config.heads + config.heart + 0.1) {
          await tester.tap(find.byKey(const ValueKey('still_glass_tails')));
          moved = 2;
        }
      }
      await tester.pump(const Duration(seconds: 1));
      expect(solved.single, 1);
    });
  });

  group('spectrum', () {
    testWidgets('record each band, then lay them oldest first', (tester) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'spectrum');
      expect(tester.takeException(), isNull, reason: 'fits the phone');
      final config = content.requirePuzzle('spectrum').config as SpectrumConfig;
      final dial = find.byKey(const ValueKey('spectrum_dial'));
      Future<void> tune(double at) async {
        final box = tester.getRect(dial);
        // The slider's track runs inside its horizontal padding.
        const inset = 24.0;
        await tester.tapAt(
          Offset(
            box.left + inset + (box.width - inset * 2) * at,
            box.center.dy,
          ),
        );
        await tester.pump();
      }

      await tune(0.25);
      await tester.tap(find.byKey(const ValueKey('spectrum_record')));
      await tester.pump();
      expect(find.text('Nothing clear at this setting.'), findsOneWidget);
      for (final band in config.bands) {
        await tune(band.at);
        await tester.tap(find.byKey(const ValueKey('spectrum_record')));
        await tester.pump();
      }
      expect(sounds.where((s) => s == UiSound.layerFound), hasLength(4));
      // The plates in the order of the painting's life.
      final byAge = [
        for (var age = 0; age < config.bands.length; age++)
          config.bands.indexWhere((b) => b.age == age),
      ];
      for (final i in byAge) {
        await tester.tap(find.byKey(ValueKey('spectrum_plate_$i')));
        await tester.pump();
      }
      await tester.pump(const Duration(seconds: 1));
      expect(solved.single, 1);
    });
  });

  group('receipt', () {
    testWidgets('the seal is a page of her receipt book', (tester) async {
      await pumpPuzzle(
        tester,
        'jar_label',
        words: {'hester_croft', 'stillroom', 'her_own', 'witch', 'the_girl'},
      );
      expect(tester.takeException(), isNull, reason: 'fits the phone');
      final config =
          content.requirePuzzle('jar_label').config as DeductionConfig;
      expect(config.form, DeductionForm.receipt);
      expect(find.text('To keep a name'), findsOneWidget);
    });
  });
}
