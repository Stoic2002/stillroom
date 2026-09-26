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

The shelves of jars shown by "New Game" (docs/stillroom_frame.md). Shelves
are difficulty tiers: shelf 1 (bottom) is open from the start; a jar opens
once the player has distilled `unlockAfter` tales (finished, playable,
non-debug episodes).

```json
{
  "episodes": [
    { "id": "whitechapel_1888", "titleKey": "episode.whitechapel_1888.title",
      "teaserKey": "episode.whitechapel_1888.teaser",
      "jarImage": "images/ui/jar_whitechapel_1888.png",
      "shelf": 1, "series": "whitechapel" },
    { "id": "sealed_3", "titleKey": "episode.sealed.title", "comingSoon": true,
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
| 2026-09-26 | post-M6 | Words (`words`, `[[id]]` markup, `wordNoted` condition), `deduction` and `reveal` puzzle types, `secret` in `game.json`. Save: `words`/`secretFound` per episode; `distilled` and `keeperNotes` in the save file (additive, old saves load). |
| 2026-09-26 | post-M6 | Korean (`ko`) added. Hints paced by the hint candle. Generated audio in `assets/audio/` (docs/audio.md); music id `stillroom_menu` plays on the menu and shelf. |
