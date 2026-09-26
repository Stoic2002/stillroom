import 'package:flutter/material.dart';

import '../../../core/theme/stillroom_palette.dart';
import '../../../core/widgets/content_image.dart';
import '../../../engine/engine.dart';
import '../puzzle_view.dart';

/// Slots on the board and a tray of pieces along the bottom. Tap a piece,
/// then a slot; tap a filled slot to pick its piece up again.
class SlotPlacementView extends StatefulWidget {
  const SlotPlacementView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<SlotPlacementView> createState() => _SlotPlacementViewState();
}

class _SlotPlacementViewState extends State<SlotPlacementView>
    with SolvesAfterPause<SlotPlacementView> {
  late final _config = widget.context.puzzle.config as SlotPlacementConfig;
  late SlotPlacementState _state = _config.start(widget.context.game);

  static const _gold = StillroomPalette.gaslight;

  void _update(SlotPlacementState next) {
    if (isSolved) return;
    setState(() => _state = next);
    if (_state.isSolved) markSolved(widget.context.onSolved);
  }

  /// A piece's own image, else its item's icon, else a placeholder.
  Widget _pieceImage(String pieceId) {
    final piece = _config.piece(pieceId);
    final itemId = piece.item;
    final path =
        piece.image ??
        (itemId == null ? null : widget.context.content.items[itemId]?.icon);
    return ContentImage(
      path: path ?? '',
      label: piece.id,
      assets: widget.context.assets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final board = constraints.biggest;
        final pieceSize = (board.height * 0.14).clamp(minTapSizeDp, 110.0);
        return Stack(
          children: [
            for (final slot in _config.slots)
              Positioned.fromRect(
                rect: boardHitRect(slot.rect, board),
                child: GestureDetector(
                  key: ValueKey('slot_${slot.id}'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _update(_state.tapSlot(slot.id)),
                  child: Center(
                    child: _Framed(
                      size: boardRect(slot.rect, board).size,
                      highlighted:
                          isSolved ||
                          (_state.selected != null &&
                              _state.placed[slot.id] == _state.selected),
                      child: switch (_state.placed[slot.id]) {
                        final piece? => _pieceImage(piece),
                        null => const SizedBox.expand(),
                      },
                    ),
                  ),
                ),
              ),
            for (final slot in _config.slots)
              if (slot.labelKey case final key?)
                Positioned(
                  left: boardRect(slot.rect, board).left - 24,
                  width: boardRect(slot.rect, board).width + 48,
                  top: boardRect(slot.rect, board).bottom + 6,
                  child: IgnorePointer(
                    child: PuzzleLabel(widget.context.text(context, key)),
                  ),
                ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 12,
                  children: [
                    for (final piece in _state.tray)
                      GestureDetector(
                        key: ValueKey('piece_$piece'),
                        onTap: () => _update(_state.selectPiece(piece)),
                        child: _Framed(
                          size: Size.square(pieceSize),
                          highlighted: _state.selected == piece,
                          child: _pieceImage(piece),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Framed extends StatelessWidget {
  const _Framed({
    required this.size,
    required this.highlighted,
    required this.child,
  });

  final Size size;
  final bool highlighted;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: StillroomPalette.ink.withValues(alpha: 0.5),
        border: Border.all(
          color: highlighted
              ? _SlotPlacementViewState._gold
              : StillroomPalette.paperShade.withValues(alpha: 0.6),
          width: highlighted ? 3 : 1.5,
        ),
      ),
      child: child,
    );
  }
}
