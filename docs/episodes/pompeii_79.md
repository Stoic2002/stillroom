# Episode design: Pompeii, 79

Status: **built** (2026-09-29): content, draft text in seven languages,
code-drawn art, generated audio, and a start-to-finish walkthrough test
(`test/state/pompeii_walkthrough_test.dart`). Chosen by the developer as
episode 4 (shelf II, `unlockAfter: 2`), the tale that makes shelf III
reachable. Episode id: `pompeii_79`.

## Premise

A baker's house in Pompeii, as Giuseppe Fiorelli's diggers left it in
**1863**: roofs gone, walls to the shoulder, the street half dug out of the
ash. In the diggers' hut the keeper finds a brass lens. **Through it, the
ash is not there yet.** Each place shows the afternoon the mountain woke:
the cloud over Vesuvius, bread sealed in the oven, pumice rattling
through the roof into the basin, a family at the door with cushions tied
on their heads.

The work is to **put back the truth the ruin hides**. The popular picture
of Pompeii is one instant of lava that froze everyone where they stood.
The house says otherwise. Its people had hours, and they left. The ones
who stayed were caught at dawn by a burning cloud, and the plaster
figures are hollows in the ash, not bodies turned to stone.

## Tone and guardrails

- **Horror through atmosphere:** an empty house, a sealed oven, the
  mountain smoking thinly over the ruins, falling stones heard through
  the lens. **No bodies and no suffering shown.**
- **The plaster casts** are shown from afar, as the developer decided:
  pale shapes under the diggers' canvas at the far end of the garden,
  without detail, and **not tappable**. The text names them once, in the
  diggers' day-book, with respect: people who stayed, whose names no one
  knows.
- **The family is invented; everything around them is real.** Felix the
  baker, his household, and their house are fiction. Their bread,
  fruit, jars, gods, graffiti habits, and way of escape follow real finds.
  No real Pompeian is given invented features.
- **Legend is shown as legend,** as in Flannan: the guidebook's "lava in
  a single instant" and the old date of 24 August are decoys on the label.
- **The date debate is honest.** The label only says it was autumn *in
  this house* (its fruit and wine say so). The ending explains that the
  books long said 24 August, and that a charcoal inscription found in 2018
  points to autumn.

## Historical facts used (verified 2026-09-29)

