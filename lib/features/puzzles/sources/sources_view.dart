import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// A file of papers to sort. The trays across the top, the papers not yet
/// sorted along the bottom. Tap a paper, then a tray; tap a paper in a tray
/// to take it back out. Once all are sorted, the file says how many are in
/// the wrong tray.
class SourcesView extends StatefulWidget {
  const SourcesView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<SourcesView> createState() => _SourcesViewState();
}

class _SourcesViewState extends State<SourcesView>
    with SolvesAfterPause<SourcesView> {
  late final _config = widget.context.puzzle.config as SourcesConfig;
  late SourcesState _state = _config.start();
  String? _selected;

  String _text(BuildContext context, String key) =>
      widget.context.text(context, key);

  void _pickCard(String id) {
    if (isSolved) return;
    setState(() => _selected = _selected == id ? null : id);
    widget.context.feedback(UiSound.lift);
  }

  void _toTray(String trayId) {
    final card = _selected;
    if (isSolved || card == null) return;
    final wasComplete = _state.isComplete;
    final next = _state.place(card, trayId);
    setState(() {
      _state = next;
      _selected = null;
    });
    if (next.isSolved) {
      widget.context.feedback(UiSound.solved);
      markSolved(widget.context.onSolved);
    } else if (next.isComplete && !wasComplete) {
      widget.context.feedback(UiSound.mistake);
    } else {
      widget.context.feedback(UiSound.place);
    }
  }

  void _lift(String id) {
    if (isSolved) return;
    setState(() {
      _state = _state.lift(id);
      _selected = id;
    });
    widget.context.feedback(UiSound.lift);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loose = [
      for (final c in _config.cards)
        if (!_state.placed.containsKey(c.id)) c,
    ];
    final status = !_state.isComplete
        ? l10n.sourcesInstruction
        : _state.isSolved
        ? ''
        : l10n.sourcesWrong(_state.wrong);
    return Padding(
      padding: const EdgeInsets.fromLTRB(56, 14, 24, 8),
      child: Column(
        children: [
          // The trays.
          Expanded(
            flex: 5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, tray) in _config.trays.indexed) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      key: ValueKey('sources_tray_${tray.id}'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _toTray(tray.id),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: _selected != null
                              ? const Color(0x33E0A84A)
                              : const Color(0x22000000),
                          border: Border.all(
                            color: _selected != null
                                ? StillroomPalette.gaslight
                                : StillroomPalette.walnutLight,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _text(context, tray.labelKey),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: AppTheme.smallCaps,
                                  fontSize: 16,
                                  color: StillroomPalette.paper,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      for (final c in _config.cards)
                                        if (_state.placed[c.id] == tray.id)
                                          ActionChip(
                                            key: ValueKey(
                                              'sources_placed_${c.id}',
                                            ),
                                            backgroundColor:
                                                StillroomPalette.paper,
                                            label: Text(
                                              _text(context, c.titleKey),
                                              style: const TextStyle(
                                                fontFamily: AppTheme.serif,
                                                fontSize: 13,
                                                color:
                                                    StillroomPalette.inkOnPaper,
                                              ),
                                            ),
                                            onPressed: () => _lift(c.id),
                                          ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          // The papers still to sort.
          Expanded(
            flex: 4,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final c in loose)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _Paper(
                      key: ValueKey('sources_card_${c.id}'),
                      title: _text(context, c.titleKey),
                      text: _text(context, c.textKey),
                      selected: _selected == c.id,
                      onTap: () => _pickCard(c.id),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 24, child: Center(child: PuzzleLabel(status))),
        ],
      ),
    );
  }
}

class _Paper extends StatelessWidget {
  const _Paper({
    required this.title,
    required this.text,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String title;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 230,
        transform: Matrix4.translationValues(0, selected ? -8 : 0, 0),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: StillroomPalette.paper,
          border: Border.all(
            color: selected
                ? StillroomPalette.gaslight
                : const Color(0xFF8A6A3A),
            width: selected ? 3 : 1,
          ),
          boxShadow: const [BoxShadow(blurRadius: 8, color: Color(0x88000000))],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: AppTheme.smallCaps,
                  fontSize: 14,
                  color: StillroomPalette.oxblood,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: const TextStyle(
                  fontFamily: AppTheme.serif,
                  fontSize: 13,
                  height: 1.25,
                  color: StillroomPalette.inkOnPaper,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
