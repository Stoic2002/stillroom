import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// A compositor's type case and composing stick. Every sort shows its
/// letter cut in mirror; the proof above shows what the line prints. Tap a
/// sort to set it; Take out removes the last.
class ComposeView extends StatefulWidget {
  const ComposeView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<ComposeView> createState() => _ComposeViewState();
}

class _ComposeViewState extends State<ComposeView>
    with SolvesAfterPause<ComposeView> {
  late final _config = widget.context.puzzle.config as ComposeConfig;
  late ComposeState _state = _config.start();
  late final _case = [
    ..._config.sortCase,
    if (_config.hasSpace) const Sort(' '),
  ];

  void _set(Sort sort) {
    if (isSolved || _state.isFull) return;
    final next = _state.set(sort);
    setState(() => _state = next);
    widget.context.feedback(UiSound.typeSort);
    if (next.isSolved) {
      widget.context.feedback(UiSound.solved);
      markSolved(widget.context.onSolved);
    } else if (next.isFull) {
      widget.context.feedback(UiSound.mistake);
    }
  }

  void _takeOut() {
    if (isSolved || _state.stick.isEmpty) return;
    setState(() => _state = _state.takeOut());
    widget.context.feedback(UiSound.lift);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wrong = _state.wrong;
    final status = _state.isFull && !_state.isSolved
        ? l10n.composeWrong
        : l10n.composeInstruction;
    return Padding(
      padding: const EdgeInsets.fromLTRB(56, 14, 56, 8),
      child: Column(
        children: [
          // The proof: the line as it prints.
          Container(
            key: const ValueKey('compose_proof'),
            height: 56,
            width: double.infinity,
            color: const Color(0xFFE8E0CC),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (i, sort) in _state.stick.indexed)
                  _Glyph(
                    sort.letter,
                    mirrored: sort.wrongWay,
                    size: 30,
                    color: wrong.contains(i) && _state.isFull
                        ? StillroomPalette.oxbloodBright
                        : const Color(0xFF15120F),
                  ),
                for (var i = _state.stick.length; i < _config.text.length; i++)
                  const _Glyph('_', size: 30, color: Color(0x55000000)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // The stick: the sorts' faces, as set.
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF6E6E70),
              border: Border.all(color: const Color(0xFF2A2A2C), width: 2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Row(
                      children: [
                        for (final sort in _state.stick)
                          _SortFace(sort, width: 30, height: 40),
                      ],
                    ),
                  ),
                ),
                TextButton(
                  key: const ValueKey('compose_back'),
                  onPressed: isSolved || _state.stick.isEmpty ? null : _takeOut,
                  child: Text(
                    l10n.composeTakeOut,
                    style: const TextStyle(color: StillroomPalette.paper),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // The case.
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: StillroomPalette.walnut,
                border: Border.all(
                  color: StillroomPalette.walnutLight,
                  width: 3,
                ),
              ),
              child: GridView.count(
                crossAxisCount: 8,
                padding: const EdgeInsets.all(8),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.25,
                children: [
                  for (final sort in _case)
                    GestureDetector(
                      key: ValueKey(
                        sort.letter == ' '
                            ? 'compose_sort_space'
                            : 'compose_sort_${sort.letter}${sort.wrongWay ? '_wrong' : ''}',
                      ),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _set(sort),
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E1812),
                        ),
                        child: Center(
                          child: _SortFace(sort, width: 46, height: 58),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 26, child: Center(child: PuzzleLabel(status))),
        ],
      ),
    );
  }
}

/// A sort seen from its face: the letter cut in mirror (or, for a wrongly
/// cut one, the right way round); a quad is a plain block.
class _SortFace extends StatelessWidget {
  const _SortFace(this.sort, {required this.width, required this.height});

  final Sort sort;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: const Color(0xFF8C8C90),
        border: Border.all(color: const Color(0xFF3A3A3E)),
      ),
      alignment: Alignment.center,
      child: sort.letter == ' '
          ? null
          : _Glyph(
              sort.letter,
              mirrored: !sort.wrongWay,
              size: height * 0.62,
              color: const Color(0xFF1A1A1C),
            ),
    );
  }
}

class _Glyph extends StatelessWidget {
  const _Glyph(
    this.letter, {
    required this.size,
    required this.color,
    this.mirrored = false,
  });

  final String letter;
  final double size;
  final Color color;
  final bool mirrored;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      letter,
      style: TextStyle(
        fontFamily: 'OldStandard',
        fontSize: size,
        height: 1,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
    return SizedBox(
      width: letter == ' ' ? size * 0.5 : null,
      child: mirrored ? Transform.flip(flipX: true, child: text) : text,
    );
  }
}
