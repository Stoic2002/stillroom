# Stillroom: notes for the next agent

Read this before doing anything in this repo. It says how this developer
works, what the game is, where things stand, and what comes next.

## How to work with this developer

- **Talk to the developer in Indonesian.** Code, comments, commit
  messages, and docs are in English.
- **Flutter runs through FVM only:** `fvm flutter …` and `fvm dart …`
  (Flutter 3.41.7). The project has its own `.fvmrc`.
- **Never run `flutter build` or `flutter run` yourself.** The developer
  builds and tests on their own Samsung (SM A556E). When a change needs
  trying, give them this command, and say when a full restart or "New
  Game" is needed:
  `fvm flutter run --release -d RRCY201XN5H`
  To check a tale without finishing the shelves below it, add
  `--dart-define=STILLROOM_UNLOCK_ALL=true`: every jar opens
  (`lib/debug/tester_flags.dart`). A build without it plays normally.
- **Check your work with:**
  - `fvm dart format lib test`, then `fvm dart fix --apply` (directive
    order);
  - `fvm flutter analyze`, which must report no issues;
  - `fvm flutter test`, which must pass;
  - `fvm dart run tool/validate_content.dart --errors-only`, which must
    report 0 errors (image warnings are normal: the art is drawn in code).
- **One milestone at a time,** then report in Indonesian and wait. Don't
  decide OPEN items (the story arc, final art, package name, release).
  Ask, and give a recommendation; the developer often answers "terserah
  rekomendasi".
- **Small UX details matter.** When fixing one case, audit similar ones.
  Render new art to PNG in a throwaway widget test and look at it before
  reporting.
- **Commit** on `main` after each finished piece, with a descriptive
  message. Keep the `ios/` folder, even though Android is the only target
  for now.
- **Don't** download files, buy anything, or use paid generators
  (Higgsfield has 0 credits) without asking.

## The game

*Stillroom*: a mobile escape-room game in landscape, built with Flutter,
Flame, and Riverpod. Everything is data-driven JSON. An old keeper's room
holds jars on shelves, and every jar is one tale from real history. The
player restores the truth of the tale and seals the jar.

- **Frame, map of tales, shelves, echoes, living things, and the rules for
  each tale's mechanics:** `docs/stillroom_frame.md`
- **Content schema** (scenes, lens, puzzles, words, label forms, hints)
  and its changelog: `docs/content_format.md`
- **One design doc per tale,** with facts and sources: `docs/episodes/*.md`
- Audio is synthesized in code: `tool/audio/generate_audio.dart` and
  `docs/audio.md`.
- Art is drawn in code: `lib/core/art/*_art.dart`, registered in
  `vector_art.dart`.
- **Seven languages,** every key required in each: `en`, `id`, `es`, `ja`,
  `zh`, `ru`, `ko`.
  - Content text lives in `assets/content/strings/*.json`, UI text in
    `lib/l10n/app_*.arb`, followed by `fvm flutter gen-l10n`.
  - The CJK fonts are subsets: `test/content/font_coverage_test.dart` fails
    on a rare glyph, so reword it (e.g. 蹚 and 祇 were replaced).

### The tales (10 playable)

| Shelf | Tale | Its own mechanics | Its label now |
|---|---|---|---|
| I | *Whitechapel, 1888* | Clock-face lock (`clockHands`), red thread on a map (`thread`), fog and ash wiped (`reveal`), a magnifier | `table` **seal**: one row, the first and the last name |
| I | *Semarang, 1945* (Lawang Sewu) | Doors into other years, `codeLock`, `sequence` (timetable, telegraph), `rotaryAlign` (stained glass), `slotPlacement` (lockers) | `telegram` **seal**: two lines, 3 blanks |
| II | *Flannan Isles, 1900* | Dark scenes by lantern light, `crank`, the beam over the island (`beamSweep`), the landing steps between waves (`swell`), who went how and when (`roster`) | `correction` **seal**: one sentence, 3 words wrong |
| II | *Pompeii, 79* | Lens between eras **by the hour** (`lensHours`), `overlay` (fresco jigsaw, tracing sheets), `rakingLight` (wax tablets) | `board` **seal of 3 words** (the new standard) |
| III | *Whitechapel, 1891* (series) | The file that grows while you look away (`unwatched`), her name set in mirrored type (`compose`) | `docket` **seal**: the file's cover, 3 words |
| III | *Beijing, 1908* (the Guangxu Emperor, set at Chongling during the 2003–08 tests) | His hair measured segment by segment on scarce reactor time (`strand`), a probe over his robe, outer and inner (`scan`) | `vermilion` **seal**: imperial yellow, 3 words, the hand *not known* |
| II | *Gyeongju, 771* (the Emille Bell) | Bronze routed into the mould (`pour`), the striker and the hollow under the bell (`resonance`), the rim struck round to find the deepest swell, the "cry" (`beat`) | `rubbing` **seal**: an ink rubbing, 3 words |
| III | *Alamut, 1256* (the library of the fortress) | Juvayni's loose sheets nested by their catchwords (`quire`), tanks in the rock named by how the reed drips (`dip`) | `colophon` **seal**: a book's closing lines, 3 words |
| III | *Great Zimbabwe, 1871* (the city of stone) | The breach laid back course by course, no joint over a joint, then the chevron band (`courses`); Mauch's splinter named by walking a key to woods (`identify`) | `cartouche` **seal**: an old map's title panel, 3 words |
| II | *Bastille, 1703* (the Iron Mask) | The turnkey's keys (`keyring`: match the bit, turn it over), the Great Cipher (`cipher`, 330 309 left unread), the prisoner's file (`sources`: written at the time vs. told after) | `order` **seal**: a royal order, 3 words |

