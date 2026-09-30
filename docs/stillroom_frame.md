# The Stillroom — Anthology Frame

Status: **direction approved** by the developer on 2026-09-25. The final
writing is the developer's; this file holds the premise the game is built
around.

## Premise

In old houses a *stillroom* was where medicines, perfumes, and preserves were
distilled. **The Stillroom** is such a room outside of time: it distils dark
tales from around the world (mysteries, legends, true crimes) and keeps each
one sealed in a glass jar, labelled with a place and a year.

- **The player** is a nameless visitor who becomes the room's new keeper.
- **The old keeper** is never seen whole; they are present only through notes,
  labels, and objects left behind.
- **Opening a jar** means entering its tale: one room, several views,
  8–12 puzzles (PRD §1).
- **Finishing a tale distils it**: the jar is sealed with wax on the shelf.

## Shelves and difficulty

The shelves are difficulty tiers (decided 2026-09-26):

- **One jar = one complete tale**, playable on its own.
- **Bottom shelf** is open from the start; each higher shelf opens after a
  number of tales are distilled (`unlockAfter` in `episodes.json`).
- **A topic can continue** in a later jar on a higher shelf, linked by a
  `series` ribbon (e.g. *Whitechapel, 1888* on shelf I, *Whitechapel, 1891*
  on shelf III). The player never has to finish one topic before trying
  another country.
- **The top shelf** will hold the old keeper's own tale.

**The full shelf (decided 2026-09-30): 16 tales on 5 shelves.** Every tale
is a real case at least about 70 years old, with a legend to set right.
The developer chose the regions; Indonesian tales wait for now (one slot
is kept on shelf IV). The game can ship before all 16 exist: jars are
data, so later tales arrive in updates.

| Shelf | Tales |
|---|---|
| I (2) | *Whitechapel, 1888* ✓, *Semarang, 1945* ✓ |
| II (4) | *Flannan Isles, 1900* ✓, *Pompeii, 79* ✓, *Bastille, 1703* ✓ (Western Europe), *Gyeongju, 771* ✓ (Korea) |
| III (4) | **Whitechapel, 1891** (series), **The death of the Guangxu Emperor, Beijing, 1908** (China), **Alamut, 1256** (Middle East), **Great Zimbabwe, 1871** (Africa) |
| IV (5) | **Dyatlov Pass, 1959** (Eastern Europe), **Honnō-ji, Kyoto, 1582** (Japan), **Roanoke, 1590** (the Americas), **The Franklin expedition, 1845** (the Arctic), *one Indonesian tale, to be chosen* |
| V (1) | The old keeper's own tale (arc OPEN) |

