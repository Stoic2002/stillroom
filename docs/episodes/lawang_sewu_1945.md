# Episode design — Lawang Sewu, Semarang, 1945

Status: **built** (2026-09-26): content, draft text in six languages,
code-drawn art, and a start-to-finish walkthrough test
(`test/state/lawang_sewu_walkthrough_test.dart`). Shelf I, opens after one
tale is distilled (`unlockAfter: 1`). Decisions by the developer: *the building's
memory across eras*; jar label "Semarang, 1945"; the five roles as listed;
**name the Battle of Five Days and Tugu Muda explicitly**. Episode id:
`lawang_sewu_1945`, shelf I.

## Premise

Lawang Sewu, "a thousand doors": the headquarters of the Dutch East Indies
railway company in Semarang. Inside the jar it is always night, and the
building remembers everything at once. The station clock on the landing has
stopped; the great stained-glass window is dark; behind some of the doors
along the corridors, other years are still going on: a busy railway office in
**1907**, a flooded cellar under occupation in **1942**, and a window onto
the streets of **October 1945**.

The keeper does not fight anyone or solve a crime. They **give back what the
workers left behind**: a conductor's ticket punch, a telegraphist's key, a
signalman's lantern, a stationmaster's whistle, a young driver's cap. When
every locker is full again, light returns to the glass, and the building can
finally close its doors.

## Tone and guardrails

- Horror through atmosphere: endless corridors of identical doors, water in
  the dark, a clock that won't move, voices on a telegraph line. **No gore;
  no violence shown.**
- **Honour, don't exploit.** The people are present through what they left
  and the roles they held (driver, conductor, telegraphist, signalman,
  stationmaster). **No invented names** of real people.
