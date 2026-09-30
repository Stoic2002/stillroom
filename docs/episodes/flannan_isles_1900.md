# Episode design: Flannan Isles, 1900

Status: **built** (2026-09-26), **rebuilt as v2** (2026-09-30, below):
content, draft text in seven languages,
code-drawn art, generated audio, and a start-to-finish walkthrough test
(`test/state/flannan_walkthrough_test.dart`). Chosen by the
developer for shelf II (episode 3). Proposed id: `flannan_isles_1900`,
shelf II, `unlockAfter: 2`, in place of the old sealed jar `sealed_3`.

## Premise

Eilean Mòr, the largest of the Flannan Isles, 32 km west of Lewis. In the jar
it is always the evening of **26 December 1900**, when the relief boat found
the lighthouse silent. The keeper (the player) comes up the cliff steps
alone. The lamp is dark, the clock has stopped, and three men are gone.

The work is to **light the lamp again** and **put the truth back together**.
Since 1900 the story has been buried under legend: a fake logbook, an
overturned chair, a meal left on the table. None of that was in the
record. The real record is quieter and sadder. Two men went down to the west
landing in their oilskins to save the stores in a storm. The third ran after
them in his shirtsleeves. A great sea took all three.

Why it fits the Stillroom: they were **keepers** too. The tale ends with the
light lit and their names written down. The legend is cleared away.

## Tone and guardrails

- **Horror through atmosphere:** a dead lamp, a stopped clock, dark
  stairwells, the sea's roar, the Hesperus sounding her horn in the fog. **No
  bodies, no violence, nothing supernatural claimed as fact.**
- **Honour the three men:** their names and roles, and only what the record
  says. No invented inner lives.
- **The legend is shown as legend.** The poem's chair and meal and the fake
  log appear as other people's words (a magazine, a copied "log"). They
  never appear in the room itself, and the player learns to tell them apart.
  This is the tale's red herring, a shelf II lever.

## Historical facts used (verified 2026-09-26)

