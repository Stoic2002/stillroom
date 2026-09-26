import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../content/audio_paths.dart';
import '../../../core/routing/app_routes.dart';
import '../../../state/content_providers.dart';
import '../../../state/services_providers.dart';
import '../../../state/settings_controller.dart';

/// The Stillroom's own music under the menu and the shelf: it starts when
/// the screen appears and again when the player comes back from a tale.
/// Silent until `assets/audio/music/stillroom_menu.*` exists.
class MenuMusic extends ConsumerStatefulWidget {
  const MenuMusic({required this.child, super.key});

  static const musicId = 'stillroom_menu';

  final Widget child;

  @override
  ConsumerState<MenuMusic> createState() => _MenuMusicState();
}

class _MenuMusicState extends ConsumerState<MenuMusic> with RouteAware {
  ModalRoute<void>? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route != _route) {
      if (_route != null) AppRoutes.observer.unsubscribe(this);
      _route = route;
      AppRoutes.observer.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    AppRoutes.observer.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() => unawaited(_play());

  @override
  void didPopNext() => unawaited(_play());

  Future<void> _play() async {
    final assets = await ref.read(bundledAssetsProvider.future);
    final path = resolveMusic(MenuMusic.musicId, assets);
    if (!mounted || path == null) return;
    await ref
        .read(audioServiceProvider)
        .playMusic(
          path,
          volume: ref.read(settingsControllerProvider).musicVolume,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      settingsControllerProvider.select((s) => s.musicVolume),
      (_, volume) =>
          unawaited(ref.read(audioServiceProvider).setMusicVolume(volume)),
    );
    return widget.child;
  }
}