- **Occupation (1942–45):** shown through absence (an empty cell, tally
  marks, a guard's chair) and never through torture. Soldiers are never
  depicted as monsters; no ethnic caricature. The game also ships in
  Japanese; the text must read as mourning, not blame.
- **The cellar prison** is recorded (building B's basement under the
  occupation), but it is shown only through absence: water, a chair, tally
  marks. No figures, no suffering depicted.
- **October 1945** is remembered, not re-enacted: a window, distant sounds,
  a cap left on the sill, smoke over the square.

## Historical facts used (verified 2026-09-26)

| Fact | Used in | Source |
|---|---|---|
| Head office of the Nederlandsch-Indische Spoorweg Maatschappij (NIS), the first railway company in the Indies; built from 1904, building A finished 1907, complex finished 1919 | 1907 office, teaser | [Wikipedia EN](https://en.wikipedia.org/wiki/Lawang_Sewu), [Wikipedia ID](https://id.wikipedia.org/wiki/Lawang_Sewu) |
| Designed by Cosman Citroen of the firm J.F. Klinkhamer & B.J. Ouëndag | Architect's note in the ledger | Wikipedia EN/ID |
| "A thousand doors": in fact **928** doors, plus hundreds of tall windows | Locker-room door lock | [Wikipedia ID](https://id.wikipedia.org/wiki/Lawang_Sewu) |
| Stained glass by **J.L. Schouten** (Delft), four panels: Java's plants and animals; the cities of Semarang and Batavia; the two as ports; a **winged wheel** with **Fortuna** and **Venus**, whose fire and water meet as steam | Stained-glass puzzle | [Tempo](https://www.tempo.co/hiburan/arti-simbol-dewi-fortuna-dan-dewi-venus-di-kaca-patri-lawang-sewu-613610), [GNFI](https://www.goodnewsfromindonesia.id/2019/09/25/makna-lukisan-kaca-patri-di-lawang-sewu) |
| First railway line in Indonesia, opened **10 August 1867**: **Samarang – Alastua – Brumbung – Tanggung** (26 km), built by NIS | Timetable puzzle | [Kompas](https://www.kompas.com/stori/read/2022/07/28/190000979/peresmian-jalur-kereta-api-pertama-di-indonesia), [Espos](https://regional.espos.id/jalur-kereta-api-pertama-indonesia-ada-di-semarang-melewati-4-stasiun-1390298) |
| Under the Japanese occupation (1942–45) the basement of building B was used as a prison, with executions | 1942 cellar (shown through absence only) | Wikipedia EN/ID |
| **Battle of Five Days in Semarang, 15–19 October 1945** (some date it from the 14th); triggered by the death of **Dr. Kariadi** on 14 October while checking a water reservoir; Indonesian fighters against the Japanese Kido Butai; British/Gurkha troops arrived on the 19th | 1945 window, clock code, ending | [Wikipedia ID](https://id.wikipedia.org/wiki/Pertempuran_Lima_Hari) |
| Young railway workers (**AMKA**, Angkatan Muda Kereta Api) fought from **Wilhelminaplein**, across from Lawang Sewu; the fallen were later reburied at Giri Tunggal heroes' cemetery | 1945 window, lockers | [Sindonews](https://daerah.sindonews.com/read/730133/707/gedung-lawang-sewu-semarang-saksi-bisu-pertempuran-5-hari-amka-melawan-tentara-jepang-1648782257?showpage=all), [detik](https://news.detik.com/berita-jawa-tengah/d-4257395/lawang-sewu-saksi-bisu-pertempuran-5-hari-di-semarang) |
| **Five employees** of the building were killed in October 1945 | The five lockers | Wikipedia EN/ID. _Double-check with a museum source before release_ |
| **Tugu Muda**, on the former Wilhelminaplein, commemorates the battle; inaugurated **1953** by Soekarno | Ending | Wikipedia ID |

Casualty figures are disputed (Japanese and Indonesian counts differ widely),
so the text gives no numbers. The deaths on both sides, including Japanese
civilians, are mourned, not tallied.

## Map

```
                    landing (start)
         [stopped station clock] [dark stained glass]
   corridor_west ◀────────┴────────▶ corridor_east
   ├─ door 1907 → office_1907        ├─ door 1945 → window_1945 (locked)
   └─ door 1942 → cellar_1942 (dark) └─ locker room → lockers
```

| Scene | What's there |
|---|---|
| `landing` | Grand staircase, stopped station clock, dark stained-glass window (3 rings of glass), corridors both ways |
| `corridor_west` / `corridor_east` | Endless identical doors; three have a year painted on them, one leads to the lockers |
| `office_1907` | Clerk's desk with a ledger, timetable board, telegraph with a Morse chart and a telegram form |
| `cellar_1942` | Knee-deep water under low arches; pitch dark until a lantern is lit; tally marks on the wall |
| `window_1945` | Night street through a tall window, smoke over the square, a cap on the sill |
| `lockers` | Five iron lockers, each with an enamel plate: driver, conductor, telegraphist, signalman, stationmaster |

## Puzzle flow (v2: the facts are the puzzles)

| # | Beat | Type | Clue (fact) | Reward |
|---|---|---|---|---|
| 1 | Ledger | examine, 4 pages | — | Map of the 1867 line; Morse chart; architect's note ("928 doors"); Schouten's note on the glass |
| 2 | Timetable board | `sequence`, 4 stations | Ledger map: the first line, **Samarang → Alastua → Brumbung → Tanggung** | **Ticket punch** (conductor) |
| 3 | Telegraph | `sequence` of dot/dash: **NIS** = `−· ·· ···` | Telegram form: "send the company's initials"; Morse chart | **Telegraph key** (telegraphist); the 1945 door unlocks |
| 4 | Window, 1945 | examine + take | A calendar page: **15 October 1945**; a young worker's cap on the sill | **Driver's cap** |
| 5 | Station clock | `codeLock`, day and month **1510** | The calendar in 1945: the day the battle began | Clock case opens: **lantern** (unlit) |
| 6 | Lantern | combination: lantern + lamp oil (office shelf) | — | **Lit lantern** |
| 7 | Cellar, 1942 | use the lit lantern on the dark | — | Tally marks shown; **stationmaster's whistle** in the water |
| 8 | Locker-room door | `codeLock`, 3 digits **928** | Architect's note: the thousand doors are really 928 | Locker room opens |
| 9 | Lockers | `slotPlacement`, 5 lockers by role | Each item's description names its owner's role | Belongings returned |
| 10 | Stained glass | `rotaryAlign`, 3 rings: plants and animals (outer), the port cities (middle), the winged wheel (inner) | Schouten's note: "where Fortuna's fire meets Venus's water, the wheel turns" (all three marks meet at the top) | Light returns → ending |

Ten beats with six puzzle screens: a clear step up from Whitechapel (clues
spread across three eras, one code needing two rooms, two unlock chains in
parallel).

**Ending** (explicit, per the developer): as the glass lights, the keeper
hears the building's memory of 15–19 October 1945, the Battle of Five Days;
the young railway workers across the square at Wilhelminaplein; and, "across
the road, one day, Tugu Muda will stand." Then the last door closes.

## Hint stages (first match wins)

`light_the_glass` (belongings returned) → `return_belongings` (all five
items held) → `light_the_cellar` (lantern found, cellar still dark) →
`open_the_lockers` (locker door still locked) → `set_the_clock` (calendar seen) →
`send_the_telegram` → `read_the_ledger` (fallback).

## Audio (ids)

Music: `lawang_sewu_night`. Effects: `clock_tick`, `door_creak`,
`telegraph_click`, `water_drip`, `lantern_light`, `locker_close`,
`distant_bells`, `glass_chime`.

## Art

Code-drawn stand-in art as for Whitechapel (`lib/core/art/`), then real art
via the style guide. Colour notes: the building's white walls turned grey-
green in the dark; stained glass in deep amber, red and blue that only glows
once solved; the 1907 office in warm sepia, the 1942 cellar in cold fog,
1945 lit by distant orange.

## Decisions (2026-09-26)

1. Roles: driver, conductor, telegraphist, signalman, stationmaster: **kept**.
2. The Battle of Five Days and Tugu Muda are **named explicitly**.
3. Facts **verified online** (sources above) and used as puzzle material.

## Words, touch and the secret (added 2026-09-26)

- **Words:**
  - the four stations of 1867 and the year, from the ledger's first page;
  - 928, from the third page;
  - Delft and Batavia, from the last page;
  - 15 October 1945, from the calendar;
  - "five", from the lockers.
- **The telegram pad** (`telegram_pad`, reveal/rub): the top sheet is gone.
  Shading the one below brings back the pressed-in form, which asks for the
  company's initials.
- **The jar's label** (`jar_label`, deduction): opens as soon as the glass
  lights. Three sentences and seven blanks, with Alastua, Brumbung and
  Batavia as decoys. Only one wrong blank is counted for the player
  (`nearMiss: 1`), because this is a harder jar.
  1. "The first railway of the Indies ran from {Samarang} to {Tanggung}, and
     opened in {1867}."
  2. "They called it a thousand doors, but there are {928}; its glass was made
     in {Delft}."
  3. "On {15 October 1945} the fighting began across the square, and {five} of
     its workers did not come home."
- **Secret:** after the player counts the doors (the locker-room lock), a
  929th door appears far down the west corridor, with the keeper's note. The
  note text is a draft.