| Fact | Used in | Source |
|---|---|---|
| Lighthouse on Eilean Mòr, Flannan Isles, 32 km west of Lewis; **first lit 7 December 1899**; tower 23 m | Gate plaque (code), setting | [Wikipedia](https://en.wikipedia.org/wiki/Flannan_Isles_Lighthouse), [NLB](https://www.nlb.org.uk/history/flannan-isles/) |
| Keepers: **James Ducat** (Principal), **Thomas Marshall** (Second Assistant), **Donald McArthur** (Occasional Keeper, standing in for William Ross, on sick leave) | Name plates, hooks, label | [NLB](https://www.nlb.org.uk/history/flannan-isles/) |
| On **15 December 1900** the steamer **Archtor** passed and saw no light | A pilot's note, label decoy/date | [NLB](https://www.nlb.org.uk/history/flannan-isles/), [NRS](https://nrscotland.gov.uk/learning-and-events/research-guides/lighthouses/the-mystery-of-the-flannan-islands-lighthouse) |
| Relief ship **Hesperus** arrived **26 December**; relief keeper **Joseph Moore** found the station empty | Setting (Moore is not shown) | NLB, Wikipedia |
| Found: gate and door closed, **clock stopped**, **no fire lit**, beds empty, **lamp cleaned and the fountain full** | Kitchen, lamp room | NLB (Moore's report) |
| **Last log entry 13 December**; the **slate** carries readings for 14 to 15 December, the last taken at **9 a.m. on 15 December** | Log vs slate puzzle | NLB |
| **One set of oilskins left behind** (McArthur's): Ducat and Marshall went out in seaboots and oilskins, McArthur in his shirtsleeves | Oilskin hooks puzzle | NLB, Wikipedia |
| West landing: a box of ropes and tackle kept in a crevice **33 m above the sea** washed away; iron railings twisted; the tramway's rails torn out of their concrete; a block of stone of **over a ton** displaced; turf torn away **60+ m up**, 10 m from the edge | West landing evidence (the rope-box plate, the swell, the beam) | Wikipedia, NLB |
| Superintendent **Robert Muirhead**: an unexpectedly large sea swept them away at the west landing on the afternoon of 15 December | The truth; label | NLB (Muirhead's report, 8 Jan 1901) |
| **Legend, not record:** the overturned chair and the uneaten meal (W. W. Gibson's poem *Flannan Isle*, 1912); the dramatic log entries of 12 to 15 December (a later fake) | Red herrings, label decoys | [Wikipedia: Flannan Isle](https://en.wikipedia.org/wiki/Flannan_Isle), [History Hit](https://www.historyhit.com/the-flannan-isle-mystery-when-three-lighthouse-keepers-vanished-overnight/) |
| Automated **28 September 1971** | Ending ("it has not missed a night since") | Wikipedia |

## Map

```
             lamp_room (top of the tower)
                  │  dark stair (lantern)
  east_landing ─ yard ─ kitchen (living quarters)
       (start)     │  └─ oil_store (dark)
                   └─ west_landing (opens late)
```

| Scene | What's there |
|---|---|
| `east_landing` | Cliff steps, flagpole with no flag, the Hesperus's lights in the fog, the brass plaque by the gate |
| `yard` | The tower, the quarters' door, the tramway rails, the path west (blocked by a fallen rail until later) |
| `kitchen` | The stopped clock, cold stove, tidy table, three coat hooks with name tags, the slate, the logbook, a magazine on the shelf (the legend) |
| `oil_store` | **Dark.** Paraffin cans, matches, a hand lantern |
| `stair` | **Dark.** The spiral stair; the lamp-room key hangs on a nail halfway up |
| `lamp_room` | The great lens, the lamp (clean, fountain full), the clockwork that turns the lens (run down) |
| `west_landing` | Twisted railings, the empty place where the rope box stood 33 m up, turf torn at the cliff top, the crane still standing |

## New mechanics (shelf II)

- **D: light and dark.** Some scenes are dark. The player sees only a small
  circle of light around their finger, the hand lantern, and drags it to
  search. It is reusable: a scene sets `dark` with a `when`.
- **Crank (B, touch).** Wind the clockwork with circular drags until it is
  wound.
- **Red herrings:** the legend's words can be noted too (chair, meal, the
  storm log). They are decoys in the label.

## Puzzle flow (12 beats, two branches meet at the lamp)

| # | Beat | Type | Clue | Reward |
|---|---|---|---|---|
| 1 | Gate | `codeLock` 4 digits **0712** | Plaque: "First lit 7 December 1899" | Into the yard |
| 2 | Kitchen | examine + note | Clock stopped; stove cold; table tidy; three hooks, **one oilskin left**; the slate; the log | Words; the lantern's glass (item) |
| 3 | Log vs slate | `sequence`: order the last readings | Log ends 13 Dec; slate runs to 9 a.m. 15 Dec | The day they vanished (word) |
| 4 | Oilskin hooks | `slotPlacement`: whose boots and oilskins are gone | Name tags on the hooks; the left oilskin's initials "D. McA." | Word "shirtsleeves"; clue: "they went down to a landing" |
| 5 | Oil store (dark) | **dark scene** + find | Lantern base + glass = hand lantern | Paraffin, matches |
| 6 | Dark stair | **dark scene**, find the key on its nail | — | Lamp-room key |
| 7 | Clockwork | **crank**: wind it | The clock face in the lamp room | The lens can turn |
| 8 | The lamp | use matches on the lamp; the light returns | — | The yard's path west is lit: the fallen rail can be seen and moved |
| 9 | West landing | examine evidence; **wipe** the salt from the rope-box plate (reveal) | "33 m above the sea" | Words: west landing, a great sea |
| 10 | The legend | read the magazine: the poem's chair and meal; the "log" copy | — | Decoy words (red herrings) |
| 11 | The jar's label | `deduction`, the truth vs the legend | All the above | The tale is distilled |
| 12 | Secret (optional) | a fourth hook with no name on it, in the dark stair | — | The keeper's note (draft) |

**The label** (draft):

1. "On {15 December 1900} the light went out; the last readings on the slate
   were taken at {9 a.m.}."
2. "{James Ducat} and {Thomas Marshall} went down to the {west landing} in
   their oilskins; {Donald McArthur} followed in his {shirtsleeves}."
3. "A {great sea} took all three. There was no {overturned chair}…"

Decoys: "overturned chair", "uneaten meal", "storm log", 13 December. The
third sentence is still open. Either the player only fills in the truth, or
also names the legend it replaces ("The {meal} and the {chair} were a
poem"). The first is simpler; the second plays up the "truth vs legend"
theme.

**Ending:** the lamp turns and throws its beam over the sea. The Hesperus
answers with her horn. "The Flannan light was lit that night by another
keeper. It has not missed a night since." (It was automated in 1971.) The
three names are the last thing on the label.

## Rework (2026-09-29)

Flannan keeps only its own mechanics: the dark scenes and the crank.
- **The gate** has a latch the player lifts; the plaque's date stays as
  a fact, not a code.
- **The rope-box plate** is read at once (no salt to wipe).
- **The jar's label** is a **correction** (form `correction`): it starts
  as the legend tells it. The day is 13 December, the Principal and
  his assistant are swapped, and the men are sent to the east landing.
  The player corrects four words.

## Puzzle flow (v2, 2026-09-30: longer, chained, shelf II)

The developer found v1 too thin for shelf II: only the crank and the label
were real puzzles. v2 follows Pompeii v2: eleven chained beats and three new
mechanics of Flannan's own, chosen by the developer ("ketiganya").

**New mechanics (Flannan only):**

- **The beam (`beamSweep`).** From the gallery round the lantern, the island
  lies dark and the relit beam turns over it. Things show only while the
  beam is on them: tap each then. The light the keepers kept is what shows
  the way to what happened.
- **The swell (`swell`).** The steps down the west landing, and the sea
  coming up them in sets. Before a great sea the water draws far back with
  a rising roar. Go down between the waves; caught, you are driven back up.
  Seen, heard and felt (vibration), so it plays with the sound off. The
  player feels the danger that took the three men; nothing of them is shown.
- **The roster (`roster`),** the height of the tale. Back at the kitchen
  hooks, each man's post, what he wore, and when he went, worked out from
  clues in three rooms: the log (the Principal signs; McArthur stands in
  for W. Ross), the hooks (one oilskin left; two pairs of seaboots gone),
  the landing (men sent down in a gale go together, dressed for the sea).
  Whoever left his coat in a gale went in a hurry, after the others.

| # | Beat | Type | Clue | Reward |
|---|---|---|---|---|
| 1 | The gate | tap (latch) | — | The yard |
| 2 | The kitchen | examine, combine | Log, slate, hooks, magazine; matches + lantern | Words; a lit lantern |
| 3 | The oil store | **dark scene** | — | The winding handle (paraffin is a red herring) |
| 4 | The stair | **dark scene** | — | The lamp-room key; the keeper's note (secret) |
| 5 | The clockwork | **crank** | — | The lens can turn |
| 6 | The lamp | use the lit lantern | — | The light is back |
| 7 | **The gallery** | **beamSweep**: the rail, the torn turf, the crane | Only while lit | The way west is seen |
| 8 | The yard | tap the path | The rail seen from above | The rail dragged aside |
| 9 | **The west landing** | **swell**: six steps, a great sea in ten waves | The water draws back before a big one | "a great sea"; the landing's evidence |
| 10 | **The hooks** | **roster**: post, wore, went | Log, hooks, landing | The three men set down |
| 11 | The seal | `deduction`, form `correction` | All the above | The tale is distilled |

**The seal** (form `correction`, one sentence, three words to correct):
"On {15 December 1900}, the sea at {the west landing} took all three;
{Donald McArthur} ran after the others in his shirtsleeves." It starts as
13 December, the east landing, Thomas Marshall. Decoys: the legend's chair,
meal and storm log, and every other word noted.

## Audio (ids)

- **Music:** `flannan_wind` (the sea, the wind, a low drone).
- **Effects:** `gate_latch`, `clock_tick`, `slate_chalk`, `lantern_light`,
  `clockwork_wind`, `lamp_light`, `ship_horn`, `wave_crash`, `page_turn`.

## Decisions (2026-09-26)

1. Jar label: **Flannan Isles, 1900**.
2. The legend is used **as red herrings only** (option 1): its words are
   decoys in the label, and the label states only the truth.
3. Both new mechanics are **approved**: dark scenes with the hand lantern, and
   the crank.
4. The relief keeper is called **"the relief"**; Joseph Moore is not named.
