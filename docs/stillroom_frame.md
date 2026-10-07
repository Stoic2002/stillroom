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
| III (4) | *Whitechapel, 1891* ✓ (series), *The death of the Guangxu Emperor, Beijing, 1908* ✓ (China), *Alamut, 1256* ✓ (Middle East), *Great Zimbabwe, 1871* ✓ (Africa) |
| IV (5) | *Dyatlov Pass, 1959* ✓ (Eastern Europe), *Honnō-ji, 1582* ✓ (Japan), *Roanoke, 1590* ✓ (the Americas), **The Franklin expedition, 1845** (the Arctic), *one Indonesian tale, to be chosen* |
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
tutorial); *Semarang, 1945* (shelf I, opens after Whitechapel; a step up: clues across three eras); *Flannan Isles, 1900*, *Pompeii, 79*, *Bastille, 1703* and *Gyeongju, 771* (shelf II, open after two tales; the shelf is full). Shelf III opens after four and is full: *Whitechapel, 1891*, *Beijing, 1908*, *Alamut, 1256*, *Great Zimbabwe, 1871*. Shelf IV (after eight): *Dyatlov Pass, 1959*, *Honnō-ji, 1582*, *Roanoke, 1590*, and a sealed teaser jar (`sealed_franklin_1845`) for the tales still to come.

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

E (a room that changes when not watched) arrived with *Whitechapel,
1891*: the file shelf that grows while the player looks away. F
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
| *Whitechapel, 1891* | The file that grows when no one is looking: turn away and back, and find the new file on the shelf (`unwatched`, the long-planned **E**); her name set in mirrored type from a compositor's case, where some sorts are cut the wrong way (`compose`) | A seal of three words on the file's cover (`docket`) |
| *Gyeongju, 771* | Bronze routed from three furnaces into the mould (`pour`); the log striker and the hollow under the bell, dug until the ring lasts (`resonance`); the rim struck all round to find where the ring swells deepest, the "cry" that is a beat (`beat`) | A seal of three words taken as an ink rubbing from the bronze (`rubbing`) |
| *Beijing, 1908* | His hair measured segment by segment on scarce reactor time, to find each strand's highest and say whether it rose in sharp peaks or ran steady (`strand`); a probe dragged over his robe, outer and inner, to find where the needle stands in the red (`scan`) | A seal of three words in vermilion on imperial yellow, the last word *not known* (`vermilion`) |
| *Alamut, 1256* | Juvayni's loose sheets nested into a quire by their catchwords, turned over where they lie the wrong way (`quire`); tanks in the rock dipped with a reed and named by how it drips, then the stores judged full or low (`dip`) | A seal of three words written as a colophon, the closing lines of a book (`colophon`) |
| *Great Zimbabwe, 1871* | The breach in the great wall laid back course by course, dry, no joint over a joint, then the chevron band leaned in turn (`courses`); Mauch's splinter named by walking a key to woods, where his own way ends at cedar (`identify`) | A seal of three words in an old map's cartouche, where the maps wrote Ophir (`cartouche`) |
| *Dyatlov Pass, 1959* | A snow pit beside the tent read layer by layer with fist, fingers, pencil and knife, the weak layer marked, its column tapped until it breaks (`snowpit`); the films from their cameras printed in the investigators' darkroom from test strips, the last frame showing the cut (`darkroom`) | A seal of three words, the last entry in the group's route book (`routebook`) |
| *Honnō-ji, 1582* | The moat's section in the 2007 dig dated layer by layer from what was dropped in it (coins, porcelain), and the black layer of 1582 told from a later fire's (`strata`); Kyoto's addresses read on its street grid (north of, south of, east of, west of a crossing) to find the old temple's block and the one it moved to (`streets`) | A seal of three words cut into the site's stone marker (`marker`) |
| *Roanoke, 1590* | A cypress core from 1998 cross-dated against a master chronology by its pattern of wide and narrow rings, and its driest run read: 1587–1589 (`rings`); White's own chart, drawn with west at the top, walked with dividers to Croatoan and "fifty miles into the main" (`dividers`) | A seal of three words cut into the palisade post under CROATOAN (`post`) |
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
- *Whitechapel 1891:* the constable with a lantern at the arch; a
  compositor at the type case. No woman is shown.
- *Gyeongju:* a founder with a long ladle by the casting pit; a monk in
  the hall and at the pavilion. The legend's child and mother are never
  drawn, echoed, or voiced.
- *Beijing 1908:* a tomb keeper with a lantern in the crypt; a scientist
  in a lab coat in the work-room. No emperor, no court, and no living
  member of the team is shown or named.
- *Alamut 1256:* a guard of the garrison with a spear, going down; a
  librarian with a small lamp among the niches. No imam, no Mongol, no
  Juvayni.
- *Dyatlov Pass 1959:* a searcher with a long probe on the slope; an
  investigator under the red lamp. None of the nine is drawn, as echo or
  otherwise; in their last frames they are small, faceless figures.
- *Honnō-ji 1582:* an excavator in a hard hat in the trench; a monk
  sweeping the court at Teramachi. No warrior, no Nobunaga, no Akechi;
  the living people of the 2007 dig are not named.
- *Roanoke 1590:* a sailor with a trumpet on the shore; a sailor digging
  at the chests. No colonist, no John White, no Croatoan person is drawn.
