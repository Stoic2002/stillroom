# Episode design: The Stillroom (the keeper's own tale)

Status: **built** (2026-10-08): draft text, code-drawn art in depth. Shelf V,
the last jar of the 16, opens after 15 tales are distilled. It replaces
the sealed jar `sealed_keeper`. Proposed id `stillroom_keeper`; jar label
**The Stillroom** (no place, no year: the room is outside time).

The developer chose the recommended shape (the keeper's own room as the
last tale, the 15 secret notes not required) and asked for the keeper
**to have a face**: faceless is "kurang wah". So the keeper is an
**invented person**, stated as invented, and the height of the tale is
her face and her name coming back. She is not an echo of a real person,
so the faceless rule (decision 5) does not bind her.

## Premise

Every jar so far kept someone's name that the world had dropped or
spelled wrong: the five women in Whitechapel's small print, the four
founders on the Emille bell, Eustache Dauger lost twice, the eleven in
the file, the empty space where a murderer's name should be. The notes
were in one careful hand and never signed.

The **legend** of the room, told by its own things: the old keeper was a
witch or an alchemist who caught souls in jars; a collector of dark
tales; a ghost who walks the shelves. Each is a red herring, in the
spirit of every other jar.

What the player finds: the keeper was **a stillroom maid** in a country
house, about **1720**: the servant who worked the household's still,
made the cordials and the rosewater, and wrote the receipts in the
house's book. Servants of her kind were mostly written down by their
place, not their name ("the stillroom maid", "the girl"). She came to
this room the way the player did, and became its keeper; and the room's
price is the keeper's own name and face. She kept everyone else's.

The last jar is the player doing for her what she did for all of them:
her face found under the paint, her hand found in the book, her name
written back. Then she can go, and the player takes the coat from the
fourth hook.

## Tone and guardrails

- **She is invented**, and the tale says so in its ending text and in
  the credits note: "Hester Croft is not a historical person; her work
  was real work, done by many whose names are lost."
- **No real person is given words or deeds.** The real things are the
  craft: the stillroom, the receipt books, the still, and how a painting
  is looked through.
- **The legends are red herrings:** witch, alchemist, soul-catcher, a
  collector of horrors, a ghost.
- **No horror at the end.** The tone turns from mystery to warmth: the
  first face in the game, lit, turning to the player, and going.

## Real things used (to be checked with sources before building)

| Fact | Used in | Source (to cite) |
|---|---|---|
| Country houses of the 17th–18th centuries had a still-room where cordials, waters and preserves were distilled and made; a still-room maid worked it | The room, the maid | Social histories of the country house (e.g. Mark Girouard, *Life in the English Country House*, 1978) |
| Households kept handwritten receipt books, added to over years in several hands | The book, `hands` | Elinor Fettiplace's receipt book (1604, ed. Hilary Spurling, 1986); Hannah Woolley, *The Queen-Like Closet* (1670) |
| In distilling, the first runnings ("heads") and the last ("tails") are set aside; the middle cut ("heart") is kept | `still` | Any distilling manual; period texts on "simple" waters |
| Aged natural varnish glows greenish under ultraviolet light; later retouching shows dark on it | `spectrum` | National Gallery Technical Bulletin; museum conservation guides |
| Infrared reflectography sees through paint to a carbon underdrawing | `spectrum` | Same |
| X-radiography shows lead white, so an earlier picture painted over shows through | `spectrum` | Same |
| Servants often appear in household accounts by their post, not their name | The premise | Social histories of service (to confirm wording) |

## Where it is set

Behind the shelves: the jar opens onto the far side of the room the
player has stood in all game, and a door to the keeper's own rooms. The
art keeps the lobby's palette (walnut, brass, candle light) and is drawn
in depth (decision 6).

## Map

```
         the study (the portrait, the fourth hook)
                    │
 behind the shelves (start) ─ the stillroom (the still, the book)
                    │
              the window (the view through all 15 places)
```

| Scene | What's there |
|---|---|
| `behind` (start) | The backs of the 15 sealed jars glowing on their shelves; a low door with a lock of wax seals |
| `stillroom` | The copper still over its little furnace, the worm tub, herb bunches drying from a rack, rows of stoppered bottles, the receipt book open on the bench |
| `study` | A small desk with the drafts of every note; a portrait in an oval frame whose face is scraped and darkened; a coat rack with four hooks, a coat on the fourth |
| `window` | A tall window whose view changes as it is turned: each of the 15 places in its turn (Gorogoa-like), and one view no jar has shown: a house in an English garden |

