// Validates all game content (PRD §9).
//
//   fvm dart run tool/validate_content.dart [--errors-only]
//
// Run from the project root. Exits with 1 when there are errors; warnings
// (e.g. art not delivered yet) do not fail the run.
import 'dart:io';

import 'package:stillroom/content/file_asset_source.dart';
import 'package:stillroom/content/project_validation.dart';

Future<void> main(List<String> args) async {
  final errorsOnly = args.contains('--errors-only');
  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    stderr.writeln('Run this from the project root (pubspec.yaml not found).');
    exit(2);
  }

  final issues = await validateProject(
    FileAssetSource(Directory.current),
    pubspec: pubspec.readAsStringSync(),
  );
  final errors = issues.where((i) => i.isError).toList();
  final warnings = issues.where((i) => !i.isError).toList();

  if (!errorsOnly) {
    for (final w in warnings) {
      stdout.writeln('warning  ${w.location}: ${w.message}');
    }
  }
  for (final e in errors) {
    stdout.writeln('ERROR    ${e.location}: ${e.message}');
  }
  stdout.writeln(
    '\n${errors.length} error(s), ${warnings.length} warning(s)'
    '${errorsOnly && warnings.isNotEmpty ? ' (warnings hidden)' : ''}.',
  );
  exit(errors.isEmpty ? 0 : 1);
}
