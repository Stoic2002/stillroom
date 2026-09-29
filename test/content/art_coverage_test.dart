import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/content/file_asset_source.dart';
import 'package:stillroom/content/project_validation.dart';
import 'package:stillroom/core/art/vector_art.dart';

/// Every picture the tales use (not the debug test room) has a file or
/// code-drawn art, so no placeholder box ships; and all of it draws.
void main() {
  test('no tale falls back to a placeholder', () async {
    final issues = await validateProject(
      FileAssetSource(Directory.current),
      pubspec: File('pubspec.yaml').readAsStringSync(),
    );
    final missing = RegExp(r'image "([^"]+)" not found');
    final uncovered = <String>{
      for (final issue in issues)
        if (!'$issue'.contains('test_room'))
          if (missing.firstMatch(issue.message) case final m?)
            if (vectorArtFor(m.group(1)!) == null) m.group(1)!,
    };
    expect(uncovered, isEmpty);
  });

  test('every piece of code-drawn art draws', () async {
    final issues = await validateProject(
      FileAssetSource(Directory.current),
      pubspec: File('pubspec.yaml').readAsStringSync(),
    );
    final missing = RegExp(r'image "([^"]+)" not found');
    final paths = {
      for (final issue in issues)
        if (missing.firstMatch(issue.message) case final m?) m.group(1)!,
    };
    for (final path in paths) {
      final art = vectorArtFor(path);
      if (art == null) continue;
      for (final size in const [Size(1920, 1080), Size(256, 256)]) {
        final recorder = PictureRecorder();
        art(Canvas(recorder), size);
        recorder.endRecording().dispose();
      }
    }
  });
}
