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
  rub('rub', Haptic.none),

  /// The lens between eras is raised or lowered.
  lens('lens', Haptic.light),

  /// A small wave breaks on the landing steps.
  wave('wave', Haptic.none),

  /// A great sea draws back and breaks over every step.
  greatSea('great_sea', Haptic.medium),

  /// A key tried in a lock that will not turn.
  keyTry('key_try', Haptic.light),

  /// Molten bronze runs down the channels.
  pour('pour', Haptic.light),

  /// The great bell struck by its log: a long ring, fading.
  bellStrike('bell_strike', Haptic.medium),

  /// The bell's rim struck, its ring swelling and fading hardly at all.
  beatSteady('beat_steady', Haptic.light),

  /// The rim struck: a light swell.
  beatLight('beat_light', Haptic.light),

  /// The rim struck: a clear swell.
  beatClear('beat_clear', Haptic.light),

  /// The rim struck: the deepest swell, fading almost to nothing and back.
  beatDeep('beat_deep', Haptic.light),

  /// A metal sort dropped into the composing stick.
  typeSort('type_sort', Haptic.selection),

  /// A gas lamp gutters and dims.
  lampGutter('lamp_gutter', Haptic.none),

  /// A counter clicks over a sample reading low.
  geiger('geiger', Haptic.selection),

  /// A counter chatters over a sample reading high.
  geigerHot('geiger_hot', Haptic.light),

  /// A glass sample tube set into its rack.
  sample('sample', Haptic.light),

  /// The probe's needle ticks as the reading under it changes.
  probeTick('probe_tick', Haptic.none),

  /// A catchword meets its page: a sheet settles into the quire.
  catchword('catchword', Haptic.light),

  /// The reed meets the surface in a dark tank.
  reedTouch('reed_touch', Haptic.light),

  /// A thin liquid dripping quickly from the reed.
  drip('drip', Haptic.none),

  /// A thick liquid falling from the reed in one slow drop.
  dripSlow('drip_slow', Haptic.none),

  /// A granite block set down in its course.
  blockLay('block_lay', Haptic.light),

  /// A thin chevron slab turned to lean the other way.
  slabTilt('slab_tilt', Haptic.selection),

  /// A step taken in an identification key: a page of the key turned.
  keyStep('key_step', Haptic.selection),

  /// A hand or a tool pushed into a snow layer.
  snowPush('snow_push', Haptic.selection),

  /// The shovel tapped on a snow column.
  shovelTap('shovel_tap', Haptic.light),

  /// A snow column breaking on its weak layer.
  columnBreak('column_break', Haptic.medium),

  /// The enlarger's timer ticking through an exposure.
  enlarger('enlarger', Haptic.light),

  /// A layer dated: a label pinned to the section.
  strataTag('strata_tag', Haptic.light),

  /// A find lifted from the earth to be read.
  findLift('find_lift', Haptic.selection),

  /// A block marked on the city map.
  streetMark('street_mark', Haptic.light),

  /// A tree-ring core slid one ring along the master chronology.
  coreSlide('core_slide', Haptic.selection),

  /// A run of rings marked on the core.
  ringMark('ring_mark', Haptic.light),

  /// The dividers walked one step across the chart.
  dividerStep('divider_step', Haptic.selection),

  /// A written sheet turned a quarter turn.
  sheetTurn('sheet_turn', Haptic.selection),

  /// A sonar lane run, its echoes drawn.
  laneRun('lane_run', Haptic.light),

  /// An echo marked as the wreck.
  echoMark('echo_mark', Haptic.medium);

  const UiSound(this.id, this.haptic);

  final String id;
  final Haptic haptic;

  String get assetPath => 'assets/audio/ui/$id.ogg';

  /// The rim sound for a swell depth from 0 (steady) to 1 (deepest).
  static UiSound forSwell(double swell) => switch (swell) {
    < 0.3 => beatSteady,
    < 0.5 => beatLight,
    < 0.75 => beatClear,
    _ => beatDeep,
  };

  /// The counter's sound for a reading, from 0 (low) to 1 (highest).
  static UiSound forCount(double reading) =>
      reading < 0.35 ? geiger : geigerHot;
}

enum Haptic { none, selection, light, medium }
