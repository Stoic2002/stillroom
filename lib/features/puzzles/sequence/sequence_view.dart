import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../core/widgets/content_image.dart';
import '../../../engine/engine.dart';
import '../puzzle_view.dart';

/// Elements placed on the board; tap them in order. A mistake flashes the
/// board and resets.
class SequenceView extends StatefulWidget {
  const SequenceView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<SequenceView> createState() => _SequenceViewState();
}

class _SequenceViewState extends State<SequenceView>
    with SolvesAfterPause<SequenceView> {
  late final _config = widget.context.puzzle.config as SequenceConfig;
  late SequenceState _state = _config.start();
  late final Map<String, int> _uses = {
    for (final id in _config.solution.toSet())
      id: _config.solution.where((s) => s == id).length,
  };
  String? _pressed;
  bool _mistake = false;
  Timer? _feedback;

  @override
  void dispose() {
    _feedback?.cancel();
    super.dispose();
  }

  void _tap(String id) {
    if (isSolved) return;
    final (next, outcome) = _state.tap(id);
    setState(() {
      _state = next;
      _pressed = id;
      _mistake = outcome == SequenceOutcome.mistake;
    });
    _feedback?.cancel();
    _feedback = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() {
        _pressed = null;
        _mistake = false;
      });
    });
    widget.context.feedback(switch (outcome) {
      SequenceOutcome.mistake => UiSound.mistake,
      SequenceOutcome.solved => UiSound.solved,
      SequenceOutcome.progress => UiSound.press,
    });
    if (outcome == SequenceOutcome.solved) markSolved(widget.context.onSolved);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final board = constraints.biggest;
        return Stack(
          children: [
            for (final e in _config.elements)
              Positioned.fromRect(
                rect: boardHitRect(e.rect, board),
                child: GestureDetector(
                  key: ValueKey('element_${e.id}'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _tap(e.id),
                  child: Center(
                    child: AnimatedScale(
                      scale: _pressed == e.id ? 0.92 : 1,
                      duration: const Duration(milliseconds: 90),
                      child: _Element(
                        element: e,
                        size: boardRect(e.rect, board).size,
                        active: _state.active.contains(e.id),
                        // Elements used more than once (e.g. Morse dots)
                        // don't stay lit: it would say nothing.
                        glow: _uses[e.id] == 1,
                        assets: widget.context.assets,
                      ),
                    ),
                  ),
                ),
              ),
            for (final e in _config.elements)
              if (e.labelKey case final key?)
                Positioned(
                  left: boardRect(e.rect, board).left - 24,
                  width: boardRect(e.rect, board).width + 48,
                  top: boardRect(e.rect, board).bottom + 6,
                  child: IgnorePointer(
                    child: PuzzleLabel(widget.context.text(context, key)),
                  ),
                ),
            IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                color: _mistake
                    ? StillroomPalette.oxbloodBright.withValues(alpha: 0.35)
                    : isSolved
                    ? StillroomPalette.gaslight.withValues(alpha: 0.2)
                    : Colors.transparent,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// One element: its image, or its `activeImage` once it is part of the
/// progress; without one, a soft gaslight glow marks it instead.
class _Element extends StatelessWidget {
  const _Element({
    required this.element,
    required this.size,
    required this.active,
    required this.glow,
    required this.assets,
  });

  final SequenceElement element;
  final Size size;
  final bool active;
  final bool glow;
  final Set<String> assets;

  @override
  Widget build(BuildContext context) {
    final activeImage = element.activeImage;
    final image =
        (active && activeImage != null ? activeImage : element.image) ?? '';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        boxShadow: active && glow && activeImage == null
            ? const [BoxShadow(color: Color(0x88E0A84A), blurRadius: 18)]
            : null,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: ContentImage(
          key: ValueKey(image),
          path: image,
          label: element.id,
          assets: assets,
        ),
      ),
    );
  }
}
