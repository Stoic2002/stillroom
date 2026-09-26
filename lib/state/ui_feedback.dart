import 'dart:async';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/audio/ui_sound.dart';
import 'services_providers.dart';
import 'settings_controller.dart';

part 'ui_feedback.g.dart';

/// Plays [UiSound]s at the effects volume, with their vibration when the
/// player has vibration on.
@Riverpod(keepAlive: true)
UiFeedback uiFeedback(Ref ref) => UiFeedback(ref);

final class UiFeedback {
  const UiFeedback(this._ref);

  final Ref _ref;

  void call(UiSound sound) {
    final settings = _ref.read(settingsControllerProvider);
    unawaited(
      _ref
          .read(audioServiceProvider)
          .playSfx(sound.assetPath, volume: settings.sfxVolume),
    );
    if (!settings.vibration) return;
    unawaited(switch (sound.haptic) {
      Haptic.none => Future<void>.value(),
      Haptic.selection => HapticFeedback.selectionClick(),
      Haptic.light => HapticFeedback.lightImpact(),
      Haptic.medium => HapticFeedback.mediumImpact(),
    });
  }
}
