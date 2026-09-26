import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// The jar's label: sentences with blanks, filled from the words the player
/// noted. Tap a blank, then a word; tap a chosen blank again to empty it.
/// "Distil" checks the whole label.
class DeductionView extends StatefulWidget {
  const DeductionView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<DeductionView> createState() => _DeductionViewState();
}

class _DeductionViewState extends State<DeductionView>
    with SolvesAfterPause<DeductionView> {
  late final _config = widget.context.puzzle.config as DeductionConfig;
  late DeductionState _state = _config.start(widget.context.game);
  int? _selected = 0;
  DeductionVerdict? _verdict;

  static final _placeholder = RegExp(r'\{(\d+)\}');

  WordDef? _word(String id) => widget.context.content.config.words[id];

  String _label(BuildContext context, String id) {
    final key = _word(id)?.labelKey;
    return key == null ? id : widget.context.text(context, key);
  }

  void _tapBlank(int blank) {
    if (isSolved) return;
    setState(() {
      _verdict = null;
      if (_selected == blank && _state.filled.containsKey(blank)) {
        _state = _state.clear(blank);
      } else {
        _selected = blank;
      }
    });
    widget.context.feedback(UiSound.tap);
  }

  void _tapWord(String id) {
    final blank = _selected;
    if (isSolved || blank == null) return;
    setState(() {
      _verdict = null;
      _state = _state.fill(blank, id);
      // Move on to the next empty blank, if any.
      _selected = [
        for (var i = 1; i <= _state.blankCount; i++)
          (blank + i) % _state.blankCount,
      ].where((b) => !_state.filled.containsKey(b)).firstOrNull;
    });
    widget.context.feedback(UiSound.place);
  }

  void _check() {
    if (isSolved) return;
    final verdict = _state.check();
    setState(() => _verdict = verdict);
    switch (verdict) {
      case DeductionSolved():
        widget.context.feedback(UiSound.solved);
        markSolved(widget.context.onSolved);
      case DeductionIncomplete():
        widget.context.feedback(UiSound.reject);
      case DeductionWrong():
        widget.context.feedback(UiSound.mistake);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const sentenceStyle = TextStyle(
      fontFamily: AppTheme.serif,
      fontSize: 19,
      height: 1.6,
      color: StillroomPalette.inkOnPaper,
    );

    final label = DecoratedBox(
      // The paper label of the jar.
      decoration: BoxDecoration(
        color: StillroomPalette.paper,
        border: Border.all(color: StillroomPalette.brass, width: 1.5),
        boxShadow: const [BoxShadow(blurRadius: 18, color: Color(0xAA000000))],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, sentence) in _config.sentences.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text.rich(
                  TextSpan(
                    style: sentenceStyle,
                    children: _sentence(context, i, sentence),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    final bank = _state.available.isEmpty
        ? Text(
            l10n.deductionNoWords,
            style: const TextStyle(color: StillroomPalette.paperShade),
          )
        : Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final kind in WordKind.values)
                for (final id in _state.available)
                  if (_word(id)?.kind == kind)
                    _WordChip(
                      key: ValueKey('word_$id'),
                      label: _label(context, id),
                      kind: kind,
                      onTap: () => _tapWord(id),
                    ),
            ],
          );

    final verdict = switch (_verdict) {
      DeductionIncomplete() => l10n.deductionIncomplete,
      DeductionWrong(wrong: final n?) => l10n.deductionNearMiss(n),
      DeductionWrong() => l10n.deductionWrong,
      _ => null,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(56, 16, 56, 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.deductionInstruction,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: StillroomPalette.paperShade,
              ),
            ),
            const SizedBox(height: 12),
            label,
            const SizedBox(height: 14),
            bank,
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      verdict ?? '',
                      key: ValueKey(verdict),
                      style: const TextStyle(
                        color: StillroomPalette.oxbloodBright,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: isSolved ? null : _check,
                  child: Text(l10n.deductionCheck),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<InlineSpan> _sentence(
    BuildContext context,
    int index,
    DeductionSentence sentence,
  ) {
    final text = widget.context.text(context, sentence.textKey);
    final first = _config.firstBlankOf(index);
    final spans = <InlineSpan>[];
    var at = 0;
    for (final match in _placeholder.allMatches(text)) {
      spans.add(TextSpan(text: text.substring(at, match.start)));
      final number = int.parse(match.group(1)!);
      final blank = first + number - 1;
      if (number >= 1 && number <= sentence.blanks.length) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: _Blank(
              key: ValueKey('blank_$blank'),
              label: switch (_state.filled[blank]) {
                final id? => _label(context, id),
                null => null,
              },
              selected: _selected == blank && !isSolved,
              solved: isSolved,
              onTap: () => _tapBlank(blank),
            ),
          ),
        );
      }
      at = match.end;
    }
    spans.add(TextSpan(text: text.substring(at)));
    return spans;
  }
}

class _Blank extends StatelessWidget {
  const _Blank({
    required this.label,
    required this.selected,
    required this.solved,
    required this.onTap,
    super.key,
  });

  final String? label;
  final bool selected;
  final bool solved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = label;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        constraints: const BoxConstraints(minWidth: 72, minHeight: 32),
        decoration: BoxDecoration(
          color: selected
              ? StillroomPalette.gaslight.withValues(alpha: 0.35)
              : StillroomPalette.paperShade.withValues(alpha: 0.5),
          border: Border(
            bottom: BorderSide(
              color: solved
                  ? StillroomPalette.oxblood
                  : selected
                  ? StillroomPalette.oxbloodBright
                  : StillroomPalette.inkOnPaper,
              width: selected ? 2.5 : 1.2,
            ),
          ),
        ),
        child: Text(
          text ?? ' ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTheme.serif,
            fontSize: 18,
            fontStyle: text == null ? FontStyle.normal : FontStyle.italic,
            color: solved
                ? StillroomPalette.oxblood
                : StillroomPalette.inkOnPaper,
          ),
        ),
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  const _WordChip({
    required this.label,
    required this.kind,
    required this.onTap,
    super.key,
  });

  final String label;
  final WordKind kind;
  final VoidCallback onTap;

  static Color colorOf(WordKind kind) => switch (kind) {
    WordKind.name => StillroomPalette.gaslight,
    WordKind.place => const Color(0xFF8FB0A0),
    WordKind.date => const Color(0xFFB7A6CC),
    WordKind.number => StillroomPalette.brass,
    WordKind.thing => StillroomPalette.paperShade,
  };

  @override
  Widget build(BuildContext context) {
    final color = colorOf(kind);
    return Material(
      color: StillroomPalette.soot,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: color, width: 3),
              top: const BorderSide(color: StillroomPalette.walnutLight),
              right: const BorderSide(color: StillroomPalette.walnutLight),
              bottom: const BorderSide(color: StillroomPalette.walnutLight),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(color: color, fontFamily: AppTheme.serif),
          ),
        ),
      ),
    );
  }
}
