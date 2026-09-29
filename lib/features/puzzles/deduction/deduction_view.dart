import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// The jar's label: sentences with blanks, filled from the words the player
/// noted. Tap a blank, then a word; tap a chosen blank again to empty it.
/// "Distil" checks the whole label. Each tale writes its label in its own
/// form ([DeductionForm]): sentences, a ledger, a telegram, a text to
/// correct, or tags pinned to a picture.
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

  /// A text to correct starts with nothing chosen: every blank is written.
  late int? _selected = _config.form == DeductionForm.correction ? null : 0;
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

    final label = switch (_config.form) {
      DeductionForm.sentences ||
      DeductionForm.correction => _paper(context, sentenceStyle),
      DeductionForm.telegram => _telegram(context, sentenceStyle),
      DeductionForm.table => _table(context, sentenceStyle),
      DeductionForm.board => const SizedBox.shrink(),
    };

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

    final check = Row(
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
    );

    if (_config.form == DeductionForm.board) {
      return _board(context, sentenceStyle, bank, check);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(56, 16, 56, 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _config.form == DeductionForm.correction
                  ? l10n.deductionCorrectionInstruction
                  : l10n.deductionInstruction,
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
            check,
          ],
        ),
      ),
    );
  }

  /// The paper label of the jar: sentences one under another.
  Widget _paper(BuildContext context, TextStyle style) => DecoratedBox(
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
                  style: style,
                  children: _sentence(context, i, sentence),
                ),
              ),
            ),
        ],
      ),
    ),
  );

  /// A telegram form: capitals, STOP between the sentences.
  Widget _telegram(BuildContext context, TextStyle style) {
    final l10n = AppLocalizations.of(context);
    final wire = style.copyWith(
      fontFamily: AppTheme.smallCaps,
      letterSpacing: 1.2,
      color: const Color(0xFF2A2A30),
    );
    final stop = l10n.telegramStop;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFE8DDB0),
        border: Border(
          top: BorderSide(color: Color(0xFF9A3A2A), width: 6),
          bottom: BorderSide(color: Color(0xFF9A3A2A), width: 2),
        ),
        boxShadow: [BoxShadow(blurRadius: 18, color: Color(0xAA000000))],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.telegramHeader,
              style: wire.copyWith(
                fontSize: 14,
                letterSpacing: 4,
                color: const Color(0xFF9A3A2A),
              ),
            ),
            const Divider(color: Color(0x662A2A30), height: 12),
            Text.rich(
              TextSpan(
                style: wire,
                children: [
                  for (final (i, sentence) in _config.sentences.indexed) ...[
                    ..._sentence(
                      context,
                      i,
                      sentence,
                      telegram: stop.isNotEmpty,
                    ),
                    if (stop.isNotEmpty) TextSpan(text: '  $stop  '),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A ledger: a heading per row, one blank per column.
  Widget _table(BuildContext context, TextStyle style) {
    final head = style.copyWith(
      fontFamily: AppTheme.smallCaps,
      fontSize: 15,
      color: StillroomPalette.oxblood,
    );
    const line = BorderSide(color: Color(0x662A2420));
    return DecoratedBox(
      decoration: BoxDecoration(
        color: StillroomPalette.paper,
        border: Border.all(color: StillroomPalette.brass, width: 1.5),
        boxShadow: const [BoxShadow(blurRadius: 18, color: Color(0xAA000000))],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {0: IntrinsicColumnWidth()},
          border: const TableBorder(horizontalInside: line),
          children: [
            TableRow(
              children: [
                const SizedBox.shrink(),
                for (final key in _config.columns)
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(widget.context.text(context, key), style: head),
                  ),
              ],
            ),
            for (final (i, row) in _config.sentences.indexed)
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(
                      widget.context.text(context, row.textKey),
                      style: style.copyWith(fontSize: 16),
                    ),
                  ),
                  for (var j = 0; j < row.blanks.length; j++)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _blank(context, _config.firstBlankOf(i) + j),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Tags pinned to the picture behind, each where its sentence belongs;
  /// the words and the check down the right-hand side, from
  /// [boardWordsFrom] across.
  Widget _board(
    BuildContext context,
    TextStyle style,
    Widget bank,
    Widget check,
  ) {
    final tag = style.copyWith(fontSize: 14, height: 1.3);
    return LayoutBuilder(
      builder: (context, constraints) {
        final board = constraints.biggest;
        return Stack(
          children: [
            for (final (i, sentence) in _config.sentences.indexed)
              Positioned.fromRect(
                rect: boardRect(sentence.rect!, board),
                // A tag only as tall as its words: the picture shows round it.
                child: Align(
                  alignment: Alignment.topLeft,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Color(0xCCEDE4CE),
                      boxShadow: [
                        BoxShadow(blurRadius: 8, color: Color(0x88000000)),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
                      child: Text.rich(
                        TextSpan(
                          style: tag,
                          children: _sentence(context, i, sentence),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // The words and the check keep the right third of the board.
            Positioned(
              left: board.width * boardWordsFrom,
              right: 12,
              top: 12,
              bottom: 8,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [bank, const SizedBox(height: 8), check],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _blank(BuildContext context, int blank) {
    final id = _state.filled[blank];
    final initial = _initialOf(blank);
    return _Blank(
      key: ValueKey('blank_$blank'),
      label: id == null ? null : _label(context, id),
      selected: _selected == blank && !isSolved,
      solved: isSolved,
      // In a text to correct, the words as first written are print; the
      // player's are in ink.
      written: id != null && id == initial,
      compact: _config.form == DeductionForm.board,
      onTap: () => _tapBlank(blank),
    );
  }

  String? _initialOf(int blank) {
    for (final (i, s) in _config.sentences.indexed) {
      final first = _config.firstBlankOf(i);
      if (blank >= first && blank < first + s.blanks.length) {
        return s.initial?[blank - first];
      }
    }
    return null;
  }

  List<InlineSpan> _sentence(
    BuildContext context,
    int index,
    DeductionSentence sentence, {
    bool telegram = false,
  }) {
    final written = widget.context.text(context, sentence.textKey);
    // A telegram is in capitals, and STOP stands for the full stop.
    final text = telegram
        ? written.toUpperCase().replaceFirst(RegExp(r'[.。]\s*$'), '')
        : written;
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
            child: _blank(context, blank),
          ),
        );
      }
      at = match.end;
    }
    spans.add(TextSpan(text: text.substring(at)));
    return spans;
  }
}

/// Where a board label's word column starts, as a share of the board's
/// width: keep a board's sentence rects to the left of it.
const boardWordsFrom = 0.64;

class _Blank extends StatelessWidget {
  const _Blank({
    required this.label,
    required this.selected,
    required this.solved,
    required this.onTap,
    this.written = false,
    this.compact = false,
    super.key,
  });

  /// Smaller, for tags pinned to a picture.
  final bool compact;

  final String? label;
  final bool selected;
  final bool solved;

  /// The word as the text was first written (a text to correct): set in
  /// print, not the player's ink.
  final bool written;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = label;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: EdgeInsets.symmetric(horizontal: 3, vertical: compact ? 1 : 2),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: compact ? 1 : 3),
        constraints: BoxConstraints(
          minWidth: compact ? 56 : 72,
          minHeight: compact ? 26 : 32,
        ),
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
            fontSize: compact ? 15 : 18,
            fontStyle: text == null || written
                ? FontStyle.normal
                : FontStyle.italic,
            color: solved
                ? StillroomPalette.oxblood
                : written
                ? StillroomPalette.inkOnPaper.withValues(alpha: 0.7)
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