The legend each one sets right, in short (facts to be checked and sourced
in each tale's design doc before it is built):

| Tale | Legend (red herring) | What the record says |
|---|---|---|
| Iron Mask, 1703 | Louis XIV's twin, in an iron mask | A prisoner named Eustache Dauger; the mask was black velvet |
| Emille Bell, 771 | A child was cast into the bronze for its voice | No trace of it in the bell; the sound is the founders' craft |
| Whitechapel, 1891 | The one name the papers gave the killer | The other names in the police file |
| Guangxu, 1908 | He died of illness | Tests in 2008 found arsenic in his remains |
| Alamut, 1256 | Drugged killers in a garden of paradise (Marco Polo) | A fortress of scholars and a library the Mongols burned |
| Great Zimbabwe, 1871 | Built by outsiders for the Queen of Sheba (a colonial myth) | Built by the ancestors of the Shona |
| Dyatlov Pass, 1959 | Aliens, a yeti, a secret weapon | A slab avalanche (studies of 2019–2021) |
| Honnō-ji, 1582 | Nobunaga escaped the burning temple | His body was never found; the fire and Akechi's betrayal are what is known |
| Roanoke, 1590 | The colony vanished without a trace | "CROATOAN" carved on a post: they had gone to Croatoan |
| Franklin, 1845 | Inuit testimony dismissed as tales | That testimony led to *Erebus* (2014) and *Terror* (2016) |

`unlockAfter` for shelves III to V is set as the tales are built (a
guide: shelf III after 4 tales, IV after 8, V after 13).

How difficulty rises from shelf to shelf:

| Lever | Lower shelves | Higher shelves |
|---|---|---|
| Clues | One clue, near its puzzle | Spread across rooms or eras; must be combined |
| Chains | One puzzle, one reward | Rewards feed other puzzles |
| Red herrings | None | Some misleading objects and notes |
| Hints | Three levels down to the solution; candle waits 45 s / 90 s / 150 s | Vaguer; the solution only at the last level; candles burn longer (×1.5 shelf II, ×2 shelf III) |
| Mechanics | Basic puzzle types | Types combined, layered puzzles |
| Length | 8–10 beats | 10–12 beats, parallel branches |

Current placement: *Whitechapel, 1888* (shelf I, the easiest, doubling as the
tutorial); *Semarang, 1945* (shelf I, opens after Whitechapel; a step up: clues across three eras); *Flannan Isles, 1900*, *Pompeii, 79*, *Bastille, 1703* and *Gyeongju, 771* (shelf II, open after two tales; the shelf is full). Shelf III opens after four.

## Signature mechanics (decided 2026-09-26)

Chosen by the developer from the gameplay study (Rusty Lake, Gorogoa, *The
Case of the Golden Idol*, Strange Horticulture):

- **A. Distilling the tale.** Underlined words in what the player reads can be
  noted down. Every tale ends with the player writing its jar's label, a
  `deduction` puzzle: sentences with blanks, filled from the noted words.
  The truth is restored in the player's own hand.
- **B. Touch.** Some surfaces give way under the finger (`reveal`): wiping
  fog, dust, or ash, or rubbing a pencil over pressed-in writing.
- **G. The keeper's secret.** Each jar hides one optional secret, a note
  from the old keeper. Finding it marks the jar with a brass star, and the
  note stays on the shelf. The notes are drafts; their arc is the
  developer's (OPEN).

Later shelves can add more: E (a room that changes when not watched). F
(listening) arrived with Flannan v2: the swell, whose great sea is heard
coming (and seen, and felt). D (light and dark) arrived with *Flannan Isles, 1900*
on shelf II: dark scenes searched by lantern light, plus the crank. C (a
lens between eras) arrived with *Pompeii, 79*, together with the stack of
tracing sheets (after *Her Trees*).

**Every tale plays differently (decided 2026-09-29).** Each tale brings one
or two mechanics of its own, tied to its story, and does not reuse another
tale's puzzles just to gate the way. Only the frame is shared: the words,
the jar's label, and the keeper's secret. Even the label differs: each
tale writes it in its own form. And the label is short: a seal of a few
words, not a form to fill (decided 2026-09-30). The height of a tale is its
own hardest puzzle; higher shelves have more puzzles, chained together.

| Tale | Its own mechanics | Its label |
|---|---|---|
| *Whitechapel, 1888* | A clock-face lock set to the stopped hour; a red thread through five streets on a map; fog and ash wiped away; a lens and frame made into a magnifier | A ledger of one row, *from 31 August to 9 November 1888*: the first and the last name |
| *Semarang, 1945* | Doors into other years; code locks (the station clock, the locker room); the timetable and the telegraph in order; the stained-glass rings; the lockers | A telegram of two lines: the doors counted, the day, how many did not come home |
| *Flannan Isles, 1900* | Dark scenes by lantern light; the clockwork crank; the beam turning over the island, showing things only while it passes; down the landing steps between the waves (the swell); the roster of who went, how, and when | A seal: the legend's sentence, three words corrected |
| *Pompeii, 79* | The lens between eras, turned through the hours of the last day; pieces laid and turned into place (the shrine's painted panel, the child's drawing); marks read by raking light | A seal of three words, pinned to the diggers' cut |
| *Gyeongju, 771* | Bronze routed from three furnaces into the mould (`pour`); the log striker and the hollow under the bell, dug until the ring lasts (`resonance`); the rim struck all round to find where the ring swells deepest, the "cry" that is a beat (`beat`) | A seal of three words taken as an ink rubbing from the bronze (`rubbing`) |
| *Bastille, 1703* | The turnkey's ring: find the one key whose bit matches the keyhole, and turn it the right way (`keyring`); the king's Great Cipher read with Bazeries's worksheet, two numbers left unread (`cipher`); the prisoner's file sorted into what was written at the time and what was told after (`sources`) | A seal of three words on a blank royal order (`order`) |

The first three tales were reworked on 2026-09-29 to follow this rule:
Whitechapel lost its code lock, candle sequence, compass rings, and frame
slots; Semarang its pencil rubbing; Flannan its gate code and salt wiping.

## Echoes (decided 2026-09-26)

Rusty Lake shows its people; the Stillroom mostly shows their things. The
developer chose **echoes**: pale, faceless figures of memory that sometimes
stand in a tale for a few seconds and dissolve when approached. They carry
no names and no faces, so no real person is ever given invented features:

- *Whitechapel:* a constable with a lantern, beyond the fogged window.
- *Semarang:* a railway worker far down the endless corridor, and a clerk
  in the 1907 office.
- *Flannan:* a keeper in oilskins on the west landing and on the path west.
- *Pompeii:* a digger of 1863 with a basket; through the lens, townspeople
  looking up at the cloud, and a family at the door with cushions tied on
  their heads. The plaster casts are only seen from afar, under the
  diggers' canvas, never touched.
- *Bastille:* a turnkey with a lantern in the court and on the tower
  stair; in the cell, the prisoner, a dark band across his blank face
  where the mask was. He is never shown with a face.
- *Gyeongju:* a founder with a long ladle by the casting pit; a monk in
  the hall and at the pavilion. The legend's child and mother are never
  drawn, echoed, or voiced.

## Living things (decided 2026-09-26)

Where a tale has animals or plants, they are there. Where it is about
people, the people come first, as echoes. The creatures are chosen by place
and season:

- *Whitechapel* is about the people: echoes of a constable and a
  passer-by, and only a rat and a moth by the candles.
- *Semarang*: house geckos (cicak) on the walls, and bats in the cellar once
  it is lit.
- *Pompeii* is about the people. The ruin has weeds; through the lens,
  a donkey stands blindfolded at the mill and the fig tree has late fruit.
- *Flannan* is in December: gulls, a fulmar on the ledge, winter grass. No
  puffins or thrift, which are summer's.
- *Bastille* is about the people, in November: weeds between the cobbles
  of the court, and rats on the tower stair and in the cell.
- *Gyeongju* is a midwinter night: frosted grass in the temple yard, a rat
  in the founders' shed, falling snow.

## How it shows in the game

| Where | What |
|---|---|
| Main menu | Title, tagline: "Every jar keeps a tale that must not be forgotten." Behind it, the living Stillroom (`LobbyScene`): glowing jars (one stirs now and then), a clock whose pendulum swings but whose hands never move, drying herbs, a candle with a moth and dust in its light; music `stillroom_menu` |
| Map of tales | "New Game" opens an old parchment chart of the world, with a brass pin where each tale happened (a wax-red pin once distilled, grey and locked until its shelf opens, the keeper's star when its secret is found). Pinch to zoom; pins keep their size and labels dodge each other |
| Episode picker | Tiered shelves (`episodes.json`): playable jars, locked jars on shelves not reached yet, sealed jars for tales still to come, wax seals on finished tales, series ribbons |
| Ending screen | "The tale is distilled" |

## Long arc (_open_)

When every jar is distilled, the old keeper's own tale is revealed: why the
room exists, and who has been collecting these tales. This can become the
final episode. Details are open.

## Tone guardrails

- Atmospheric and psychological horror; no gore, violence off screen.
- For tales about **real people**, centre the people who suffered, not the
  perpetrator. Use their real names with care, state only historical facts,
  and do not invent intimate details of their lives or deaths.
- Every tale ends with something restored (a name, a memory, a truth), not
  only with escape.

## Episodes

| Id | Label | Status | Design |
|---|---|---|---|
| `whitechapel_1888` | Whitechapel, 1888 | Structure built, placeholders | [episodes/whitechapel_1888.md](episodes/whitechapel_1888.md) |
| `lawang_sewu_1945` | Semarang, 1945 | Built, draft text, code-drawn art (shelf I, opens after 1 tale) | [episodes/lawang_sewu_1945.md](episodes/lawang_sewu_1945.md) |
| `flannan_isles_1900` | Flannan Isles, 1900 | Built, draft text, code-drawn art (shelf II, opens after 2 tales). Dark scenes, crank, legend as red herrings | [episodes/flannan_isles_1900.md](episodes/flannan_isles_1900.md) |
| `pompeii_79` | Pompeii, 79 | Built, draft text, code-drawn art (shelf II, opens after 2 tales). Lens between eras, tracing sheets, legend as red herrings | [episodes/pompeii_79.md](episodes/pompeii_79.md) |
| `sealed_whitechapel_1891` | Sealed jar (shelf III, series whitechapel) | Idea: the six other names in the police file | — |
| `gyeongju_771` | Gyeongju, 771 | Built, draft text, code-drawn art (shelf II, opens after 2 tales). The pour, the hollow, the beat; the child legend, Seoul and 1925 as red herrings | [episodes/gyeongju_771.md](episodes/gyeongju_771.md) |
| `bastille_1703` | Bastille, 1703 | Built, draft text, code-drawn art (shelf II, opens after 2 tales). Key ring, Great Cipher, the file of sources; Voltaire, Dumas and Bazeries as red herrings | [episodes/bastille_1703.md](episodes/bastille_1703.md) |
| *(planned)* | The other nine new tales | See *The full shelf* above | — |
| `test_room` | Test room | Debug builds only | Feature test room |
