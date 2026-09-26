import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/content/content_loader.dart';
import 'package:stillroom/content/file_asset_source.dart';
import 'package:stillroom/core/audio/audio_service.dart';
import 'package:stillroom/core/storage/key_value_store.dart';
import 'package:stillroom/engine/engine.dart';
import 'package:stillroom/features/game/widgets/game_effects.dart';
import 'package:stillroom/features/game/widgets/hint_button.dart';
import 'package:stillroom/l10n/generated/app_localizations.dart';
import 'package:stillroom/state/content_providers.dart';
import 'package:stillroom/state/game_session.dart';
import 'package:stillroom/state/services_providers.dart';
import 'package:stillroom/state/settings_controller.dart';
import 'package:stillroom/state/storage_providers.dart';

const _episode = 'test_room';

final class _FakeAudio implements AudioService {
  final calls = <String>[];

  @override
  Future<void> playSfx(String assetPath, {required double volume}) async =>
      calls.add('sfx $assetPath @$volume');

  @override
  Future<void> playMusic(String assetPath, {required double volume}) async =>
      calls.add('music $assetPath @$volume');

  @override
  Future<void> setMusicVolume(double volume) async =>
      calls.add('volume $volume');

  @override
  Future<void> stopMusic({String? ifPlaying}) async => calls.add('stop');
}

void main() {
  late LoadedEpisode loaded;
  late ProviderContainer container;
  late _FakeAudio audio;
  late List<(int, double)> shakes;

  // Pretend these audio files exist; the rest stay silent placeholders.
  const audioFiles = {
    'assets/audio/music/test_room_ambience.ogg',
    'assets/audio/music/test_room_desk.mp3',
    'assets/audio/sfx/switch_click.ogg',
  };

  setUpAll(() async {
    final loader = ContentLoader(FileAssetSource(Directory.current));
    loaded = LoadedEpisode(
      content: await loader.loadEpisode(
        _episode,
        ContentRegistries.withBuiltIns(),
      ),
      assets: {...await loader.source.listAssets(), ...audioFiles}
        // Stands in for a sound with no file yet.
        ..remove('assets/audio/sfx/drawer_open.ogg'),
      strings: await loader.loadStringTables(),
    );
  });

  GameSession notifier() =>
      container.read(gameSessionProvider(_episode).notifier);

  Future<void> pump(WidgetTester tester, {Map<String, String>? stored}) async {
    audio = _FakeAudio();
    shakes = [];
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        loadedEpisodeProvider(_episode).overrideWith((ref) async => loaded),
        keyValueStoreProvider.overrideWithValue(MemoryKeyValueStore(stored)),
        audioServiceProvider.overrideWithValue(audio),
      ],
    );
    addTearDown(container.dispose);
    container.listen(gameSessionProvider(_episode), (_, _) {});
    await container.read(gameSessionProvider(_episode).future);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Stack(
              children: [
                GameEffects(
                  episodeId: _episode,
                  onShake: (ms, strength) => shakes.add((ms, strength)),
                ),
                const HintButton(episodeId: _episode),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('GameEffects', () {
    testWidgets('music follows the scene; missing files stay silent', (
      tester,
    ) async {
      await pump(tester);
      expect(audio.calls, [
        'music assets/audio/music/test_room_ambience.ogg @0.8',
      ]);

      notifier().debugJumpToScene('desk');
      await tester.pump();
      expect(
        audio.calls.last,
        'music assets/audio/music/test_room_desk.mp3 @0.8',
      );

      notifier().debugJumpToScene('room_east');
      await tester.pump();
      expect(
        audio.calls.last,
        'music assets/audio/music/test_room_ambience.ogg @0.8',
      );
    });

    testWidgets('sound effects use the sfx volume; absent sounds are skipped', (
      tester,
    ) async {
      await pump(tester, stored: {'settings': '{"sfxVolume": 0.5}'});
      audio.calls.clear();
      notifier()
        ..debugJumpToScene('room_east')
        ..tapScene(0.65, 0.50); // lamp switch: playSound switch_click
      await tester.pump();
      expect(audio.calls, ['sfx assets/audio/sfx/switch_click.ogg @0.5']);

      audio.calls.clear();
      notifier()
        ..debugJumpToScene('desk')
        ..tapScene(0.5, 0.7)
        ..solvePuzzle('drawer_lock'); // playSound drawer_open: no file
      await tester.pump();
      expect(audio.calls.where((c) => c.startsWith('sfx')), isEmpty);
    });

    testWidgets('shake events reach the camera', (tester) async {
      await pump(tester);
      notifier()
        ..debugJumpToScene('room_east')
        ..tapScene(0.12, 0.37) // ring dial
        ..solvePuzzle('wall_rings'); // onSolved: shake
      await tester.pump();
      expect(shakes, [(300, 0.5)]);
    });

    testWidgets('changing the music volume applies to playing music', (
      tester,
    ) async {
      await pump(tester);
      container.read(settingsControllerProvider.notifier).setMusicVolume(0.2);
      await tester.pump();
      expect(audio.calls.last, 'volume 0.2');
    });
  });

  group('HintButton', () {
    FilledButton showHint(WidgetTester tester) => tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Show a hint'),
    );

    testWidgets('reveals stage hints one at a time, each after its candle', (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(find.byTooltip('Hint'));
      await tester.pumpAndSettle();
      expect(find.text('Hints'), findsOneWidget);
      expect(find.textContaining('TODO_TEXT'), findsNothing);
      expect(find.textContaining('still catching'), findsOneWidget);
      expect(showHint(tester).onPressed, isNull);

      await tester.pump(const Duration(seconds: 44));
      expect(showHint(tester).onPressed, isNull);
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Show a hint'));
      await tester.pumpAndSettle();
      expect(find.text('1. TODO_TEXT: hint.stage.find_key.1'), findsOneWidget);

      // A fresh, longer candle for the next one.
      expect(showHint(tester).onPressed, isNull);
      await tester.pump(const Duration(seconds: 90));

      // find_key.2 needs saw_clock; only find_key.3 is left.
      await tester.tap(find.text('Show a hint'));
      await tester.pumpAndSettle();
      expect(find.text('2. TODO_TEXT: hint.stage.find_key.3'), findsOneWidget);
      expect(find.text('Show a hint'), findsNothing);
      expect(find.text("That's every hint for now."), findsOneWidget);
    });

    testWidgets('the candle only burns while the app is in the foreground', (
      tester,
    ) async {
      await pump(tester);
      void go(List<AppLifecycleState> states) {
        for (final s in states) {
          tester.binding.handleAppLifecycleStateChanged(s);
        }
      }

      go(const [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
      ]);
      await tester.pump(const Duration(minutes: 5));
      go(const [
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]);
      await tester.tap(find.byTooltip('Hint'));
      await tester.pumpAndSettle();
      expect(showHint(tester).onPressed, isNull);
    });
  });
}
