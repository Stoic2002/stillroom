# Episode design — Whitechapel, 1888

Status: **structure built** (rooms, puzzles, items, hints) with placeholder art,
silent audio, and **draft writing** in English and Indonesian (2026-09-25),
awaiting the developer's revision. Direction approved on 2026-09-25:
the tale centres the five women, not the killer. Final text is the
developer's. The episode is played start to finish in
`test/state/whitechapel_walkthrough_test.dart`.

## Premise

Autumn 1888. A rented room in a Whitechapel lodging house, sealed in its jar
since the fog came. The newspapers remember a name the killer gave himself;
almost no one remembers the names of the women. **The room will not let the
keeper leave until those five names are back where they belong.**

The killer never appears: only fog, a letter, the newspapers' fascination,
and the gaps he left. Nothing graphic is shown or described.

The five women, in the order the historical record gives:

| Name | Date | Place |
|---|---|---|
| Mary Ann Nichols | 31 August 1888 | Buck's Row |
| Annie Chapman | 8 September 1888 | Hanbury Street |
| Elizabeth Stride | 30 September 1888 (~1 a.m.) | Berner Street |
| Catherine Eddowes | 30 September 1888 (~1:45 a.m.) | Mitre Square |
| Mary Jane Kelly | 9 November 1888 | Miller's Court |

Only these facts are used in content (names, dates, places). Nothing else
about their lives or deaths is invented.

## Map

```
             room_north (start)
        window ▲      ▲ desk
   room_west ◀─┼──────┼─▶ room_east
   (5 frames)  │      │   (mantel: clock, candles)
               └ room_south ┘
                 (door, coat)
```

| Scene | What's there |
|---|---|
| `room_north` | Window (→ `window`), writing desk (→ `desk`), bed |
| `room_east` | Fireplace, mantel clock (stopped at 3:40), five cold candles |
| `room_south` | The locked door, a coat on a rack (lens in the pocket) |
| `room_west` | Five empty portrait frames, a small brass frame on the floor |
| `desk` | Newspaper clippings, a faded paper, the locked drawer |
| `window` | Fog over the street, a street map pinned to the frame |

## Puzzle flow (reworked 2026-09-29: only Whitechapel's own mechanics)

| # | Beat | Type | Clue | Reward |
|---|---|---|---|---|
| 1 | `desk_drawer` | `clockHands`, set to **3:40** (starts at 9:00) | Mantel clock stopped at 3:40 | matches, letter, **Nichols** |
| 2 | Candles | use the matches on them (no puzzle) | — | **Chapman** |
| 3 | `street_thread` | `thread` through five pinned streets, oldest first | The clippings are pinned oldest first; the letter holds a map with red wool | **Stride**, **Eddowes** (the same night) |
| 4 | Lens + brass frame | combination → magnifier | Lens in the coat, frame on the floor | magnifier |
| 5 | Faded paper | use the magnifier on it | — | **Kelly** |
| 6 | `jar_label` at the five frames | `deduction`, form `table`: a name and a place under each date | Each card names her and where she was found | Names restored, the door opens |
| 7 | Door | leave (`endEpisode`) | — | The tale is distilled |

Hint stages (first match wins): `leave` → `write_label` (all five cards
found) → `light_candles` → `open_drawer` → `find_names`.

## Text

All keys are in `assets/content/strings/{en,id}.json`. Facts (the title,
street names, frame dates, and the five names) are final. **Everything else
is a draft** for the developer to revise: room descriptions, item
descriptions, the jar teaser, and every hint (vague → explicit → solution).

Voice of the drafts: quiet, melancholic, and slightly surreal. The room is
alive; the killer is only an absence. About the five women, the drafts state
only where and when they were found, nothing more.

When rewriting, three texts must keep their clue:

