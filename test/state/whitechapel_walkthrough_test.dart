import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/content/file_asset_source.dart';
import 'package:stillroom/core/storage/key_value_store.dart';
import 'package:stillroom/engine/engine.dart';
import 'package:stillroom/state/content_providers.dart';
import 'package:stillroom/state/game_session.dart';
import 'package:stillroom/state/storage_providers.dart';

/// Plays "Whitechapel, 1888" start to finish through the real content, so a
/// content change that makes the episode unwinnable fails here.
void main() {
  const episode = 'whitechapel_1888';

  test('the episode can be completed', () async {
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        assetSourceProvider.overrideWithValue(
          FileAssetSource(Directory.current),
        ),
        keyValueStoreProvider.overrideWithValue(MemoryKeyValueStore()),
      ],
    );
    addTearDown(container.dispose);
    container.listen(gameSessionProvider(episode), (_, _) {});
    await container.read(gameSessionProvider(episode).future);
    final play = container.read(gameSessionProvider(episode).notifier);
    GameSessionState now() =>
        container.read(gameSessionProvider(episode)).requireValue;
    String? stage() => play.currentHints()?.key;

    void readAll() {
      while (now().currentText != null) {
        play.dismissText();
      }
    }

    void solve(String puzzle) {
      expect(now().openPuzzle, puzzle);
      play.solvePuzzle(puzzle);
      readAll();
    }

    expect(now().game.sceneId, 'room_north');
    expect(stage(), 'stage:open_drawer');

    // 1. The desk drawer: code from the stopped clock.
    play.tapScene(0.7, 0.69); // desk (exit area)
    expect(now().game.sceneId, 'desk');
    play.tapScene(0.5, 0.77); // drawer
    solve('desk_drawer');
    expect(
      now().game.inventory,
      containsAll(['matches', 'letter', 'name_card_nichols']),
    );
    expect(stage(), 'stage:light_candles');

    // 2. Candles on the mantel, lit in the order of the clippings.
    play
      ..takeExit('back')
      ..takeExit('right')
      ..tapInventoryItem('matches')
      ..tapScene(0.5, 0.42); // candles
    solve('candles');
    expect(now().game.inventory, contains('name_card_chapman'));

    // 3. The street map by the window.
    play
      ..takeExit('left')
      ..tapScene(0.27, 0.35); // window (exit area)
    expect(now().game.sceneId, 'window');
    play.tapScene(0.73, 0.42); // street map
    solve('street_compass');
    expect(
      now().game.inventory,
      containsAll(['name_card_stride', 'name_card_eddowes']),
    );

    // 4. Lens from the coat + brass frame from the floor = magnifier.
    play
      ..takeExit('back')
      ..takeExit('left') // room_west
      ..tapScene(0.65, 0.85) // brass frame
      ..takeExit('left') // room_south
      ..tapScene(0.8, 0.4); // coat pocket
    readAll();
    play
      ..tapInventoryItem('lens')
      ..tapInventoryItem('brass_frame');
    expect(now().game.inventory, contains('magnifier'));

    // 5. Read the faded paper on the desk with it.
    play
      ..takeExit('right') // room_west
      ..takeExit('right') // room_north
      ..tapScene(0.7, 0.69) // desk
      ..tapInventoryItem('magnifier')
      ..tapScene(0.67, 0.27); // faded paper
    readAll();
    expect(now().game.inventory, contains('name_card_kelly'));
    expect(stage(), 'stage:place_names');

    // 6. Return the five names to their frames.
    play
      ..takeExit('back')
      ..takeExit('left') // room_west
      ..tapScene(0.5, 0.33); // frames
    final frames = now().engine.content.requirePuzzle('five_frames');
    final placement = (frames.config as SlotPlacementConfig).start(now().game);
    expect(placement.available, hasLength(5), reason: 'all names collected');
    solve('five_frames');
    expect(now().game.flags['names_restored'], isTrue);
    expect(now().game.inventory, isNot(contains('name_card_kelly')));
    expect(stage(), 'stage:leave');

    // 7. The door opens.
    play
      ..takeExit('left') // room_south
      ..tapScene(0.5, 0.5);
    readAll();
    expect(now().game.completed, isTrue);
  });
}
