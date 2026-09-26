/// Where content files come from. Kept free of Flutter so the loader and the
/// validator also run from the CLI (`tool/`) and in plain unit tests.
abstract interface class AssetSource {
  /// Every asset path, e.g. `assets/content/game.json`.
  Future<Set<String>> listAssets();

  Future<String> loadString(String path);
}
