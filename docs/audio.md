# Audio

Status (2026-09-26): **generated stand-ins.** Every sound effect and music
loop is built in code by `tool/audio/generate_audio.dart`. There are no
recordings, no licences to track, and no credits needed. The developer chose
this over CC0 libraries or AI generation for now. Real audio can replace any
file later: drop in a file with the same id and the game picks it up.

## Regenerate

```bash
fvm dart run tool/audio/generate_audio.dart            # everything
fvm dart run tool/audio/generate_audio.dart bell_toll  # one or more ids
```

- **Needs `ffmpeg`** on the PATH. It encodes Ogg Vorbis with the built-in
  encoder, which is why the files are stereo.
- **Output** goes to `assets/audio/sfx/<id>.ogg` and
  `assets/audio/music/<id>.ogg`.
- **Deterministic:** everything is seeded, so a rerun gives the same sound.
- **Levels:** sound effects are normalized to −3 dBFS peak; music to −6 dBFS.
- **Loops:** music loops are crossfaded into their start. Drone frequencies
  are rounded to whole cycles per loop, so the loop point can't be heard.

## Sound effects

| Id | Used by | How it's made |
|---|---|---|
| `clock_tick` | Whitechapel mantel clock; Lawang Sewu station clock | Tick and tock: a noise click plus small metal partials |
| `match_strike` | Whitechapel candles | A rising band-passed scratch with crackles, then a low flare |
| `door_rattle` | Locked doors (both tales) | Wooden thuds with a metal latch |
| `door_creak` | Opening doors | Stick-slip pulses through wood resonances |
| `bell_toll` | Whitechapel candles and frames solved | A church bell from ten partials (hum, prime, tierce, …), big reverb |
| `drawer_open` | Whitechapel desk drawer | A juddering wooden slide, a thump, and things rattling inside |
| `paper` | Whitechapel clippings and letter | Crinkle clicks over a soft rustle |
| `page_turn` | Lawang Sewu ledger and telegram form | A band-passed whoosh and a flap |
| `water_drip` | Lawang Sewu cellar | Rising "plips" in a long, wet reverb |
| `lantern_light` | Lawang Sewu cellar | The lantern door's clink, the wick catching |
| `distant_bells` | Lawang Sewu 1945 window | A far-off peal, low-passed, with a faint low rumble |
| `locker_close` | Lawang Sewu lockers | A sheet-metal slam and latch |
| `glass_chime` | Lawang Sewu stained glass | A rising arpeggio of glassy tones |
| `telegraph_click` | Lawang Sewu telegraph | A sounder tapping out **N·I·S** in Morse, the puzzle's own answer |
| `station_bell` | Lawang Sewu timetable | A handbell rung four times |
| `ship_horn` | Flannan: the relief boat; the ending | Two long, low steam-horn blasts, far off in fog |
| `wave_crash` | Flannan: the west landing | A heavy sea breaking on rock |
| `rumble` | Pompeii: the mountain, the cloud, the label | A long, low rumble, far off |
| `shovel_dig` | Pompeii: the ash bank at the shop door | A shovel biting hard ash three times; the bank giving way |
| `oven_door` | Pompeii: the oven levered open | An iron door dragged over grit, a clank |
| `millstone` | Pompeii: the mills | Lava stone grinding on stone |
| `pumice_fall` | Pompeii: the basin, in the ruin and through the lens | Light stones pattering on tiles and into water |
| `lamp_light` | Flannan: the great lamp is lit | A soft rush, then a steady roar, and a glassy ring |
| `key_turn` | Bastille: a tower door unlocked | A key scraping in, the wards grinding, the bolt's heavy clunk |
| `door_heavy` | Bastille: the tower doors | A low groan on the hinges and a thud on stone |
| `bell_saint_paul` | Bastille: Saint-Paul; the ending | Two strokes of a higher bell, far off across the roofs |
| `quill` | Bastille: the burial register; the cipher read | A quill scratching a line, a dip in the ink, more scratching |
| `bronze_pour` | Gyeongju: the bell is cast | A long rush of molten metal, bubbling and settling |
| `great_bell` | Gyeongju: the bell rung; the ending | The great bell's full ring, 20 s: each partial split in two (64.07/64.42 Hz, 168.52/168.63 Hz, …) so it swells and fades, as measured |
| `striker_creak` | Gyeongju: the striker's rope tied | A rope creaking on a beam |
| `footsteps_away` | Whitechapel 1891: the arch | A man's footsteps on wet stone, walking away |
| `police_whistle` | Whitechapel 1891: the seal | A police whistle, two blasts |
| `train_arch` | Whitechapel 1891: the arch | A goods train over the railway arch, heard from under it |
| `stone_door` | Beijing 1908: the crypt's marble doors | A stone leaf grinding in its socket, then settling |
| `reactor_count` | Beijing 1908: the hair and the robe measured | A counter's clicks quickening to a chatter, then the reader's short tone |
| `wind_pines` | Beijing 1908: the pines; the seal | Wind through pines, rising and falling like water |
| `wind_rock` | Alamut 1256: the fires below, the tower window; the seal | Wind over bare rock in gusts, a low moan under it |
| `tank_cover` | Alamut 1256: the tanks opened; the count done | A heavy wooden cover dragged aside over stone, then set down |
| `keys_jingle` | Alamut 1256: the commander's keys | An iron ring of keys lifted from its hook |
| `eagle_cry` | Alamut 1256: the eagle (creature); Great Zimbabwe's bateleur | A thin, falling scream, twice, far over the gorge |
| `stone_set` | Great Zimbabwe 1871: the breach, the lintel, the wall standing | A granite block set down on another: a dull knock and grit |
| `cicadas` | Great Zimbabwe 1871: the view from the hill; the seal | Cicadas in dry grass, a shimmering buzz that swells and falls |
| `trumpet_call` | Roanoke 1590: the trumpet on the boat; the seal | A call on a natural trumpet across the water: up the harmonics (G, C, E, G) and down to a long C, open-air echo |
| `surf_low` | Roanoke 1590: the view south from the hill | Low surf on the banks far off, swelling and falling |
| `chest_lid` | Roanoke 1590: the chart found in the chests | A broken chest's lid lifted on a stiff hinge and set back |
| `temple_bell` | Honnō-ji 1582: the hall at Teramachi; the seal | A temple bell struck with a swung beam, 14 s: low (98 Hz), its first partial split so it wavers, the hum dying away |
| `trowel` | Honnō-ji 1582: the trench opened; the section dated | A trowel drawn across damp clay, three strokes, grit in it |
| `wind_ridge` | Dyatlov Pass 1959: the shoulder; the pit; the seal | Wind over a bare ridge, thin and high, gusting, a low rumble under it |
| `canvas_flap` | Dyatlov Pass 1959: the slit tent | Tent canvas snapping in the wind |
| `radio_static` | Dyatlov Pass 1959: the search camp's radio | A field radio's static, a carrier whistle drifting in it |
| `notebook` | Great Zimbabwe 1871: Mauch's notebook; the key solved | A stiff field notebook opened, its pages flicked |

