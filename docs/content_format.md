# Content Format — Stillroom

Schema documentation for game content under `assets/content/`.
The baseline is PRD §5. Every schema change must be recorded in the changelog below.

## Layout

```
assets/content/
├── episodes.json        # The shelf: jars in menu order (see below)
├── strings/             # Content string tables (key → text), one per language:
│   ├── en.json          #   English      ├── es.json  Spanish
│   ├── id.json          #   Indonesian   ├── ja.json  Japanese
│   ├── ru.json          #   Russian      ├── zh.json  Simplified Chinese
│   └── ko.json          #   Korean
└── episodes/
    └── <episode_id>/    # One folder per episode; the folder name is the episode id
        ├── game.json
        ├── items.json
        ├── scenes/*.json   # One scene per file
        └── puzzles/*.json  # One puzzle per file
```

Scene and puzzle files are discovered automatically: every `.json` in
`scenes/` and `puzzles/` is loaded; file names do not matter, the `id` inside does.

Art and audio follow the same per-episode grouping:

```
assets/images/scenes/<episode_id>/     # Scene backgrounds, 1920×1080
assets/images/objects/<episode_id>/    # Layer sprites (transparent)
assets/images/items/<episode_id>/      # Item icons (transparent)
assets/audio/sfx/<sound_id>.ogg        # Sound ids map to sfx/<id>.ogg|mp3|wav
```

**Asset folders must be listed per directory in `pubspec.yaml`** (Flutter does
not recurse into subfolders). A new episode needs its content and image
folders registered there; `test/content/bundled_content_test.dart` fails when a
folder with files is not listed.

**Missing art is fine while developing:** code-drawn stand-in art is used
when one exists for that path (`lib/core/art/`), otherwise a colored
placeholder box labelled with the id. Dropping a file at the path used in the JSON
replaces the placeholder, with no code change.

UI strings (menu, settings, buttons) are not content: they live in
`lib/l10n/app_<locale>.arb` (Flutter gen-l10n).

### Languages

Every language must have **every key**, in both the ARB files and the content
tables; the validator fails otherwise. Proper names are transliterated per
language and must match exactly wherever they appear (puzzle labels, clues,
hints, cards).

To add a language:

1. `lib/l10n/app_<code>.arb` with all UI keys, plus its endonym as
   `language<Name>` in every ARB; add it to the language chips in
   `lib/features/settings/settings_screen.dart`.
2. `assets/content/strings/<code>.json` with all content keys.
3. If the script is not Latin, Cyrillic, Japanese, or Simplified Chinese, add
   a font (see `docs/art_style_guide.md`, Typography).
4. `fvm flutter test`: `test/content/font_coverage_test.dart` checks every
   character has a bundled glyph.

## `episodes.json`

The tales: "New Game" opens the map of tales, with a pin for each `place`;
the shelves of jars (docs/stillroom_frame.md) are a button away. Shelves
are difficulty tiers: shelf 1 (bottom) is open from the start; a jar opens
once the player has distilled `unlockAfter` tales (finished, playable,
non-debug episodes).

```json
{
  "episodes": [
    { "id": "whitechapel_1888", "titleKey": "episode.whitechapel_1888.title",
      "teaserKey": "episode.whitechapel_1888.teaser",
      "jarImage": "images/ui/jar_whitechapel_1888.png",
      "shelf": 1, "series": "whitechapel", "place": [51.52, -0.07] },
    { "id": "sealed_whitechapel_1891", "titleKey": "episode.sealed.title", "comingSoon": true,
      "shelf": 2, "unlockAfter": 2 },
    { "id": "test_room", "titleKey": "episode.test_room.title", "debugOnly": true }
  ]
}
```

| Field | Required | Notes |
|---|---|---|
| `id` | yes | Episode folder name under `episodes/` |
| `titleKey` | yes | Label on the jar |
| `teaserKey` | no | Line shown when the jar is picked |
| `jarImage` | no | Jar art; a jar is drawn in code until it exists |
| `comingSoon` | no | A sealed jar: shown dimmed, not playable, needs no folder |
| `debugOnly` | no | Listed only in debug builds; never counts towards unlocking |
| `shelf` | no | Difficulty tier, default 1 (bottom, easiest). Higher = harder |
| `unlockAfter` | no | Distilled tales needed before the jar opens, default 0 |
| `series` | no | Links tales of one topic (e.g. two Whitechapel jars); they share a ribbon colour. Put later chapters on higher shelves |
| `place` | no | `[latitude, longitude]` where the tale happened: its pin on the map of tales. Without it the jar is only on the shelf |

The map's coastlines are `assets/map/land.json`, built by
`tool/map/build_world_map.py` from Natural Earth 1:110m land (public
domain).

## General rules

- **Unknown fields are errors.** A typo such as `onTAp` fails loading with the
  file name and JSON path (e.g. `scenes/desk.json $.hotspots[0].onTAp: unknown field`).
- **Ids** are non-empty strings. Scene, item, and puzzle ids are unique within
  an episode; hotspot, exit, and layer ids are unique within their scene.
- **`rect`** is `[x, y, width, height]`, normalized 0–1 to the scene image
  (or, for examine views, to the examine image). Width and height must be > 0.
- **Image paths** are relative to `assets/`, e.g. `images/scenes/desk.png`.
- **Text** is always a key into the content string tables, never literal text.
- **Stacking:** in `hotspots` and `layers`, later entries are on top. On a tap,
  the topmost visible hotspot wins; exit areas are checked after all hotspots.
- **Minimum tap size:** areas smaller than 44×44 dp on the physical screen are
  grown around their center for hit testing (NFR-05). Small objects stay
  tappable; keep neighbouring small hotspots apart, or put the one that should
  win later in the list.

## `game.json`

```json
{
  "startScene": "room_north",
  "flags": { "drawer_open": false, "clock_turns": 0 },
  "logicalResolution": [1920, 1080],
  "orientation": "landscape",
  "sceneTransitionMs": 400,
  "music": "ambience",
  "hintStages": [
    {
      "id": "find_key",
      "when": [{ "everHadItem": "small_key", "equals": false }],
      "hints": [
        { "key": "hint.stage.find_key.1" },
        { "key": "hint.stage.find_key.2", "when": [ ... ] }
      ]
    },
    { "id": "explore", "hints": [{ "key": "hint.stage.explore.1" }] }
  ]
}
```

| Field | Required | Notes |
|---|---|---|
| `startScene` | yes | Scene id where a new game begins |
| `flags` | yes | Every flag the episode uses, with its default. Values are `true`/`false` (bool flag) or an integer (int flag). The type is fixed by the default |
| `logicalResolution` | yes | `[width, height]`, positive integers |
| `orientation` | no | `landscape` (default) or `portrait` (NFR-03) |
| `sceneTransitionMs` | no | Total fade time between scenes (out + in), default 400; `0` switches instantly |
| `music` | no | Music id played in every scene that has no `music` of its own |
| `hintStages` | no | Hints outside puzzles, per stage of the episode (see **Hints**) |
| `words` | no | Words the player can note down (see **Words and the jar's label**) |
| `secret` | no | The episode's optional secret (see **The keeper's secret**) |

## Conditions (`when`)

A list of condition objects combined with AND. Missing or empty `when` means
always. Each object has exactly one subject key:

| Form | Meaning |
|---|---|
| `{ "flag": "drawer_open", "equals": true }` | Flag has this value. `equals` is required and must match the flag type (bool or int) |
| `{ "hasItem": "small_key", "equals": true }` | Item is currently in the inventory |
| `{ "everHadItem": "small_key", "equals": false }` | Item has ever been picked up (stays true after it is used or combined) |
| `{ "puzzleSolved": "drawer_lock", "equals": true }` | Puzzle is solved |
| `{ "wordNoted": "bucks_row", "equals": true }` | The player has noted this word |

For `hasItem`, `everHadItem`, `puzzleSolved`, and `wordNoted`, `equals`
defaults to `true`.

> **Pickup spots:** hide them with `everHadItem` rather than `hasItem`.
> With `{ "hasItem": "small_key", "equals": false }`, the key reappears after it
> is used up and can be picked up again.

## Actions

Action lists (`onTap`, `onUseItem[].actions`, `onSolved`) run in order. All
state changes apply immediately; presentation effects (text, sound, puzzle
screens, ...) are emitted as events in the same order and played back by the UI.

| `type` | Fields | Effect |
|---|---|---|
| `goToScene` | `scene` | Switch scene. No-op if already there |
| `pickItem` | `item` | Add to inventory. No-op if already held |
| `removeItem` | `item` | Remove from inventory. No-op if not held |
| `setFlag` | `flag`, `value` | `value` must match the flag's declared type |
| `showText` | `key` | Show a text box |
| `openPuzzle` | `puzzle` | Open the puzzle screen |
| `examineItem` | `item` | Open the item's examine view |
| `playSound` | `sound` | Play a sound effect by id |
| `shake` | `durationMs` (int, default 300), `strength` (0–1, default 0.5) | Small camera shake |
| `endEpisode` | — | Mark the episode complete and show the ending screen |

New action types are added in code by implementing `GameAction` and
registering a parser in `ActionRegistry` (`lib/engine/actions/`).