Shelf III opens after 4 tales are distilled and is full: *Whitechapel,
1891*, *Beijing, 1908*, *Alamut, 1256*, *Great Zimbabwe, 1871*. Shelf IV
(`unlockAfter` 8) holds only a sealed teaser jar (`sealed_dyatlov_1959`)
for its tales still to come. The top shelf is meant for the old keeper's
own tale; its arc is OPEN.

**The plan: 16 tales on 5 shelves** (decided 2026-09-30), all real cases
with a legend to set right. The lineup, by shelf and region, is in
`docs/stillroom_frame.md` (*The full shelf*). Indonesian tales wait for now.

## Decisions to respect

1. **Every tale plays differently.** Each puzzle type belongs to exactly
   one tale; don't reuse one tale's mechanic in another. A new tale gets
   1–3 new mechanics tied to its story. Update the table in
   `docs/stillroom_frame.md`.
2. **The jar's label is a short seal:** one sentence, 2–3 blanks, not a
   form to fill (decided 2026-09-30, after the developer found the long
   fill-ins boring). The height of a tale is its own hardest puzzle.
3. **Higher shelves are harder and longer:** more puzzles, chained
   together. Shelf II needs roughly 8–10 chained beats; Pompeii v2 is the
   model.
4. **Take ideas from wide references:** *Her Trees* (overlap, silhouette,
   jigsaw, rotation, hidden letters), *Gorogoa* (one place at many times,
   picture through picture), *Rusty Lake* (puzzles that carry the story),
   *The Room* (tactile objects).
5. **Tone:**
   - Atmospheric, with no gore.
   - Honour real people: no invented names for real victims, only
     historical facts. Invented households must be stated as invented.
   - Legends appear as red herrings, never as truth.
   - Echoes are faceless.
   - Pompeii's plaster casts are shown only from afar and cannot be
     tapped.

## Next steps (in this order)

1. **Build the remaining tales of the plan, one after another.** The
   developer does not play-test tale by tale: once all 16 exist they test
   the whole game and do one big round of fixes and polish (decided
   2026-10-01; Play Store target mid-October 2026, end of October at the
   latest). Keep each design doc's *Things to watch* as the checklist for
   that review.
2. **Next:** shelf IV, in the plan's order: *Dyatlov Pass, 1959*, then
   *Honnō-ji, 1582*, *Roanoke, 1590*, *The Franklin expedition, 1845*, and
   one Indonesian tale (to be chosen with the developer). For each: a design doc first (facts with
   sources, 2–3 mechanics of its own, the chain, the seal), approved by
   the developer before building.
3. Later, and to be asked first:
   - the Indonesian tale for shelf IV;
   - the keeper's arc (OPEN);
   - native-speaker translation review;
   - final art. The package name (`com.example.stillroom`) and release are
     on hold.

## Gotchas learned the hard way

- **Large string tables:** `AssetBundle.loadString` hands files over
  50 KB to an isolate, which never finishes in widget tests.
  `FlutterAssetSource` decodes inline; keep it that way.
- **Map pins** take taps only on their head and tag
  (`HitTestBehavior.deferToChild`); otherwise one pin's box swallows a
  neighbour's label.
- **Walkthrough tests** (`test/state/*_walkthrough_test.dart`) play every
  tale through its real content. Update them with every content change;
  they catch unwinnable tales.
- **`test/content/art_coverage_test.dart`** fails if any tale falls back to
  a placeholder box.
- **In widget tests of overlay puzzles**, grab a sheet by a corner that no
  other sheet covers: the last-touched sheet lies on top.
- **Pan gestures:** a drag's first movement is swallowed by the slop, so
  views react in `onPanDown` and `onPanStart` too (see `thread_view.dart`).
- **A cloud session has no FVM:** install Flutter 3.41.7 from the release
  archive (and `ffmpeg` for `tool/audio/generate_audio.dart`) to run the
  checks; the developer still does every build.
- **Hint keys:** a hint stage and a puzzle both take their hints from
  `hint.<episode>.<id>.<n>`, so a stage must not share a puzzle's id
  (Alamut's stages are `stores` and `library`, its puzzles `dip` and
  `quire`).
- **Python heredocs that write strings:** write `\"` for a quote inside a
  JSON value, never `\\"`.

Project memory for Claude also lives in
`~/.claude/projects/-Users-arulkarim-Project-stillroom/memory/`.
