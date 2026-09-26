import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/fps_overlay.dart';
import 'features/game/game_screen.dart';
import 'features/inventory/examine_overlay.dart';
import 'features/inventory/inventory_bar.dart';
import 'features/menu/episode_shelf_screen.dart';
import 'features/menu/main_menu_screen.dart';
import 'features/menu/map_screen.dart';
import 'features/puzzles/built_in_puzzle_widgets.dart';
import 'features/puzzles/puzzle_overlay.dart';
import 'features/settings/settings_screen.dart';
import 'l10n/generated/app_localizations.dart';
import 'state/settings_controller.dart';

/// Composition root: routes, and which features plug into the game screen.
class StillroomApp extends ConsumerWidget {
  const StillroomApp({super.key});

  static final _puzzleWidgets = builtInPuzzleWidgets();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = ref.watch(
      settingsControllerProvider.select((s) => s.languageCode),
    );
    final showFps = ref.watch(
      settingsControllerProvider.select((s) => s.showFps),
    );
    final supported = AppLocalizations.supportedLocales.map(
      (l) => l.languageCode,
    );
    // The language in effect: the player's choice, else the device's if
    // supported, else English. It picks the fallback fonts.
    final activeLanguage =
        languageCode ??
        WidgetsBinding.instance.platformDispatcher.locales
            .map((l) => l.languageCode)
            .firstWhere(supported.contains, orElse: () => 'en');
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      builder: (context, child) =>
          Stack(children: [?child, if (showFps) const FpsOverlay()]),
      theme: AppTheme.dark(languageCode: activeLanguage),
      // null follows the device; switching applies without a restart.
      locale: languageCode == null ? null : Locale(languageCode),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      navigatorObservers: [AppRoutes.observer],
      home: const MainMenuScreen(),
      onGenerateRoute: (settings) => switch (settings.name) {
        AppRoutes.game => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => GameScreen(
            episodeId: settings.arguments! as String,
            sideBar: (id, axis) => InventoryBar(episodeId: id, axis: axis),
            overlays: [
              (id) => ExamineOverlay(episodeId: id),
              (id) => PuzzleOverlay(episodeId: id, widgets: _puzzleWidgets),
            ],
          ),
        ),
        AppRoutes.map => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MapScreen(),
        ),
        AppRoutes.shelf => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const EpisodeShelfScreen(),
        ),
        AppRoutes.settings => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SettingsScreen(),
        ),
        _ => null,
      },
    );
  }
}
