// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Settings _$SettingsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_Settings', json, ($checkedConvert) {
      final val = _Settings(
        musicVolume: $checkedConvert(
          'musicVolume',
          (v) => (v as num?)?.toDouble() ?? 0.8,
        ),
        sfxVolume: $checkedConvert(
          'sfxVolume',
          (v) => (v as num?)?.toDouble() ?? 1.0,
        ),
        languageCode: $checkedConvert('languageCode', (v) => v as String?),
        vibration: $checkedConvert('vibration', (v) => v as bool? ?? true),
      );
      return val;
    });

Map<String, dynamic> _$SettingsToJson(_Settings instance) => <String, dynamic>{
  'musicVolume': instance.musicVolume,
  'sfxVolume': instance.sfxVolume,
  'languageCode': instance.languageCode,
  'vibration': instance.vibration,
};