## Music

| Id | Where | Loop | How it's made |
|---|---|---|---|
| `stillroom_menu` | Main menu and shelf | 36 s | A low A drone; a quiet pendulum tick every second, matching the lobby clock's swing; a faint glass shimmer twice per loop |
| `whitechapel_fog` | Whitechapel | 48 s | A D-minor drone; wind; one distant bell; six footsteps that never come closer |
| `lawang_sewu_night` | Lawang Sewu (default) | 48 s | A low C-minor drone; two crickets (a tropical night); a far train whistle |
| `flannan_wind` | Flannan Isles | 48 s | A low drone; wind over the bare island; the swell below |
| `pompeii_ash` | Pompeii, 79 | 48 s | A warm drone in D; dry wind; a slow plucked string in D dorian, like a lyre from another courtyard |
| `lawang_sewu_1907` | Lawang Sewu, 1907 office | 32 s | A warm F-major drone; the office clock; record-like crackle; the NIS telegraph far off |
| `whitechapel_1891` | Whitechapel, 1891 | 48 s | The fog's drone again, colder; rain; a train passing over an arch, once a loop |
| `gyeongju_night` | Gyeongju, 771 | 48 s | A low drone near the bell's 64 Hz hum; winter wind; a wooden fish knocked far off, slowing, every 12 s |
| `bastille_dawn` | Bastille, 1703 | 48 s | A cold drone in A; a draught in the court; two slow bowed notes in A aeolian every 16 s, like a viol through a wall |
| `chongling_winter` | Beijing, 1908 | 48 s | A cold drone in B♭; wind in the pines; a temple bowl struck far off every 16 s |
| `ural_wind` | Dyatlov Pass, 1959 | 48 s | A thin drone over a low A; wind over a bare ridge; a slow low pulse twice a loop |
| `sound_dawn` | Roanoke, 1590 | 48 s | A low drone in A; water lapping on the shore; once a loop a trumpet call far off across the water, unanswered |
| `kyoto_ash` | Honnō-ji, 1582 | 48 s | A low drone in D; a bamboo flute's breathy phrase in the old scale every 24 s; a temple bell far off once a loop; cicadas faint |
| `zimbabwe_dry` | Great Zimbabwe, 1871 | 48 s | A warm drone in E; dry wind in the grass; cicadas; a mbira-like figure plucked far off every 12 s |
| `alamut_snow` | Alamut, 1256 | 48 s | A low drone in D; wind over the rock; a long-necked lute plucked far off, a falling phrase every 16 s |

