import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/app.dart';
import 'package:stillroom/content/flutter_asset_source.dart';
import 'package:stillroom/core/audio/audio_service.dart';
import 'package:stillroom/core/storage/key_value_store.dart';
import 'package:stillroom/engine/engine.dart';
import 'package:stillroom/state/content_providers.dart';
import 'package:stillroom/state/save_repository.dart';
import 'package:stillroom/state/services_providers.dart';
import 'package:stillroom/state/settings_controller.dart';
import 'package:stillroom/state/storage_providers.dart';

Future<MemoryKeyValueStore> pumpApp(
  WidgetTester tester, {
  Map<String, String>? stored,
  Locale locale = const Locale('en'),
  AudioService audio = const SilentAudioService(),
}) async {
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  // Reduced motion stills the living lobby, so the tree can settle.
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  final store = MemoryKeyValueStore(stored);
  // Start from a clean tree, so a second call in one test starts fresh.
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        keyValueStoreProvider.overrideWithValue(store),
        audioServiceProvider.overrideWithValue(audio),
        // A fresh bundle per test: rootBundle caches futures, and a future
        // from an earlier test's fake-async zone never completes here.
        assetSourceProvider.overrideWithValue(
          FlutterAssetSource(PlatformAssetBundle()),
        ),
      ],
      child: const StillroomApp(),
    ),
  );
  await tester.pumpAndSettle();
  return store;
}

String saveWith(GameState state) => const SaveSerializer().encode(
  SaveFile(lastEpisodeId: state.episodeId, episodes: {state.episodeId: state}),
);

TextButton button(WidgetTester tester, String label) =>
    tester.widget<TextButton>(find.widgetWithText(TextButton, label));

final class _MusicLog implements AudioService {
  final calls = <String>[];

  @override
  Future<void> playSfx(String assetPath, {required double volume}) async {}

  @override
  Future<void> playMusic(String assetPath, {required double volume}) async =>
      calls.add('play $assetPath');

  @override
  Future<void> setMusicVolume(double volume) async {}

  @override
  Future<void> stopMusic({String? ifPlaying}) async =>
      calls.add('stop $ifPlaying');
}

