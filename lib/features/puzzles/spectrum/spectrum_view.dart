import 'package:flutter/material.dart';

import '../../../core/art/art_kit.dart';
import '../../../core/art/keeper_art.dart';
import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// The portrait on an easel under the conservator's lamp. Turn the lamp's
/// dial along its bands: where a band is clear, the picture shows what that
/// light sees. Record each band's plate; then lay the plates on the
/// portrait in the order of the painting's life, the oldest first.
class SpectrumView extends StatefulWidget {
  const SpectrumView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<SpectrumView> createState() => _SpectrumViewState();
}

/// What each band's light shows of the portrait, by band id.
PortraitLook lookOf(String bandId) => switch (bandId) {
  'uv' => PortraitLook.uv,
  'infrared' => PortraitLook.infrared,
  'xray' => PortraitLook.xray,
  _ => PortraitLook.scraped,
};

class _SpectrumViewState extends State<SpectrumView>
    with SolvesAfterPause<SpectrumView> {
  late final _config = widget.context.puzzle.config as SpectrumConfig;
  late SpectrumState _state = _config.start();
  String? _message;

  /// The plate whose caption is showing.
  int? _shown;

  void _tune(double to) {
    if (isSolved) return;
    final before = _state.tuned;
    setState(() {
      _state = _state.tune(to);
      _message = null;
    });
    if (_state.tuned != null && _state.tuned != before) {
      widget.context.feedback(UiSound.dial);
    }
  }

  void _record() {
    if (isSolved) return;
    final l10n = AppLocalizations.of(context);
    final judged = _state.judge();
    final tuned = _state.tuned;
    setState(() {
      _state = _state.record();
      _message = switch (judged) {
        SpectrumShot.blurred => l10n.spectrumBlurred,
        SpectrumShot.already => l10n.spectrumAlready,
        SpectrumShot.recorded => null,
      };
      if (judged == SpectrumShot.recorded) _shown = tuned;
    });
    widget.context.feedback(
      judged == SpectrumShot.recorded ? UiSound.layerFound : UiSound.reject,
    );
  }

  void _plate(int i) {
    if (isSolved || !_state.recorded.contains(i)) return;
    if (!_state.allRecorded) {
      setState(() => _shown = i);
      widget.context.feedback(UiSound.page);
      return;
    }
    final l10n = AppLocalizations.of(context);
    final fits = _state.fits(i);
    setState(() {
      _state = _state.lay(i);
      _shown = i;
      _message = fits ? null : l10n.spectrumWrongOrder;
    });
    if (_state.isSolved) {
      widget.context.feedback(UiSound.solved);
      markSolved(widget.context.onSolved);
      return;
    }
    widget.context.feedback(fits ? UiSound.layerFound : UiSound.mistake);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shown = _shown;
    final caption = shown == null
        ? null
        : widget.context.text(context, _config.bands[shown].captionKey);
    final instruction = _state.allRecorded
        ? l10n.spectrumLayInstruction
        : '${l10n.spectrumInstruction}\n'
              '${l10n.spectrumRecorded(_state.recorded.length, _config.bands.length)}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(52, 6, 20, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: CustomPaint(
              painter: _EaselPainter(
                state: _state,
                looks: [for (final b in _config.bands) lookOf(b.id)],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // The plates: recorded ones show their picture; laid ones
                // are marked with their place in the order.
                SizedBox(
                  height: 92,
                  child: Row(
                    children: [
                      for (final (i, band) in _config.bands.indexed)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: GestureDetector(
                              key: ValueKey('spectrum_plate_$i'),
                              onTap: () => _plate(i),
                              child: _Plate(
                                label: widget.context.text(
                                  context,
                                  band.labelKey,
                                ),
                                look: _state.recorded.contains(i)
                                    ? lookOf(band.id)
                                    : null,
                                laidAt: _state.laid.indexOf(i),
                                shown: shown == i,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                if (!_state.allRecorded) ...[
                  _Dial(
                    config: _config,
                    value: _state.dial,
                    labels: [
                      for (final b in _config.bands)
                        widget.context.text(context, b.labelKey),
                    ],
                    onChanged: _tune,
                  ),
                  const SizedBox(height: 4),
                  FilledButton(
                    key: const ValueKey('spectrum_record'),
                    onPressed: isSolved ? null : _record,
                    child: Text(l10n.spectrumRecord),
                  ),
                ],
                const SizedBox(height: 4),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      caption ?? '',
                      style: const TextStyle(
                        fontFamily: AppTheme.serif,
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                        color: StillroomPalette.paper,
                      ),
                    ),
                  ),
                ),
                PuzzleLabel(_message ?? instruction, maxLines: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The lamp's dial: a track along the bands, each marked; a slider.
class _Dial extends StatelessWidget {
  const _Dial({
    required this.config,
    required this.value,
    required this.labels,
    required this.onChanged,
  });

  final SpectrumConfig config;
  final double value;
  final List<String> labels;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: LayoutBuilder(
        builder: (context, box) {
          const inset = 24.0;
          final track = box.maxWidth - inset * 2;
          return Stack(
            children: [
              for (final (i, band) in config.bands.indexed)
                Positioned(
                  left: inset + track * band.at - 40,
                  width: 80,
                  top: 0,
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTheme.smallCaps,
                      fontSize: 11,
                      color: StillroomPalette.paperShade,
                    ),
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: StillroomPalette.brass,
                    inactiveTrackColor: const Color(0xFF5A4A3A),
                    thumbColor: StillroomPalette.gaslight,
                    overlayShape: SliderComponentShape.noOverlay,
                    padding: const EdgeInsets.symmetric(horizontal: inset),
                  ),
                  child: Slider(
                    key: const ValueKey('spectrum_dial'),
                    value: value,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A plate: blank until recorded, then the picture it took; numbered once
/// laid on the portrait.
class _Plate extends StatelessWidget {
  const _Plate({
    required this.label,
    required this.look,
    required this.laidAt,
    required this.shown,
  });

  final String label;
  final PortraitLook? look;
  final int laidAt;
  final bool shown;

  @override
  Widget build(BuildContext context) {
    final look = this.look;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1612),
        border: Border.all(
          color: shown ? StillroomPalette.gaslight : const Color(0xFF5A4A3A),
          width: shown ? 2.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (look != null) CustomPaint(painter: _PortraitPainter(look)),
                if (laidAt >= 0)
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      color: StillroomPalette.brass,
                      child: Text(
                        '${laidAt + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1A1612),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: AppTheme.smallCaps,
                fontSize: 11,
                color: StillroomPalette.paper,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortraitPainter extends CustomPainter {
  const _PortraitPainter(this.look);

  final PortraitLook look;

  @override
  void paint(Canvas canvas, Size size) =>
      paintKeeperPortrait(Art(canvas, size), look: look);

  @override
  bool shouldRepaint(_PortraitPainter old) => old.look != look;
}

/// The portrait under the lamp: cleaned but scraped; where the dial sits
/// near a band, that band's sight of it showing through, as clearly as the
/// dial is near. Once every plate is laid, the face whole.
class _EaselPainter extends CustomPainter {
  const _EaselPainter({required this.state, required this.looks});

  final SpectrumState state;
  final List<PortraitLook> looks;

  @override
  void paint(Canvas canvas, Size size) {
    final a = Art(canvas, size);
    if (state.isSolved) {
      paintKeeperPortrait(a, look: PortraitLook.whole);
      return;
    }
    paintKeeperPortrait(a, look: PortraitLook.scraped);
    if (state.allRecorded) {
      // The plates laid so far, faint over the picture.
      for (final i in state.laid) {
        canvas.saveLayer(
          Offset.zero & size,
          Paint()..color = const Color(0x55FFFFFF),
        );
        paintKeeperPortrait(a, look: looks[i]);
        canvas.restore();
      }
      return;
    }
    for (var i = 0; i < looks.length; i++) {
      final clarity = state.clarity(i);
      if (clarity <= 0) continue;
      canvas.saveLayer(
        Offset.zero & size,
        Paint()..color = Color.fromRGBO(255, 255, 255, clarity),
      );
      paintKeeperPortrait(a, look: looks[i]);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_EaselPainter old) => true;
}
