import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// One square sheet, written all round, its passages at quarter turns to
/// one another; beside it the question, the arrows that turn the sheet,
/// and the count answered. A passage can be tapped as the answer only
/// once the sheet is turned so that it stands upright.
class MarginsView extends StatefulWidget {
  const MarginsView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<MarginsView> createState() => _MarginsViewState();
}

enum _Note { none, unreadable, wrong }

class _MarginsViewState extends State<MarginsView>
    with SolvesAfterPause<MarginsView> {
  late final _config = widget.context.puzzle.config as MarginsConfig;
  late MarginsState _state = _config.start();
  _Note _note = _Note.none;

  /// Quarter turns made, not wrapped, so the sheet turns the short way.
  late int _turns = _config.startTurn;

  void _rotate(int by) {
    if (isSolved) return;
    setState(() {
      _state = _state.rotate(by);
      _turns += by;
      _note = _Note.none;
    });
    widget.context.feedback(UiSound.sheetTurn);
  }

  void _tap(int i) {
    if (isSolved) return;
    final judged = _state.judge(i);
    final next = _state.answer(i);
    setState(() {
      _state = next;
      _note = switch (judged) {
        MarginsAnswer.unreadable => _Note.unreadable,
        MarginsAnswer.wrong => _Note.wrong,
        _ => _Note.none,
      };
    });
    if (next.isSolved) {
      widget.context.feedback(UiSound.solved);
      markSolved(widget.context.onSolved);
      return;
    }
    widget.context.feedback(switch (judged) {
      MarginsAnswer.right => UiSound.place,
      MarginsAnswer.wrong => UiSound.mistake,
      _ => UiSound.reject,
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final question = _state.current;
    final status = switch (_note) {
      _Note.unreadable => l10n.marginsUnreadable,
      _Note.wrong => l10n.marginsWrong,
      _Note.none => l10n.marginsProgress(
        _state.answered,
        _config.questions.length,
      ),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(52, 8, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: AnimatedRotation(
                  turns: _turns / 4,
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOut,
                  child: CustomPaint(
                    key: const ValueKey('margins_sheet'),
                    painter: const _FormPainter(),
                    child: LayoutBuilder(
                      builder: (context, box) => Stack(
                        children: [
                          for (final (i, p) in _config.passages.indexed)
                            Positioned(
                              left: p.rect.$1 * box.maxWidth,
                              top: p.rect.$2 * box.maxHeight,
                              width: p.rect.$3 * box.maxWidth,
                              height: p.rect.$4 * box.maxHeight,
                              child: GestureDetector(
                                key: ValueKey('margins_passage_$i'),
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _tap(i),
                                child: RotatedBox(
                                  quarterTurns: (4 - p.turn) % 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.topLeft,
                                      child: SizedBox(
                                        width: _lineWidth(p, box),
                                        child: Text(
                                          widget.context.text(
                                            context,
                                            p.textKey,
                                          ),
                                          style: TextStyle(
                                            fontFamily: p.printed
                                                ? AppTheme.smallCaps
                                                : AppTheme.serif,
                                            fontStyle: p.printed
                                                ? FontStyle.normal
                                                : FontStyle.italic,
                                            fontSize: 12,
                                            height: 1.2,
                                            color: p.printed
                                                ? const Color(0xFF3A3630)
                                                : const Color(0xFF2A2440),
                                          ),
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
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 220,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8DCC0),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        question == null
                            ? status
                            : widget.context.text(
                                context,
                                question.questionKey,
                              ),
                        key: const ValueKey('margins_question'),
                        style: const TextStyle(
                          fontFamily: AppTheme.serif,
                          fontSize: 15,
                          height: 1.3,
                          color: Color(0xFF241A10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      key: const ValueKey('margins_left'),
                      onPressed: isSolved ? null : () => _rotate(-1),
                      icon: const Icon(Icons.rotate_left),
                      color: StillroomPalette.paper,
                    ),
                    IconButton(
                      key: const ValueKey('margins_right'),
                      onPressed: isSolved ? null : () => _rotate(1),
                      icon: const Icon(Icons.rotate_right),
                      color: StillroomPalette.paper,
                    ),
                  ],
                ),
                PuzzleLabel(
                  _note == _Note.none
                      ? '${l10n.marginsInstruction}\n$status'
                      : status,
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The width a passage's lines run, in its own upright frame.
  double _lineWidth(MarginsPassage p, BoxConstraints box) {
    final w = p.rect.$3 * box.maxWidth;
    final h = p.rect.$4 * box.maxHeight;
    final along = p.turn.isOdd ? h : w;
    return math.max(40, along - 4);
  }
}

/// The printed form: aged paper, a ruled border, faint lines of print
/// where the heading runs in other languages, foxing.
class _FormPainter extends CustomPainter {
  const _FormPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final sheet = Offset.zero & size;
    canvas
      ..drawRect(
        sheet.shift(const Offset(0, 5)),
        Paint()
          ..color = const Color(0x99000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      )
      ..drawRect(
        sheet,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8DDC0), Color(0xFFD8C8A0)],
          ).createShader(sheet),
      )
      ..drawRect(
        sheet.deflate(size.width * 0.12),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0x553A3630),
      );
    final random = math.Random(1848);
    for (var i = 0; i < 14; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        2 + random.nextDouble() * 6,
        Paint()..color = const Color(0x22806040),
      );
    }
  }

  @override
  bool shouldRepaint(_FormPainter old) => false;
}
