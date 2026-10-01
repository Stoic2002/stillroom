import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/audio/audio_service.dart';
import '../core/audio/flame_audio_service.dart';
import '../core/services/hint_gate.dart';
import 'hint_candle.dart';

part 'services_providers.g.dart';

/// Hints wait for their candle (docs/stillroom_frame.md).
@Riverpod(keepAlive: true)
HintGate hintGate(Ref ref) => CandleHintGate(ref);

@Riverpod(keepAlive: true)
AudioService audioService(Ref ref) {
  final service = FlameAudioService();
  // Free every player when Android takes the engine away, so none keeps
  // talking to a detached engine.
  final lifecycle = AppLifecycleListener(onDetach: service.release);
  ref.onDispose(() {
    lifecycle.dispose();
    unawaited(service.release());
  });
  return service;
}
