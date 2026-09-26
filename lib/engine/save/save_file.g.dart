// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SaveFile _$SaveFileFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_SaveFile', json, ($checkedConvert) {
      final val = _SaveFile(
        schemaVersion: $checkedConvert(
          'schemaVersion',
          (v) => (v as num?)?.toInt() ?? SaveFile.currentSchemaVersion,
        ),
        lastEpisodeId: $checkedConvert('lastEpisodeId', (v) => v as String?),
        episodes: $checkedConvert(
          'episodes',
          (v) =>
              (v as Map<String, dynamic>?)?.map(
                (k, e) =>
                    MapEntry(k, GameState.fromJson(e as Map<String, dynamic>)),
              ) ??
              const <String, GameState>{},
        ),
        distilled: $checkedConvert(
          'distilled',
          (v) =>
              (v as List<dynamic>?)?.map((e) => e as String).toSet() ??
              const <String>{},
        ),
        keeperNotes: $checkedConvert(
          'keeperNotes',
          (v) =>
              (v as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as String),
              ) ??
              const <String, String>{},
        ),
      );
      return val;
    });

Map<String, dynamic> _$SaveFileToJson(_SaveFile instance) => <String, dynamic>{
  'schemaVersion': instance.schemaVersion,
  'lastEpisodeId': instance.lastEpisodeId,
  'episodes': instance.episodes.map((k, e) => MapEntry(k, e.toJson())),
  'distilled': instance.distilled.toList(),
  'keeperNotes': instance.keeperNotes,
};
