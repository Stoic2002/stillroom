# Episode design: Roanoke, 1590 (the colony that left a word)

Status: **design draft** (2026-10-07), for the developer's approval before
anything is built. Shelf IV (opens after 8 tales), the Americas, from the
plan of 16 tales (`docs/stillroom_frame.md`, *The full shelf*). It
replaces the sealed teaser `sealed_roanoke_1590`; a teaser for the next
tale (`sealed_franklin_1845`) takes its place. Proposed id:
`roanoke_1590`; jar label **Roanoke, 1590**, its map pin on the north end
of Roanoke Island (Fort Raleigh). Drawn in depth from the start (CLAUDE.md
decision 6), with one camera per scene.

## Premise

In July 1587 about 115 English men, women and children were left on
Roanoke Island under their governor, **John White**. His granddaughter,
**Virginia Dare**, was born there on 18 August. White sailed home for
supplies nine days later, and the war with Spain (the Armada of 1588) kept
him in England for three years.

He came back on **18 August 1590**, her third birthday. At night his men
saw a fire through the woods and sounded a trumpet and sang English tunes
to it; no one answered. In the morning they found the houses taken down,
a palisade of great trees built round the place, iron bars and lead
overgrown with grass, and five chests dug up, three of them his: his
books torn, his maps and pictures spoiled by rain, his armour rusted.
On a tree on the hill, **CRO**; on a post at the palisade's entrance, its
bark stripped, in fair capital letters, **CROATOAN**, "without any crosse
or signe of distresse". Before he left they had agreed to carve where they
had gone, and a cross over it if they went in danger. Croatoan was the
island to the south (Hatteras today), home of the Croatoan people and of
**Manteo**, who had sailed to England and back with the English.

White could not go to see. A storm, a lost anchor and a parted cable
drove the ship out to sea; seven men had drowned in the landing. He never
returned.

The **legend** says the colony "vanished without a trace". The carving
is the trace. What is known beyond it is slow and partial: tree rings
show the **worst drought in eight hundred years** in 1587–1589; digs on
Hatteras have found English things of the time among Croatoan ones; a
patch on White's own map hides a fort inland ("Site X"). The **Dare
Stones**, carved messages "from Eleanor Dare" found from 1937, were
shown in 1941 to be largely forgeries.

The keeper's jar holds what is known: the word they carved, the cross
they did not, and the drought they lived through.

## Tone and guardrails

- **No violence shown.** The drowned men are told in one line, unnamed but
  for the captain the record names. No bodies.
- **The Croatoan and the other Algonquian peoples** are named with respect
  and by their own names; the record's word "Salvages" is not used in our
  text. Manteo appears by his own facts.
- **The ending stays open.** The seal says what they carved and what they
  lived through, not where they ended up. Hatteras, Site X and the inland
  theories are stated as evidence still argued over, never as the answer.
- **Legends are red herrings:** "vanished without a trace", the Dare
  Stones, Virginia Dare as a white doe, a Spanish raid, a massacre.
- **Virginia Dare** is a real child of whom nothing is known after 1587:
  she appears only in the record's line about her birth.

## Historical facts used (checked 2026-10-07)

| Fact | Used in | Source |
|---|---|---|
| About 115 colonists in 1587, White governor; Virginia Dare born 18 Aug 1587; White left 27 Aug; the Armada kept him in England; he landed 18 Aug 1590 | The premise; the ship | [Wikipedia: Roanoke Colony][col] |
| White's 1590 account: the fire seen at night, the trumpet and English tunes; footprints in the sand; CRO on a tree; the houses taken down; the palisade "very Fort-like"; iron bars, two pigs of lead, four iron fowlers, saker shot, overgrown; five chests, three his, books torn, maps spoiled, armour rusted; CROATOAN on a post "without any crosse or signe of distresse"; the agreed token and the cross | The shore, the hill, the fort, the seal | [White, in Hakluyt (Encyclopedia Virginia)][white]; [constitution.org transcription][white2] |
| Seven drowned when a boat overset in the landing, Captain Edward Spicer among them; the colonists "were prepared to remoue from Roanoak 50 miles into the maine"; a cable broke, one cable and anchor left of four, foul weather, scarce victuals: the search abandoned | The shore, the ship, the dividers | [white2] |
| Croatoan Island is Hatteras today; Manteo was Croatoan | The map | [col] |
| Bald cypress tree rings: the worst three-year drought in 800 years, peaking in 1587 (Stahle et al., *Science* 280, 1998) | The rings (`rings`) | [ScienceDaily, 1998][drought]; [NOAA dataset][noaa] |
| Hatteras digs since 2009 (Croatoan Archaeological Project, M. Horton): a rapier hilt, a slate with a letter "M", English pottery among Croatoan finds; still argued over | A later paper | [History.com][horton] |
| Site X: a patch on White's map *La Virginea Pars* hides a fort symbol inland (2012) | A later paper | [col] |
| The Dare Stones, 1937–1940; exposed as largely forged in the *Saturday Evening Post*, 1941 | A later paper (decoy) | [NCpedia: Dare Stones][dare] |

[col]: https://en.wikipedia.org/wiki/Roanoke_Colony
[white]: https://encyclopediavirginia.org/primary-documents/john-white-returns-to-roanoke-an-excerpt-from-the-fift-voyage-of-master-john-white-into-the-west-indies-and-parts-of-america-called-virginia-in-the-yeere-1590-1600/
[white2]: https://www.constitution.org/primarysources/ronoake.html
[drought]: https://www.sciencedaily.com/releases/1998/04/980428075409.htm
[noaa]: https://catalog.data.gov/dataset/noaa-wds-paleoclimatology-stahle-et-al-1998-jamestown-roanoke-climate-reconstructions
[horton]: https://www.history.com/articles/archaeologists-find-new-clues-to-lost-colony-mystery
[dare]: https://www.ncpedia.org/dare-stones