| Fact | Used in | Source |
|---|---|---|
| Eruption of Vesuvius in 79; the column reached about 33 km; pumice fell for **18 to 20 hours**; pyroclastic surges came in the night and the early morning | Section in the garden, label | [Wikipedia: Eruption of Vesuvius in 79](https://en.wikipedia.org/wiki/Eruption_of_Mount_Vesuvius_in_79_AD) |
| Pliny the Younger: the cloud was like a **pine tree**, with a trunk and branches; people fled with **pillows tied to their heads** against the stones | Pliny's letters in the hut, lens, label | Wikipedia (Pliny's letters to Tacitus) |
| The traditional date, **24 August**, comes from the manuscripts. A charcoal inscription found in **2018** reads the 16th day before the Kalends of November (17 October), and autumn fruit (pomegranates, chestnuts), braziers, and sealed wine jars point to autumn; the date is still debated | Store corner, lens, label decoy, ending | Wikipedia; [Getty](https://www.getty.edu/news/when-did-vesuvius-erupt-august-october-24/); [National Geographic](https://www.nationalgeographic.com/history/article/mount-vesuvius-eruption-pompeii) |
| Earthquake of **5 February 62**, still not fully repaired in 79 | Crack in the atrium | Wikipedia |
| About **1,044 casts and remains** found at Pompeii; no one knows how many escaped | Day-book (no figure given) | Wikipedia |
| Excavations began in **1748**; the city was identified by an inscription in 1763 | Plaque in the street (decoy year) | [Wikipedia: Pompeii](https://en.wikipedia.org/wiki/Pompeii) |
| **Giuseppe Fiorelli** directed the excavations from **1863**; that February his team first poured **plaster into the hollows** bodies had left in the ash; he numbered the city into regiones, insulae, and doors | Day-book, casts, label | Wikipedia; [pompeiiinpictures: first casts, 3–6 February 1863](https://pompeiiinpictures.com/pompeiiinpictures/Casts/victim%203.htm) |
| At least **31 bakeries**, with lava-stone mills and wood-fired ovens; in 1862 Fiorelli's team found **81 carbonised loaves** in the oven of the bakery of Modestus, each scored into eight | Bakery, loaves | Wikipedia; [Tavola Mediterranea](https://tavolamediterranea.com/2018/06/14/baking-bread-romans-part-iii-panis-strikes-back/) |
| Graffiti everywhere; one found on three walls reads "I am amazed, O wall, that you have not fallen in ruins, you who hold up the tedium of so many writers" (CIL IV 1904) | Graffiti in the atrium | [CIL IV 1904](https://sententiaeantiquae.com/2012/03/21/cil-iv-1904/) |
| Gates: **Porta Marina** (west, towards the sea), **Porta Vesuvio** (north, towards the mountain), and the Stabian, Nucerian, Sarno, Nolan, and Herculaneum gates | Town plan in the hut | Wikipedia |

## Map

```
                 garden (the section, the casts far off)
                   │
  hut ─── street ─── bakery ─── atrium (label at the shrine)
 (start: street)
```

| Scene (1863) | Seen through the lens (79) | What's there |
|---|---|---|
| `street` (start) | `street_79` | Ash bank at the shop door, painted election notice, the diggers' plaque, Vesuvius smoking. Lens: bright shopfronts, the pine cloud rising |
| `hut` | — (no lens: the hut did not exist) | Drafting table, town plan with the gates, Pliny's letters, a guidebook, the day-book, the lens, a shovel |
| `bakery` | `bakery_79` | Two lava-stone mills, the oven (iron door stuck), sealed wine jars and charred fruit. Lens: oven sealed with bread in it, a basket of stamped loaves, autumn fruit, the donkey at the mill |
| `atrium` | `atrium_79` | Empty shrine, pumice in the basin, the earthquake crack, a flaked charcoal drawing, the draughtsman's tracings, a niche under the stair. Lens: stones falling through the roof, the family at the door, the household gods being wrapped, a clay horse in the niche |
| `garden` | `garden_79` | The diggers' cut through the layers; the casts under canvas, far off. Lens: fig tree, vine, and the cloud over the wall |

## New mechanics (shelf II)

- **C. The lens between eras.** A scene with a `lens` shows a lens button;
  raised, a brass circle the player drags shows the other scene inside it.
  Taps inside the circle reach that scene's hotspots. Words and clues sit
  on both sides of the lens.
- **The stack of sheets (`overlay`),** after *Her Trees*: tracing sheets
  are dragged and turned on the drafting table until the four registration
  crosses meet and the lines make one drawing.

## Puzzle flow (11 beats)

| # | Beat | Type | Clue | Reward |
|---|---|---|---|---|
| 1 | The hut | pick up | — | Lens, shovel; the day-book, Pliny, the guidebook, the town plan (words) |
| 2 | The ash bank | use the shovel (no puzzle: wiping belongs to other tales) | The shop door is buried | Into the bakery |
| 3 | Through the lens | lens | Every scene with a lens | Words: pine tree, Felix, autumn, pillows |
| 4 | The oven | use the shovel as a lever | Door stuck with ash | Charred loaves: bread |
| 5 | The store corner | examine | Sealed jars, charred pomegranates | Word: autumn |
| 6 | The atrium | pick up | The draughtsman's tube | Tracings |
| 7 | The drawing | `overlay`: three sheets, two turned | Registration crosses on the table | A child's drawing: a boat, three figures with pillows, AD MARE ("to the sea") |
| 8 | The gates | town plan | "To the sea" | Marina Gate (and the decoy, the Vesuvius Gate) |
| 9 | The garden | examine the cut | Pumice, then fine ash | Words: pumice, a burning cloud, dawn |
| 10 | The jar's label | `deduction` at the shrine | All of the above | The tale is distilled |
| 11 | Secret (optional) | lens → ruin | Through the lens, a clay horse pushed into the niche under the stair | The keeper's note |

**The label** (draft):

1. "It was {autumn} in this house. Over Vesuvius a cloud rose like {a pine
   tree}, and {pumice} fell on the city all afternoon and all night."
2. "{Felix} the baker left his {bread} in the oven and led his family out
   through {the Marina Gate}, {pillows} tied on their heads."
3. "Those who stayed were caught at {dawn} by {a burning cloud}. In {1863}
   the hollows they left in the ash were filled with plaster."

Decoys: 24 August, lava, the Vesuvius Gate, 1748.

**Ending:** the books long said 24 August; the house remembered autumn, and
in 2018 a line of charcoal on a wall nearby, dated mid-October, made many
historians agree. No one knows if Felix's family found a boat. The house
kept their bread, and a child's drawing of the sea.

## Audio (ids)

- **Music:** `pompeii_ash` (a warm drone in D, dry wind, a slow plucked
  string).
- **Effects:** `rumble` (the mountain), `shovel_dig`, `oven_door`, `millstone`,
  `pumice_fall`, `page_turn`, `paper`. Interface: `lens`.

## Decisions (2026-09-29)

1. Jar label: **Pompeii, 79**, without a day; the date debate is in the
   story (autumn fruit, the ending).
2. **An invented household, real objects.**
3. New mechanics: **the lens between eras** and **the stack of sheets**.
4. The plaster casts are shown **from afar** (not tappable, no detail).
5. **Every tale plays differently:** Pompeii uses only its own mechanics
   (the lens and the sheets) plus the shared frame (words, label, secret).
