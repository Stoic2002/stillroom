import 'package:flutter/material.dart';

import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Direction arrows for the current scene's visible exits: left and right at
/// the sides, back at the bottom. Place inside a [SceneFrame].
class ExitButtons extends StatelessWidget {
  const ExitButtons({required this.exits, required this.onExit, super.key});

  final List<SceneExit> exits;
  final ValueChanged<String> onExit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      children: [
        for (final exit in exits)
          if (exit.direction case final direction?)
            Align(
              alignment: switch (direction) {
                ExitDirection.left => Alignment.centerLeft,
                ExitDirection.right => Alignment.centerRight,
                ExitDirection.back => Alignment.bottomCenter,
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _ArrowButton(
                  icon: switch (direction) {
                    ExitDirection.left => Icons.chevron_left,
                    ExitDirection.right => Icons.chevron_right,
                    ExitDirection.back => Icons.expand_more,
                  },
                  label: switch (direction) {
                    ExitDirection.left => l10n.navLeft,
                    ExitDirection.right => l10n.navRight,
                    ExitDirection.back => l10n.navBack,
                  },
                  onPressed: () => onExit(exit.id),
                ),
              ),
            ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: StillroomPalette.ink.withValues(alpha: 0.35),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox.square(
            dimension: 56,
            child: Icon(
              icon,
              size: 40,
              color: StillroomPalette.paper.withValues(alpha: 0.75),
            ),
          ),
        ),
      ),
    );
  }
}
