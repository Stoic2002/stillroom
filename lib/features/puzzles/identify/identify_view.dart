import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// A specimen (on the puzzle's background, at the left) and a key to name
/// it, at the right: the couplet now asked, its two statements to choose
/// between, and the steps already taken. A path that ends at a wrong name
/// shows what the key says of it, and goes back to where it turned wrong.
class IdentifyView extends StatefulWidget {
  const IdentifyView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<IdentifyView> createState() => _IdentifyViewState();
}

class _IdentifyViewState extends State<IdentifyView>
    with SolvesAfterPause<IdentifyView> {
  late final _config = widget.context.puzzle.config as IdentifyConfig;
  late IdentifyState _state = _config.begin();

  void _choose(int k) {
    if (isSolved) return;
    final next = _state.choose(k);
    setState(() => _state = next);
    if (next.isSolved) {
      widget.context.feedback(UiSound.solved);
      markSolved(widget.context.onSolved);
    } else {
      widget.context.feedback(
        next.wrongEnd != null ? UiSound.mistake : UiSound.keyStep,
      );
    }
  }

  String _text(String key) => widget.context.text(context, key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wrong = _state.wrongEnd;
    final shown = _state.isSolved ? _config.answer : wrong;
    final choices = _config.couplets[_state.couplet]!;
    const ink = StillroomPalette.inkOnPaper;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 28, 8),
      child: Row(
        children: [
          // The specimen lies on the background, at the left.
          const Spacer(flex: 9),
          Expanded(
            flex: 11,
            child: Column(
              children: [
                // The steps taken: one mark per couplet passed.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _state.path.length; i++)
                      Container(
                        key: ValueKey('identify_step_$i'),
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _state.path.length - 1
                              ? StillroomPalette.gaslight
                              : StillroomPalette.paperShade,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (shown != null)
                          Container(
                            key: const ValueKey('identify_note'),
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xEEE6D6B0),
                              border: Border.all(
                                color: _state.isSolved
                                    ? StillroomPalette.gaslight
                                    : const Color(0xFF8A3A2A),
                                width: 2,
                              ),
                            ),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: _state.isSolved
                                        ? _text(_config.names[shown]!.nameKey)
                                        : l10n.identifyWrong(
                                            _text(
                                              _config.names[shown]!.nameKey,
                                            ),
                                          ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '\n${_text(_config.names[shown]!.noteKey)}',
                                  ),
                                ],
                              ),
                              style: const TextStyle(
                                fontFamily: AppTheme.serif,
                                fontSize: 14,
                                height: 1.25,
                                color: ink,
                              ),
                            ),
                          ),

                        for (final (k, choice) in choices.indexed) ...[
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              key: ValueKey('identify_choice_$k'),
                              onPressed: isSolved ? null : () => _choose(k),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: const Color(0xCC1A140E),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                alignment: Alignment.centerLeft,
                              ),
                              child: Text(
                                '${k == 0 ? 'a' : 'b'}.  ${_text(choice.textKey)}',
                                style: const TextStyle(
                                  fontFamily: AppTheme.serif,
                                  fontSize: 15,
                                  height: 1.2,
                                  color: StillroomPalette.paper,
                                ),
                              ),
                            ),
                          ),
                          if (k == 0) const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                ),
                PuzzleLabel(
                  wrong != null ? l10n.identifyBack : l10n.identifyInstruction,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
