import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// The wall of a snow pit, its layers from the surface down, each as
/// thick as it is. Tap a layer and push a fist, fingers, a pencil or a
/// knife into it; once its hardness is known, a bar shows it, as on a
/// snow profile. Mark the weak layer; a column is cut down to just below
/// it, and the shovel tapped on top until it breaks.
class SnowpitView extends StatefulWidget {
  const SnowpitView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<SnowpitView> createState() => _SnowpitViewState();
}

enum _Note { none, pushed, untested, notSofter, column, spent, elsewhere }

class _SnowpitViewState extends State<SnowpitView>
    with SolvesAfterPause<SnowpitView> {
  late final _config = widget.context.puzzle.config as SnowpitConfig;
  late SnowpitState _state = _config.start();
  int _picked = 0;
  _Note _note = _Note.none;
  (SnowHardness, bool)? _last;

  void _pick(int i) {
    if (isSolved) return;
    setState(() {
      _picked = i;
      _note = _Note.none;
    });
    widget.context.feedback(UiSound.tap);
  }

  void _push(SnowHardness tool) {
    if (isSolved) return;
    final goes = _config.goesIn(_picked, tool);
    setState(() {
      _state = _state.push(_picked, tool);
      _last = (tool, goes);
      _note = _Note.pushed;
    });
    widget.context.feedback(goes ? UiSound.snowPush : UiSound.reject);
  }

  void _mark() {
    if (isSolved) return;
    final judged = _state.judge(_picked);
    setState(() {
      _state = _state.mark(_picked);
      _note = switch (judged) {
        SnowpitMark.marked => _Note.column,
        SnowpitMark.untested => _Note.untested,
        SnowpitMark.notSofter => _Note.notSofter,
        SnowpitMark.none => _Note.none,
      };
    });
    widget.context.feedback(switch (judged) {
      SnowpitMark.marked => UiSound.place,
      SnowpitMark.notSofter => UiSound.mistake,
      SnowpitMark.untested || SnowpitMark.none => UiSound.reject,
    });
  }

  void _tap() {
    if (isSolved) return;
    final next = _state.tap();
    if (identical(next, _state)) return;
    setState(() {
      _state = next;
      if (next.broken != null && !next.isSolved) _note = _Note.elsewhere;
      if (next.spent) _note = _Note.spent;
    });
    if (next.isSolved) {
      widget.context.feedback(UiSound.columnBreak);
      markSolved(widget.context.onSolved);
    } else if (next.broken != null) {
      widget.context.feedback(UiSound.columnBreak);
    } else {
      widget.context.feedback(UiSound.shovelTap);
    }
  }

  String _tool(AppLocalizations l10n, SnowHardness t) => switch (t) {
    SnowHardness.fist => l10n.toolFist,
    SnowHardness.fourFingers => l10n.toolFourFingers,
    SnowHardness.oneFinger => l10n.toolOneFinger,
    SnowHardness.pencil => l10n.toolPencil,
    SnowHardness.knife => l10n.toolKnife,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final last = _last;
    final status = switch (_note) {
      _Note.pushed when last != null =>
        last.$2
            ? l10n.snowpitIn(_tool(l10n, last.$1))
            : l10n.snowpitOut(_tool(l10n, last.$1)),
      _Note.untested => l10n.snowpitUntested,
      _Note.notSofter => l10n.snowpitNotSofter,
      _Note.column => l10n.snowpitColumn,
      _Note.spent => l10n.snowpitSpent,
      _Note.elsewhere => l10n.snowpitBrokeElsewhere,
      _Note.pushed || _Note.none => l10n.snowpitInstruction,
    };
    final phase = _state.taps <= 10
        ? l10n.snowpitWrist
        : _state.taps <= 20
        ? l10n.snowpitElbow
        : l10n.snowpitShoulder;
    const small = TextStyle(
      fontFamily: AppTheme.smallCaps,
      fontSize: 14,
      color: StillroomPalette.paperShade,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(52, 10, 24, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: LayoutBuilder(
              builder: (context, box) {
                final heights = _PitPainter.layout(_config, box.maxHeight);
                return GestureDetector(
                  key: const ValueKey('snowpit_wall'),
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (d) {
                    var y = 0.0;
                    for (final (i, h) in heights.indexed) {
                      y += h;
                      if (d.localPosition.dy < y) {
                        _pick(i);
                        return;
                      }
                    }
                  },
                  child: CustomPaint(
                    size: box.biggest,
                    painter: _PitPainter(
                      config: _config,
                      state: _state,
                      picked: _picked,
                      heights: heights,
                    ),
                  ),
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
                    for (final t in SnowHardness.values)
                      OutlinedButton(
                        key: ValueKey('snowpit_tool_${t.name}'),
                        onPressed: isSolved ? null : () => _push(t),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, minTapSizeDp),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        child: Text(_tool(l10n, t)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  key: const ValueKey('snowpit_mark'),
                  onPressed: isSolved ? null : _mark,
                  child: Text(l10n.snowpitMark),
                ),
                const Spacer(),
                Text(
                  _state.marked == null
                      ? ''
                      : l10n.snowpitTaps(_state.taps, phase),
                  style: small,
                ),
                const SizedBox(height: 4),
                FilledButton(
                  key: const ValueKey('snowpit_tap'),
                  onPressed:
                      _state.marked == null ||
                          _state.broken != null ||
                          _state.spent ||
                          isSolved
                      ? null
                      : _tap,
                  child: Text(l10n.snowpitTap),
                ),
                const SizedBox(height: 6),
                PuzzleLabel(status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The pit wall in section: layers in shades of snow, the picked one
/// outlined, each known hardness as a bar from the right (longer is
/// harder), the marked layer underlined in red, and the column cut down
/// to just below it, its upper part slid aside once it breaks.
class _PitPainter extends CustomPainter {
  const _PitPainter({
    required this.config,
    required this.state,
    required this.picked,
    required this.heights,
  });

  final SnowpitConfig config;
  final SnowpitState state;
  final int picked;
  final List<double> heights;

  /// Each layer's height in [total]: as thick as it is, but never too
  /// thin to tap.
  static List<double> layout(SnowpitConfig c, double total) {
    const least = 30.0;
    final sum = c.layers.fold(0, (a, l) => a + l.thickness);
    final thin = [for (final l in c.layers) total * l.thickness / sum < least];
    final thinCount = thin.where((t) => t).length;
    final thickSum = [
      for (final (i, l) in c.layers.indexed)
        if (!thin[i]) l.thickness,
    ].fold(0, (a, b) => a + b);
    final rest = total - least * thinCount;
    return [
      for (final (i, l) in c.layers.indexed)
        thin[i] ? least : rest * l.thickness / thickSum,
    ];
  }

  static const _shades = [
    Color(0xFFF2F4F6),
    Color(0xFFDDE3EA),
    Color(0xFFE9EDF2),
    Color(0xFFCCD4DE),
    Color(0xFFB8C4D2),
    Color(0xFFE2E6EC),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final columnW = size.width * 0.28;
    var y = 0.0;
    final tops = <double>[];
    for (final (i, h) in heights.indexed) {
      tops.add(y);
      final r = Rect.fromLTWH(0, y, size.width, h);
      final hard = config.layers[i].hardness.index;
      canvas.drawRect(
        r,
        Paint()
          ..color = Color.lerp(
            _shades[i % _shades.length],
            const Color(0xFF9AA8BA),
            hard / 8,
          )!,
      );
      canvas.drawLine(
        r.bottomLeft,
        r.bottomRight,
        Paint()
          ..strokeWidth = 1
          ..color = const Color(0x667A8696),
      );
      if (state.known(i)) {
        final w = (size.width - columnW - 48) * (hard + 1) / 5;
        canvas.drawRect(
          Rect.fromLTWH(size.width - w - 4, y + h * 0.25, w, h * 0.5),
          Paint()..color = const Color(0xCC3A5A8A),
        );
        // The profile's own shorthand: F, 4F, 1F, P, K.
        final label = TextPainter(
          text: TextSpan(
            text: const ['F', '4F', '1F', 'P', 'K'][hard],
            style: const TextStyle(
              fontFamily: AppTheme.smallCaps,
              fontSize: 14,
              color: Color(0xFF1E2A44),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        label.paint(
          canvas,
          Offset(size.width - w - 10 - label.width, y + (h - label.height) / 2),
        );
      }
      y += h;
    }
    // The picked layer.
    canvas.drawRect(
      Rect.fromLTWH(1, tops[picked] + 1, size.width - 2, heights[picked] - 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = StillroomPalette.gaslight,
    );
    // The column, cut down to just below the marked layer.
    final m = state.marked;
    if (m != null) {
      final bottom = tops[m] + heights[m];
      final broken = state.broken;
      final column = Rect.fromLTWH(8, 0, columnW, bottom);
      canvas.drawRect(
        column,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF2A3A5A),
      );
      if (broken != null) {
        // The block above the break slides off down the slope.
        final top = Rect.fromLTWH(
          8,
          0,
          columnW,
          tops[broken] + heights[broken] * 0.4,
        );
        canvas
          ..drawRect(
            top.shift(Offset(columnW * 0.35, top.height * 0.08)),
            Paint()..color = const Color(0xCCF6F8FA),
          )
          ..drawLine(
            Offset(8, top.bottom),
            Offset(8 + columnW, top.bottom),
            Paint()
              ..strokeWidth = 3
              ..color = const Color(0xFFB03A2A),
          );
      }
      canvas.drawLine(
        Offset(0, bottom - 1.5),
        Offset(size.width, bottom - 1.5),
        Paint()
          ..strokeWidth = 2
          ..color = const Color(0xCCB03A2A),
      );
      // The shovel's blade on the column's top.
      canvas.drawRect(
        Rect.fromLTWH(4, -2, columnW + 8, math.min(8, size.height * 0.03)),
        Paint()..color = const Color(0xFF4A4A50),
      );
    }
  }

  @override
  bool shouldRepaint(_PitPainter old) =>
      old.state != state || old.picked != picked;
}
