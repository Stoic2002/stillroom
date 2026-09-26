import 'package:flutter/widgets.dart';

/// Named routes, so features navigate without importing each other.
abstract final class AppRoutes {
  /// Tells screens when they are covered or shown again (e.g. to resume
  /// their music).
  static final observer = RouteObserver<ModalRoute<void>>();

  /// Argument: the episode id (`String`). The game resumes the episode from
  /// the save slot; clear it first to start over.
  static const game = '/game';

  static const settings = '/settings';

  /// The shelf of jars: pick an episode.
  static const shelf = '/shelf';

  /// The map of tales: pick an episode by where it happened.
  static const map = '/map';
}
