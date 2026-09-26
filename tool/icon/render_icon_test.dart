// Renders the app icon (lib/core/art/app_icon_art.dart) to PNG masters:
//   fvm flutter test tool/icon/render_icon_test.dart
// then scales them into the Android and iOS icon sets:
//   sh tool/icon/make_icons.sh
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/core/art/app_icon_art.dart';

void main() {
  test('render icon masters', () async {
    Directory('build/icon').createSync(recursive: true);
    for (final (name, layer) in [
      ('icon_full', AppIconLayer.full),
      ('icon_background', AppIconLayer.background),
      ('icon_foreground', AppIconLayer.foreground),
      ('icon_monochrome', AppIconLayer.monochrome),
    ]) {
      const size = Size(1024, 1024);
      final recorder = ui.PictureRecorder();
      paintAppIcon(Canvas(recorder), size, layer: layer);
      final image = await recorder.endRecording().toImage(1024, 1024);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      File('build/icon/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
    }
  });
}