- *Great Zimbabwe 1871:* a builder with a block on the shoulder, from the
  city's time, by the wall; a hunter with a rifle at the camp. Mauch and
  Render are named in papers, never shown.

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
- *Whitechapel 1891* is a February night of rain: a rat under the arch,
  moths at the gas in the station and the file room.
- *Gyeongju* is a midwinter night: frosted grass in the temple yard, a rat
  in the founders' shed, falling snow.
- *Beijing 1908* is winter at the tombs: dry grass through the snow,
  pines round the court, falling snow.
- *Dyatlov Pass 1959* is late February in the northern Urals: nothing
  living on the open slope but the wind; at the forest edge larch and
  spruce under snow and a raven in a tree (a new creature, `raven`).
- *Great Zimbabwe 1871* is September, the end of the dry season: msasa
  trees red with new leaves, a wild fig rooted in the wall, dry grass, a
  bateleur overhead (the `eagle` creature), a lizard on the warm stone
  (the `gecko` creature).
- *Honnō-ji 1582* is set in the summer of 2007: a crow on the site
  fence (the `raven` creature), weeds on the spoil heap, cicadas faint in
  the music.
- *Roanoke 1590* is a dawn in August on the Outer Banks: a heron in the
  shallows (a new creature, `heron`), live oaks hung with wild vines, dune
  grass, grass still smouldering at the woods' edge.
- *Alamut 1256* is December in the Alborz: dry thistles in the snowy
  court, an eagle turning over the gorge (a new creature, `eagle`), a
  mouse in the storerooms, falling snow.

## How it shows in the game

| Where | What |
|---|---|
| Main menu | Title, tagline: "Every jar keeps a tale that must not be forgotten." Behind it, the living Stillroom (`LobbyScene`): glowing jars (one stirs now and then), a clock whose pendulum swings but whose hands never move, drying herbs, a candle with a moth and dust in its light; music `stillroom_menu` |
| Map of tales | "New Game" opens an old parchment chart of the world, with a brass pin where each tale happened (a wax-red pin once distilled, grey and locked until its shelf opens, the keeper's star when its secret is found). Pinch to zoom; pins keep their size; each label goes below or above its pin, wherever it covers no other label or pin, and one with no room is hidden until the chart is zoomed in (pins on one spot, like the two Whitechapel jars, stand side by side) |
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
| `chongling_1908` | Beijing, 1908 (the Guangxu Emperor) | Built, draft text, code-drawn art (shelf III, opens after 4 tales). The hair, the robe; "illness", Cixi and the 1980 test as red herrings; the hand left unknown | [episodes/chongling_1908.md](episodes/chongling_1908.md) |
| `dyatlov_1959` | Dyatlov Pass, 1959 | Built, draft text, code-drawn art (shelf IV, opens after 8 tales). The pit, the darkroom; aliens, a yeti, weapons, radiation, the Mansi and "a compelling natural force" as red herrings | [episodes/dyatlov_1959.md](episodes/dyatlov_1959.md) |
| `honnoji_1582` | Honnō-ji, 1582 | Built, draft text, code-drawn art in depth (shelf IV, opens after 8 tales). The section, the streets; "he escaped", Hideyoshi, Ieyasu, the court, the wooden statue, Teramachi and 1591 as red herrings | [episodes/honnoji_1582.md](episodes/honnoji_1582.md) |
| `roanoke_1590` | Roanoke, 1590 | Built, draft text, code-drawn art in depth (shelf IV, opens after 8 tales). The rings, the dividers; "vanished", the Dare Stones, a white doe, the Spanish, a massacre and Site X as red herrings | [episodes/roanoke_1590.md](episodes/roanoke_1590.md) |
| `great_zimbabwe_1871` | Great Zimbabwe, 1871 | Built, draft text, code-drawn art (shelf III, opens after 4 tales). The courses, the key; the Queen of Sheba, Ophir, the Phoenicians and cedar as red herrings | [episodes/great_zimbabwe_1871.md](episodes/great_zimbabwe_1871.md) |
| `alamut_1256` | Alamut, 1256 | Built, draft text, code-drawn art (shelf III, opens after 4 tales). The quire, the tanks; Polo's garden, drug and three-year siege, and "hashish", as red herrings | [episodes/alamut_1256.md](episodes/alamut_1256.md) |
| `whitechapel_1891` | Whitechapel, 1891 | Built, draft text, code-drawn art (shelf III, series whitechapel, opens after 4 tales). The file that grows, her name set in type; "Jack the Ripper" and "five" as red herrings | [episodes/whitechapel_1891.md](episodes/whitechapel_1891.md) |
| `gyeongju_771` | Gyeongju, 771 | Built, draft text, code-drawn art (shelf II, opens after 2 tales). The pour, the hollow, the beat; the child legend, Seoul and 1925 as red herrings | [episodes/gyeongju_771.md](episodes/gyeongju_771.md) |
| `bastille_1703` | Bastille, 1703 | Built, draft text, code-drawn art (shelf II, opens after 2 tales). Key ring, Great Cipher, the file of sources; Voltaire, Dumas and Bazeries as red herrings | [episodes/bastille_1703.md](episodes/bastille_1703.md) |
| *(planned)* | The other three new tales (shelves IV and V) | See *The full shelf* above | — |
| `test_room` | Test room | Debug builds only | Feature test room |
