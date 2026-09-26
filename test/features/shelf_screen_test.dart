import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/content/episode_catalog.dart';
import 'package:stillroom/core/audio/audio_service.dart';
import 'package:stillroom/core/storage/key_value_store.dart';
import 'package:stillroom/engine/engine.dart';
import 'package:stillroom/features/menu/episode_shelf_screen.dart';
import 'package:stillroom/l10n/generated/app_localizations.dart';
import 'package:stillroom/state/content_providers.dart';
import 'package:stillroom/state/save_repository.dart';
import 'package:stillroom/state/services_providers.dart';
import 'package:stillroom/state/storage_providers.dart';

void main() {
  const catalog = [
    EpisodeEntry(id: 'first', titleKey: 'first', series: 'london'),
    EpisodeEntry(id: 'second', titleKey: 'second', shelf: 2, unlockAfter: 1),
    EpisodeEntry(
      id: 'third',
      titleKey: 'third',
      shelf: 3,
      unlockAfter: 2,
      series: 'london',
    ),
  ];

  Future<void> pump(WidgetTester tester, {Set<String> finished = const {}}) {
    final save = const SaveSerializer().encode(
      SaveFile(
        episodes: {
          for (final id in finished)
            id: GameState(episodeId: id, sceneId: 's', completed: true),
        },
      ),
    );
    return tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          episodeCatalogProvider.overrideWith((ref) async => catalog),
          contentStringsProvider.overrideWith(
            (ref) async => {
              'en': {
                'first': 'First tale',
                'second': 'Second tale',
                'third': 'Third tale',
              },
            },
          ),
          bundledAssetsProvider.overrideWith((ref) async => <String>{}),
          audioServiceProvider.overrideWithValue(const SilentAudioService()),
          keyValueStoreProvider.overrideWithValue(
            MemoryKeyValueStore({SaveRepository.storageKey: save}),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: EpisodeShelfScreen(),
        ),
      ),
    );
  }

  testWidgets('one shelf per tier, numbered', (tester) async {
    await pump(tester);
    await tester.pumpAndSettle();
    for (final tier in [1, 2, 3]) {
      expect(find.byKey(ValueKey('shelf_$tier')), findsOneWidget);
    }
    expect(find.text('I'), findsOneWidget);
  });

  testWidgets('a jar on a higher shelf is locked until enough are done', (
    tester,
  ) async {
    await pump(tester);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.lock_outline), findsNWidgets(2));

    await tester.tap(find.byKey(const ValueKey('jar_second')));
    await tester.pumpAndSettle();
    expect(find.text('Not yet'), findsOneWidget);
    expect(find.text('Distil one more tale to open this jar.'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    // The vertical list of shelves is the outermost scrollable.
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('jar_third')),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('jar_third')));
    await tester.pumpAndSettle();
    expect(find.text('Distil 2 more tales to open this jar.'), findsOneWidget);
  });

  testWidgets('finishing a tale opens the next shelf', (tester) async {
    await pump(tester, finished: {'first'});
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.lock_outline), findsOneWidget, reason: 'third');

    await tester.tap(find.byKey(const ValueKey('jar_second')));
    await tester.pumpAndSettle();
    expect(find.text('Open the jar'), findsOneWidget);
  });
}
