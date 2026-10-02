import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// A city's grid of named streets, north up, and an address card beside
/// it. Read the address by its words (north of, south of, east of, west
/// of a crossing) and tap the block it names; the next address follows.
class StreetsView extends StatefulWidget {
  const StreetsView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<StreetsView> createState() => _StreetsViewState();
}

class _StreetsViewState extends State<StreetsView>
    with SolvesAfterPause<StreetsView> {
  late final _config = widget.context.puzzle.config as StreetsConfig;
  late StreetsState _state = _config.start();
  bool _wrong = false;
  (int, int)? _missed;

  void _mark(int c, int r) {
    if (isSolved) return;
    final next = _state.mark(c, r);
    final right = next.found > _state.found;
    setState(() {
      _state = next;
      _wrong = !right;
      _missed = right ? null : (c, r);
    });
    if (next.isSolved) {
      widget.context.feedback(UiSound.solved);
      markSolved(widget.context.onSolved);
    } else {
      widget.context.feedback(right ? UiSound.streetMark : UiSound.mistake);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = _state.current;
    final found = {
      for (final t in _config.targets.take(_state.found)) (t.column, t.row),
    };
    final ink = StillroomPalette.paper.withValues(alpha: 0.85);
    final labelStyle = TextStyle(
      fontFamily: AppTheme.serif,
      fontSize: 11,
      height: 1,
      color: ink,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(52, 8, 24, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: LayoutBuilder(
              builder: (context, box) {
                const top = 80.0;
                const left = 92.0;
                final cols = _config.columns.length;
                final rows = _config.rows.length;
                final cw = (box.maxWidth - left - 6) / (cols - 1);
                final rh = (box.maxHeight - top - 6) / (rows - 1);
                double x(int c) => left + cw * c;
                double y(int r) => top + rh * r;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _GridPainter(
                          left: left,
                          top: top,
                          columns: cols,
                          rows: rows,
                          cw: cw,
                          rh: rh,
                        ),
                      ),
                    ),
                    // Street names: north–south streets along the top,
                    // turned; east–west streets down the left.
                    for (var c = 0; c < cols; c++)
                      Positioned(
                        left: x(c) - 7,
                        top: 0,
                        width: 14,
                        height: top - 4,
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Text(
                            widget.context.text(context, _config.columns[c]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: labelStyle,
                          ),
                        ),
                      ),
                    for (var r = 0; r < rows; r++)
                      Positioned(
                        left: 0,
                        top: y(r) - 13,
                        width: left - 6,
                        height: 26,
                        child: Text(
                          widget.context.text(context, _config.rows[r]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: labelStyle,
                        ),
                      ),
                    for (var c = 0; c < cols - 1; c++)
                      for (var r = 0; r < rows - 1; r++)
                        Positioned(
                          left: x(c) + 2,
                          top: y(r) + 2,
                          width: cw - 4,
                          height: rh - 4,
                          child: GestureDetector(
                            key: ValueKey('streets_block_${c}_$r'),
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _mark(c, r),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: found.contains((c, r))
                                    ? const Color(0xCCB0302A)
                                    : _missed == (c, r)
                                    ? const Color(0x33E8C87A)
                                    : const Color(0x14E8DCC0),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: found.contains((c, r))
                                  ? const Center(
                                      child: Icon(
                                        Icons.temple_buddhist_outlined,
                                        size: 18,
                                        color: StillroomPalette.paper,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                    // North.
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Row(
                        children: [
                          Icon(Icons.north, size: 14, color: ink),
                          Text('N', style: labelStyle.copyWith(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8DCC0),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: const [
                        BoxShadow(color: Color(0x88000000), blurRadius: 6),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            current == null
                                ? l10n.streetsProgress(
                                    _state.found,
                                    _config.targets.length,
                                  )
                                : widget.context.text(context, current.clueKey),
                            key: const ValueKey('streets_clue'),
                            style: const TextStyle(
                              fontFamily: AppTheme.serif,
                              fontSize: 14,
                              height: 1.3,
                              color: Color(0xFF241A10),
                            ),
                          ),
                          const Divider(color: Color(0x66241A10), height: 18),
                          Text(
                            l10n.streetsInstruction,
                            style: const TextStyle(
                              fontFamily: AppTheme.serif,
                              fontStyle: FontStyle.italic,
                              fontSize: 12.5,
                              height: 1.25,
                              color: Color(0xFF5A4A36),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                PuzzleLabel(
                  _wrong
                      ? l10n.streetsWrong
                      : l10n.streetsProgress(
                          _state.found,
                          _config.targets.length,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The streets: pale lines on a dark ground, the blocks between them.
class _GridPainter extends CustomPainter {
  const _GridPainter({
    required this.left,
    required this.top,
    required this.columns,
    required this.rows,
    required this.cw,
    required this.rh,
  });

  final double left;
  final double top;
  final int columns;
  final int rows;
  final double cw;
  final double rh;

  @override
  void paint(Canvas canvas, Size size) {
    final street = Paint()
      ..color = const Color(0xFFCDBF9C)
      ..strokeWidth = 2;
    final bottom = top + rh * (rows - 1);
    final right = left + cw * (columns - 1);
    for (var c = 0; c < columns; c++) {
      final x = left + cw * c;
      canvas.drawLine(Offset(x, top - 4), Offset(x, bottom + 4), street);
    }
    for (var r = 0; r < rows; r++) {
      final y = top + rh * r;
      canvas.drawLine(Offset(left - 4, y), Offset(right + 4, y), street);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.cw != cw || old.rh != rh;
}