## New mechanics (this tale only)

- **The book's hands (`hands`).** The household's receipt book, written
  over years by four hands: the mistress, the cook, the steward, and one
  more. Each hand has its tells (how it makes its g, its long s, its
  ampersand). Sort the receipts by hand; the fourth hand is the one in
  all 15 keeper's notes (the player can lay a note beside the page). Her
  receipts are the stillroom's; at the foot of the last, the one place
  she signed, a name rubbed out by the house: only its first letters
  left. Unlike `margins` (turning a sheet) or `compose` (setting type):
  this is reading a person in their letters.
- **The still (`still`).** The height of the stillroom. Feed the fire,
  run the cooling water, watch the drip. The first runnings come cloudy
  and sharp (heads), the middle clear and sweet (the heart), the last
  oily and heavy (tails); switch the receiver at the right moments. Too
  hot and it all comes over at once; too cold and nothing runs. The
  heart is the clean spirit the portrait needs. The game's own word made
  a mechanic: to distil is to keep the heart and set the rest aside.
- **Looking through the portrait (`spectrum`).** The height of the tale.
  A conservator's lamp tuned through its bands: ultraviolet shows the old
  varnish glowing and the dark patches where someone painted over; the
  visible band shows the scraped, grimed face; infrared reaches the
  painter's drawing underneath and the letters of a name written in it;
  X-ray shows the face as it was first painted, in lead white. Clean the
  grime with the spirit from the still, then tune each band to bring up
  its layer and lay the layers together: the face comes back. Unlike
  `rakingLight` (one lamp's angle) or `reveal` (wiping): a set of ways of
  seeing, each showing a different time in the painting's life.

## Puzzle flow (12 beats)

| # | Beat | Type | Clue | Reward |
|---|---|---|---|---|
| 1 | Behind the shelves | read | The jars from behind; the door's lock, a wax seal for each distilled tale | The door opens |
| 2 | The study | read | The drafts of every note; the scraped portrait; the coat on the fourth hook (Flannan's note: "I hung my coat here once") | — |
| 3 | The window | read | The view turned through the 15 places; the last view, a house | Decoys (alchemist, witch) |
| 4 | The stillroom | read | The still cold; the receipt book | — |
| 5 | The stillroom | **hands** | The book's four hands, a note laid beside it | Word (stillroom), first letters of a name |
| 6 | The study | read | A tinder box in the coat pocket | Item |
| 7 | The stillroom | **still** | The fire, the water, the drip | Item: the heart, clean spirit |
| 8 | The study | use | The spirit on the portrait's grime | — |
| 9 | The study | **spectrum** | The four bands | Her face; Word (her name) |
| 10 | The window | read | The house in the garden, now with her at its stillroom window | Word (her own name, given up) |
| 11 | The seal | `deduction`, a new form | All the above | — |
| 12 | The end | scene | She turns, faces the player, and goes; the coat is left on the hook | The game's ending |
| — | Stars | read | Each keeper's star found adds one line to her story in the study | Optional |

## The seal

A new form, **`receipt`**: a page of the household receipt book, its
heading and a short receipt in her hand, the blanks in the lines.

"Her name was {Hester Croft}; she kept their names in the {stillroom},
and gave up {her own} to do it."

Decoys: a witch, an alchemist, a ghost, a collector, "the girl".

**Ending:** "The keeper of the Stillroom was a servant whose name the
house did not write down. She kept every name it let fall. Now someone
keeps hers." Then the credits note on her being invented.

## The face

The first face in the game. Drawn in code like everything else, but
with more care than any echo: a half-length portrait in an oval, a plain
cap and a dark bodice, candle light from one side, the eyes looking out.
In beat 12 the portrait's sitter is seen once more as a figure in the
study (not an echo: warm colour, a face), turning to the player before
she fades. A render goes to the developer before the rest is built.

## Echoes and living things

- **Echoes:** none of real people in this jar. Her figure appears only
  at the end, with a face.
- **Living things:** a moth at the candle (exists), a cat asleep by the
  furnace (a new creature, `cat`), bees at the herbs in the window's
  garden view.

## Audio (ids, to generate)

- **Music:** `keeper_room` (the lobby's theme, slowed, a music box
  under it; at the end it resolves).
- **Effects:** `still_drip` (drops into a glass), `fire_feed` (charcoal
  fed to a small furnace), `lamp_band` (a hum shifting pitch as the
  lamp is tuned). Interface: `hand_sorted`, `layer_found`.

## Decisions (2026-10-08)

The developer took every recommendation:

1. Her name **Hester Croft** (invented).
2. An English country house, about **1720**.
3. **No map pin**: the room is outside time.
4. The three mechanics (`hands`, `still`, `spectrum`) and the `receipt`
   seal as above.
5. The ending: **she goes**, and the player takes her coat from the
   fourth hook.

The developer also said that people and living things drawn only as
shapeless extras make a game feel thin. The portrait is drafted in
`lib/core/art/keeper_art.dart`, and a figure kit for echoes with bodies
and faces in `lib/core/art/figure_kit.dart`. A sample was sent for
approval before all the echoes are redrawn.

## As built

- **Map:** behind the shelves (start) opens through the low arch on the
  left to the stillroom, and, once the lock is read, through the door on
  the right to the study; the study's window (left) is its own view.
- **Flow:** behind the shelves the jars from behind, the chapbook (*a
  witch*, *an alchemist*, *a ghost*), the lock of broken seals (the door
  opens). In the study the drafts of every note, the scraped portrait,
  the coat on the fourth peg (a tinder box), and its lining: the
  keeper's secret, a slip in an older hand. At the window the view is
  turned by its brass ring through the 15 tales in shelf order; the
  16th, a house at dusk, is read only once she has gone. In the
  stillroom the receipt book (`hands`, gives *stillroom* and *the
  girl*); the tinder on the cold furnace; the still (`still`, gives the
  spirit). The spirit on the portrait cleans it; the lamp by the easel
  (`spectrum`, gives *Hester Croft*). She stands by the coat rack, looks
  at the portrait and at the player, touches the coat and goes. The
  window's last view then shows her at the lit stillroom window (*her
  own*). The seal is the blank page at the end of her book.
- **The hands:** four hands (the mistress, the cook, the steward, the
  hand of the notes), nine receipts; eight lack one letter (no "and", no
  long s, no g), so the slant and the letters left must be read. Her
  receipts are rosewater, the cordial and the lavender water.
- **The still:** heads 2, heart 8, tails 3 measures; gentle 0.8 and
  fierce 2.0 measures a second; at a fierce fire the cuts smear (blur
  3.0) and the heart is lost; four seconds lit with no water spoils the
  run. Kept: 80% of the heart in its glass, at most 0.6 of the rest.
- **The lamp:** ultraviolet (0.14: the varnish glows, the scraped face a
  dark patch), visible (0.38: as it is now), infrared (0.63: the first
  lines and the name written in them), X-ray (0.86: the face in lead
  white); laid oldest first: infrared, X-ray, ultraviolet, visible.
- **Her letters (stars):** each 3 keeper's notes found in other jars
  (`stars_3` … `stars_15`) put one more letter of hers on the study's
  desk. Not needed to finish.
- **Words:** *Hester Croft*, *stillroom*, *her own* (the answers); *a
  witch*, *an alchemist*, *a ghost*, *the girl* (decoys).
- **Figures:** her portrait in six looks (`PortraitLook`); she herself in
  the study at the end, warm and with a face (`hester`), not an echo.
  **Living things:** a moth at the candle, a cat asleep by the furnace
  (`cat`).
- **Audio:** music `keeper_room`; effects `cloth`, `candle_gutter`,
  `window_turn`, `fire_feed`, `still_drip`, `layer_settle`, `cat_purr`;
  interface `hand_sorted`, `glass_move`, `layer_found`. (`lamp_band`
  from the draft was not made: the lamp uses `layer_found`.)

## Things to watch when tested

- Whether the hands read at phone size, and whether receipts lacking a
  letter feel fair (the slant must be seen).
- The still's timing: whether a gentle fire with the glass moved on the
  drip's colour feels right without the hint, and whether a spoiled or
  lost run explains itself.
- The lamp: whether the bands are found on the dial without hunting, and
  whether "oldest first" is clear from the captions.
- The window: 16 views turned one by one may feel long; whether the
  ring is found, and whether the last view after she goes is noticed.
- The ending's tone: her face and her going should land warm, not eerie.
  Whether the credits note on her being invented is seen.
- The stars letters: whether a player with few notes misses nothing
  needed, and whether those with many find the letters.
- The jar on shelf V opens only after 15 tales; check with
  `STILLROOM_UNLOCK_ALL`.
