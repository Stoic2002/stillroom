import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/core/storage/key_value_store.dart';
import 'package:stillroom/engine/engine.dart';
import 'package:stillroom/state/save_repository.dart';
import 'package:stillroom/state/settings.dart';
import 'package:stillroom/state/settings_controller.dart';
import 'package:stillroom/state/storage_providers.dart';

void main() {
  ProviderContainer containerFor(MemoryKeyValueStore store) {
    final container = ProviderContainer(
      overrides: [keyValueStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('SaveRepository', () {
    const room = GameState(episodeId: 'room', sceneId: 'a');
    const hall = GameState(episodeId: 'hall', sceneId: 'b');

    test('empty store: nothing to continue', () {
      final save = containerFor(
        MemoryKeyValueStore(),
      ).read(saveRepositoryProvider);
      expect(save.isCorrupted, isFalse);
      expect(save.continueEpisodeId, isNull);
      expect(save.file.episodes, isEmpty);
    });

    test('saves per episode and remembers the last one played', () async {
      final store = MemoryKeyValueStore();
      final container = containerFor(store);
      container.read(saveRepositoryProvider.notifier)
        ..saveEpisode(room)
        ..saveEpisode(hall);
      await container.read(saveRepositoryProvider.notifier).flush();

      final reloaded = containerFor(store).read(saveRepositoryProvider);
      expect(reloaded.episode('room'), room);
      expect(reloaded.episode('hall'), hall);
      expect(reloaded.continueEpisodeId, 'hall');
      expect(
        store.values[SaveRepository.storageKey],
        contains('"schemaVersion":1'),
      );
    });

    test('startNew keeps other episodes', () {
      final container = containerFor(MemoryKeyValueStore());
      container.read(saveRepositoryProvider.notifier)
        ..saveEpisode(room)
        ..saveEpisode(hall)
        ..startNew('room');
      final save = container.read(saveRepositoryProvider);
      expect(save.episode('room'), isNull);
      expect(save.episode('hall'), hall);
      expect(save.file.lastEpisodeId, 'room');
      expect(save.continueEpisodeId, isNull, reason: 'room has no state yet');
    });

    test(
      'a corrupt save is reported and left untouched until cleared',
      () async {
        final store = MemoryKeyValueStore({SaveRepository.storageKey: 'nope'});
        final container = containerFor(store);
        final save = container.read(saveRepositoryProvider);
        expect(save.isCorrupted, isTrue);
        expect(save.corruptionReason, contains('invalid JSON'));
        expect(save.continueEpisodeId, isNull);
        expect(store.values[SaveRepository.storageKey], 'nope');

        container.read(saveRepositoryProvider.notifier).clearAll();
        await container.read(saveRepositoryProvider.notifier).flush();
        expect(container.read(saveRepositoryProvider).isCorrupted, isFalse);
        expect(store.values, isEmpty);
      },
    );
  });

  group('SettingsController', () {
    test('defaults, then every change is persisted', () {
      final store = MemoryKeyValueStore();
      final container = containerFor(store);
      expect(container.read(settingsControllerProvider), const Settings());

      container.read(settingsControllerProvider.notifier)
        ..setMusicVolume(0.3)
        ..setSfxVolume(2) // clamped
        ..setLanguage('id')
        ..setVibration(enabled: false);

      final reloaded = containerFor(store).read(settingsControllerProvider);
      expect(
        reloaded,
        const Settings(
          musicVolume: 0.3,
          sfxVolume: 1,
          languageCode: 'id',
          vibration: false,
        ),
      );
    });

    test('unreadable settings fall back to defaults', () {
      for (final raw in ['{bad', '[]', '{"musicVolume": "loud"}']) {
        final store = MemoryKeyValueStore({SettingsController.storageKey: raw});
        expect(
          containerFor(store).read(settingsControllerProvider),
          const Settings(),
          reason: raw,
        );
      }
    });
  });
}
