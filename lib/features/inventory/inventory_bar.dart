import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/content_strings.dart';
import '../../core/theme/stillroom_palette.dart';
import '../../core/widgets/content_image.dart';
import '../../engine/engine.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/game_session.dart';

/// Always-visible inventory (PRD FR-03). Tap to select, tap the selected
/// item again to deselect, tap another item to combine, long-press or use
/// the examine button to open the close-up view.
///
/// [axis] follows the screen orientation: vertical beside a landscape scene,
/// horizontal below a portrait one.
class InventoryBar extends ConsumerStatefulWidget {
  const InventoryBar({required this.episodeId, required this.axis, super.key});

  final String episodeId;
  final Axis axis;

  static const thickness = 88.0;
  static const slotSize = 68.0;

  @override
  ConsumerState<InventoryBar> createState() => _InventoryBarState();
}

class _InventoryBarState extends ConsumerState<InventoryBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shake;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = gameSessionProvider(widget.episodeId);
    ref.listen(provider, (previous, next) {
      final session = next.value;
      if (session == null || session.revision == previous?.value?.revision) {
        return;
      }
      final refused = session.events.any(
        (e) => e is CombinationFailedEvent || e is ItemRejectedEvent,
      );
      if (refused) _shake.forward(from: 0);
    });

    final session = ref.watch(provider).value;
    if (session == null) return const SizedBox.shrink();
    final notifier = ref.read(provider.notifier);
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final items = session.engine.inventoryItems(session.game);
    final selected = session.selectedItem;
    final vertical = widget.axis == Axis.vertical;

    final slots = [
      for (final item in items)
        _Slot(
          item: item,
          name: contentText(session.episode.strings, language, item.nameKey),
          assets: session.episode.assets,
          selected: item.id == selected,
          shake: item.id == selected ? _shake : null,
          onTap: () => notifier.tapInventoryItem(item.id),
          onLongPress: () => notifier.examineItem(item.id),
        ),
    ];

    return Semantics(
      container: true,
      label: l10n.inventoryLabel,
      // A dark walnut cabinet with a brass trim facing the scene.
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: vertical ? Alignment.centerLeft : Alignment.topCenter,
            end: vertical ? Alignment.centerRight : Alignment.bottomCenter,
            colors: const [StillroomPalette.walnut, StillroomPalette.soot],
          ),
          border: vertical
              ? const Border(
                  left: BorderSide(color: StillroomPalette.brass, width: 1.2),
                )
              : const Border(
                  top: BorderSide(color: StillroomPalette.brass, width: 1.2),
                ),
        ),
        child: SafeArea(
          left: !vertical,
          top: vertical,
          child: SizedBox(
            width: vertical ? InventoryBar.thickness : null,
            height: vertical ? null : InventoryBar.thickness,
            child: Flex(
              direction: widget.axis,
              children: [
                Expanded(
                  child: ListView.separated(
                    scrollDirection: widget.axis,
                    padding: const EdgeInsets.all(10),
                    itemCount: slots.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox.square(dimension: 8),
                    itemBuilder: (_, i) => Center(child: slots[i]),
                  ),
                ),
                if (selected != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: IconButton.outlined(
                      tooltip: l10n.examineItem,
                      color: StillroomPalette.gaslight,
                      style: IconButton.styleFrom(
                        side: const BorderSide(color: StillroomPalette.brass),
                      ),
                      icon: const Icon(Icons.search),
                      onPressed: () => notifier.examineItem(selected),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({
    required this.item,
    required this.name,
    required this.assets,
    required this.selected,
    required this.shake,
    required this.onTap,
    required this.onLongPress,
  });

  final ItemDef item;
  final String name;
  final Set<String> assets;
  final bool selected;
  final Animation<double>? shake;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final slot = Semantics(
      button: true,
      selected: selected,
      label: name,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: InventoryBar.slotSize,
          height: InventoryBar.slotSize,
          padding: const EdgeInsets.all(6),
          // A recessed compartment; the selected one is lit by gaslight.
          decoration: BoxDecoration(
            color: StillroomPalette.ink,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: selected
                  ? StillroomPalette.gaslight
                  : StillroomPalette.walnutLight,
              width: selected ? 2.5 : 1,
            ),
            boxShadow: selected
                ? const [BoxShadow(color: Color(0x55E0A84A), blurRadius: 10)]
                : null,
          ),
          child: ContentImage(path: item.icon, label: item.id, assets: assets),
        ),
      ),
    );
    final shake = this.shake;
    if (shake == null) return slot;
    return AnimatedBuilder(
      animation: shake,
      builder: (_, child) => Transform.translate(
        offset: Offset(
          math.sin(shake.value * math.pi * 6) * 6 * (1 - shake.value),
          0,
        ),
        child: child,
      ),
      child: slot,
    );
  }
}
