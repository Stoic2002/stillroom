import 'dart:async';
import 'dart:ui' show FramePhase, FrameTiming;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../theme/stillroom_palette.dart';

/// A small frame-rate readout for checking performance on a real phone
/// (Settings › Show frame rate). It counts the frames Flutter actually
/// drew in the last second, and how long the slowest took on the UI
/// thread (building) and the raster thread (drawing). Anything under
/// 16 ms keeps 60 fps.
class FpsOverlay extends StatefulWidget {
  const FpsOverlay({super.key});

  @override
  State<FpsOverlay> createState() => _FpsOverlayState();
}

class _FpsOverlayState extends State<FpsOverlay> {
  final List<FrameTiming> _recent = [];
  Timer? _refresh;
  String _text = '–';
  bool _slow = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    _refresh = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _summarise();
    });
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    _refresh?.cancel();
    super.dispose();
  }

  void _onTimings(List<FrameTiming> timings) => _recent.addAll(timings);

  void _summarise() {
    final now = _recent.isEmpty
        ? 0
        : _recent.last.timestampInMicroseconds(FramePhase.rasterFinish);
    _recent.removeWhere(
      (t) => now - t.timestampInMicroseconds(FramePhase.vsyncStart) > 1000000,
    );
    if (!mounted) return;
    setState(() {
      if (_recent.isEmpty) {
        _text = 'idle';
        _slow = false;
        return;
      }
      double ms(Duration d) => d.inMicroseconds / 1000;
      final ui = _recent
          .map((t) => ms(t.buildDuration))
          .reduce((a, b) => a > b ? a : b);
      final raster = _recent
          .map((t) => ms(t.rasterDuration))
          .reduce((a, b) => a > b ? a : b);
      _slow = ui > 16 || raster > 16;
      _text =
          '${_recent.length} fps  ·  UI ${ui.toStringAsFixed(1)} ms  ·  '
          'GPU ${raster.toStringAsFixed(1)} ms';
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            color: const Color(0xCC000000),
            child: Text(
              _text,
              textDirection: TextDirection.ltr,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: _slow
                    ? StillroomPalette.oxbloodBright
                    : const Color(0xFF8FD694),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
