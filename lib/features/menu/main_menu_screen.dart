import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/routing/app_routes.dart';
import '../../core/theme/stillroom_palette.dart';
import '../../core/widgets/atmosphere.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/content_providers.dart';
import '../../state/save_repository.dart';
import 'episode_launcher.dart';
import 'widgets/lobby_scene.dart';
import 'widgets/menu_music.dart';

/// Main menu (PRD FR-11): Continue (when an unfinished save exists), New
/// Game (opens the shelf to pick a tale), Settings.
class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen> {
  bool _corruptionShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportCorruption());
  }

  /// Tells the player once per launch that the save could not be read
  /// (NFR-06), offering a new game.
  Future<void> _reportCorruption() async {
    if (!mounted ||
        _corruptionShown ||
        !ref.read(saveRepositoryProvider).isCorrupted) {
      return;
    }
    _corruptionShown = true;
    final l10n = AppLocalizations.of(context);
    final startNew = await showConfirmDialog(
      context,
      title: l10n.saveCorruptedTitle,
      body: l10n.saveCorruptedBody,
      confirmLabel: l10n.menuNewGame,
      cancelLabel: l10n.actionCancel,
    );
    if (startNew && mounted) await _openShelf();
  }

  Future<void> _openShelf() async {
    final catalog = await ref.read(episodeCatalogProvider.future);
    if (!mounted) return;
    final playable = [
      for (final e in catalog)
        if (e.playable) e,
    ];
    // Skip the shelf when there is nothing to choose between.
    if (catalog.length == 1 && playable.length == 1) {
      await startEpisode(context, ref, playable.single.id);
    } else {
      await Navigator.of(context).pushNamed(AppRoutes.shelf);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final continueId = ref.watch(saveRepositoryProvider).continueEpisodeId;
    final hasEpisodes =
        ref.watch(episodeCatalogProvider).value?.any((e) => e.playable) ??
        false;
    final theme = Theme.of(context);

    return MenuMusic(
      child: Scaffold(
        body: Atmosphere(
          vignette: 0.9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const LobbyScene(),
              // A pool of shadow behind the title keeps the menu readable.
              const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 0.62,
                      colors: [Color(0xE00E0B09), Color(0x000E0B09)],
                    ),
                  ),
                ),
              ),
              _menu(context, l10n, theme, continueId, hasEpisodes),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menu(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    String? continueId,
    bool hasEpisodes,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.appTitle, style: theme.textTheme.displayMedium),
          const SizedBox(height: 6),
          Text(
            l10n.menuTagline,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              color: StillroomPalette.faded,
            ),
          ),
          const SizedBox(height: 16),
          const _Rule(),
          const SizedBox(height: 16),
          _MenuButton(
            label: l10n.menuContinue,
            highlighted: continueId != null,
            onPressed: continueId == null
                ? null
                : () => continueEpisode(context, continueId),
          ),
          _MenuButton(
            label: l10n.menuNewGame,
            highlighted: continueId == null,
            onPressed: hasEpisodes ? _openShelf : null,
          ),
          _MenuButton(
            label: l10n.menuSettings,
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.settings),
          ),
        ],
      ),
    );
  }
}

/// A thin brass rule with a diamond, under the title.
class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) {
    const line = Expanded(
      child: Divider(color: StillroomPalette.brass, thickness: 0.6),
    );
    return const SizedBox(
      width: 220,
      child: Row(
        children: [
          line,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.diamond_outlined,
              size: 10,
              color: StillroomPalette.brass,
            ),
          ),
          line,
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.label,
    this.onPressed,
    this.highlighted = false,
  });

  final String label;
  final VoidCallback? onPressed;

  /// The suggested next step glows like gaslight.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: TextButton(
        onPressed: onPressed,
        style: highlighted
            ? TextButton.styleFrom(foregroundColor: StillroomPalette.gaslight)
            : null,
        child: Text(label),
      ),
    );
  }
}
