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
            // When elements repeat (Morse dots and dashes), a paper tape
            // shows what has been tapped so far.
            if (_uses.values.any((n) => n > 1))
              Positioned(
                left: 0,
                right: 0,
                bottom: board.height * 0.06,
                child: IgnorePointer(
                  child: Center(
                    child: _Tape(
                      key: const ValueKey('sequence_tape'),
                      marks: [
                        for (final id in _config.solution.take(_state.progress))
                          switch (_config.elements
                              .firstWhere((e) => e.id == id)
                              .labelKey) {
                            final key? => widget.context.text(context, key),
                            null => id,
                          },
                      ],
                    ),
                  ),
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

/// A strip of telegraph tape with the marks tapped so far.
class _Tape extends StatelessWidget {
  const _Tape({required this.marks, super.key});

  final List<String> marks;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 220, minHeight: 40),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: StillroomPalette.paper,
        border: Border.all(color: StillroomPalette.paperShade),
        boxShadow: const [BoxShadow(blurRadius: 8, color: Color(0x88000000))],
      ),
      child: Text(
        marks.join('  '),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 26,
          letterSpacing: 2,
          color: StillroomPalette.inkOnPaper,
        ),
      ),
    );
  }
}
