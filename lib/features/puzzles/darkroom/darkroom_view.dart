import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../core/widgets/content_image.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// Under the red lamp: the roll's frames as negatives along the top, the
/// picked frame's test strip in bands of doubling exposure, and the last
/// print. Tap a band to print the frame at it: right, it joins the prints
/// with its caption; too short, it comes out grey; too long, black.
class DarkroomView extends StatefulWidget {
  const DarkroomView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<DarkroomView> createState() => _DarkroomViewState();
}

class _DarkroomViewState extends State<DarkroomView>
    with SolvesAfterPause<DarkroomView> {
  late final _config = widget.context.puzzle.config as DarkroomConfig;
  late DarkroomState _state = _config.start();
  int _frame = 0;

  /// The last print made: (frame, band).
  (int, int)? _print;

  void _pickFrame(int f) {
    if (isSolved) return;
    setState(() => _frame = f);
    widget.context.feedback(UiSound.tap);
  }

  void _printAt(int band) {
    if (isSolved || _state.printed.contains(_frame)) return;
    final next = _state.print(_frame, band);
    setState(() {
      _state = next;
      _print = (_frame, band);
      // Move on to the next frame still to print.
      if (next.printed.contains(_frame)) {
        final rest = [
          for (var f = 0; f < _config.frames.length; f++)
            if (!next.printed.contains(f)) f,
        ];
        if (rest.isNotEmpty) _frame = rest.first;
      }
    });
    if (next.isSolved) {
      widget.context.feedback(UiSound.solved);
      markSolved(widget.context.onSolved);
    } else {
      widget.context.feedback(
        next.spoiled == null ? UiSound.enlarger : UiSound.mistake,
      );
    }
  }

  Widget _image(String path, {required int tone, bool negative = false}) {
    final image = ContentImage(
      path: path,
      label: path.split('/').last,
      assets: widget.context.assets,
    );
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(negative ? _negative : _printTone(tone)),
      child: image,
    );
  }

  /// A print [tone] doublings off: below 0 lighter and greyer, above 0
  /// darker.
  static List<double> _printTone(int tone) {
    // Greyscale first, then lift or sink the levels.
    const r = 0.3, g = 0.59, b = 0.11;
    final n = tone.abs();
    final k = tone < 0 ? 1 - 0.32 * n : 1 - 0.18 * n;
    final offset = tone < 0 ? 85.0 * n : -95.0 * n;
    return [
      r * k, g * k, b * k, 0, offset, //
      r * k, g * k, b * k, 0, offset,
      r * k, g * k, b * k, 0, offset,
      0, 0, 0, 1, 0,
    ];
  }

  static const _negative = <double>[
    -0.3, -0.59, -0.11, 0, 230, //
    -0.3, -0.59, -0.11, 0, 200,
    -0.3, -0.59, -0.11, 0, 160,
    0, 0, 0, 1, 0,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spoiled = _state.spoiled;
    final status = spoiled == null
        ? l10n.darkroomInstruction
        : _state.tone(spoiled.$1, spoiled.$2) < 0
        ? l10n.darkroomLight
        : l10n.darkroomDark;
    final frame = _config.frames[_frame];
    final last = _print;
    return Padding(
      padding: const EdgeInsets.fromLTRB(52, 8, 24, 6),
      child: Column(
        children: [
          // The negatives along the top.
          SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final (f, fr) in _config.frames.indexed)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      key: ValueKey('darkroom_frame_$f'),
                      onTap: () => _pickFrame(f),
                      child: Container(
                        width: 86,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A1C14),
                          border: Border.all(
                            color: f == _frame
                                ? StillroomPalette.gaslight
                                : const Color(0xFF5A3A2A),
                            width: f == _frame ? 2.5 : 1,
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _image(
                              fr.image,
                              tone: 0,
                              negative: !_state.printed.contains(f),
                            ),
                            if (_state.printed.contains(f))
                              const Align(
                                alignment: Alignment.topRight,
                                child: Icon(
                                  Icons.check,
                                  size: 16,
                                  color: StillroomPalette.gaslight,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // The test strip: the frame in bands of doubling exposure.
                Expanded(
                  flex: 3,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var b = 0; b < _config.strip.length; b++)
                        Expanded(
                          child: GestureDetector(
                            key: ValueKey('darkroom_band_$b'),
                            onTap: () => _printAt(b),
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRect(
                                    child: OverflowBox(
                                      maxWidth: double.infinity,
                                      alignment: Alignment(
                                        -1 + 2 * b / (_config.strip.length - 1),
                                        0,
                                      ),
                                      child: AspectRatio(
                                        aspectRatio: 4 / 3,
                                        child: _image(
                                          frame.image,
                                          tone: b - frame.exposure,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.darkroomSeconds(
                                    _config.strip[b] % 1 == 0
                                        ? _config.strip[b].toInt().toString()
                                        : _config.strip[b].toString(),
                                  ),
                                  style: const TextStyle(
                                    fontFamily: AppTheme.smallCaps,
                                    fontSize: 13,
                                    color: StillroomPalette.paperShade,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // The last print, and its caption if it came out right.
                Expanded(
                  flex: 2,
                  child: last == null
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            Expanded(
                              child: Container(
                                key: const ValueKey('darkroom_print'),
                                padding: const EdgeInsets.all(6),
                                color: const Color(0xFFF2EEE4),
                                child: _image(
                                  _config.frames[last.$1].image,
                                  tone: _state.tone(last.$1, last.$2),
                                ),
                              ),
                            ),
                            if (_state.printed.contains(last.$1))
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  widget.context.text(
                                    context,
                                    _config.frames[last.$1].captionKey,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: AppTheme.serif,
                                    fontSize: 13,
                                    height: 1.2,
                                    color: StillroomPalette.paper,
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          PuzzleLabel(status),
        ],
      ),
    );
  }
}
