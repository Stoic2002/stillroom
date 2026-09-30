import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// A shelf of files standing spine out. Look away: the lamp gutters, the
/// room goes dark for a moment, and when it comes back something on the
/// shelf is new. Tap the new one.
class UnwatchedView extends StatefulWidget {
  const UnwatchedView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<UnwatchedView> createState() => _UnwatchedViewState();
}

class _UnwatchedViewState extends State<UnwatchedView>
    with SingleTickerProviderStateMixin, SolvesAfterPause<UnwatchedView> {
  late final _config = widget.context.puzzle.config as UnwatchedConfig;
  late UnwatchedState _state = _config.startState();
  bool _wrong = false;

  /// The dark while looking away: in, the shelf changes, out.
  late final _dark = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void dispose() {
    _dark.dispose();
    super.dispose();
  }

  Future<void> _lookAway() async {
    if (isSolved || !_state.looking || _dark.isAnimating) return;
    widget.context.feedback(UiSound.lampGutter);
    setState(() => _wrong = false);
    await _dark.animateTo(1, duration: const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() => _state = _state.lookAway());
    await _dark.animateTo(0, duration: const Duration(milliseconds: 450));
  }

  void _tap(String id) {
    if (isSolved || _state.added == null || _dark.isAnimating) return;
    final next = _state.tap(id);
    final found = next.round > _state.round;
    setState(() {
      _state = next;
      _wrong = !found;
    });
    if (next.isSolved) {
      widget.context.feedback(UiSound.solved);
      markSolved(widget.context.onSolved);
    } else {
      widget.context.feedback(found ? UiSound.note : UiSound.mistake);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = _wrong
        ? l10n.unwatchedWrong
        : _state.looking
        ? l10n.unwatchedInstruction
        : l10n.unwatchedFind;
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(56, 18, 56, 8),
          child: Column(
            children: [
              Text(
                l10n.unwatchedProgress(_state.round, _config.rounds.length),
                style: const TextStyle(
                  fontFamily: AppTheme.smallCaps,
                  fontSize: 15,
                  color: StillroomPalette.paperShade,
                ),
              ),
              const SizedBox(height: 8),
              // The shelf.
              Expanded(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: StillroomPalette.walnutLight,
                        width: 10,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final id in _state.shelf)
                        Expanded(
                          child: _Spine(
                            key: ValueKey('unwatched_item_$id'),
                            label: widget.context.text(
                              context,
                              _config.item(id).labelKey,
                            ),
                            date: switch (_config.item(id).dateKey) {
                              final d? => widget.context.text(context, d),
                              null => null,
                            },
                            tone: id.codeUnits.fold(0, (a, b) => a + b),
                            onTap: () => _tap(id),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: FilledButton(
                  key: const ValueKey('unwatched_look'),
                  onPressed: isSolved || !_state.looking ? null : _lookAway,
                  child: Text(l10n.unwatchedLookAway),
                ),
              ),
              SizedBox(height: 26, child: Center(child: PuzzleLabel(status))),
            ],
          ),
        ),
        // The dark while looking away.
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _dark,
            builder: (context, _) => ColoredBox(
              color: Colors.black.withValues(alpha: _dark.value * 0.96),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }
}

/// A file standing on the shelf, its name on the spine.
class _Spine extends StatelessWidget {
  const _Spine({
    required this.label,
    required this.date,
    required this.tone,
    required this.onTap,
    super.key,
  });

  final String label;
  final String? date;
  final int tone;
  final VoidCallback onTap;

  static const _boards = [
    Color(0xFF7A6448),
    Color(0xFF6E5A40),
    Color(0xFF84704E),
    Color(0xFF6A5A48),
  ];

  @override
  Widget build(BuildContext context) {
    final heights = [0.94, 0.88, 0.97, 0.9];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: FractionallySizedBox(
        heightFactor: heights[tone.abs() % heights.length],
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: _boards[tone.abs() % _boards.length],
            border: Border.all(color: const Color(0xFF2A1E14), width: 1.5),
            boxShadow: const [
              BoxShadow(blurRadius: 4, color: Color(0x88000000)),
            ],
          ),
          child: Column(
            children: [
              // A paper label, and the tape round the file.
              Container(
                height: 6,
                margin: const EdgeInsets.only(top: 10),
                color: const Color(0xFF8A2A22),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                  color: StillroomPalette.paper,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: label),
                              if (date case final d?)
                                TextSpan(
                                  text: '   $d',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: StillroomPalette.faded,
                                  ),
                                ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: AppTheme.serif,
                            fontSize: 17,
                            height: 1.1,
                            color: StillroomPalette.inkOnPaper,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