| Key | Must convey |
|---|---|
| `whitechapel_1888.clock.look` | The clock stopped at 3:40 (the drawer's clock) |
| `whitechapel_1888.clippings.look` | The five streets, oldest first (the thread) |
| `item.whitechapel_1888.name_card_*.desc` | Her name and where she was found, marked (the label) |

Solution hints must stay correct if a puzzle changes: `desk_drawer.3`,
`street_thread.3`, and `jar_label.3`.

## Assets to produce

Placeholders are drawn for anything missing; see `docs/art_style_guide.md`.

**Scene backgrounds and puzzle boards (1920×1080, opaque)**

- `assets/images/scenes/whitechapel_1888/candles_close.png`
- `assets/images/scenes/whitechapel_1888/desk.png`
- `assets/images/scenes/whitechapel_1888/drawer_lock_close.png`
- `assets/images/scenes/whitechapel_1888/frames_close.png`
- `assets/images/scenes/whitechapel_1888/room_east.png`
- `assets/images/scenes/whitechapel_1888/room_north.png`
- `assets/images/scenes/whitechapel_1888/room_south.png`
- `assets/images/scenes/whitechapel_1888/room_west.png`
- `assets/images/scenes/whitechapel_1888/street_map_close.png`
- `assets/images/scenes/whitechapel_1888/window.png`

**Object layers (transparent PNG, sized to their rect)**

- `assets/images/objects/whitechapel_1888/bed_sprite.png`
- `assets/images/objects/whitechapel_1888/brass_frame.png`
- `assets/images/objects/whitechapel_1888/candle.png`
- `assets/images/objects/whitechapel_1888/candles_cold_sprite.png`
- `assets/images/objects/whitechapel_1888/candles_lit_sprite.png`
- `assets/images/objects/whitechapel_1888/clippings_sprite.png`
- `assets/images/objects/whitechapel_1888/clock_sprite.png`
- `assets/images/objects/whitechapel_1888/coat_rack_sprite.png`
- `assets/images/objects/whitechapel_1888/compass_inner.png`
- `assets/images/objects/whitechapel_1888/compass_middle.png`
- `assets/images/objects/whitechapel_1888/compass_outer.png`
- `assets/images/objects/whitechapel_1888/desk_sprite.png`
- `assets/images/objects/whitechapel_1888/door_closed_sprite.png`
- `assets/images/objects/whitechapel_1888/door_open_sprite.png`
- `assets/images/objects/whitechapel_1888/drawer_closed_sprite.png`
- `assets/images/objects/whitechapel_1888/drawer_open_sprite.png`
- `assets/images/objects/whitechapel_1888/faded_paper_sprite.png`
- `assets/images/objects/whitechapel_1888/fireplace_sprite.png`
- `assets/images/objects/whitechapel_1888/frames_empty_sprite.png`
- `assets/images/objects/whitechapel_1888/frames_restored_sprite.png`
- `assets/images/objects/whitechapel_1888/gaslamp_sprite.png`
- `assets/images/objects/whitechapel_1888/letter_street_names.png`
- `assets/images/objects/whitechapel_1888/mantel_sprite.png`
- `assets/images/objects/whitechapel_1888/street_map_sprite.png`
- `assets/images/objects/whitechapel_1888/window_sprite.png`

**Item icons and examine views (transparent; examine views square)**

- `assets/images/items/whitechapel_1888/brass_frame.png`
- `assets/images/items/whitechapel_1888/lens.png`
- `assets/images/items/whitechapel_1888/letter.png`
- `assets/images/items/whitechapel_1888/letter_examine.png`
- `assets/images/items/whitechapel_1888/magnifier.png`
- `assets/images/items/whitechapel_1888/matches.png`
- `assets/images/items/whitechapel_1888/name_card.png`

**UI**

- `assets/images/ui/jar_whitechapel_1888.png`

**Sound effects** (`assets/audio/sfx/<id>.ogg`)

- `bell_toll`
- `clock_tick`
- `door_creak`
- `door_rattle`
- `drawer_open`
- `match_strike`
- `paper`

**Music** (`assets/audio/music/<id>.ogg`, looped)

- `whitechapel_fog`

## Words, touch and the secret (added 2026-09-26)

- **Words:**
  - five names, noted from the name cards and the restored frames;
  - five streets, from the clippings and the fog;
  - three dates, from the cards and the frames.
- **The fog on the window** (`window_fog`, reveal/wipe): wiped from the
  inside, it shows *Berner St. — Mitre Sq.*, the two women found within one
  hour of each other.
- **The jar's label** (`jar_label`, deduction, form `table`): the five
  frames on the west wall. Each row is a date; the player writes her name
  and the place she was found. Ten blanks; the three dates in the bank are
  decoys. Writing it restores the names and opens the door.
- **Secret:** look into the hearth a second time and brush the ash aside
  (`hearth_ash`): a scrap in the keeper's hand. The note text is a draft.
