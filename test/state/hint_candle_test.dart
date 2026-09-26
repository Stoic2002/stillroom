import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/core/services/hint_gate.dart';
import 'package:stillroom/core/services/hint_pacing.dart';
import 'package:stillroom/core/storage/key_value_store.dart';
import 'package:stillroom/state/hint_candle.dart';
import 'package:stillroom/state/services_providers.dart';
import 'package:stillroom/state/storage_providers.dart';

void main() {
  group('HintPacing', () {
    const pacing = HintPacing();

    test('each level waits longer; later levels reuse the last wait', () {
      expect(pacing.waitFor(level: 1, shelf: 1), const Duration(seconds: 45));
      expect(pacing.waitFor(level: 2, shelf: 1), const Duration(seconds: 90));
      expect(pacing.waitFor(level: 3, shelf: 1), const Duration(seconds: 150));
      expect(pacing.waitFor(level: 4, shelf: 1), const Duration(seconds: 150));
    });

    test('higher shelves wait longer', () {
      expect(
        pacing.waitFor(level: 1, shelf: 2),
        const Duration(milliseconds: 67500),
      );
      expect(pacing.waitFor(level: 3, shelf: 3), const Duration(seconds: 300));
    });
  });

  group('CandleHintGate', () {
    late ProviderContainer container;
    const request = HintUnlockRequest(
      episodeId: 'e',
      groupKey: 'stage:a',
      level: 1,
    );

    setUp(() {
      container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          keyValueStoreProvider.overrideWithValue(MemoryKeyValueStore()),
        ],
      );
      addTearDown(container.dispose);
    });

    HintCandle candle() => container.read(hintCandleProvider('e').notifier);

    test(
      'refuses until the candle has burned, then starts a new one',
      () async {
        final gate = container.read(hintGateProvider);
        expect(await gate.unlock(request), isFalse);

        candle().burn('stage:a', const Duration(seconds: 44));
        expect(await gate.unlock(request), isFalse);
        candle().burn('stage:a', const Duration(seconds: 1));
        expect(await gate.unlock(request), isTrue);
        expect(container.read(hintCandleProvider('e')), isEmpty);
      },
    );

    test('groups burn separately', () async {
      candle().burn('puzzle:b', const Duration(minutes: 5));
      expect(await container.read(hintGateProvider).unlock(request), isFalse);
    });
  });
}
