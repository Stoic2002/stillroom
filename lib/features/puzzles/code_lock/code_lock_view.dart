import 'package:flutter/material.dart';

import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// Dials in a row, each with next/previous arrows.
class CodeLockView extends StatefulWidget {
  const CodeLockView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<CodeLockView> createState() => _CodeLockViewState();
}

class _CodeLockViewState extends State<CodeLockView>
    with SolvesAfterPause<CodeLockView> {
  late CodeLockState _state = (widget.context.puzzle.config as CodeLockConfig)
      .start();

  void _rotate(int slot, int delta) {
    if (isSolved) return;
    setState(() => _state = _state.rotate(slot, delta));
    if (_state.isSolved) markSolved(widget.context.onSolved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final dial = (constraints.maxHeight * 0.22).clamp(56.0, 140.0);
        final color = isSolved
            ? StillroomPalette.gaslight
            : StillroomPalette.paper;
        return Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var slot = 0; slot < _state.positions.length; slot++)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: dial * 0.08),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: l10n.dialNext,
                          iconSize: dial * 0.45,
                          icon: const Icon(Icons.keyboard_arrow_up),
                          onPressed: () => _rotate(slot, 1),
                        ),
                        Container(
                          width: dial * 0.8,
                          height: dial,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: StillroomPalette.ink.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: color, width: 2),
                          ),
                          child: Text(
                            _state.symbolAt(slot),
                            key: ValueKey('dial_$slot'),
                            style: TextStyle(
                              fontSize: dial * 0.5,
                              color: color,
                              fontFamily: 'IMFell',
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.dialPrevious,
                          iconSize: dial * 0.45,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          onPressed: () => _rotate(slot, -1),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
