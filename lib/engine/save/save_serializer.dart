import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import 'save_file.dart';

/// Upgrades raw save JSON from version `n` to `n + 1`.
typedef SaveMigration =
    Map<String, dynamic> Function(Map<String, dynamic> json);

sealed class SaveDecodeResult {
  const SaveDecodeResult();
}

final class SaveDecoded extends SaveDecodeResult {
  const SaveDecoded(this.file, {required this.migratedFrom});

  final SaveFile file;

  /// Original schema version when migrations ran, otherwise `null`.
  final int? migratedFrom;
}

/// The save could not be read. The game offers a new start instead of
/// crashing (NFR-06).
final class SaveCorrupted extends SaveDecodeResult {
  const SaveCorrupted(this.reason);

  final String reason;
}

/// Encodes and decodes [SaveFile] as JSON, migrating old schema versions.
final class SaveSerializer {
  const SaveSerializer({
    this.currentVersion = SaveFile.currentSchemaVersion,
    this.migrations = const {},
  });

  final int currentVersion;

  /// Keyed by the version each migration upgrades *from*.
  final Map<int, SaveMigration> migrations;

  String encode(SaveFile file) => jsonEncode(file.toJson());

  SaveDecodeResult decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const SaveCorrupted('save is not a JSON object');
      }
      final original = decoded['schemaVersion'];
      if (original is! int || original < 1) {
        return const SaveCorrupted('missing or invalid schemaVersion');
      }
      if (original > currentVersion) {
        return SaveCorrupted(
          'save schema $original is newer than supported $currentVersion',
        );
      }
      var json = decoded;
      for (var version = original; version < currentVersion; version++) {
        final migrate = migrations[version];
        if (migrate == null) {
          return SaveCorrupted('no migration from schema $version');
        }
        json = {...migrate(json), 'schemaVersion': version + 1};
      }
      return SaveDecoded(
        SaveFile.fromJson(json),
        migratedFrom: original == currentVersion ? null : original,
      );
    } on FormatException catch (e) {
      return SaveCorrupted('invalid JSON: ${e.message}');
    } on CheckedFromJsonException catch (e) {
      return SaveCorrupted('unexpected data at "${e.key}": ${e.message}');
    }
  }
}
