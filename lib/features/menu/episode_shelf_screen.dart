import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/content_strings.dart';
import '../../content/episode_catalog.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/stillroom_palette.dart';
import '../../core/widgets/atmosphere.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/content_providers.dart';
import '../../state/save_repository.dart';
import 'jar_actions.dart';
import 'widgets/jar.dart';
import 'widgets/menu_music.dart';

/// The episode picker: shelves of jars, one jar per tale (`episodes.json`).
/// Shelves are difficulty tiers: the bottom one is open from the start and
/// higher ones open as tales are distilled. Sealed jars are tales still to
/// come; a wax seal marks finished ones.
class EpisodeShelfScreen extends ConsumerWidget {
  const EpisodeShelfScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final catalog = ref.watch(episodeCatalogProvider).value ?? const [];
    final strings = ref.watch(contentStringsProvider).value ?? const {};
    final assets = ref.watch(bundledAssetsProvider).value ?? const <String>{};
    final save = ref.watch(saveRepositoryProvider);
    final progress = ShelfProgress(catalog, {
      for (final e in catalog)
        if (save.isCompleted(e.id)) e.id,
    });

    String text(String key) => contentText(strings, language, key);

    return MenuMusic(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.shelfTitle)),
        body: Atmosphere(
          child: SafeArea(
            top: false,
            // Reversed: the bottom (easiest) shelf shows first; harder
            // shelves are above, a scroll up.
            child: ListView(
              reverse: true,
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    l10n.shelfHint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: StillroomPalette.faded,
                    ),
                  ),
                ),
                for (final (tier, entries) in progress.shelvesTopDown.reversed)
                  _Shelf(
                    key: ValueKey('shelf_$tier'),
                    tier: tier,
                    children: [
                      for (final entry in entries)
                        Jar(
                          key: ValueKey('jar_${entry.id}'),
                          id: entry.id,
                          label: entry.comingSoon
                              ? l10n.jarSealed
                              : text(entry.titleKey),
                          image: entry.jarImage,
                          assets: assets,
                          sealed: entry.comingSoon,
                          locked: entry.playable && !progress.isUnlocked(entry),
                          distilled: save.isCompleted(entry.id),
                          keeperNote: save.keeperNote(entry.id) != null,
                          series: entry.series,
                          onTap: entry.playable
                              ? () => pickJar(
                                  context,
                                  ref,
                                  entry,
                                  progress: progress,
                                  text: text,
                                )
                              : null,
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One wooden shelf: a roman numeral plaque, a row of jars, and the board.
class _Shelf extends StatelessWidget {
  const _Shelf({required this.tier, required this.children, super.key});

  final int tier;
  final List<Widget> children;

  static const _numerals = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII'];

  @override
  Widget build(BuildContext context) {
    final numeral = tier <= _numerals.length ? _numerals[tier - 1] : '$tier';
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 48,
                child: Text(
                  numeral,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppTheme.smallCaps,
                    fontSize: 20,
                    color: StillroomPalette.brass,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(right: 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final jar in children)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: jar,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: const BoxDecoration(
              color: StillroomPalette.walnut,
              border: Border(
                top: BorderSide(color: StillroomPalette.walnutLight, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