void main() {
  testWidgets('the menu and the shelf play the Stillroom music', (
    tester,
  ) async {
    final audio = _MusicLog();
    await pumpApp(tester, audio: audio);
    expect(audio.calls, ['play assets/audio/music/stillroom_menu.ogg']);

    await tester.tap(find.text('New Game'));
    await tester.pumpAndSettle();
    expect(find.text('The shelf'), findsOneWidget);
    // The shelf asks too; the service keeps the same music going.
    expect(audio.calls, [
      'play assets/audio/music/stillroom_menu.ogg',
      'play assets/audio/music/stillroom_menu.ogg',
    ]);
  });

  testWidgets('menu in English; Continue is off without a save', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Stillroom'), findsOneWidget);
    expect(button(tester, 'Continue').onPressed, isNull);
    expect(button(tester, 'New Game').onPressed, isNotNull);
    expect(button(tester, 'Settings').onPressed, isNotNull);
  });

  testWidgets('menu follows an Indonesian device', (tester) async {
    await pumpApp(tester, locale: const Locale('id'));
    expect(find.text('Lanjutkan'), findsOneWidget);
    expect(find.text('Mulai Baru'), findsOneWidget);
    expect(find.text('Pengaturan'), findsOneWidget);
  });

  testWidgets('Continue is on for an unfinished save, off once completed', (
    tester,
  ) async {
    const state = GameState(episodeId: 'test_room', sceneId: 'desk');
    await pumpApp(tester, stored: {SaveRepository.storageKey: saveWith(state)});
    expect(button(tester, 'Continue').onPressed, isNotNull);

    await pumpApp(
      tester,
      stored: {
        SaveRepository.storageKey: saveWith(state.copyWith(completed: true)),
      },
    );
    expect(button(tester, 'Continue').onPressed, isNull);
  });

  group('the shelf', () {
    testWidgets('New Game opens the shelf of jars', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('New Game'));
      await tester.pumpAndSettle();
      expect(find.text('The shelf'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('jar_whitechapel_1888')),
        findsOneWidget,
      );
      expect(find.text('Whitechapel, 1888'), findsOneWidget);
      // Sealed jars are shown but not playable; the test room is debug-only.
      expect(find.text('Still sealed'), findsOneWidget);
      expect(find.byKey(const ValueKey('jar_test_room')), findsOneWidget);
    });

    testWidgets('Semarang, 1945 opens once Whitechapel is distilled', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.text('New Game'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('jar_lawang_sewu_1945')));
      await tester.pumpAndSettle();
      expect(find.text('Not yet'), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      await pumpApp(
        tester,
        stored: {
          SaveRepository.storageKey: saveWith(
            const GameState(
              episodeId: 'whitechapel_1888',
              sceneId: 'room_south',
              completed: true,
            ),
          ),
        },
      );
      await tester.tap(find.text('New Game'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('jar_lawang_sewu_1945')));
      await tester.pumpAndSettle();
      expect(find.text('Open the jar'), findsOneWidget);
    });

    testWidgets('Flannan Isles, 1900 opens once both tales below are done', (
      tester,
    ) async {
      final save = const SaveSerializer().encode(
        const SaveFile(distilled: {'whitechapel_1888', 'lawang_sewu_1945'}),
      );
      await pumpApp(tester, stored: {SaveRepository.storageKey: save});
      await tester.tap(find.text('New Game'));
      await tester.pumpAndSettle();
      final jar = find.byKey(const ValueKey('jar_flannan_isles_1900'));
      await tester.scrollUntilVisible(
        jar,
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(jar);
      await tester.pumpAndSettle();
      expect(find.text('Flannan Isles, 1900'), findsWidgets);
      expect(find.text('Open the jar'), findsOneWidget);
    });

    testWidgets('a sealed jar does nothing', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('New Game'));
      await tester.pumpAndSettle();
      final sealed = find.byKey(const ValueKey('jar_sealed_whitechapel_1891'));
      await tester.scrollUntilVisible(
        sealed,
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(sealed);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('an unfinished tale offers continue or start over', (
      tester,
    ) async {
      const state = GameState(episodeId: 'whitechapel_1888', sceneId: 'desk');
      final store = await pumpApp(
        tester,
        stored: {SaveRepository.storageKey: saveWith(state)},
      );
      await tester.tap(find.text('New Game'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('jar_whitechapel_1888')));
      await tester.pumpAndSettle();
      expect(find.text('You left this tale unfinished.'), findsOneWidget);
      expect(find.text('Start over'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Continue'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(store.values[SaveRepository.storageKey], saveWith(state));
    });

    testWidgets('a fresh jar shows its teaser and an open button', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.text('New Game'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('jar_whitechapel_1888')));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'A rented room, a stopped clock, and five names the fog has kept.',
        ),
        findsOneWidget,
      );
      expect(find.text('Open the jar'), findsOneWidget);
    });

    testWidgets('a finished tale carries a seal', (tester) async {
      await pumpApp(
        tester,
        stored: {
          SaveRepository.storageKey: saveWith(
            const GameState(
              episodeId: 'whitechapel_1888',
              sceneId: 'room_south',
              completed: true,
            ),
          ),
        },
      );
      await tester.tap(find.text('New Game'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.water_drop), findsOneWidget);
    });
  });

  testWidgets('a damaged save is reported and does not crash', (tester) async {
    await pumpApp(tester, stored: {SaveRepository.storageKey: '{broken'});
    expect(find.text("Saved game can't be read"), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(button(tester, 'Continue').onPressed, isNull);
  });

  group('settings', () {
    Future<MemoryKeyValueStore> openSettings(
      WidgetTester tester, {
      Map<String, String>? stored,
    }) async {
      final store = await pumpApp(tester, stored: stored);
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      return store;
    }

    testWidgets('switching language applies immediately and is saved', (
      tester,
    ) async {
      final store = await openSettings(tester);
      await tester.tap(find.text('Bahasa Indonesia'));
      await tester.pumpAndSettle();
      expect(find.text('Volume musik'), findsOneWidget);
      expect(
        jsonDecode(store.values[SettingsController.storageKey]!),
        containsPair('languageCode', 'id'),
      );

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Mulai Baru'), findsOneWidget);
    });

    for (final (chip, newGame) in [
      ('日本語', 'はじめから'),
      ('简体中文', '新游戏'),
      ('Русский', 'Новая игра'),
      ('Español', 'Nueva partida'),
    ]) {
      testWidgets('switching to $chip translates the menu', (tester) async {
        final store = await openSettings(tester);
        await tester.tap(find.text(chip));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(find.text(newGame), findsOneWidget);
        expect(store.values[SettingsController.storageKey], isNotNull);
      });
    }

    testWidgets('vibration switch is saved', (tester) async {
      final store = await openSettings(tester);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(
        jsonDecode(store.values[SettingsController.storageKey]!),
        containsPair('vibration', false),
      );
    });

    testWidgets('reset progress asks, then clears the save only', (
      tester,
    ) async {
      final store = await openSettings(
        tester,
        stored: {
          SaveRepository.storageKey: saveWith(
            const GameState(episodeId: 'test_room', sceneId: 'desk'),
          ),
          SettingsController.storageKey: '{"vibration": false}',
        },
      );
      await tester.tap(find.text('Reset progress'));
      await tester.pumpAndSettle();
      expect(find.text('Reset all progress?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Reset'));
      await tester.pumpAndSettle();

      expect(store.values.containsKey(SaveRepository.storageKey), isFalse);
      expect(
        store.values[SettingsController.storageKey],
        '{"vibration": false}',
      );
      expect(find.text('Progress has been reset.'), findsOneWidget);
    });
  });
}
