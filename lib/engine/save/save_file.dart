import 'package:freezed_annotation/freezed_annotation.dart';

import '../state/game_state.dart';

part 'save_file.freezed.dart';
part 'save_file.g.dart';

/// The single save slot: progress for every episode played so far.
@freezed
abstract class SaveFile with _$SaveFile {
  const factory SaveFile({
    @Default(SaveFile.currentSchemaVersion) int schemaVersion,

    /// Episode the "Continue" button resumes.
    String? lastEpisodeId,

    /// Keyed by episode id.
    @Default(<String, GameState>{}) Map<String, GameState> episodes,
  }) = _SaveFile;

  factory SaveFile.fromJson(Map<String, dynamic> json) =>
      _$SaveFileFromJson(json);

  /// Bump when the save shape changes, and add a migration from the previous
  /// version to [SaveSerializer].
  static const currentSchemaVersion = 1;
}