## Where it is set

- **A. Roanoke Island, 18 August 1590** (recommended): White's landing,
  dawn after the night of the trumpet. The shore with the burnt grass and
  the footprints, the hill with CRO, the empty fort, the chests' pit, and
  the ship's cabin. The tree-ring core, the Hatteras finds, Site X and the
  Dare Stones arrive as papers "that should not be here yet".
- **B. Today, at Fort Raleigh and on Hatteras:** the earthwork, the dig, a
  lab with the cypress cores. Strong for the evidence, but it loses the
  carved post, the tale's one hard fact.

## Map (A)

```
          the hill (CRO)
               │
 the ship ─ the shore (start) ─ the fort
                                  │
                              the chests
```

| Scene | What's there |
|---|---|
| `shore` (start) | The ship's boat drawn up, burnt grass smoking, footprints in the sand, a trumpet left on a thwart |
| `hill` | Live oaks and wild vines on a sandy rise; one tree with CRO cut in it; a sea view south toward Croatoan |
| `fort` | The palisade of great trees with its flankers; the entrance post with the bark stripped; iron bars, pigs of lead, fowlers in the grass; the house sites, bare |
| `chests` | A pit by the old trench, five chests dug up and broken open; White's spoiled maps and books, his rusted armour |
| `ship` | The cabin of the ship: a table, a chart, a lantern, the papers from the future |

## New mechanics (this tale only)

- **The rings (`rings`).** The height of the tale. A core from an old bald
  cypress (a paper from 1998): its rings, wide in wet years, narrow in dry.
  Slide the core along a master chronology, a strip of ring widths with
  years, until the patterns of wide and narrow match (cross-dating); then
  mark the run of the three narrowest rings in a row and read their years.
  One trap: a single narrow ring that matches in two places; only the
  whole pattern fixes the core. Unlike the hair (`strand`) or the snow
  pit (`snowpit`): nothing is measured by hand; a pattern is matched.
- **The dividers (`dividers`).** White's own chart and its scale of
  miles. Open the dividers to a span on the scale, then walk them from
  Roanoke along a bearing, step by step, to find what lies at the
  distances the papers name: Croatoan, about fifty miles south; "fifty
  miles into the main", the plan they spoke of in 1587. Unlike the red
  thread (`thread`) or the street grid (`streets`): no route and no
  address; a distance is walked with an instrument.

## Puzzle flow (11 beats)

| # | Beat | Type | Clue | Reward |
|---|---|---|---|---|
| 1 | The shore | read | Burnt grass, footprints; the trumpet: they sounded it all night | — |
| 2 | The hill | read | CRO on a tree: the agreed token, unfinished | — |
| 3 | The fort | read | The palisade, the iron and lead in the grass; the stripped post | Word (Croatoan) |
| 4 | The fort | read | The agreement: a cross over the name if in distress; there is none | Word (cross) |
| 5 | The chests | read | Five chests dug up; White's maps spoiled, one chart still whole | The chart |
| 6 | The ship | **dividers** | White's chart, the papers' distances | Croatoan fifty miles south; "fifty miles into the main" |
| 7 | The ship | read | A later paper: the Hatteras digs; Site X | Decoys (Hatteras finds as proof, Site X) |
| 8 | The ship | **rings** | The cypress core, the master chronology | Word (drought) |
| 9 | The ship | read | Later papers: the Dare Stones; "vanished without a trace"; the white doe | Decoys |
| 10 | The seal | `deduction`, a new form | All the above | The tale is distilled |
| — | Secret | read twice | The trumpet on the boat, after the seal's words are found | The keeper's note |

## The seal

A new form, **`post`**: the palisade's entrance post, the bark stripped
from a hand's width of pale wood, the words cut into it in capitals.

"They carved {Croatoan} with no {cross} of distress, in the worst
{drought} in eight hundred years."

Decoys: vanished, the Spanish, a massacre, the Dare Stones, a white doe,
Site X.

**Ending:** "In August 1590 John White found CROATOAN cut into the fort's
post, and no cross. He never reached Croatoan. Where the colonists went
after that, the evidence is still argued over."

## Echoes and living things

- **Echoes:** a sailor with a trumpet on the shore; a sailor digging at
  the chests. No colonist, no White, no Croatoan person is drawn.
- **Living things (the Outer Banks, August):** a heron in the shallows
  (a new creature, `heron`), fiddler crabs on the sand, wild grapevines on
  the live oaks, sea oats on the dunes.

## Audio (ids, to generate)

- **Music:** `sound_dawn` (a low drone, water lapping, a far trumpet call
  now and then, unanswered).
- **Effects:** `trumpet_call`, `surf_low`, `chest_lid`. Interface:
  `core_slide` (the core slid along), `ring_mark` (a ring marked),
  `divider_step` (the dividers walked a step).

## Open questions for the developer

1. Where it is set: **A** (White's landing, 18 August 1590, recommended)
   or B (today, at Fort Raleigh and Hatteras)?
2. The two mechanics: the rings (`rings`) and the dividers (`dividers`)?
3. The jar's label **Roanoke, 1590**, and the seal as the carved post
   (`post`) with its sentence (Croatoan / cross / drought)?
