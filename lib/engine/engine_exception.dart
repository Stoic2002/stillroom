/// Thrown when the engine is asked to do something the content or state does
/// not allow, e.g. jumping to an unknown scene or setting an undeclared flag.
///
/// These indicate content or caller bugs. The content validator is meant to
/// catch them before the game ships.
final class EngineException implements Exception {
  const EngineException(this.message);

  final String message;

  @override
  String toString() => 'EngineException: $message';
}
