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
tutorial); *Semarang, 1945* (shelf I, opens after Whitechapel; a step up: clues across three eras); *Flannan Isles, 1900* and *Pompeii, 79* (shelf II, open after two tales). Shelf III opens after four.

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

Later shelves can add more: E (a room that changes when not watched), F
(listening puzzles). D (light and dark) arrived with *Flannan Isles, 1900*
on shelf II: dark scenes searched by lantern light, plus the crank. C (a
lens between eras) arrived with *Pompeii, 79*, together with the stack of
tracing sheets (after *Her Trees*).

**Every tale plays differently (decided 2026-09-29).** Each tale brings one
or two mechanics of its own, tied to its story, and does not reuse another
tale's puzzles just to gate the way. Only the frame is shared: the words,
the jar's label, and the keeper's secret. The first three tales were built
before this rule and still share puzzle types:

| Tale | Its puzzles | Shared with another tale |
|---|---|---|
| *Whitechapel, 1888* | Candles in order, desk code lock, five frames, street compass rings, fog and hearth ash wiped | Code lock, sequence, rings, slots, wipe |
| *Semarang, 1945* | Doors into other years, clock and locker code locks, stained-glass rings, telegraph and timetable sequences, lockers, telegram rubbing | Code lock, sequence, rings, slots |
| *Flannan Isles, 1900* | Dark scenes by lantern light, clockwork crank, gate code lock, salt wiped from a plate | Code lock, wipe |
| *Pompeii, 79* | Lens between eras, stack of tracing sheets | None |

Whether to rework the older tales' shared puzzles is the developer's call
(_open_).

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
| `test_room` | Test room | Debug builds only | Feature test room |
