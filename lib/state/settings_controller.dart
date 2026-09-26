import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'settings.dart';
import 'storage_providers.dart';

part 'settings_controller.g.dart';

/// Player settings, persisted on every change. Unreadable stored settings
/// fall back to defaults.
@Riverpod(keepAlive: true)
class SettingsController extends _$SettingsController {
  static const storageKey = 'settings';

  @override
  Settings build() {
    final raw = ref.watch(keyValueStoreProvider).getString(storageKey);
    if (raw == null) return const Settings();
    try {
      final json = jsonDecode(raw);
      if (json is Map<String, dynamic>) return Settings.fromJson(json);
    } on FormatException {
      // Fall through to defaults.
    } on CheckedFromJsonException {
      // Fall through to defaults.
    }
    return const Settings();
  }

  void setMusicVolume(double value) =>
      _update(state.copyWith(musicVolume: value.clamp(0, 1)));

  void setSfxVolume(double value) =>
      _update(state.copyWith(sfxVolume: value.clamp(0, 1)));

  /// `null` follows the device language.
  void setLanguage(String? languageCode) =>
      _update(state.copyWith(languageCode: languageCode));

  void setVibration({required bool enabled}) =>
      _update(state.copyWith(vibration: enabled));

  void _update(Settings next) {
    if (next == state) return;
    state = next;
    ref
        .read(keyValueStoreProvider)
        .setString(storageKey, jsonEncode(next.toJson()))
        .ignore();
  }
}
