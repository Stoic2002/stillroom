import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// A letter in numbers on the left, the worksheet on the right. Tap a
/// number in the letter, then the same number on the worksheet: its
/// syllable is written over every group with that number. Numbers that are
/// on no worksheet stay as they are, ringed once the rest is read.
class CipherView extends StatefulWidget {
  const CipherView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<CipherView> createState() => _CipherViewState();
}

class _CipherViewState extends State<CipherView>
    with SolvesAfterPause<CipherView> {
  late final _config = widget.context.puzzle.config as CipherConfig;
  late CipherState _state = _config.start();
  int? _selected;

  void _selectGroup(int index) {
    if (isSolved || _state.textAt(index) != null) return;
    if (!_config.key.containsKey(_config.groups[index])) {
      // A number on no worksheet: there is nothing to read it with.
      widget.context.feedback(UiSound.reject);
      return;
    }
    setState(() => _selected = index);
    widget.context.feedback(UiSound.tap);
  }

  void _pick(String code) {
    final index = _selected;
    if (isSolved || index == null) return;
    final next = _state.match(index, code);
    final read = next.read.length > _state.read.length;
    setState(() {
      _state = next;
      if (read) _selected = null;
    });
    widget.context.feedback(read ? UiSound.note : UiSound.mistake);
    if (next.isSolved) {
      widget.context.feedback(UiSound.solved);
      markSolved(widget.context.onSolved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lines = <List<int>>[];
    var start = 0;
    for (final end in [..._config.lines, _config.groups.length]) {
      lines.add([for (var i = start; i < end; i++) i]);
      start = end;
    }
    final entries = _config.key.entries.toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(56, 20, 24, 12),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // The letter.
                Expanded(
                  flex: 3,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8DDBE),
                      border: Border.all(color: const Color(0xFF8A6A3A)),
                      boxShadow: const [
                        BoxShadow(blurRadius: 16, color: Color(0xAA000000)),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final line in lines)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  for (final i in line)
                                    _Group(
                                      key: ValueKey('cipher_group_$i'),
                                      code: _config.groups[i],
                                      text: _state.textAt(i),
                                      selected: _selected == i,
                                      unknown:
                                          isSolved &&
                                          _config.unknown.contains(
                                            _config.groups[i],
                                          ),
                                      onTap: () => _selectGroup(i),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // The worksheet.
                Expanded(
                  flex: 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2EEE2),
                      border: Border.all(color: const Color(0xFF9AA0A8)),
                    ),
                    child: GridView.count(
                      crossAxisCount: 3,
                      childAspectRatio: 2.1,
                      padding: const EdgeInsets.all(8),
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      children: [
                        for (final e in entries)
                          _Entry(
                            key: ValueKey('cipher_key_${e.key}'),
                            code: e.key,
                            text: e.value,
                            onTap: () => _pick(e.key),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          PuzzleLabel(l10n.cipherInstruction),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({
    required this.code,
    required this.text,
    required this.selected,
    required this.unknown,
    required this.onTap,
    super.key,
  });

  final String code;
  final String? text;
  final bool selected;

  /// On no worksheet: ringed in pencil once the rest is read.
  final bool unknown;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: minTapSizeDp,
          minHeight: minTapSizeDp,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: selected ? const Color(0x55E0A84A) : null,
          border: unknown
              ? Border.all(color: StillroomPalette.oxbloodBright, width: 2)
              : Border(
                  bottom: BorderSide(
                    color: selected
                        ? StillroomPalette.gaslight
                        : const Color(0x552A2420),
                  ),
                ),
          borderRadius: unknown ? BorderRadius.circular(20) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text ?? ' ',
              style: const TextStyle(
                fontFamily: AppTheme.serif,
                fontStyle: FontStyle.italic,
                fontSize: 16,
                color: StillroomPalette.oxblood,
              ),
            ),
            Text(
              code,
              style: TextStyle(
                fontFamily: AppTheme.serif,
                fontSize: 19,
                color: text == null
                    ? StillroomPalette.inkOnPaper
                    : StillroomPalette.faded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({
    required this.code,
    required this.text,
    required this.onTap,
    super.key,
  });

  final String code;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE6E0D0),
      child: InkWell(
        onTap: onTap,
        splashColor: const Color(0x33A88B4A),
        child: Center(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$code  ',
                  style: const TextStyle(
                    fontFamily: AppTheme.serif,
                    fontSize: 16,
                    color: Color(0xFF2A2A30),
                  ),
                ),
                TextSpan(
                  text: text,
                  style: const TextStyle(
                    fontFamily: AppTheme.serif,
                    fontStyle: FontStyle.italic,
                    fontSize: 15,
                    color: StillroomPalette.oxblood,
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