## Interface sounds (`assets/audio/ui/`)

Not content: the game answers every touch (`UiSound`, played through
`UiFeedback` at the effects volume, with a light vibration where noted when
vibration is on). Quieter than content sounds (−9 dBFS peak).

| Id | When | Vibration |
|---|---|---|
| `tap` | Menu buttons, selecting an inventory item, a jar on the shelf | selection |
| `dial` | A code-lock dial clicks over | selection |
| `press` | A sequence element is pressed | selection |
| `mistake` | A wrong move in a sequence | medium |
| `lift` / `place` | Picking up / setting down a piece in a slot puzzle; lifting / settling a tracing sheet | — / light |
| `turn` | A ring of a rotary puzzle turns; a tracing sheet is turned | selection |
| `lens` | The lens between eras is raised or lowered | light |
| `wave` | Flannan's swell puzzle: a small wave breaks on the landing steps | — |
| `great_sea` | Flannan's swell puzzle: a great sea draws back with a rising roar (1.2 s), then breaks over every step | medium |
| `key_try` | Bastille's key ring: a key tried in a lock that will not turn | light |
| `pour` | Gyeongju's pour: bronze runs down the channels | light |
| `bell_strike` | Gyeongju's hollow: the great bell struck by its log (the first seconds of its ring) | medium |
| `type_sort` | Whitechapel 1891's type case: a metal sort dropped into the stick | selection |
| `lamp_gutter` | Whitechapel 1891's shelf: the gas lamp dips while looking away | none |
| `geiger`, `geiger_hot` | Beijing 1908's hair: a segment measured, a few sparse clicks for a low reading, a chatter for a high one | selection / light |
| `sample` | Beijing 1908's hair: a new sample tube set in the rack | light |
| `probe_tick` | Beijing 1908's robe: the needle crosses a mark on its dial | none |
| `catchword` | Alamut 1256's quire: a move makes a catchword meet its page (a paper slide and a small tick) | light |
| `reed_touch` | Alamut 1256's tanks: the reed meets the surface (a soft, low plup) | light |
| `snow_push` | Dyatlov Pass 1959's pit: a hand or tool going into a layer (a soft crunch) | selection |
| `shovel_tap` | Dyatlov Pass 1959's pit: the shovel tapped on the column | light |
| `column_break` | Dyatlov Pass 1959's pit: the column breaking and its top sliding off | medium |
| `enlarger` | Dyatlov Pass 1959's darkroom: a frame printed right (the timer ticking through the exposure) | light |
| `strata_tag` | Honnō-ji 1582's section: a layer dated right (a paper tag pinned) | light |
| `find_lift` | Honnō-ji 1582's section: a find read (a small ceramic clink, a crumble) | selection |
| `core_slide` | Roanoke 1590's rings: the core slid one ring along (a soft wooden slide) | selection |
| `ring_mark` | Roanoke 1590's rings: the driest run marked (a pencil's tick) | light |
| `divider_step` | Roanoke 1590's dividers: a step walked (a brass point set down on paper) | selection |
| `street_mark` | Honnō-ji 1582's streets: the block an address names marked (a pencil's quick hatch) | light |
| `block_lay` | Great Zimbabwe 1871's courses: a block laid in its course | light |
| `slab_tilt` | Great Zimbabwe 1871's courses: a chevron slab turned | selection |
| `key_step` | Great Zimbabwe 1871's key: a step taken | selection |
| `drip`, `drip_slow` | Alamut 1256's tanks: a thin drop falling back, or a thick one letting go of its thread | none |
| `beat_steady`, `beat_light`, `beat_clear`, `beat_deep` | Gyeongju's rim: a strike whose ring swells and fades barely, lightly, clearly, or almost to silence (two tones 1.4 Hz apart, the second as loud as the swell needs) | light |
| `solved` | Any puzzle gives way (before its own `onSolved` sounds) | light |
| `pickup` | An item goes into the inventory | light |
| `combine` | Two items become one | light |
| `reject` | An item doesn't fit; a locked jar | (the existing light buzz) |
| `open` / `close` | A puzzle or close-up opens / closes | — |
| `page` | A text box appears (only when the content plays no sound) | — |
| `step` | The view moves to another scene | — |
| `jar_open` | Opening or continuing a tale: a cork and a glass ring | light |

Engine events pick at most one interface sound per tap
(`interfaceSoundFor` in `game_effects.dart`).

## Playback

- **Missing files** play silently and show as validator warnings (PRD §0).
- **`MenuMusic`** plays `stillroom_menu` on the menu and shelf, and again when
  the player comes back from a tale.
- **The game screen** plays scene or episode music.
- **Stopping and restarting:** `AudioService.stopMusic(ifPlaying:)` stops only
  the music that screen started. `FlameAudioService` doesn't restart a track
  that is already playing.
