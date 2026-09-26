/// The game's own interface sounds (not content): every touch answers with
/// a small sound, and some with a light vibration. Files live in
/// `assets/audio/ui/<id>.ogg` (generated, docs/audio.md).
enum UiSound {
  /// A plain button or item tap.
  tap('tap', Haptic.selection),

  /// A code-lock dial clicks over one symbol.
  dial('dial', Haptic.selection),

  /// An element of a sequence is pressed.
  press('press', Haptic.selection),

  /// A wrong move in a puzzle.
  mistake('mistake', Haptic.medium),

  /// A piece is picked up.
  lift('lift', Haptic.none),

  /// A piece is set down in a slot.
  place('place', Haptic.light),

  /// A ring turns.
  turn('turn', Haptic.selection),

  /// A puzzle gives way.
  solved('solved', Haptic.light),

  /// An item goes into the inventory.
  pickup('pickup', Haptic.light),

  /// Two items become one.
  combine('combine', Haptic.light),

  /// An item doesn't fit there.
  reject('reject', Haptic.none),

  /// A puzzle or close-up opens.
  open('open', Haptic.none),

  /// A puzzle or close-up closes.
  close('close', Haptic.none),

  /// A text box appears.
  page('page', Haptic.none),

  /// The view moves to another scene.
  step('step', Haptic.none),

  /// A jar is opened on the shelf.
  jarOpen('jar_open', Haptic.light),

  /// A word is noted down: a pencil scratch.
  note('note', Haptic.selection),

  /// The keeper's note is found.
  secret('secret', Haptic.medium),

  /// A finger wipes fog, dust or ash.
  wipe('wipe', Haptic.none),

  /// A pencil shades paper.
  rub('rub', Haptic.none);

  const UiSound(this.id, this.haptic);

  final String id;
  final Haptic haptic;

  String get assetPath => 'assets/audio/ui/$id.ogg';
}

enum Haptic { none, selection, light, medium }
