import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/content/content_loader.dart';
import 'package:stillroom/content/file_asset_source.dart';
import 'package:stillroom/core/storage/key_value_store.dart';
import 'package:stillroom/engine/engine.dart';
import 'package:stillroom/features/game/widgets/ending_overlay.dart';
import 'package:stillroom/features/game/widgets/text_box.dart';
import 'package:stillroom/features/inventory/examine_overlay.dart';
import 'package:stillroom/features/inventory/inventory_bar.dart';
import 'package:stillroom/l10n/generated/app_localizations.dart';
import 'package:stillroom/state/content_providers.dart';
import 'package:stillroom/state/game_session.dart';
import 'package:stillroom/state/storage_providers.dart';

const _episode = 'test_room';

void main() {
  late ProviderContainer container;
  late LoadedEpisode loaded;

  // Real file IO does not complete inside testWidgets' fake async zone, so
  // the content is loaded once up front and injected into the provider.
  setUpAll(() async {
    final loader = ContentLoader(FileAssetSource(Directory.current));
    loaded = LoadedEpisode(
      content: await loader.loadEpisode(
        _episode,
        ContentRegistries.withBuiltIns(),
      ),
      assets: await loader.source.listAssets(),
      strings: await loader.loadStringTables(),
    );
  });

  GameSession notifier() =>
      container.read(gameSessionProvider(_episode).notifier);
  GameSessionState session() =>
      container.read(gameSessionProvider(_episode)).requireValue;

  Future<void> pumpUi(WidgetTester tester) async {
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        loadedEpisodeProvider(_episode).overrideWith((ref) async => loaded),
        keyValueStoreProvider.overrideWithValue(MemoryKeyValueStore()),
      ],
    );
    addTearDown(container.dispose);
    container.listen(gameSessionProvider(_episode), (_, _) {});
    await container.read(gameSessionProvider(_episode).future);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Row(
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ExamineOverlay(episodeId: _episode),
                      TextBox(episodeId: _episode),
                      EndingOverlay(episodeId: _episode),
                    ],
                  ),
                ),
                InventoryBar(episodeId: _episode, axis: Axis.vertical),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('picked items appear as slots and can be selected', (
    tester,
  ) async {
    await pumpUi(tester);
    expect(find.text('lens'), findsNothing);

    notifier()
      ..debugJumpToScene('room_east')
      ..tapScene(0.65, 0.50) // lamp: dim
      ..tapScene(0.65, 0.50) // lamp: bright
      ..tapScene(0.83, 0.55);
    await tester.pump();
    // Placeholder slot is labelled with the item id.
    expect(find.text('lens'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsNothing);

    await tester.tap(find.text('lens'));
    await tester.pump();
    expect(session().selectedItem, 'lens');
    expect(find.byIcon(Icons.search), findsOneWidget, reason: 'examine button');

    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    expect(session().examinedItem, 'lens');
    expect(find.text('TODO_TEXT: item.lens.name'), findsOneWidget);
    expect(find.text('TODO_TEXT: item.lens.desc'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pump();
    expect(session().examinedItem, isNull);
  });

  testWidgets('long-press opens the examine view', (tester) async {
    await pumpUi(tester);
    notifier()
      ..debugJumpToScene('room_east')
      ..tapScene(0.12, 0.37) // ring dial
      ..solvePuzzle('wall_rings')
      ..tapScene(0.12, 0.62); // frame
    await tester.pump();
    await tester.longPress(find.text('frame'));
    await tester.pump();
    expect(session().examinedItem, 'frame');
  });

  testWidgets('text box shows the content string and closes on tap', (
    tester,
  ) async {
    await pumpUi(tester);
    notifier().tapScene(0.83, 0.24); // clock
    await tester.pump();
    expect(find.text('TODO_TEXT: test_room.clock.look'), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pump();
    expect(find.text('TODO_TEXT: test_room.clock.look'), findsNothing);
    expect(session().currentText, isNull);
  });

  testWidgets('ending screen appears after endEpisode, once text is read', (
    tester,
  ) async {
    await pumpUi(tester);
    notifier()
      ..debugJumpToScene('desk')
      ..tapScene(0.5, 0.7) // drawer: code lock
      ..solvePuzzle('drawer_lock')
      ..tapScene(0.5, 0.72) // box
      ..examineItem('box')
      ..tapExamine(0.5, 0.4) // lid
      ..tapExamine(0.5, 0.6) // key + text
      ..dismissText()
      ..closeExamine()
      ..debugJumpToScene('room_south')
      ..tapScene(0.5, 0.4) // emblem panel
      ..solvePuzzle('door_emblems')
      ..dismissText()
      ..tapInventoryItem('small_key')
      ..tapScene(0.5, 0.7); // use the key on the door
    await tester.pump();
    expect(session().game.flags['door_unlocked'], isTrue);
    expect(find.text('The tale is distilled'), findsNothing);

    notifier()
      ..dismissText()
      ..tapScene(0.5, 0.7); // the open door: endEpisode
    await tester.pumpAndSettle();
    expect(session().game.completed, isTrue);
    expect(find.text('The tale is distilled'), findsOneWidget);
    expect(find.text('Back to menu'), findsOneWidget);
  });
}
