import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// PRD §6.1: the engine must stay pure Dart.
void main() {
  test('lib/engine does not import Flutter, Flame, or dart:ui', () {
    final forbidden = RegExp(
      r'''^\s*(import|export)\s+['"](package:(flutter|flame)[a-z_]*/|dart:ui)''',
      multiLine: true,
    );
    final offenders = [
      for (final file in Directory('lib/engine').listSync(recursive: true))
        if (file is File &&
            file.path.endsWith('.dart') &&
            forbidden.hasMatch(file.readAsStringSync()))
          file.path,
    ];
    expect(offenders, isEmpty);
  });
}
