// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GameState _$GameStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_GameState', json, ($checkedConvert) {
      final val = _GameState(
        episodeId: $checkedConvert('episodeId', (v) => v as String),
        sceneId: $checkedConvert('sceneId', (v) => v as String),
        inventory: $checkedConvert(
          'inventory',
          (v) =>
              (v as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
        ),
        everHadItems: $checkedConvert(
          'everHadItems',
          (v) =>
              (v as List<dynamic>?)?.map((e) => e as String).toSet() ??
              const <String>{},
        ),
        flags: $checkedConvert(
          'flags',
          (v) =>
              (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as Object),
              ) ??
              const <String, Object>{},
        ),
        solvedPuzzles: $checkedConvert(
          'solvedPuzzles',
          (v) =>
              (v as List<dynamic>?)?.map((e) => e as String).toSet() ??
              const <String>{},
        ),
        revealedHints: $checkedConvert(
          'revealedHints',
          (v) =>
              (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, (e as num).toInt()),
              ) ??
              const <String, int>{},
        ),
        words: $checkedConvert(
          'words',
          (v) =>
              (v as List<dynamic>?)?.map((e) => e as String).toSet() ??
              const <String>{},
        ),
        secretFound: $checkedConvert('secretFound', (v) => v as bool? ?? false),
        completed: $checkedConvert('completed', (v) => v as bool? ?? false),
      );
      return val;
    });

Map<String, dynamic> _$GameStateToJson(_GameState instance) =>
    <String, dynamic>{
      'episodeId': instance.episodeId,
      'sceneId': instance.sceneId,
      'inventory': instance.inventory,
      'everHadItems': instance.everHadItems.toList(),
      'flags': instance.flags,
      'solvedPuzzles': instance.solvedPuzzles.toList(),
      'revealedHints': instance.revealedHints,
      'words': instance.words.toList(),
      'secretFound': instance.secretFound,
      'completed': instance.completed,
    };
