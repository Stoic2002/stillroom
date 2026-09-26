import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'debug_settings.g.dart';

/// Whether hotspot and exit outlines are drawn over the scene.
@Riverpod(keepAlive: true)
class ShowHotspots extends _$ShowHotspots {
  @override
  bool build() => false;

  void toggle() => state = !state;
}
