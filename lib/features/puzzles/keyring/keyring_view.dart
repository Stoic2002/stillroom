import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// A lock plate with its keyhole, the turnkey's ring of keys beside it, and
/// the key in hand below. Tap a key on the ring to take it; tap the key in
/// hand to turn it over; tap the lock to try it.
class KeyringView extends StatefulWidget {
  const KeyringView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<KeyringView> createState() => _KeyringViewState();
}

class _KeyringViewState extends State<KeyringView>
    with SolvesAfterPause<KeyringView> {
  late final _config = widget.context.puzzle.config as KeyringConfig;
  late KeyringState _state = _config.start();
  bool _refused = false;

  void _select(String id) {
    if (isSolved) return;
    setState(() {
      _state = _state.select(id);
      _refused = false;
    });
    widget.context.feedback(UiSound.lift);
  }

  void _flip() {
    if (isSolved || _state.selected == null) return;
    setState(() {
      _state = _state.flip();
      _refused = false;
    });
    widget.context.feedback(UiSound.turn);
  }

  void _try() {
    if (isSolved || _state.selected == null) return;
    final next = _state.tryKey();
    setState(() {
      _state = next;
      _refused = !next.isSolved;
    });
    if (next.isSolved) {
      widget.context.feedback(UiSound.solved);
      markSolved(widget.context.onSolved);
    } else {
      widget.context.feedback(UiSound.keyTry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = _state.selected;
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final keyWidth = math.min(w * 0.3, h * 0.55);
        return Stack(
          children: [
            // The lock plate, left.
            Positioned(
              left: w * 0.06,
              top: h * 0.08,
              width: w * 0.4,
              height: h * 0.5,
              child: GestureDetector(
                key: const ValueKey('keyring_lock'),
                behavior: HitTestBehavior.opaque,
                onTap: _try,
                child: CustomPaint(
                  painter: _LockPainter(_config.profile, open: _state.isSolved),
                ),
              ),
            ),
            // The key in hand, under the lock.
            if (selected != null)
              Positioned(
                left: w * 0.08,
                top: h * 0.62,
                width: keyWidth,
                height: keyWidth * 0.42,
                child: GestureDetector(
                  key: const ValueKey('keyring_hand'),
                  behavior: HitTestBehavior.opaque,
                  onTap: _flip,
                  child: CustomPaint(
                    painter: _KeyPainter(
                      _config.key(selected).seen(flipped: _state.flipped),
                      lit: true,
                    ),
                  ),
                ),
              ),
            // The ring, right: every key hanging from it.
            Positioned(
              left: w * 0.52,
              top: h * 0.06,
              width: w * 0.44,
              height: h * 0.8,
              child: LayoutBuilder(
                builder: (context, box) {
                  final n = _config.keys.length;
                  final rowH = box.maxHeight / n;
                  return Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        width: box.maxWidth * 0.1,
                        height: box.maxHeight,
                        child: const CustomPaint(painter: _RingPainter()),
                      ),
                      for (final (i, key) in _config.keys.indexed)
                        Positioned(
                          left: box.maxWidth * 0.08,
                          top: rowH * i,
                          width: box.maxWidth * 0.8,
                          height: math.max(rowH, minTapSizeDp),
                          child: GestureDetector(
                            key: ValueKey('keyring_key_${key.id}'),
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _select(key.id),
                            child: Opacity(
                              opacity: key.id == selected ? 0.25 : 1,
                              child: CustomPaint(
                                painter: _KeyPainter(key.bits, lit: false),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: PuzzleLabel(
                    _refused
                        ? l10n.keyringWrong
                        : selected == null
                        ? l10n.keyringInstruction
                        : l10n.keyringHand,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The bit's outline: a strip hanging from the shaft, cut from below at
/// each place to its depth (0 to 3 quarters of its height).
Path _bitPath(List<int> cuts, Rect bit) {
  final step = bit.width / cuts.length;
  final path = Path()..moveTo(bit.left, bit.top);
  for (final (i, cut) in cuts.indexed) {
    final bottom = bit.bottom - bit.height * cut / 4;
    path
      ..lineTo(bit.left + step * i, bottom)
      ..lineTo(bit.left + step * (i + 1), bottom);
  }
  return path
    ..lineTo(bit.right, bit.top)
    ..close();
}

class _KeyPainter extends CustomPainter {
  const _KeyPainter(this.cuts, {required this.lit});

  final List<int> cuts;
  final bool lit;

  @override
  void paint(Canvas canvas, Size size) {
    final iron = Paint()
      ..color = lit ? const Color(0xFFB8A070) : const Color(0xFF8A7A5A);
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF2A2018);
    final h = size.height;
    final bow = Offset(h * 0.3, h * 0.3);
    // Bow, shaft, bit.
    canvas
      ..drawCircle(bow, h * 0.24, iron)
      ..drawCircle(bow, h * 0.24, edge)
      ..drawCircle(bow, h * 0.11, Paint()..color = const Color(0xFF1A1410));
    final shaft = Rect.fromLTRB(
      h * 0.52,
      h * 0.24,
      size.width * 0.72,
      h * 0.36,
    );
    canvas
      ..drawRect(shaft, iron)
      ..drawRect(shaft, edge);
    final bit = Rect.fromLTRB(
      size.width * 0.66,
      h * 0.3,
      size.width * 0.96,
      h * 0.92,
    );
    final path = _bitPath(cuts, bit);
    canvas
      ..drawPath(path, iron)
      ..drawPath(path, edge);
  }

  @override
  bool shouldRepaint(_KeyPainter old) => old.cuts != cuts || old.lit != lit;
}

/// A brass lock plate with the keyhole cut the shape of the bit it takes.
class _LockPainter extends CustomPainter {
  const _LockPainter(this.profile, {required this.open});

  final List<int> profile;
  final bool open;

  @override
  void paint(Canvas canvas, Size size) {
    final plate = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.shortestSide * 0.06),
    );
    canvas
      ..drawRRect(plate, Paint()..color = const Color(0xFF8C6F3A))
      ..drawRRect(
        plate,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFF3A2A14),
      );
    for (final at in [
      Offset(size.width * 0.08, size.height * 0.12),
      Offset(size.width * 0.92, size.height * 0.12),
      Offset(size.width * 0.08, size.height * 0.88),
      Offset(size.width * 0.92, size.height * 0.88),
    ]) {
      canvas.drawCircle(
        at,
        size.shortestSide * 0.035,
        Paint()..color = const Color(0xFF4A3A1E),
      );
    }
    // The keyhole: a slot for the shaft, and the bit's shape below its end.
    final hole = Paint()
      ..color = open ? const Color(0xFFE0A84A) : const Color(0xFF0E0B09);
    final slot = Rect.fromLTRB(
      size.width * 0.14,
      size.height * 0.36,
      size.width * 0.6,
      size.height * 0.46,
    );
    final bit = Rect.fromLTRB(
      size.width * 0.52,
      size.height * 0.4,
      size.width * 0.86,
      size.height * 0.84,
    );
    canvas
      ..drawRect(slot, hole)
      ..drawPath(_bitPath(profile, bit), hole);
    if (open) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = const Color(0x22E0A84A),
      );
    }
  }

  @override
  bool shouldRepaint(_LockPainter old) => old.open != open;
}

/// The iron ring the keys hang from.
class _RingPainter extends CustomPainter {
  const _RingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.3, 0, size.width * 0.4, size.height),
        Radius.circular(size.width),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.25
        ..color = StillroomPalette.brass.withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => false;
}