## Scene (`scenes/*.json`)

```json
{
  "id": "desk",
  "background": "images/scenes/desk.png",
  "exits": [ ... ],
  "hotspots": [ ... ],
  "layers": [ ... ]
}
```

`exits`, `hotspots`, and `layers` are optional. `music` (optional) overrides
the episode music while the scene is shown; music keeps playing across scenes
that use the same id.

### Dark scenes

```json
"dark": { "when": [{ "flag": "lamp_lit", "equals": false }], "radius": 0.15 }
```

- **While dark:** while every `when` holds (always, without `when`), the
  scene is black except a circle of lantern light, `radius` wide as a share
  of the scene's width (default 0.16).
- **The light follows the finger:** a drag moves it, and a tap moves it
  before it hits.
- **Getting in:** the scene itself doesn't need a lantern. Content decides
  how the player gets in, usually an exit with
  `{ "hasItem": "lit_lantern" }` and a hotspot in its place that says it is
  too dark.

### A lens between eras

```json
"lens": { "scene": "atrium_79", "when": [{ "hasItem": "era_lens" }], "radius": 0.2 }
```

- **The lens button:** while every `when` holds (always, without `when`), a
  lens button shows at the bottom left. Raised, it is a brass circle,
  `radius` wide as a share of the scene's width (default 0.2), that the
  player pushes around by dragging.
- **Inside the circle** the lens scene shows: its background and its
  visible layers. Taps inside reach that scene's hotspots; taps outside
  reach the scene as usual. **Looking happens through the lens, acting in
  the present:** with an item selected, a tap inside the lens goes to the
  scene itself. Echoes and creatures of the lens scene are not shown.
- **The lens scene** is an ordinary scene file the player never stands in:
  its exits are ignored (a warning). It cannot have a lens of its own, and a
  scene cannot be its own lens (errors). Put pale figures in it as layers
  with echo art.
- **Line them up:** the two scenes are the same place in different years,
  drawn to the same layout, so a thing moves when the lens passes over it.
- **Hours:** with `"scenes": [ … ]` instead of `scene`, the lens looks at a
  different hour, one scene per hour of `lensHours` in `game.json`:

  ```json
  "lensHours": { "flag": "lens_hour",
    "labels": ["pompeii_79.hour.morning", "pompeii_79.hour.noon", "pompeii_79.hour.afternoon"] }
  ```

  A brass tag beside the raised lens names the hour; tapping it turns the
  lens on to the next, round to the first. The int `flag` holds the hour
  (0 = the first label), so conditions can use it. Validated: `scenes`
  needs `lensHours` and one scene per label.

### Echoes

```json
"echoes": [
  { "id": "keeper", "image": "images/objects/flannan_isles_1900/echo_keeper.png",
    "rect": [0.3, 0.4, 0.07, 0.28], "when": [ ... ], "chance": 0.8,
    "drift": [-0.05, 0.05] }
]
```

- **What they are:** faint, faceless figures of memory. **Never a face,
  never a name** (tone guardrails).
- **When they appear:** each time the scene is shown and `when` holds, an
  echo appears with probability `chance` (default 1) a moment later. It
  breathes and drifts by `drift` (normalized), then dissolves when the
  player taps near it or after a while.
- **Taps:** they never block a tap.
- **Art:** figures are drawn pale by `lib/core/art/echo_art.dart`
  (`EchoFigure`).

### Creatures

```json
"creatures": [
  { "id": "gecko", "kind": "gecko", "rect": [0.01, 0.1, 0.1, 0.6], "when": [ ... ], "chance": 1 }
]
```

Small living things, animated in code. `rect` is where each one lives, and
a tap near it may startle it. They never block taps.

