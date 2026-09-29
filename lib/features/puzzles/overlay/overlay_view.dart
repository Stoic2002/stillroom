import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/widgets/content_image.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// See-through sheets on a board: drag them, tap one to turn it a quarter.
/// A sheet let go close to its place settles there; when every sheet has
/// settled, their lines make one picture.
class OverlayView extends StatefulWidget {
  const OverlayView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<OverlayView> createState() => _OverlayViewState();
}

class _OverlayViewState extends State<OverlayView>
    with SolvesAfterPause<OverlayView> {
  late final _config = widget.context.puzzle.config as OverlayConfig;
  late OverlayPuzzleState _state = _config.start();

  /// Drawing order, bottom first: the sheet last touched is on top.
  late final List<String> _order = [
    // Settled sheets lie underneath the loose ones.
    for (final s in _config.sheets)
      if (_config.start().isPlaced(s.id)) s.id,
    for (final s in _config.sheets)
      if (!_config.start().isPlaced(s.id)) s.id,
  ];
  var _moved = false;

  void _raise(String id) {
    if (_order.last == id) return;
    setState(
      () => _order
        ..remove(id)
        ..add(id),
    );
  }

  void _start(String id) {
    if (isSolved || _state.isPlaced(id)) return;
    _raise(id);
    widget.context.feedback(UiSound.lift);
  }

  void _drag(String id, Offset delta, Size board) {
    if (isSolved) return;
    final next = _state.move(
      id,
      delta.dx / board.width,
      delta.dy / board.height,
    );
    if (identical(next, _state)) return;
    setState(() {
      _state = next;
      _moved = true;
    });
  }

  void _drop(String id) {
    if (isSolved) return;
    final next = _state.drop(id);
    if (identical(next, _state)) return;
    setState(() {
      _state = next;
      // A settled sheet sinks under the loose ones.
      _order
        ..remove(id)
        ..insert(0, id);
    });
    widget.context.feedback(UiSound.place);
    _checkSolved();
  }

  void _turn(String id) {
    if (isSolved || _state.isPlaced(id)) return;
    _raise(id);
    setState(() {
      _state = _state.turn(id);
      _moved = true;
    });
    widget.context.feedback(UiSound.turn);
    // Turned the right way up where it belongs: it settles.
    _drop(id);
  }

  void _checkSolved() {
    if (!_state.isSolved) return;
    widget.context.feedback(UiSound.solved);
    markSolved(widget.context.onSolved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final board = constraints.biggest;
        return Stack(
          fit: StackFit.expand,
          children: [
            for (final id in _order) _sheet(id, board),
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: isSolved ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [Color(0x33F2D9A0), Color(0x00F2D9A0)],
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _moved ? 0 : 1,
                  duration: const Duration(milliseconds: 400),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: PuzzleLabel(l10n.overlayInstruction),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _sheet(String id, Size board) {
    final sheet = _config.sheets.firstWhere((s) => s.id == id);
    final place = _state.place(id);
    final settled = _state.isPlaced(id);
    final w = sheet.rect.width * board.width;
    final h = sheet.rect.height * board.height;
    return Positioned(
      key: ValueKey('sheet_$id'),
      left: place.x * board.width,
      top: place.y * board.height,
      width: w,
      height: h,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _turn(id),
        onPanStart: (_) => _start(id),
        onPanUpdate: (d) => _drag(id, d.delta, board),
        onPanEnd: (_) => _drop(id),
        child: AnimatedRotation(
          turns: place.turns / 4,
          duration: const Duration(milliseconds: 180),
          child: DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: settled
                  ? const []
                  : const [
                      BoxShadow(
                        color: Color(0x55000000),
                        blurRadius: 14,
                        offset: Offset(4, 6),
                      ),
                    ],
            ),
            child: Opacity(
              opacity: settled ? 1 : 0.92,
              child: ContentImage(
                path: sheet.image,
                label: sheet.id,
                assets: widget.context.assets,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
