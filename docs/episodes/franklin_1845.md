# Episode design: The Franklin expedition, 1845 (the ship the Inuit remembered)

Status: **design draft** (2026-10-07), for the developer's approval before
anything is built. Shelf IV (opens after 8 tales), the Arctic, from the
plan of 16 tales (`docs/stillroom_frame.md`, *The full shelf*). It
replaces the sealed teaser `sealed_franklin_1845`; the last place on
shelf IV is the Indonesian tale still to be chosen. Proposed id:
`franklin_1845`; jar label **Franklin, 1845** (see question 3), its map
pin on the wreck of *Erebus* off the Adelaide Peninsula. Drawn in depth,
one camera per scene (CLAUDE.md decision 6).

## Premise

On 19 May 1845 **HMS *Erebus*** and **HMS *Terror*** sailed from
Greenhithe under **Sir John Franklin** to find the Northwest Passage: 129
men after five were sent home. Whalers saw them in Baffin Bay in July
1845; no European saw them alive again.

In 1859 a search party found a note in a cairn at Victory Point, on
King William Island. On a printed Admiralty form ("whoever finds this
paper...", in six languages), a first message of **28 May 1847**: "All
well". Round its margins, a second, of **25 April 1848**, signed by
Crozier and Fitzjames: the ships, beset since September 1846, had been
**deserted on 22 April 1848**; Franklin had died on 11 June 1847; nine
officers and fifteen men were dead; 105 were setting out the next day
for Back's Fish River. None reached it.

From 1854 on, **Inuit** told what they had seen: men walking south,
starving; and a ship, found afloat in the ice off **Ugjulik** ("there
are bearded seals there"), off the west coast of the Adelaide Peninsula,
abandoned, a body inside, that later sank. In 1869 an Inuk,
**Inukpujijuk**, showed the place on Charles Francis Hall's Admiralty
chart. In London much of this was waved away as hearsay; Charles Dickens
wrote against John Rae's Inuit reports in 1854.

The **legend** is that the ships were lost without trace, or crushed in
the ice, and the Inuit stories only tales. In **2014** a Parks Canada
search, guided by the Inuit accounts that Louie Kamookak of Gjoa Haven
had gathered for thirty years, found ***Erebus*** off the Adelaide
Peninsula, where Ugjulik is; in **2016**, on a Gjoa Haven hunter's word,
***Terror*** in Terror Bay.

The keeper's jar holds what is known: when they left the ships, where
the Inuit said one went down, and the ship that lay there.

## Tone and guardrails

- **No gore.** The deaths are numbers on the note. The starving men are
  told as the Inuit told them, in one line; nothing more is described.
- **The Inuit are the witnesses who were right**, named where the record
  names them (Inukpujijuk); their knowledge is shown with respect, never
  as folklore. Louie Kamookak (d. 2018) is named in a later paper for his
  work; the living members of the 2014 team and the hunter of 2016 are
  not named.
- **Legends are red herrings:** "lost without a trace", "crushed in the
  ice", lead from the tins as the whole answer (argued over still), the
  Inuit accounts as tales.
- **The graves at Beechey Island** and the men's remains are not shown.

## Historical facts used (checked 2026-10-07)

| Fact | Used in | Source |
|---|---|---|
| Sailed 19 May 1845, *Erebus* and *Terror*, 129 men; whalers saw them in Baffin Bay, July 1845; wintered at Beechey Island 1845–46; beset off King William Island September 1846; Rae's Inuit reports, 1854; lead (Beattie, 1984) and later doubts | The premise; later papers | [Wikipedia: Franklin's lost expedition][exp] |
| The Victory Point note: 28 May 1847 (Gore, Des Voeux: "All well"), 25 April 1848 in the margins (Crozier, Fitzjames: deserted 22 April, 5 leagues NNW, beset since 12 Sept 1846, 105 souls, Franklin died 11 June 1847, 9 officers and 15 men, start for Back's Fish River); its "1846-7" error; found by Hobson, May 1859 | The margins (`margins`) | [Wikipedia: Victory Point note][note] |
| The printed form: "Whoever finds this paper is requested to forward it to the Secretary of the Admiralty", in six languages | The seal's form | [American Philosophical Society][form] |
| Ugjulik, "there are bearded seals there"; Hall, 1869: the wreck off the west shore of the Adelaide Peninsula, Inukpujijuk marked it on Hall's chart; found afloat in the ice, boarded, a body inside, then sank; Schwatka was told it sank off Grant Point; Kamookak on the advisory committee; *Terror* in Terror Bay, 2016 | The elders' stories; the survey | [Parks Canada: Inuit traditional knowledge][ik] |
| *Erebus* found 2 September 2014 by side-scan sonar, "mowing the lawn"; the day before, a davit pintle and a deck hawse plug found on a small island moved the search | The island; the survey (`sonar`) | [Parks Canada: Finding HMS Erebus][find]; [Wikipedia: HMS Erebus][ereb] |
| *Terror* found in Terror Bay in 2016 after a Gjoa Haven hunter told of timber seen through the ice | A later paper | [CBC News][cbc] |

[exp]: https://en.wikipedia.org/wiki/Franklin%27s_lost_expedition
[note]: https://en.wikipedia.org/wiki/Victory_Point_note
[form]: https://diglib-legacy.amphilsoc.org/islandora/object/h-m-s-th-18-lat-long-commanderwhoever-finds-paper-requested-forward-it-secretary
[ik]: https://www.parks.canada.ca/lhn-nhs/nu/epaveswrecks/culture/inuit/qaujimajatuqangit
[find]: https://parks.canada.ca/lhn-nhs/nu/epaveswrecks/culture/archeologie-archeology/decouvertes-discoveries/erebus
[ereb]: https://en.wikipedia.org/wiki/HMS_Erebus_(1826)
[cbc]: https://amp.cbc.ca/news/canada/north/sammy-kogvik-hms-terror-franklin-1.3763653

## Where it is set

- **A. September 2014, the search off the Adelaide Peninsula**
  (recommended): the deck of the survey ship among the floes, its
  survey room with the sonar and the chart table, the small island where
  the iron pintle lay, and the community hall in Gjoa Haven with the
  elders' stories and the place names. The Victory Point note arrives as
  a paper "from the past"; Hall's chart and the later papers too.
- **B. May 1859, Victory Point:** the cairn, the note, the boat in Erebus
  Bay. Strong, but the tale's truth (the wreck where the Inuit said) is
  out of its reach.

## Map (A)

```
 the hall (Gjoa Haven) ─ the deck (start) ─ the survey room
                              │
                          the island
```

| Scene | What's there |
|---|---|
| `deck` (start) | The survey ship's deck among broken ice, the launch on its davits, the low shore of the peninsula; the ice chart pinned by the bridge door |
| `survey` | The survey room: the sonar screen, the chart table with Hall's chart, the note in its sleeve, the later papers |
| `island` | A small rocky island, the helicopter set down; on the shore an iron pintle and a wooden plug, both a ship's |
| `hall` | The community hall in Gjoa Haven: a wall map with Inuit place names and what they mean, the elders' stories on tape, a drum on the wall |

## New mechanics (this tale only)

- **The margins (`margins`).** The Victory Point note: a printed form
  with writing all round it, in two hands, two years apart, some of it
  upside down or up the sides. Turn the sheet (drag or the arrows, by
  quarter turns) until a passage stands upright and can be read; tap it
  to answer the question at hand: when the ships were deserted, when
  Franklin died, how many went on. The trap: the 1847 "All well" and the
  error "1846-7" read upright first. Unlike the quire (`quire`): nothing
  is put in order; one sheet is turned to read it.
- **The sonar (`sonar`).** The height of the tale. A survey area off the
  peninsula as a grid; pick the lanes the launch runs, one at a time, from
  a small budget of hours; each lane draws the seabed beneath it as
  side-scan echoes (rocks, ice scours, and one long shape with a straight
  shadow). The Inuit accounts (Ugjulik, off the west shore, northeast of
  O'Reilly Island) and the island's finds say where to look; the
  Admiralty's own guess (crushed in the ice far to the north) wastes the
  hours. Mark the wreck on a lane's echo. Unlike the beam over the island
  (`beamSweep`): what a lane shows stays, the lanes are chosen and paid
  for, and an echo is read for its shape and shadow.

## Puzzle flow (11 beats)

| # | Beat | Type | Clue | Reward |
|---|---|---|---|---|
| 1 | The deck | read | The ice chart: the north closed by ice this year; the search moved south | — |
| 2 | The hall | read | The elders' stories: a ship found afloat off Ugjulik, boarded, a body inside, then sank; tracks of men walking south | Word (Ugjulik) |
| 3 | The hall | read | The wall map: Inuit place names and their meanings | — |
| 4 | The survey room | **margins** | The Victory Point note | Word (1848); decoy (1847) |
| 5 | The survey room | read | Hall's chart, 1869: Inukpujijuk's mark | — |
| 6 | The island | read | An iron pintle and a wooden plug on the shore: a ship's | The search area moves south |
| 7 | The survey room | **sonar** | The survey grid, the accounts, the island | Word (*Erebus*) |
| 8 | The survey room | read | Later papers: Dickens, 1854; the lead in the tins; "crushed in the ice"; *Terror* found in Terror Bay, 2016 | Decoys (lead, crushed, *Terror*, Victory Point) |
| 9 | The seal | `deduction`, a new form | All the above | The tale is distilled |
| — | Secret | read twice | The drum in the hall, after the seal's words are found | The keeper's note |

## The seal

A new form, **`admiralty`**: a fresh copy of the printed Admiralty form,
its heading in six languages ("Whoever finds this paper..."), the words
written into its blanks by hand.

"They left the ships in {1848}; the Inuit said one went down off
{Ugjulik}, and {*Erebus*} lay there."

Decoys: 1847, Victory Point, *Terror*, lead, crushed in the ice.

**Ending:** "In 2014 *Erebus* was found where the Inuit had said a ship
went down; in 2016, *Terror*, where a hunter of Gjoa Haven had seen
timber through the ice. No one of the 129 came home."

## Echoes and living things

- **Echoes:** a man of 1848 hauling a sledge on the island's shore; a
  surveyor in a float coat on the deck. No Franklin, no Inuk is drawn.
- **Living things (the Arctic, September):** a bearded seal on a floe
  that slips into the water when tapped (a new creature, `seal`), gulls
  over the deck, lichen and saxifrage on the island's rocks.

## Audio (ids, to generate)

- **Music:** `ice_drift` (a cold low drone, ice creaking, wind, a far
  sonar ping now and then).
- **Effects:** `ice_creak`, `rotor` (a helicopter on the island),
  `drum_low` (the drum in the hall). Interface: `sheet_turn` (the note
  turned), `lane_run` (a lane surveyed), `echo_mark` (an echo marked).

## Open questions for the developer

1. Where it is set: **A** (the 2014 search, recommended) or B (Victory
   Point, 1859)?
2. The two mechanics: the margins (`margins`) and the sonar (`sonar`)?
3. The jar's label: **Franklin, 1845** (recommended) or Erebus, 1845?
   And the seal as the Admiralty form (`admiralty`), with its sentence
   (1848 / Ugjulik / *Erebus*)?