| `kind` | Behaviour | Sound |
|---|---|---|
| `gecko` | Clings to a wall, darts between spots, bolts when tapped | `gecko_call` now and then |
| `rat` | Now and then scurries across the floor | — |
| `moth` | Circles the middle of its area (a flame) | — |
| `bats` | Three hang from the vault; one flies a loop now and then; all take off when tapped | `wings_flutter` |
| `gull` | Now and then flies across its sky band | `gull_cry` |
| `fulmar` | Sits on a ledge; flies off when tapped, glides back | `wings_flutter` |
| `grass` | Tufts bending in the wind | — |
| `raven` | Sits on a branch; flies off when tapped, comes back (the fulmar's ways, in black) | `wings_flutter` |
| `swifts` | A few swiftlets wheeling over their area in wide loops; scatter when tapped, wheel back | `wings_flutter` |
| `seal` | A bearded seal lying on a floe (the area's bottom centre), now and then raising its head; slips into the water when tapped, its head seen off the floe a while, then hauls out again | `splash` |
| `heron` | Stands in the shallows on long legs (the area's bottom centre is its feet), now and then strikes at the water; lifts off slowly when tapped, comes back | `wings_flutter` |
| `eagle` | Turns in slow circles high over its area, on broad still wings; too high to startle | `eagle_cry` now and then |

Pick creatures that belong to the tale's place and **season**. For example,
Flannan in December has gulls and fulmars, and no puffins or flowering
thrift.

### Exit

```json
{ "direction": "back", "to": "room_north" }
{ "id": "door", "to": "hallway", "rect": [0.8, 0.2, 0.1, 0.6], "when": [ ... ] }
```

| Field | Required | Notes |
|---|---|---|
| `to` | yes | Target scene id |
| `direction` | one of `direction`/`rect` | `left`, `right`, or `back` (arrow buttons) |
| `rect` | one of `direction`/`rect` | Tap area on the scene |
| `id` | only without `direction` | Defaults to the direction name |
| `when` | no | Exit exists only while met |

### Hotspot

```json
{
  "id": "music_box",
  "rect": [0.12, 0.40, 0.14, 0.18],
  "when": [ ... ],
  "onTap": [ ... ],
  "onUseItem": [
    { "item": "small_key", "actions": [ ... ] }
  ]
}
```

A hotspot whose `when` is not met is hidden: not drawn, not tappable. Using an
item that has no `onUseItem` entry gives short "that doesn't work" feedback.
`onUseItem` may list each item once.

### Layer

```json
{ "id": "drawer_open_sprite", "image": "images/objects/drawer_open.png",
  "rect": [0.40, 0.58, 0.22, 0.18], "when": [ ... ] }
```

Drawn over the background, in list order, while `when` is met.

## Items (`items.json`)

```json
{
  "items": [
    {
      "id": "locket",
      "nameKey": "item.locket.name",
      "descKey": "item.locket.desc",
      "icon": "images/items/locket.png",
      "examine": {
        "image": "images/items/locket_examine.png",
        "hotspots": [ ... ],
        "layers": [ ... ]
      }
    }
  ],
  "combinations": [
    { "a": "lens", "b": "frame", "result": "magnifier" }
  ]
}
```

- `examine` is optional: a close-up view with its own hotspots and layers
  (same format as in scenes). **The examine image is square** (e.g.
  1024×1024); `rect`s are relative to it. Without `examine`, the close-up
  shows the icon. Examine hotspots respond to taps (`onTap`); `onUseItem`
  is not used there.
- A combination works in either order and replaces both items with `result`.
  An item cannot be combined with itself, and each pair may appear only once.

## Puzzle (`puzzles/*.json`)

```json
{
  "id": "drawer_lock",
  "type": "codeLock",
  "background": "images/scenes/<episode>/drawer_lock_close.png",
  "config": { ... },
  "onSolved": [ ... ],
  "hints": [
    { "key": "hint.drawer_lock.1" },
    { "key": "hint.drawer_lock.2", "when": [ ... ] },
    { "key": "hint.drawer_lock.3" }
  ]
}
```

- `background` (optional) is the board image, with the same aspect ratio as
  scenes (1920×1080). Without it a placeholder is drawn.
- `config` is type-specific; see below. Positions inside a puzzle (`rect`)
  are normalized to the board.
- The puzzle screen opens with `openPuzzle` and has a close button; closing
  keeps it unsolved, and it starts fresh when opened again. Once solved,
  input stops, and after a short pause `onSolved` runs and the screen closes.
  Hide the opening hotspot with `{ "puzzleSolved": "<id>", "equals": false }`.
- `onSolved` runs once. Solving an already solved puzzle does nothing.
- At most 3 `hints`, ordered vague → explicit → solution. A hint is offered
  only while its `when` is met.

### `codeLock`

N dials cycling through the same symbols. Arrows turn each dial; the lock
solves as soon as every dial shows the solution.

```json
"config": {
  "slots": 4,
  "symbols": ["0","1","2","3","4","5","6","7","8","9"],
  "solution": ["3","1","4","1"],
  "initial": ["0","0","0","0"]
}
```

`initial` is optional (first symbol on every dial). Symbols are shown as
written, so use digits or glyphs, not words (they are not translated).

### `sequence`

Tap elements in order. A wrong tap flashes the board and resets progress (it
counts as the first step if it matches the first element).

```json
"config": {
  "elements": [
    { "id": "pane_1", "rect": [0.30, 0.12, 0.19, 0.36], "image": "images/..." }
  ],
  "solution": ["pane_2", "pane_4", "pane_1", "pane_3"]
}
```

`image` and `labelKey` (a caption under the element) are optional. An
element may appear several times in `solution`.
- An element's optional `activeImage` replaces its `image` from the moment it
  is tapped in the right place (a candle lights at once) until a wrong tap
  resets the sequence. Elements without one glow instead, unless they appear
  more than once in `solution`.

### `rotaryAlign`

Concentric rings, **outermost first**. Tapping a ring turns it one step
clockwise; solved when every ring is at its `target`. A fixed pointer at the
top marks step 0.

```json
"config": {
  "rings": [
    { "id": "outer", "steps": 8, "initial": 2, "target": 0,
      "image": "images/...", "links": [{ "ring": "middle", "steps": 1 }] },
    { "id": "middle", "steps": 8, "initial": 5, "target": 0 }
  ]
}
```

`links` turn other rings along (`steps` may be negative). `image` is a
square picture of the whole ring, drawn rotated. Make sure the targets are
reachable: rings only turn one way, so links can make combinations
impossible.

### `slotPlacement`

Put pieces into slots. Pieces wait in a tray along the bottom; tap a piece,
then a slot. Tapping a filled slot picks its piece up; dropping a piece on a
filled slot swaps them.

```json
"config": {
  "pieces": [
    { "id": "sun", "image": "images/..." },
    { "id": "gem", "item": "gem" }
  ],
  "slots": [
    { "id": "top", "rect": [0.45, 0.10, 0.10, 0.18] }
  ],
  "solution": { "top": "sun", "bottom": "gem" },
  "initial": { }
}
```

- A piece with `item` appears only while the player holds that item; its
  picture falls back to the item icon. Removing the item is up to
  `onSolved` (e.g. `removeItem`).
- `solution` maps slot → piece; each piece at most once. Slots it leaves out
  may hold anything. `initial` (optional) pre-places pieces.
- A slot's optional `labelKey` is shown as a caption under it.

### `deduction`: the jar's label

```json
"config": {
  "sentences": [
    { "textKey": "whitechapel_1888.label.s1",
      "blanks": ["nichols", "bucks_row", "chapman", "hanbury_street"] }
  ],
  "words": ["nichols", "chapman", "bucks_row", "hanbury_street", "aug31"],
  "nearMiss": 2
}
```

- Each sentence's text holds the placeholders `{1}`, `{2}`, … for its
  `blanks`, in that order. A translation may move them anywhere, but every
  language must hold each exactly once (validated).
- `words` is the bank: every answer plus decoys. Only words the player has
  noted appear. A word can fill several blanks.
- "Distil" checks the whole label. With at most `nearMiss` wrong blanks
  (default 2), the player is told how many; otherwise only that something is
  wrong.
- Every answer must be notable: `given`, or marked `[[id]]` in some text the
  episode shows (validated, as an error). Mark each answer somewhere the
  player can come back to (a hotspot, not only a one-time text).

**Every tale writes its label in its own form** (`form`, default
`sentences`). The check is the same for all:

| `form` | Looks like | Extra fields |
|---|---|---|
| `sentences` | Sentences on a paper label | — |
| `table` | A ledger. Each sentence is a row: its text is the row's heading, with no placeholders, and it has one blank per column | `columns`: heading text keys |
| `telegram` | A telegram form, in capitals, with the UI string `telegramStop` (STOP, ТЧК; nothing in Japanese, Chinese, Korean) in place of each full stop | — |
| `correction` | A text already written and wrong in places: every blank starts with the sentence's `initial` word; the player finds and corrects the wrong ones | `initial` on every sentence, one word per blank, all in `words`; at least one must be wrong |
| `board` | Tags pinned to the picture behind (the puzzle `background`), each at its sentence's `rect`; the words take the right third of the board, so keep every `rect` left of x = 0.64 | `rect` on every sentence |
| `order` | A royal order on parchment: the header *De par le Roy* (UI string `orderHeader`, the same in every language) over `orderSubheader`, the sentences in italic, a red wax seal | — |
| `rubbing` | An ink rubbing (*takbon*) taken from a cast inscription: black paper, the letters pale, a band of lotus scroll, the caption `rubbingCaption` | — |
| `docket` | The cover sheet of a police file: printed headings (`docketHeader`, `docketSubheader`), a register stamp, the entry in dark ink by hand | — |
| `vermilion` | A sheet of imperial yellow in a double vermilion rule, the sentences in vermilion (the emperor's own ink), the caption `vermilionCaption` | — |
| `routebook` | A sports club's route book open at its last page: grey ruled paper, a red margin, a violet club stamp, the caption `routebookCaption`, the entry written in ink | — |
| `cartouche` | An old map's title cartouche: a parchment panel in a double rule with scrolled ends, the caption `cartoucheCaption`, the sentences written inside | — |
| `lontar` | Palm-leaf strips bound on cords at both ends, the sentences incised and blackened across them | — |
| `admiralty` | A printed Admiralty form: its heading `admiraltyCaption` in small capitals, faint rows of print where the request runs on in other languages, a ruled border, the sentences in a hand | — |
| `post` | A palisade post: furrowed bark at both edges, a band stripped to pale wood, the caption `postCaption` and the sentences cut in capitals | — |
| `marker` | A city's stone site marker: grey granite flecked with crystal, a bevelled edge, a cut line framing the face, the caption `markerCaption` cut above, the sentences cut below | — |
| `colophon` | A manuscript's colophon: burnished paper in a thin brown double rule, scorched at one corner, the caption `colophonCaption`, the sentences centred and narrowing, closed by a triangle of dots | — |

Used so far: Whitechapel `table` (the five frames), Semarang `telegram`,
Flannan `correction` (the legend's account), Pompeii `board` (the
diggers' cut, a tag on every layer), Bastille `order` (a blank *lettre de
cachet*, written with only what is known), Gyeongju `rubbing` (taken from
the bell's bronze), Whitechapel 1891 `docket` (the file's cover), Beijing
1908 `vermilion` (written where the court once wrote "illness"), Alamut
1256 `colophon` (the closing lines of the library's last book), Great
Zimbabwe 1871 `cartouche` (where the old maps wrote Ophir), Dyatlov Pass
1959 `routebook` (the last entry the group never wrote), Honnō-ji 1582
`marker` (the site's stone, its face left smooth for what is known),
Roanoke 1590 `post` (under the word the colonists cut), Franklin 1845
`admiralty` (a fresh copy of the form left in the cairn), Borobudur 1814
`lontar` (palm leaves, as Java wrote).

### `clockHands`: set the hands

```json
"config": { "time": "3:40", "start": "9:00", "step": 5 }
```

- **Playing:** the player drags the hands round the dial. The minute hand
  moves in `step` minutes (default 5; it must divide 60), the hour hand from
  hour to hour, and the hand the finger is nearest to moves. When the hands
  lie close together, a finger near the middle takes the short hand.
- **Solved** as soon as they show `time` (hours 1 to 12). `start` (default
  12:00) must differ from it; avoid a start where both hands overlap.
- `image` (optional) is the dial; without it a paper dial with Roman
  numerals is drawn.

### `rakingLight`: read by a low light

```json
"config": { "surface": "images/…/wax_tablet_surface.png",
            "marks": "images/…/wax_tablet_marks.png", "from": 290, "tolerance": 14 }
```

- **Playing:** a surface in the dark and a lamp the player drags round it.
  The faint `marks` rise out of the `surface` as the light grazes them:
  shadows on one side of every stroke, a glint on the other.
- **Solved** when the lamp rests for a moment within `tolerance` degrees
  (default 12) of `from`: the direction the light must come from, clockwise
  from the top (0 above, 90 right, 180 below, 270 left). The marks begin to
  show within three times the tolerance. The lamp starts on the opposite
  side.
- Draw `marks` in any colour: the view tints it as shadow and highlight.

### `thread`: a red thread from pin to pin

```json
"config": {
  "pins": [ { "id": "bucks_row", "at": [0.74, 0.3], "labelKey": "…" } ],
  "solution": ["bucks_row", "hanbury_street", "…"]
}
```

- **Playing:** the player drags the thread from pin to pin, or taps the
  pins in turn. The next pin of `solution` takes the thread. A wrong pin
  snaps it, and it starts again from `solution`'s first pin.
- `at` is a pin's place on the board (normalized); `labelKey` (optional) is
  written under it in ink. Draw the map in the puzzle `background`.

### `crank`: wind it

```json
"config": { "turns": 4, "clockwise": true, "image": "images/…/drum.png" }
```

- **Winding:** drag round the wheel. `turns` full circles wind it (default
  3), in the direction `clockwise` says (default `true`).
- **Ratchet:** turning the wrong way does nothing. A ratchet click (and
  vibration) sounds every quarter turn.
- **Image:** `image` (optional) turns with the handle; without it, a brass
  wheel is drawn.

### `reveal`: wipe or rub

```json
"config": {
  "style": "wipe",
  "hidden": "images/objects/whitechapel_1888/fog_writing.png",
  "cover": "images/objects/whitechapel_1888/hearth_ash.png",
  "area": [0.22, 0.3, 0.56, 0.4],
  "threshold": 0.6,
  "brush": 0.055
}
```

- `style`: `wipe` (fog, dust, ash) or `rub` (shading paper with a pencil).
- `hidden` is the picture uncovered. `cover` (optional) is the surface on top.
  It must be code-drawn art for now; without it, the style draws fog or blank
  paper.
- Only `area` counts; the puzzle is solved when `threshold` of it is
  uncovered (default 0.7). `brush` is the finger's radius as a share of the
  board width (default 0.05).

### `overlay`: stack the sheets

```json
"config": {
  "sheets": [
    { "id": "boat", "image": "images/objects/pompeii_79/sheet_boat.png",
      "rect": [0.3, 0.1, 0.4, 0.8], "from": [0.03, 0.14] },
    { "id": "people", "image": "…", "rect": [0.3, 0.1, 0.4, 0.8],
      "from": [0.58, 0.05], "turns": 1 }
  ],
  "snap": 0.04
}
```

- **Sheets** are see-through (tracing paper, glass negatives, stencils).
  Each belongs at `rect`, which is also its size. It starts with its
  top-left corner at `from` (default: already in place) and `turns` quarter
  turns clockwise (0 to 3, default 0).
- **Playing:** drag a sheet to move it; tap it to turn it a quarter. The
  sheet last touched lies on top.
- **Settling:** a sheet let go within `snap` (a share of the board, default
  0.035) of its place, the right way up, settles there and stays. Settled
  sheets sink under the loose ones. The puzzle is solved when every sheet
  has settled.
- **A sheet without `from`** starts in place: a fixed base to build on. At
  least one sheet must start out of place.
- **Draw the sheets** so their lines only make sense together, and give
  them marks that meet (registration crosses) so the player sees how close
  they are.

### `beamSweep`: what the beam shows

```json
"config": {
  "pivot": [0.5, 0.9],
  "period": 7,
  "spread": 0.3,
  "targets": [
    { "id": "rail", "rect": [0.6, 0.5, 0.1, 0.08],
      "labelKey": "flannan_isles_1900.beam.rail" }
  ]
}
```

- **The beam** turns clockwise round `pivot` (where the lamp is), once
  every `period` seconds (default 8, from 2 to 60), starting pointing
  right. `spread` is half its width in radians (default 0.2). Everything
  outside it is dark.
- **Targets** are lit while the beam's centre line is within `spread` of
  their centre, as seen from the pivot on the board as drawn. Tapping a lit
  target finds it (ringed in gaslight, `labelKey` written under it);
  tapping it in the dark is a miss. Solved when every target is found.
- **The background** is the whole scene, drawn as if lit; the puzzle
  darkens it.

### `swell`: down the steps between the waves

```json
"config": {
  "steps": 6,
  "stepSeconds": 0.55,
  "interval": 2.2,
  "pattern": [2, 1, 3, 2, 1, 4, 6, 1, 1, 2]
}
```

- **The player** starts on the top step (0) and goes down one step per tap,
  no faster than one every `stepSeconds` (default 0.6). Reaching step
  `steps` (the bottom, 2 to 12) solves it.
- **Waves** break every `interval` seconds (default 2.2), the first one
  `interval` seconds in. Each covers `pattern[i]` steps from the bottom
  (1 to `steps`), the pattern looping. A wave that covers the player's step
  sends them back to the top. A wave of `steps` is a great sea: it covers
  all but the top.
- **Cues:** before each wave the water draws back, further before a bigger
  one; before a great sea it draws right back while the `great_sea` roar
  rises (1.2 s). Small waves play `wave`. Being caught plays `mistake` and a
  vibration, so the puzzle also works with the sound off.
- **Background:** the sky and the cliff; the puzzle draws the steps, the
  sea, and the player's lantern.

### `roster`: who, what, when

```json
"config": {
  "rows": [ { "id": "ducat", "labelKey": "flannan_isles_1900.word.ducat" } ],
  "columns": [
    { "id": "wore", "labelKey": "flannan_isles_1900.roster.wore",
      "options": [
        { "id": "oilskins", "labelKey": "…" },
        { "id": "shirtsleeves", "labelKey": "…" }
      ] }
  ],
  "solution": { "ducat": { "wore": "oilskins" } }
}
```

- **A board on paper:** a row per person (at least two), a column per thing
  to work out (at least one), each column with two or more options.
- **Playing:** tap a box to step through its column's options, from blank
  round and round.
- **Checking:** once every box is filled, a board that does not match
  `solution` says how many rows are still wrong. Solved when every row
  matches. `solution` must name every row and column with a real option.

### `keyring`: find the key and turn it the right way

```json
"config": {
  "profile": [1, 3, 0, 2, 2],
  "keys": [
    { "id": "a", "bits": [1, 3, 0, 2, 1] },
    { "id": "c", "bits": [2, 2, 0, 3, 1] }
  ]
}
```

- **What the player sees:** a lock plate whose keyhole is cut the shape of
  `profile`, a ring of keys, and the key in hand.
- **Cuts:** `profile` and every key's `bits` are cut depths along the bit,
  0 to 3, from the stem to the tip; 3 to 8 places, the same count
  everywhere.
- **Playing:** tap a key on the ring to take it (the right way up); tap the
  key in hand to turn it over, which reads its bits from the tip back; tap
  the lock to try it. A key that does not fit plays `keyTry` and says so.
- **Validation:** at least two keys, unique ids, and exactly one (key, way
  round) that fits.

### `cipher`: read a letter in numbers

```json
"config": {
  "groups": ["511", "208", "73", "219", "64", "401"],
  "lines": [3],
  "key": [
    { "code": "511", "text": "Bu" },
    { "code": "208", "text": "lon" }
  ]
}
```

- **What the player sees:** the letter, its `groups` of numbers broken into
  lines before each index in `lines`; and beside it a worksheet of `key`
  entries (a number and the syllable it stands for), in the order given.
- **Playing:** tap a number in the letter, then the same number on the
  worksheet: its syllable is written over every group with that number. A
  wrong entry is a slip (a mistake sound).
- **Numbers on no worksheet** (in `groups` but not `key`) cannot be picked;
  once the rest is read they are ringed. Solved when every number that has
  an entry is read. The key may hold decoys that are not in the letter.
- **Validation:** at least two groups, `lines` rising inside the letter,
  codes unique in the key, and at least one group the key can read.

### `sources`: sort a file of papers

```json
"config": {
  "trays": [
    { "id": "time", "labelKey": "bastille_1703.file.tray_time" },
    { "id": "after", "labelKey": "bastille_1703.file.tray_after" }
  ],
  "cards": [
    { "id": "louvois_1669", "titleKey": "…", "textKey": "…", "tray": "time" }
  ]
}
```

- **What the player sees:** the trays across the top, the papers still to
  sort along the bottom, each with a title (who wrote it, and when) and a
  short text.
- **Playing:** tap a paper, then a tray; tap a paper in a tray to take it
  back out. Once every paper is in a tray, the file says how many are in
  the wrong one (`sourcesWrong`); solved when none are.
- **Validation:** at least two trays and three cards, unique ids, every
  card's `tray` known, and at least one card for every tray.

### `pour`: route the bronze

```json
"config": {
  "columns": 5,
  "furnaces": [0, 2, 4],
  "cups": [1, 2, 3],
  "tiles": ["straight:0", "tee:0", "straight:0", "tee:2", "straight:0",
            "bend:0", "bend:2", "straight:0", "bend:1", "bend:3",
            "empty", "straight:0", "straight:0", "straight:0", "bend:0"],
  "start": [1, 1, 1, 0, 3, 2, 1, 1, 3, 2, 0, 1, 3, 1, 2]
}
```

- **What the player sees:** furnaces over the top row (at the columns in
  `furnaces`), the mould's pouring cups under the bottom row (at `cups`),
  and a grid of clay channel pieces between.
- **Pieces:** `tiles` lists the grid row by row as `kind:turns`, the
  clockwise quarter turns each has **when solved**. Kinds: `straight`
  (top–bottom), `bend` (top–right), `tee` (top–right–bottom), `cross`
  (all four, cannot turn), `empty` (sand, cannot turn). `start` adds turns
  to scramble them.
- **Playing:** tap a piece to turn it a quarter; tap Pour. Bronze runs
  from every furnace; where it would run into sand, air or a piece that
  does not meet it, it splashes, and the furnaces close again.
- **Solved** when every furnace feeds the channels, every cup fills, and
  nothing spills. Other routes than the given one count too.
- **Validation:** 2–8 columns, whole rows, the solved turns must pour, the
  scrambled start must not.

### `resonance`: the bell over its hollow

```json
"config": { "depths": 5, "start": 0, "right": 3, "mark": 0.8 }
```

- **What the player sees:** the bell in cross-section over a hollow in the
  ground, a log striker on ropes, Deeper and Shallower, and a panel where
  each strike's ring is drawn, with a mark.
- **Playing:** drag the log back and let go. The ring's length is the pull
  (below 0.4 it barely touches) times how well the hollow suits the bell:
  1 at `right`, 0.75 one step off, and so on. Solved when a ring reaches
  `mark` (above 0.75, at most 1): only a strong pull over the right depth.
- **Validation:** 3–8 depths; `start` and `right` differ.

### `beat`: find where the ring swells deepest

```json
"config": { "swell": [0.25, 0.45, 0.35, 0.6, 0.3, 0.92, 0.5, 0.2] }
```

- **What the player sees:** the bell's rim from below with a place to
  strike for each entry of `swell` (6–12, clockwise from the top), a panel
  for the ring's trace, and a Mark button.
- **Playing:** tap a place to strike it: its ring swells and fades as deep
  as its `swell` (0 steady, 1 to silence and back), heard (four sounds,
  `beat_steady` to `beat_deep`, chosen by depth) and seen. Mark the place
  last struck. The deepest place solves it; any other is a mistake.
- **Validation:** the deepest must stand at least 0.15 above every other.

### `unwatched`: what changed while no one was looking

```json
"config": {
  "items": [
    { "id": "nichols", "labelKey": "…", "dateKey": "…" },
    { "id": "smith", "labelKey": "…", "dateKey": "…" }
  ],
  "start": ["nichols"],
  "rounds": [ { "add": "smith", "at": 0, "move": [1, 0] } ]
}
```

- **What the player sees:** a shelf of files standing spine out, each with
  its `labelKey` and a smaller `dateKey` line, and a Look away button.
- **Playing:** Look away: the lamp gutters (`lamp_gutter`), the screen goes
  dark for a moment, and the next round changes the shelf: `add` goes in
  at `at`, then, if `move` is given, the file at `move[0]` moves to
  `move[1]`. Tap the new file; any other is a mistake (it was already
  there). Solved once every round's file is found.
- **Validation:** unique ids; `start` and every `add` known; an `add` is
  never already on the shelf; `at` and `move` within the shelf.

### `compose`: set a line of type

```json
"config": { "text": "FRANCES COLES", "reversed": ["R", "N", "C", "S", "L"],
            "extra": ["P", "D", "B"] }
```

- **What the player sees:** a proof (what the line prints), the composing
  stick (the sorts set so far, face up), and the type case.
- **The case:** one sort for each letter of `text` and of `extra`, cut in
  mirror as real type is; for each letter in `reversed`, a second sort cut
  the wrong way (it looks right on its face and prints backwards); a
  blank quad for spaces. The case is dealt in a fixed jumble.
- **Playing:** tap a sort to set it; Take out removes the last. A wrongly
  cut sort shows backwards in the proof. Solved when the stick holds the
  whole line from rightly cut sorts; a full line that is wrong says so.
- **Validation:** `text` is 3–24 capitals A–Z and single spaces;
  `reversed` letters are in the text and not mirror-symmetric
  (A H I M O T U V W X Y); `extra` letters are not in the text.

### `strand`: find the highest segment on a short budget

```json
"config": {
  "strands": [ { "readings": [9, 14, 22, 41, 88, 190, 420, 980, 1650, 2404, 1210, 530, 240, 96] } ],
  "measurements": 7,
  "curve": "peak"
}
```

- **What the player sees:** each strand (I, II, III) as a row of
  segments, root to tip, on a strip of bench paper; beside it the
  readings left and a New sample button; a Mark as highest button below.
- **Playing:** tap a segment to measure it (a counter's clicks,
  `geiger` or `geiger_hot` by the reading): its reading shows as a number
  and a bar, drawn against a ceiling of 2.2 times the strand's highest so
  a bar alone does not give it away. A sample allows `measurements`
  readings; New sample (`sample`) starts the strand over. Tap a measured
  segment and Mark it: the strand's highest finds it and shows the whole
  strand's readings; any other is a mistake. Once every strand is found,
  say whether the readings run `steady` along the hair or rise to sharp
  `peak`s; `curve` is the right answer.
- **Validation:** 1 to 3 strands of 6 to 30 readings, all above 0, each
  with one clear highest; `measurements` from 3 to one less than the
  shortest strand; `curve` is `steady` or `peak`.

### `scan`: a probe over a garment

```json
"config": {
  "layers": [
    { "id": "outer", "labelKey": "…", "scale": 0.4 },
    { "id": "inner", "labelKey": "…", "scale": 1 }
  ],
  "spots": [
    { "id": "stomach", "labelKey": "…", "at": [0.5, 0.6], "radius": 0.1, "strength": 0.9 }
  ],
  "background": 0.06
}
```

- **What the player sees:** a robe laid flat (the layer with `scale` 1 as
  pale inner silk, any other as the dark outer robe), a brass probe on
  it, a dial with the top half of its scale in red, a chip per layer, and
  a Mark here button.
- **Playing:** drag or tap on the robe to move the probe; the needle shows
  the reading there (`probe_tick` as it crosses each tenth): `background`
  plus the layer's `scale` times each spot's `strength`, falling off as
  exp(−(d/radius)²). Mark here where the reading is at least 0.5 (the red)
  inside a spot not yet found: it is found and ringed in vermilion. Inside
  a spot but below the red is only faint (no mistake); outside every spot
  is a mistake. Solved when every spot is found.
- **Validation:** 1 to 3 layers with scales above 0 up to 1, one of them 1;
  `background` below 0.5; 1 to 6 spots with unique ids, `at` from 0 to 1,
  `radius` 0.03 to 0.3, `strength` above 0 up to 1, each reading at least
  0.5 at its centre on the strongest layer. Spots may share a `labelKey`
  (both shoulders).

### `quire`: sheets nested by their catchwords

```json
"config": {
  "leaves": ["ep.quire.l1", "ep.quire.l2", "…", "ep.quire.l8"],
  "start": [
    { "sheet": 2, "turned": true },
    { "sheet": 0, "turned": false },
    { "sheet": 3, "turned": true },
    { "sheet": 1, "turned": true }
  ]
}
```

- **What the player sees:** the gathering opened flat, page by page in
  the order the sheets now nest: each page with its first word at the
  head, faint lines of script, and at its foot the catchword (the first
  word of the page that truly follows it; the last page ends in a
  triangle of dots). Between two pages a gold thread when the catchword
  meets the next page. Beneath, an arc per sheet joining its two leaves,
  the outermost widest. A Turn over button, the count of catchwords that
  meet, and the page last tapped read in full.
- **Playing:** sheet `k` is folded from leaves `k` and `n − 1 − k` (`n`
  leaves). Tap a page to pick its sheet (both its leaves light up), then
  a page of another sheet: the two sheets swap depths. Turn over swaps
  the picked sheet's two leaves. A move that makes a catchword meet plays
  `catchword`, any other `place`. Solved when every catchword meets its
  page, which is only the true order.
- **The catchword** is the first word of a leaf's text in the current
  language (quotes and marks skipped); in Japanese and Chinese, its first
  two characters. Every leaf must begin with a different one, in every
  language, and leaf texts carry no word marks (both checked by
  `test/features/alamut_puzzles_test.dart`).
- **Validation:** 4 to 12 leaves, an even number, all different; `start`
  lays every sheet once, outermost first; the start may not already read
  through.

### `dip`: tanks named by how the reed drips

```json
"config": {
  "tanks": [
    { "liquid": "wine", "level": 0.86 },
    { "liquid": "honey", "level": 0.9 }
  ],
  "names": [
    { "liquid": "wine", "labelKey": "…" },
    { "liquid": "honey", "labelKey": "…" },
    { "liquid": "milk", "labelKey": "…" }
  ]
}
```

- **What the player sees:** each tank in section: a dark shaft cut into
  the rock under a wooden cover, and a reed.
- **Playing:** drag down on a tank to lower the reed; where it meets the
  surface it goes heavily on (`reed_touch`). Let go after touching: the
  reed is drawn out and drips for a few seconds, each liquid its own way
  (water clear and quick, vinegar pale and quicker, wine dark, milk white;
  honey and oil stretch into a thread before a drop lets go: `drip` or
  `drip_slow`), and the tank shows how full it is. Then a name button per
  offered liquid: the right one names the tank, a wrong one is a mistake.
  Once every tank is named, say whether the stores were running low or
  full: full when every tank stands at least 0.6 deep.
- **Liquids:** `water`, `wine`, `vinegar`, `honey`, `milk`, `oil`.
- **Validation:** 2 to 5 tanks, each liquid in one tank only, `level` from
  0.1 to 0.95; `names` each liquid once, every tank's liquid among them,
  and at least one more to mislead.

### `courses`: a breach laid back, dry, course by course

```json
"config": {
  "width": 12,
  "base": [3, 4, 2, 3],
  "courses": 3,
  "blocks": [4, 2, 4, 4, 4, 2, 4, 2, 4, 4, 2],
  "chevrons": [true, true, false, true, false, false, true, false, true, true]
}
```

- **What the player sees:** the gap in the wall face on: the course still
  standing at the bottom (`base`), the courses to lay above it, the
  chevron band on top; beside it the course count and Take back; under it
  the fallen pile, each block as long as it is.
- **Playing:** tap a block to lay it next in the current course, from the
  left (`block_lay`). It is refused, as a mistake, if it would run past
  the gap or end over a joint of the course below (the joints below are
  marked in red). A full course moves on to the next. Take back lifts the
  last block laid. Once every course is laid (`note`), tap the band's
  slabs to lean them the other way (`slab_tilt`) until they lean in turn,
  starting either way.
- **Validation:** `width` 4 to 16; `base` and every block whole lengths
  from 1 to `width`, `base` summing to `width`; `courses` 1 to 5; the pile
  summing to `width` × `courses` and layable (checked by search); 4 to 16
  `chevrons`, not already alternating.

### `identify`: a key walked to a name

```json
"config": {
  "start": "pores",
  "couplets": [
    { "id": "pores", "choices": [
      { "textKey": "…", "to": "size" },
      { "textKey": "…", "to": "cedar" } ] }
  ],
  "names": [
    { "id": "cedar", "nameKey": "…", "noteKey": "…" }
  ],
  "answer": "tambootie"
}
```

- **What the player sees:** the specimen on the puzzle's background, at
  the left; at the right a mark per step taken, and the couplet asked: its
  two statements as buttons, a. and b.
- **Playing:** pick the statement true of the specimen (`key_step`). A
  statement leads to the next couplet or to a name. The answer's name
  solves it, shown with its note. Any other name is a wrong end: a
  mistake; its name and note are shown, and the key goes back to the last
  couplet the path shared with the answer's, where it turned wrong.
- **Validation:** every couplet has exactly two choices; ids are unique
  across couplets and names; `start` is a couplet and `answer` a name; the
  key is a tree reaching every couplet and name exactly once.

### `snowpit`: a snow profile and a column test

```json
"config": {
  "layers": [
    { "thickness": 12, "hardness": "fist" },
    { "thickness": 38, "hardness": "oneFinger" },
    { "thickness": 6, "hardness": "fist" }
  ],
  "weak": 2,
  "breakTap": 14
}
```

- **What the player sees:** the pit wall, its layers from the surface
  down, each drawn as thick as it is (never thinner than a tap); five
  buttons (fist, four fingers, one finger, pencil, knife), Mark as weak,
  and Tap with the count and its phase (wrist, elbow, shoulder).
- **Playing:** tap a layer, then push an object into it (`snow_push`, or
  `reject` if it will not go in). A layer's hardness is known once the
  object of its hardness went in and the next larger did not (a fist is
  the largest); it then shows as a bar and its shorthand (F, 4F, 1F, P,
  K). Mark a layer whose hardness, and the one above it, are known: if it
  is not softer than the layer above, a mistake. Marking cuts a column to
  just below it; each Tap (`shovel_tap`) counts to 30. If the `weak` layer
  is in the column, it breaks there at `breakTap` (`column_break`): solved
  if that is the layer marked, otherwise a mistake and the player marks
  again. A column above the weak layer never breaks.
- **Hardness:** `fist`, `fourFingers`, `oneFinger`, `pencil`, `knife`
  (softest first).
- **Validation:** 3 to 8 layers, each 2 to 80 cm; `weak` below the first
  layer and softer than the one above it; `breakTap` 1 to 30.

### `darkroom`: frames printed from a test strip

```json
"config": {
  "strip": [2, 4, 8, 16, 32],
  "frames": [
    { "image": "images/objects/ep/frame_1.png", "captionKey": "…", "exposure": 2 }
  ]
}
```

- **What the player sees:** the roll's frames as negatives along the top
  (printed ones as positives with a check); the picked frame's test strip,
  a band per exposure, each a slice of the frame printed at that time; the
  last print, with its caption once printed right.
- **Playing:** pick a frame, tap a band to print it: the right band
  (`exposure`) prints it (`enlarger`) and moves on to the next frame;
  shorter comes out grey and empty, longer dark, a mistake. Solved when
  every frame is printed. The frames are drawn in plain tones; the view
  greys them and lightens or darkens them by the bands' distance from the
  right one.
- **Validation:** 3 to 7 bands, rising and above 0; 1 to 6 frames, each
  `exposure` never the first or last band.

### `strata`: layers dated by what was dropped in them

```json
"config": {
  "layers": [
    { "labelKey": "ep.strata.topsoil",
      "finds": [ { "labelKey": "ep.find.yen", "year": 1951 } ] },
    { "labelKey": "ep.strata.ash", "burnt": true,
      "finds": [ { "labelKey": "ep.find.eiraku", "year": 1408 } ] }
  ],
  "fireYear": 1582,
  "fire": 1
}
```

- **What the player sees:** a section through the earth, its layers from
  the top down as bands (burnt ones black, flecked with tile), each with
  its finds in it (coins drawn holed, anything else as a sherd) and its
  name, or once dated "Not before …"; beside it a chip for every find's
  year, the status, and "This is the fire".
- **Playing:** tap a find to read it (`find_lift`): its text says the
  earliest year it could have been dropped. Tap a layer, then a year: the
  right one (`strata_tag`) is its earliest year, the later of its own
  youngest find and the layer beneath it (a layer lies on top of what was
  there before); the pick then moves to the next undated layer. A wrong
  year is a mistake. Once every layer is dated, pick the layer of the
  fire and tap "This is the fire": a layer that did not burn, or one too
  young to be that fire, is a mistake; the `fire` layer solves it.
- **Validation:** 3 to 8 layers, each with 1 to 4 finds (years 1 to
  2100); `fire` is a burnt layer whose earliest year is no later than
  `fireYear`, and no other burnt layer's is.

### `streets`: a block named by its address

```json
"config": {
  "columns": [ { "labelKey": "ep.street.aburanokoji" }, { "labelKey": "…" } ],
  "rows": [ { "labelKey": "ep.street.oike" }, { "labelKey": "…" } ],
  "targets": [ { "clueKey": "ep.streets.old", "block": [0, 3] } ]
}
```

- **What the player sees:** a city's grid, north up: `columns` (north to
  south streets, west to east) named along the top, `rows` (east to west
  streets, north to south) down the left, the blocks between them; a
  card with the current address and the instruction (the UI string
  `streetsInstruction`), and the count found.
- **Playing:** read the address and tap the block it names: block
  `[c, r]` lies east of column `c`, west of `c + 1`, south of row `r` and
  north of `r + 1`. Right (`street_mark`) marks it and turns to the next
  address; wrong is a mistake. Solved when every target is marked.
- **Validation:** 2 to 14 columns and 2 to 10 rows; 1 to 4 targets, each a
  different block between the streets.

### `rings`: a tree-ring core cross-dated

```json
"config": {
  "startYear": 1560,
  "master": [0.47, 0.81, 0.22],
  "core": [0.75, 0.65, 0.61],
  "offset": 19,
  "run": 3
}
```

- **What the player sees:** the master chronology across the top, a bar
  for every year (its height the ring's width), years every ten; below
  it the core, a strip of wood with its own bars and no years, where it
  lies along the master; arrows, the status, and Check the match (later
  These are the driest years).
- **Playing:** drag the core (or step it with the arrows, `core_slide`)
  along the master; Check: where its pattern matches (`offset`), it is
  dated and shows its years; anywhere else is a mistake. Then a bracket
  `run` rings wide appears on the core: move it with a drag or the arrows
  and mark it; the narrowest run (`ring_mark`) solves it, any other is a
  mistake.
- **Validation:** widths 0.05 to 1; 12 to 60 master years and 6 to 24
  core rings, the core wholly on the master at `offset`; the core matches
  there better than anywhere else by 0.5 in summed difference; `run` 2 to
  5, its narrowest run narrower than any other.

### `dividers`: a distance walked on a chart

```json
"config": {
  "milesAcross": 120,
  "aspect": 0.6,
  "north": 90,
  "origin": [0.62, 0.84],
  "spans": [5, 10, 25],
  "tolerance": 6,
  "places": [ { "labelKey": "ep.place.croatoan", "at": [0.2, 0.86] } ],
  "targets": [ { "clueKey": "ep.dividers.croatoan", "place": 0 } ]
}
```

- **What the player sees:** the chart (`aspect` as tall as wide, drawn as
  its maker drew it: the compass rose shows where `north` lies, degrees
  clockwise from up), its places, a scale of miles, the origin in red;
  beside it the clue, the spans, eight headings (from true north), Step,
  Back and Mark here, and the walk drawn as the dividers' legs.
- **Playing:** open the dividers to a span and pick a heading (either
  starts the walk again at the origin), Step (`divider_step`) and Back;
  Mark: within `tolerance` miles of the clue's place finds it (rings it
  red; the next clue follows); near another place, or nowhere, is a
  mistake.
- **Validation:** 1 to 4 spans above 0, 2 to 10 places (positions 0 to
  1), 1 to 4 targets, each a different place that a whole number of
  steps (1 to 15) of one span on one heading reaches.

### `margins`: a sheet turned to read its margins

```json
"config": {
  "passages": [
    { "textKey": "ep.note.body", "rect": [0.18, 0.31, 0.64, 0.32], "turn": 0 },
    { "textKey": "ep.note.deserted", "rect": [0.84, 0.16, 0.16, 0.68], "turn": 1 }
  ],
  "questions": [ { "questionKey": "ep.note.q_deserted", "passage": 1 } ],
  "startTurn": 0
}
```

- **What the player sees:** a square sheet with its passages where they
  lie (`rect`, on the sheet as it lies unturned), each written at its own
  quarter turn (`turn`: how far the sheet must be turned clockwise for it
  to stand upright); a `printed` passage is set in the form's type.
  Beside it the question, two arrows to turn the sheet, the count
  answered.
- **Playing:** turn the sheet (`sheet_turn`, it turns the short way);
  tap a passage: if it does not stand upright, a nudge to turn the sheet
  (`reject`); upright and the answer, the next question (`place`);
  upright and not the answer, a mistake.
- **Validation:** 3 to 8 passages on the sheet, `turn` 0 to 3; 1 to 4
  questions, each a different passage; `startTurn` 0 to 3.

### `sonar`: a side-scan survey, lane by lane

```json
"config": {
  "columns": 12,
  "rows": 8,
  "hours": 3,
  "wreck": { "column": 5, "row": 5, "length": 2 },
  "rocks": [ [2, 1], [8, 5] ],
  "scours": [ [2, 5] ],
  "marks": [ { "labelKey": "ep.sonar.grant_point", "at": [11.4, 3.3] } ]
}
```

- **What the player sees:** the survey area as dark water, the lanes
  ruled east and west (north at the top), the named places; each lane run
  as an amber side-scan strip: rocks a bright round echo with a short
  shadow, ice scours a long groove with none, the wreck a long shape with
  a long straight shadow. Beside it the hours left and what the last mark
  showed; Next season once the hours are spent.
- **Playing:** tap a lane not run to run it (`lane_run`, an hour); tap a
  cell of a run lane to mark the wreck: the wreck solves it (`echo_mark`),
  anything else is a mistake. With the hours spent and the wreck not
  found, Next season clears the lanes and gives the hours back (a
  mistake).
- **Validation:** 6 to 16 columns, 4 to 12 rows, 1 to `rows` hours; the
  wreck, rocks and scours inside the grid, on no other; up to 8 marks.

### `mudra`: statues set back by their hands

```json
"config": {
  "statues": ["earth", "meditation", "wheel"],
  "places": [
    { "labelKey": "ep.mudra.east", "mudra": "earth", "slots": 1 },
    { "labelKey": "ep.mudra.west", "mudra": "meditation", "slots": 1 },
    { "labelKey": "ep.mudra.stupa", "mudra": "wheel", "slots": 1 }
  ]
}
```

- **What the player sees:** the statues in a row, each a seated Buddha
  drawn with its hands in its gesture (no label); beside them the
  monument from above, north up: a band for each face (`noFear` north,
  `giving` south, `meditation` west, `earth` east), the fifth balustrade
  (`teaching`) within, the stupas (`wheel`) at the centre, each with its
  count filled.
- **Playing:** tap a statue (`lift`), then a place: where its hands
  belong and with room, it is set (`niche_set`) and leaves the row; any
  other place is a mistake; a full place, a nudge.
- **Gestures:** `earth`, `giving`, `meditation`, `noFear`, `teaching`,
  `wheel`.
- **Validation:** 3 to 12 statues; 2 to 6 places, each a different
  gesture, with exactly as many slots as statues with it.

### `casing`: a memory of deeds and their fruits

```json
"config": {
  "columns": 4,
  "panels": [
    { "labelKey": "ep.karma.killing", "pair": 0 },
    { "labelKey": "ep.karma.short_life", "pair": 0, "fruit": true }
  ]
}
```

- **What the player sees:** a wall of numbered casing stones, `columns`
  across, in panel order row by row; a lifted stone shows its relief (a
  deed: two figures; a fruit: one) with its caption and a Deed or Fruit
  tag; a kept pair framed as photographed.
- **Playing:** lift a stone (`stone_lift`); with one out, lift another:
  a deed and its fruit (same `pair`) are kept (`pair_found`), any other
  two stay out until the next lift puts them back (a mistake).
- **Validation:** 2 to 6 columns, 4 to 16 panels, every `pair` one deed
  and one `fruit`.

## Words and the jar's label

`words` in `game.json` declares what the player can note down:

```json
"words": [
  { "id": "nichols", "labelKey": "item.whitechapel_1888.name_card_nichols.name", "kind": "name" },
  { "id": "bucks_row", "labelKey": "whitechapel_1888.street.bucks_row", "kind": "place" },
  { "id": "north", "labelKey": "…", "kind": "thing", "given": true }
]
```

- `kind` is one of `name`, `place`, `date`, `number`, `thing`. It sets the
  word's color on the label screen.
- `labelKey` is any text key; reusing existing names keeps them consistent.
- `given` words are known from the start.
- In any text shown in the text box or an item's description, `[[id]]` marks
  a word. It reads as the word's label, underlined; tapping it notes the word
  (the `WordNotedEvent`, with a toast and a pencil sound).
- Every language must mark the same words in a text (validated).
- Every tale ends by writing its jar's label (a `deduction` puzzle) before the
  episode ends. That is the Stillroom's own step (*Menyuling kisah*).

## The keeper's secret

```json
"secret": {
  "when": [{ "puzzleSolved": "hearth_ash" }],
  "noteKey": "whitechapel_1888.keeper.note"
}
```

- **Found:** the secret is found the moment all conditions hold, checked
  after every action. The player sees "✦ You found one of the keeper's
  notes" and a chime.
- **Kept:** the save keeps `noteKey` per episode, even after the tale is
  started over. The jar gets a small brass star, and its dialog shows the
  note.
- **Optional:** a secret must never be needed to finish the tale. Hide it
  behind curiosity: a second look, a door that appears later.
- **Showing the note:** the note text is content like any other; show it
  with `showText` where the secret is found.

## Hints

The hint button (💡) shows the hints relevant right now (PRD FR-08):

- **In a puzzle:** that puzzle's `hints`.
- **Elsewhere:** the current **stage** from `hintStages` in `game.json` — the
  **first** stage in the list whose `when` is met. List later stages of the
  episode first, and end with a stage without `when` as the fallback.

Each group has up to 3 hints (vague → explicit → solution). A hint's own
`when` hides it until it applies. The player reveals them one at a time; each
reveal goes through the `HintGate` and is stored in the save, so a revealed
hint stays revealed. The button is hidden when no hint is on offer.

**Hint candle (pacing, 2026-09-26).** The gate is `CandleHintGate`: each
hint waits for a candle that burns only while the player is on that stage or
puzzle with the app in the foreground. Waits (`HintPacing`): 45 s, then
90 s, then 150 s for the solution, counted from the previous hint of the same
group; shelf II waits 1.5×, shelf III 2×. The button's flame grows as the
candle burns. Candles live in memory, so they start again after a restart.
The debug panel has *Light the hint candle*.

## Audio

- `playSound` ids map to `assets/audio/sfx/<id>.ogg|mp3|wav`.
- `music` ids map to `assets/audio/music/<id>.ogg|mp3|wav` and loop.
- A missing file plays silently (placeholder) and shows up as a validator
  warning. Volumes follow the player's settings.
- `shake` shakes the scene and, if vibration is on, vibrates the phone.
  Rejected items and failed combinations give a light vibration.

## How players interact (M3)

Useful when designing content; the rules live in `GameSession`.

- **Inventory:** tap an item to select it, tap it again to deselect.
  With an item selected, tapping another item tries a combination: success
  replaces both with the result; failure gives a short shake and selects the
  tapped item instead.
- **Using items:** with an item selected, tapping a hotspot runs its
  `onUseItem` entry for that item. On success the selection clears; if the
  hotspot does not accept it, the slot shakes and the item stays selected.
  Tapping an exit with an item selected still leaves the scene.
- **Examine:** long-press a slot, or tap the magnifier button while an item is
  selected. The `examineItem` action opens it from content (e.g. right after
  picking up a note).
- **Text:** `showText` keys queue up; each tap closes one. While text is on
  screen, taps on the scene, the inventory, and the examine view are ignored.
- **Puzzles:** while a puzzle screen is open, the scene, exits, and the
  inventory do not react.
- **Placeholder text:** until final writing exists, string tables use
  `TODO_TEXT: <key>`, so the key on screen shows which one is used.

## Save format

Stored as JSON (see `lib/engine/save/`). Not authored by hand; documented here
for debugging.

```json
{
  "schemaVersion": 1,
  "lastEpisodeId": "test_room",
  "episodes": {
    "test_room": {
      "episodeId": "test_room",
      "sceneId": "desk",
      "inventory": ["small_key"],
      "everHadItems": ["small_key"],
      "flags": { "drawer_open": true, "clock_turns": 0 },
      "solvedPuzzles": ["drawer_lock"],
      "revealedHints": { "puzzle:drawer_lock": 1, "stage:find_key": 2 },
      "words": ["bucks_row"],
      "secretFound": false,
      "completed": false
    }
  },
  "distilled": ["whitechapel_1888"],
  "keeperNotes": { "whitechapel_1888": "whitechapel_1888.keeper.note" }
}
```

The save is written after every change to the game state (item, flag,
puzzle, scene), in one slot shared by all episodes. Player settings are
stored separately, so resetting progress keeps them. "Continue" resumes
`lastEpisodeId` unless that episode is `completed`; "New Game" drops only that
episode's entry. `distilled` and `keeperNotes` outlive that: a tale started
over keeps its seal, its keeper's note, and the shelves it opened.

A save that cannot be read (bad JSON, wrong types, newer `schemaVersion`) is
reported as corrupt instead of crashing: the menu offers a new game, and the
unreadable data stays in storage until the player starts over. After loading, the save is reconciled
against the current content: unknown scenes, items, and puzzles are dropped,
new flags get their defaults, and flags whose type changed are reset.

## Validation

Run the validator from the project root:

```bash
fvm dart run tool/validate_content.dart            # errors and warnings
fvm dart run tool/validate_content.dart --errors-only
```

It exits with 1 when there are errors. The same check runs in
`test/content/bundled_content_test.dart`, and in debug builds every episode is
validated when it loads (errors stop loading and are listed on screen;
warnings show in the debug panel).

| Check | Severity |
|---|---|
| Referenced scenes, items, puzzles exist (actions, exits, `onUseItem`, combinations, conditions) | error |
| Flags are declared in `game.json`; compared/assigned values match the flag type | error |
| Every text key exists in every language; all languages have the same keys | error |
| `rect` within 0–1 | error |
| `startScene` exists | error |
| JSON files parse and match the schema | error |
| Asset folders with files are listed in `pubspec.yaml` (CLI and test only) | error |
| Images exist | warning (placeholder drawn) |
| Sounds and music exist | warning (silent) |

## Changelog

| Date | Milestone | Change |
|---|---|---|
| 2026-09-25 | M0 | Folder layout set. Content is grouped per episode under `episodes/<episode_id>/`, following the multi-episode note in PRD §2. |
| 2026-09-25 | M1 | Schemas documented. Additions to PRD §5: `orientation` in `game.json`; `everHadItem` condition; `equals` optional (default `true`) for item/puzzle conditions; exit `id`/`rect`/`when`; item `examine`; `shake` fields. Unknown fields are rejected. |
| 2026-09-25 | M2 | `episodes.json` index; scene/puzzle files discovered per folder; `sceneTransitionMs` in `game.json`; per-episode image folders; sound id → `audio/sfx/<id>.<ext>`; 44 dp minimum tap area. |
| 2026-09-25 | M3 | Item `examine.layers`; examine images are square; interaction rules documented; placeholder text format `TODO_TEXT: <key>`. |
| 2026-09-25 | M4 | Puzzle `background`; config schemas for `codeLock`, `sequence`, `rotaryAlign`, `slotPlacement`. |
| 2026-09-25 | M5 | Save behavior documented (autosave, Continue/New Game, corrupt saves). No content schema changes. |
| 2026-09-25 | M6 | `music` in `game.json` and scenes; `hintStages` in `game.json`; `revealedHints` in the save (additive, old saves load); validator CLI. |
| 2026-09-25 | post-M6 | `episodes.json` becomes a catalog of jars (`titleKey`, `teaserKey`, `jarImage`, `comingSoon`, `debugOnly`); `labelKey` on `sequence` elements and `slotPlacement` slots; episode `whitechapel_1888`. |
| 2026-09-25 | post-M6 | Languages: Spanish (`es`), Japanese (`ja`), Simplified Chinese (`zh`), Russian (`ru`) added; all keys required in every language. |
| 2026-09-26 | post-M6 | `episodes.json`: `shelf`, `unlockAfter`, `series` (tiered shelves). |
| 2026-09-26 | post-M6 | `creatures` in scenes (geckos, rats, moths, bats, gulls, fulmars, grass). |
| 2026-09-26 | post-M6 | `echoes` in scenes (faceless figures of memory). |
| 2026-09-26 | post-M6 | `place` in `episodes.json` (the map of tales); `activeImage` on `sequence` elements. |
| 2026-09-26 | post-M6 | `dark` scenes and the `crank` puzzle type; episode `flannan_isles_1900` (shelf II) replaces `sealed_3`. |
| 2026-09-26 | post-M6 | Words (`words`, `[[id]]` markup, `wordNoted` condition), `deduction` and `reveal` puzzle types, `secret` in `game.json`. Save: `words`/`secretFound` per episode; `distilled` and `keeperNotes` in the save file (additive, old saves load). |
| 2026-09-30 | post-M6 | `lensHours` in `game.json` and `scenes` (by the hour) on scene lenses; puzzle type `rakingLight`. Pompeii rebuilt around them (fresco, strongbox, wax tablets); its label is a short seal. |
| 2026-09-29 | post-M6 | `form` on `deduction` (`sentences`, `table`, `telegram`, `correction`, `board`) with `columns`, and sentence `rect` and `initial`; puzzle types `clockHands` and `thread`. Whitechapel, Semarang and Flannan reworked so no puzzle type is shared between tales. |
| 2026-09-29 | post-M6 | `lens` in scenes (a lens between eras) and the `overlay` puzzle type; episode `pompeii_79` (shelf II). |
| 2026-09-26 | post-M6 | Korean (`ko`) added. Hints paced by the hint candle. Generated audio in `assets/audio/` (docs/audio.md); music id `stillroom_menu` plays on the menu and shelf. |
| 2026-09-30 | post-M6 | Puzzle types `beamSweep`, `swell` and `roster`; interface sounds `wave` and `great_sea`. Flannan rebuilt around them (the gallery, the west landing steps, the hooks); its label is a short seal. |
| 2026-09-30 | post-M6 | Puzzle types `keyring`, `cipher` and `sources`; deduction form `order`; interface sound `key_try`. Episode `bastille_1703` (shelf II). |
| 2026-09-30 | post-M6 | Puzzle types `pour`, `resonance` and `beat`; deduction form `rubbing`; interface sounds `pour`, `bell_strike`, `beat_*`. Episode `gyeongju_771` (shelf II). |
| 2026-09-30 | post-M6 | Puzzle types `unwatched` and `compose`; deduction form `docket`; interface sounds `type_sort`, `lamp_gutter`. Episode `whitechapel_1891` (shelf III, series whitechapel) replaces the sealed jar; a sealed teaser `sealed_guangxu_1908` stands on shelf III. |
| 2026-09-30 | post-M6 | Puzzle types `strand` and `scan`; deduction form `vermilion`; interface sounds `geiger`, `geiger_hot`, `sample`, `probe_tick`. Episode `chongling_1908` (shelf III) replaces `sealed_guangxu_1908`; the sealed teaser on shelf III is now `sealed_alamut_1256`. |
| 2026-09-30 | post-M6 | Puzzle types `quire` and `dip`; deduction form `colophon`; creature `eagle`; interface sounds `catchword`, `reed_touch`, `drip`, `drip_slow`. Episode `alamut_1256` (shelf III) replaces `sealed_alamut_1256`; the sealed teaser on shelf III is now `sealed_zimbabwe_1871`. |
| 2026-10-01 | post-M6 | Puzzle types `courses` and `identify`; deduction form `cartouche`; interface sounds `block_lay`, `slab_tilt`, `key_step`. Episode `great_zimbabwe_1871` (shelf III) replaces `sealed_zimbabwe_1871` and fills shelf III; a sealed teaser `sealed_dyatlov_1959` stands on shelf IV (`unlockAfter` 8). |
| 2026-10-01 | post-M6 | Puzzle types `snowpit` and `darkroom`; deduction form `routebook`; creature `raven`; interface sounds `snow_push`, `shovel_tap`, `column_break`, `enlarger`. Episode `dyatlov_1959` (shelf IV) replaces `sealed_dyatlov_1959`; the sealed teaser on shelf IV is now `sealed_honnoji_1582`. |
| 2026-10-02 | post-M6 | Puzzle types `strata` and `streets`; deduction form `marker`; interface sounds `strata_tag`, `find_lift`, `street_mark`; `PuzzleLabel` takes `maxLines`. Episode `honnoji_1582` (shelf IV) replaces `sealed_honnoji_1582`; the sealed teaser on shelf IV is now `sealed_roanoke_1590`. |
| 2026-10-07 | post-M6 | Puzzle types `rings` and `dividers`; deduction form `post`; creature `heron`; interface sounds `core_slide`, `ring_mark`, `divider_step`. Episode `roanoke_1590` (shelf IV) replaces `sealed_roanoke_1590`; the sealed teaser on shelf IV is now `sealed_franklin_1845`. |
| 2026-10-07 | post-M6 | Puzzle types `margins` and `sonar`; deduction form `admiralty`; creature `seal`; interface sounds `sheet_turn`, `lane_run`, `echo_mark`. Episode `franklin_1845` (shelf IV) replaces `sealed_franklin_1845`; the sealed teaser on shelf IV is now `sealed_indonesia_shelf4`, for the Indonesian tale still to be chosen. |
| 2026-10-07 | post-M6 | Puzzle types `mudra` and `casing`; deduction form `lontar`; creature `swifts`; interface sounds `niche_set`, `stone_lift`, `pair_found`; `Room.floorGrid` takes 0 columns. Episode `borobudur_1814` (shelf IV) replaces `sealed_indonesia_shelf4`; shelf IV is full; a sealed `sealed_keeper` (shelf V, `unlockAfter` 15) marks the keeper's tale. |
