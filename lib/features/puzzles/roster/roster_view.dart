import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// A roster board on a sheet of paper: a row for each person, a column for
/// each thing to be worked out. Tap a box to step through its options;
/// once every box is filled, the board says how many rows are still wrong.
class RosterView extends StatefulWidget {
  const RosterView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<RosterView> createState() => _RosterViewState();
}

class _RosterViewState extends State<RosterView>
    with SolvesAfterPause<RosterView> {
  late final _config = widget.context.puzzle.config as RosterConfig;
  late RosterState _state = _config.start();

  void _cycle(String row, String column) {
    if (isSolved) return;
    final wasComplete = _state.isComplete;
    final next = _state.cycle(row, column);
    setState(() => _state = next);
    if (next.isSolved) {
      widget.context.feedback(UiSound.solved);
      markSolved(widget.context.onSolved);
    } else if (next.isComplete && !wasComplete) {
      widget.context.feedback(UiSound.mistake);
    } else {
      widget.context.feedback(UiSound.turn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String text(String key) => widget.context.text(context, key);
    const ink = StillroomPalette.inkOnPaper;
    final heading = Theme.of(context).textTheme.labelLarge?.copyWith(
      fontFamily: AppTheme.smallCaps,
      color: StillroomPalette.faded,
      fontSize: 14,
    );
    final status = !_state.isComplete
        ? l10n.rosterInstruction
        : _state.isSolved
        ? ''
        : l10n.rosterWrong(_state.wrongRows);

    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.86,
        heightFactor: 0.86,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: StillroomPalette.paper,
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [BoxShadow(blurRadius: 16, color: Colors.black54)],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    for (final column in _config.columns)
                      Expanded(
                        flex: 2,
                        child: Text(
                          text(column.labelKey),
                          textAlign: TextAlign.center,
                          style: heading,
                        ),
                      ),
                  ],
                ),
                const Divider(color: StillroomPalette.paperShade, height: 12),
                for (final row in _config.rows)
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            text(row.labelKey),
                            style: const TextStyle(
                              fontFamily: AppTheme.serif,
                              fontSize: 16,
                              color: ink,
                            ),
                          ),
                        ),
                        for (final column in _config.columns)
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(3),
                              child: _Cell(
                                key: ValueKey('roster_${row.id}_${column.id}'),
                                label: switch (_state.pick(row.id, column.id)) {
                                  final picked? => text(
                                    column.options
                                        .firstWhere((o) => o.id == picked)
                                        .labelKey,
                                  ),
                                  null => '—',
                                },
                                solved: isSolved,
                                onTap: () => _cycle(row.id, column.id),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                SizedBox(
                  height: 22,
                  child: Text(
                    status,
                    style: const TextStyle(
                      fontFamily: AppTheme.serif,
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                      color: StillroomPalette.oxblood,
                    ),
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

class _Cell extends StatelessWidget {
  const _Cell({
    required this.label,
    required this.solved,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool solved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: solved ? const Color(0xFFE6D6A8) : const Color(0xFFE4D7B8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
        side: const BorderSide(color: StillroomPalette.paperShade),
      ),
      child: InkWell(
        onTap: onTap,
        splashColor: const Color(0x33A88B4A),
        highlightColor: const Color(0x22A88B4A),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: minTapSizeDp),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppTheme.serif,
                  fontSize: 14,
                  height: 1.1,
                  color: StillroomPalette.inkOnPaper,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
