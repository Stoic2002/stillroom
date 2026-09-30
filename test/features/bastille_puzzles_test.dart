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

/// The Bastille's own puzzles: the turnkey's keys, the Great Cipher, the
/// prisoner's file, and the seal written as a royal order.
void main() {
  late EpisodeContent content;
  late StringTables strings;
  final widgets = builtInPuzzleWidgets();

  setUpAll(() async {
    final loader = ContentLoader(FileAssetSource(Directory.current));
    content = await loader.loadEpisode(
      'bastille_1703',
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
                episodeId: 'bastille_1703',
                sceneId: 'tower_stair',
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

  group('keyring', () {
    testWidgets('a key that does not fit will not turn; turned over, it does', (
      tester,
    ) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'door_upper');
      final config =
          content.requirePuzzle('door_upper').config as KeyringConfig;
      final third = config.keys[2].id;
      expect(find.text('Take a key off the ring.'), findsOneWidget);
      // The lock does nothing with no key in hand.
      await tester.tap(find.byKey(const ValueKey('keyring_lock')));
      await tester.pump();
      expect(sounds, isEmpty);

      await tester.tap(find.byKey(ValueKey('keyring_key_$third')));
      await tester.pump();
      expect(
        find.text('Tap the key to turn it over; tap the lock to try it.'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('keyring_lock')));
      await tester.pump();
      expect(sounds.last, UiSound.keyTry);
      expect(find.text('It will not turn.'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('keyring_hand')));
      await tester.pump();
      expect(sounds.last, UiSound.turn);
      await tester.tap(find.byKey(const ValueKey('keyring_lock')));
      await tester.pump();
      expect(sounds.last, UiSound.solved);
      await tester.pump(const Duration(seconds: 2));
      expect(solved[0], 1);
    });
  });

  group('cipher', () {
    testWidgets('matching numbers reads every group; 330 309 stay unread', (
      tester,
    ) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'cipher');
      final config = content.requirePuzzle('cipher').config as CipherConfig;
      expect(
        find.text(
          'Tap a number in the letter, then the same number on the worksheet.',
        ),
        findsOneWidget,
      );
      // A number on no worksheet cannot be picked.
      final unread = config.groups.indexOf('330');
      await tester.tap(find.byKey(ValueKey('cipher_group_$unread')));
      await tester.pump();
      expect(sounds.last, UiSound.reject);

      // A wrong syllable is a slip.
      await tester.tap(find.byKey(const ValueKey('cipher_group_0')));
      await tester.pump();
      await tester.ensureVisible(find.byKey(const ValueKey('cipher_key_22')));
      await tester.tap(find.byKey(const ValueKey('cipher_key_22')));
      await tester.pump();
      expect(sounds.last, UiSound.mistake);

      for (var i = 0; i < config.groups.length; i++) {
        final code = config.groups[i];
        if (!config.key.containsKey(code)) continue;
        final group = find.byKey(ValueKey('cipher_group_$i'));
        // Groups read by an earlier match are already written.
        if (find
            .descendant(of: group, matching: find.text(config.key[code]!))
            .evaluate()
            .isNotEmpty) {
          continue;
        }
        await tester.ensureVisible(group);
        await tester.tap(group);
        await tester.pump();
        final entry = find.byKey(ValueKey('cipher_key_$code'));
        await tester.ensureVisible(entry);
        await tester.tap(entry);
        await tester.pump();
      }
      expect(sounds.last, UiSound.solved);
      expect(find.text('Bu'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      expect(solved[0], 1);
    });
  });

  group('sources', () {
    testWidgets('a wrong tray is counted; sorted right, the file closes', (
      tester,
    ) async {
      final (solved, sounds) = await pumpPuzzle(tester, 'file');
      final config = content.requirePuzzle('file').config as SourcesConfig;
      expect(find.text('Tap a paper, then the tray it belongs in.'), findsOne);

      Future<void> put(String card, String tray) async {
        final paper = find.byKey(ValueKey('sources_card_$card'));
        await tester.ensureVisible(paper);
        await tester.tap(paper);
        await tester.pump();
        await tester.tap(find.byKey(ValueKey('sources_tray_$tray')));
        await tester.pump();
      }

      // Everything in its tray but Voltaire, who is put with the letters.
      for (final c in config.cards) {
        await put(c.id, c.id == 'voltaire' ? 'time' : c.tray);
      }
      expect(sounds.last, UiSound.mistake);
      expect(find.text('One paper is in the wrong tray.'), findsOneWidget);

      // Take Voltaire back out, and put him with what was told after.
      await tester.tap(find.byKey(const ValueKey('sources_placed_voltaire')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('sources_tray_after')));
      await tester.pump();
      expect(sounds.last, UiSound.solved);
      await tester.pump(const Duration(seconds: 2));
      expect(solved[0], 1);
    });
  });

  group('order', () {
    testWidgets('the seal is a royal order with one sentence', (tester) async {
      final config =
          content.requirePuzzle('jar_label').config as DeductionConfig;
      final (solved, _) = await pumpPuzzle(
        tester,
        'jar_label',
        words: config.words.toSet(),
      );
      expect(find.text('De par le Roy'), findsOneWidget);
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
