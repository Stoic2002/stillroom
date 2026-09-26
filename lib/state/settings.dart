import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';
part 'settings.g.dart';

/// Player preferences (PRD FR-11). Stored apart from the game save, so
/// resetting progress keeps them.
@freezed
abstract class Settings with _$Settings {
  const factory Settings({
    /// 0–1.
    @Default(0.8) double musicVolume,

    /// 0–1.
    @Default(1.0) double sfxVolume,

    /// UI and content language, e.g. `id`. `null` follows the device.
    String? languageCode,
    @Default(true) bool vibration,

    /// Shows the frame-rate readout (for checking performance).
    @Default(false) bool showFps,
  }) = _Settings;

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);
}
