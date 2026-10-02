import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// A section through the moat's fill, from the top down: each layer a band
/// of earth with its finds in it. Tap a find to read it; tap a layer, then
/// a year, to date it; once every layer is dated, mark the layer of the
/// fire.
class StrataView extends StatefulWidget {
  const StrataView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<StrataView> createState() => _StrataViewState();
}

enum _Note { none, find, wrong, notBurnt, tooLate }

class _StrataViewState extends State<StrataView>
    with SolvesAfterPause<StrataView> {
  late final _config = widget.context.puzzle.config as StrataConfig;
  late StrataState _state = _config.start();
  int _picked = 0;
  _Note _note = _Note.none;
  StrataFind? _find;
  int? _fireMarked;

  void _pick(int i) {
    if (isSolved) return;
    setState(() {
      _picked = i;
      _note = _Note.none;
    });
    widget.context.feedback(UiSound.tap);
  }

  void _read(int layer, StrataFind find) {
    setState(() {
      _picked = layer;
      _find = find;
      _note = _Note.find;
    });
    widget.context.feedback(UiSound.findLift);
  }

  void _date(int year) {
    if (isSolved || _state.dated.containsKey(_picked)) return;
    final next = _state.date(_picked, year);
    final right = next.dated.containsKey(_picked);
    setState(() {
      _state = next;
      _note = right ? _Note.none : _Note.wrong;
      // Move on to the next layer still to date, from the top.
      if (right) {
        final rest = [
          for (var i = 0; i < _config.layers.length; i++)
            if (!next.dated.containsKey(i)) i,
        ];
        if (rest.isNotEmpty) _picked = rest.first;
      }
    });
    widget.context.feedback(right ? UiSound.strataTag : UiSound.mistake);
  }

  void _markFire() {
    if (isSolved) return;
    final judged = _state.judgeFire(_picked);
    final next = _state.markFire(_picked);
    setState(() {
      _state = next;
      _note = switch (judged) {
        StrataFire.notBurnt => _Note.notBurnt,
        StrataFire.tooLate => _Note.tooLate,
        _ => _Note.none,
      };
      if (next.isSolved) _fireMarked = _picked;
    });
    if (next.isSolved) {
      widget.context.feedback(UiSound.solved);
      markSolved(widget.context.onSolved);
    } else {
      widget.context.feedback(UiSound.mistake);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final find = _find;
    final status = switch (_note) {
      _Note.find when find != null =>
        '${widget.context.text(context, find.labelKey)}.',
      _Note.wrong => l10n.strataWrong,
      _Note.notBurnt => l10n.strataNotBurnt,
      _Note.tooLate => l10n.strataTooLate,
      _ when _state.allDated => l10n.strataFireQuestion,
      _ => l10n.strataInstruction,
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(52, 10, 24, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: LayoutBuilder(
              builder: (context, box) {
                final layers = _config.layers.length;
                final h = box.maxHeight / layers;
                return Stack(
                  children: [
                    for (var i = 0; i < layers; i++)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: h * i,
                        height: h,
                        child: GestureDetector(
                          key: ValueKey('strata_layer_$i'),
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _pick(i),
                          child: CustomPaint(
                            painter: _LayerPainter(
                              index: i,
                              burnt: _config.layers[i].burnt,
                              picked: i == _picked,
                              fire: i == _fireMarked,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Row(
                                children: [
                                  for (final (k, f)
                                      in _config.layers[i].finds.indexed)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: GestureDetector(
                                        key: ValueKey('strata_find_${i}_$k'),
                                        onTap: () => _read(i, f),
                                        child: SizedBox(
                                          width: minTapSizeDp,
                                          height: minTapSizeDp,
                                          child: CustomPaint(
                                            painter: _FindPainter(
                                              coin: _isCoin(f.labelKey),
                                              seed: i * 7 + k,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  const Spacer(),
                                  Flexible(
                                    flex: 3,
                                    child: Text(
                                      switch (_state.dated[i]) {
                                        final year? => l10n.strataNotBefore(
                                          year,
                                        ),
                                        null => widget.context.text(
                                          context,
                                          _config.layers[i].labelKey,
                                        ),
                                      },
                                      key: ValueKey('strata_tag_$i'),
                                      textAlign: TextAlign.end,
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontFamily: AppTheme.serif,
                                        fontSize: 13,
                                        height: 1.1,
                                        fontWeight: _state.dated.containsKey(i)
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                        color: _config.layers[i].burnt
                                            ? StillroomPalette.paper
                                            : const Color(0xFF241A10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final year in _config.years)
                      OutlinedButton(
                        key: ValueKey('strata_year_$year'),
                        onPressed: isSolved || _state.allDated
                            ? null
                            : () => _date(year),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(64, minTapSizeDp),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text('$year'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SingleChildScrollView(
                      child: PuzzleLabel(status, maxLines: null),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  key: const ValueKey('strata_fire'),
                  onPressed: !_state.allDated || isSolved ? null : _markFire,
                  child: Text(l10n.strataFire),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Coins are drawn as holed coins; any other find as a sherd.
bool _isCoin(String key) => const {
  'yen',
  'sen',
  'eiraku',
  'kanei',
  'genpo',
}.contains(key.split('.').last);

/// One layer of the section: its earth, a ragged top edge, burnt layers
/// black with fragments of tile, the picked one outlined.
class _LayerPainter extends CustomPainter {
  const _LayerPainter({
    required this.index,
    required this.burnt,
    required this.picked,
    required this.fire,
  });

  final int index;
  final bool burnt;
  final bool picked;
  final bool fire;

  static const _earth = [
    Color(0xFF8A7458),
    Color(0xFF7A5A3A),
    Color(0xFF2A2420),
    Color(0xFF8C8A80),
    Color(0xFF1E1A18),
    Color(0xFF4A4A40),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final base = burnt
        ? const Color(0xFF221D1A)
        : _earth[index % _earth.length];
    final random = math.Random(index * 13 + 1);
    // A ragged top edge where it meets the layer above.
    final top = Path()..moveTo(0, 0);
    for (var x = 0.0; x <= size.width; x += size.width / 12) {
      top.lineTo(x, random.nextDouble() * 4);
    }
    top
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(top, Paint()..color = base);
    // Grit, and for a burnt layer, red-brown fragments of tile.
    for (var i = 0; i < 60; i++) {
      final p = Offset(
        random.nextDouble() * size.width,
        4 + random.nextDouble() * (size.height - 6),
      );
      canvas.drawCircle(
        p,
        0.6 + random.nextDouble() * 1.2,
        Paint()
          ..color = burnt && i.isEven
              ? const Color(0xAA8A4A30)
              : Color.lerp(base, Colors.white, 0.15)!.withValues(alpha: 0.6),
      );
    }
    if (picked || fire) {
      canvas.drawRect(
        (Offset.zero & size).deflate(1.5),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = fire ? const Color(0xFFD04030) : StillroomPalette.gaslight,
      );
    }
  }

  @override
  bool shouldRepaint(_LayerPainter old) =>
      old.picked != picked || old.fire != fire;
}

/// A find in the earth: a holed coin, or a sherd.
class _FindPainter extends CustomPainter {
  const _FindPainter({required this.coin, required this.seed});

  final bool coin;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    if (coin) {
      canvas
        ..drawCircle(
          c,
          size.width * 0.26,
          Paint()..color = const Color(0xFF6A7A5A),
        )
        ..drawCircle(
          c,
          size.width * 0.26,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2
            ..color = const Color(0xFF2A3020),
        )
        ..drawRect(
          Rect.fromCenter(
            center: c,
            width: size.width * 0.12,
            height: size.width * 0.12,
          ),
          Paint()..color = const Color(0xFF2A2018),
        );
    } else {
      // A sherd of a bowl: one curved edge from the rim, the rest
      // broken; a blue band painted along the rim.
      final r = size.width * 0.3;
      final tilt = (seed % 3 - 1) * 0.3;
      canvas
        ..save()
        ..translate(c.dx, c.dy)
        ..rotate(tilt);
      final shard = Path()
        ..moveTo(-r, -r * 0.3)
        ..quadraticBezierTo(0, -r * 0.9, r, -r * 0.35)
        ..lineTo(r * 0.7, r * 0.2)
        ..lineTo(r * 0.85, r * 0.55)
        ..lineTo(-r * 0.2, r * 0.6)
        ..lineTo(-r * 0.6, r * 0.25)
        ..close();
      final band = Path()
        ..moveTo(-r * 0.9, -r * 0.12)
        ..quadraticBezierTo(0, -r * 0.62, r * 0.9, -r * 0.16);
      canvas
        ..drawPath(shard, Paint()..color = const Color(0xFFE6E2D6))
        ..drawPath(
          shard,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = const Color(0xFF4A4438),
        )
        ..drawPath(
          band,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = const Color(0xFF3A5A9A),
        )
        ..restore();
    }
    // A soft ring so it reads as tappable.
    canvas.drawCircle(
      c,
      size.width * 0.42,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x66E8C87A),
    );
  }

  @override
  bool shouldRepaint(_FindPainter old) => false;
}
