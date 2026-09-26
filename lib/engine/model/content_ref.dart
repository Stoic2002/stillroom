/// A reference from content to something that must exist elsewhere: a scene,
/// item, flag, text key, asset, ... Used by the content validator, so new
/// action or puzzle types get validated without changing the validator.
library;

enum RefKind { scene, item, puzzle, flag, text, sound, music, image }

final class ContentRef {
  const ContentRef(this.kind, this.id, {this.flagValue});

  const ContentRef.scene(String id) : this(RefKind.scene, id);
  const ContentRef.item(String id) : this(RefKind.item, id);
  const ContentRef.puzzle(String id) : this(RefKind.puzzle, id);
  const ContentRef.text(String key) : this(RefKind.text, key);
  const ContentRef.sound(String id) : this(RefKind.sound, id);
  const ContentRef.music(String id) : this(RefKind.music, id);

  /// Path relative to `assets/`.
  const ContentRef.image(String path) : this(RefKind.image, path);

  /// [value] is the `bool`/`int` compared against or assigned, if any, so the
  /// validator can check it matches the flag's declared type.
  const ContentRef.flag(String name, [Object? value])
    : this(RefKind.flag, name, flagValue: value);

  final RefKind kind;
  final String id;
  final Object? flagValue;

  @override
  bool operator ==(Object other) =>
      other is ContentRef &&
      other.kind == kind &&
      other.id == id &&
      other.flagValue == flagValue;

  @override
  int get hashCode => Object.hash(kind, id, flagValue);

  @override
  String toString() => '${kind.name}:$id';
}
