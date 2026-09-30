# Episode design: Whitechapel, 1891 (the file of eleven)

Status: **built** (2026-09-30): draft text in seven languages, code-drawn
art (`lib/core/art/whitechapel_1891_art.dart`), generated audio,
walkthrough test. Approved by the developer with both mechanics, the
`docket` seal, and the newspaper name kept to the headline and the letter. Shelf III (opens after 4 tales), series *whitechapel*,
from the plan of 16 tales (`docs/stillroom_frame.md`, *The full shelf*).
It replaces the sealed teaser jar `sealed_whitechapel_1891`. Proposed id:
`whitechapel_1891`; jar label **Whitechapel, 1891**.

## Premise

Leman Street police station, H Division, Whitechapel, in the small hours of
**Friday 13 February 1891**. At 2.15 a.m. PC Ernest Thompson found a woman
under the railway arch between Swallow Gardens and Orman Street. He heard a
man's footsteps walking away, and stayed with her, as regulations said,
and blew his whistle. She was **Frances Coles**. The evening before, she
had bought a new black crêpe hat.

The newspapers will say *Jack the Ripper again*. The name came from a
letter sent to a news agency in 1888, which the police themselves came to
think a journalist's work. Later, a police memorandum of 1894 would say
the murderer had "5 victims & 5 victims only", and the world would
remember five. But the police file itself, the **Whitechapel Murders**
file, holds **eleven** women, from **Emma Smith** in April 1888 to Frances
Coles in February 1891.

The first Whitechapel jar kept the five names "in the small print". This
jar opens the whole file.

## Tone and guardrails

- **No violence shown, no bodies.** The arch is empty but for the hat and
  a constable's chalk. What happened is said once, plainly, in the
  occurrence book ("found dying"; no injuries described).
- **Honour the women:** their real names, dates and places, as the file
  gives them; nothing invented about their lives. The woman of Pinchin
  Street was never identified and is named only as *an unknown woman*.
- **The killer gets no name.** "Jack the Ripper" appears only as the
  newspapers' headline and the 1888 letter's signature, told as what the
  police thought of it. No suspect is named. James Sadler, charged and
  released for lack of evidence, is mentioned once, as the record has it.
- **Legends are red herrings:** "Jack the Ripper", "five victims only".
- **Invented props are stated as invented:** the compositor's forme and
  the jar's shelf of folders are the jar's own.

## Historical facts used (checked 2026-09-30)

| Fact | Used in | Source |
|---|---|---|
| The Metropolitan Police file known as the **Whitechapel Murders** covered **eleven** murders, **April 1888 to February 1891** | The file room; the seal | [Wikipedia: Whitechapel murders][wm]; [jack-the-ripper.org][jtro] |
| The eleven, in order: **Emma Smith** (attacked 3 April, died 4 April 1888); **Martha Tabram** (7 Aug 1888); **Mary Ann Nichols** (31 Aug); **Annie Chapman** (8 Sep); **Elizabeth Stride** and **Catherine Eddowes** (30 Sep); **Mary Jane Kelly** (9 Nov); **Rose Mylett** (20 Dec 1888, Poplar); **Alice McKenzie** (17 July 1889, Castle Alley); **an unknown woman**, Pinchin Street (Sept 1889); **Frances Coles** (13 Feb 1891) | The file (`unwatched`) | [wm]; [jtro]; [timeline][tl] |
| Frances Coles was found at about **2.15 a.m., 13 February 1891**, by **PC Ernest Thompson**, under the Great Eastern Railway arch from **Swallow Gardens** to Orman Street. He heard a man's **footsteps walking away**; she was still alive, so regulations kept him with her; he blew his **whistle**, and PCs Hyde and Hinton came | The occurrence book; the arch | [jtro Coles][coles]; [Casebook][cb] |
| The evening before, about **7.30 p.m.**, she bought a **black crêpe hat** at a milliner's at **25 Nottingham Street**; it lay beside her, her old hat pinned under her dress | The arch; the milliner's | [jtro Coles][coles]; [Casebook][cb] |
| **James Thomas Sadler**, a ship's fireman who had been with her, was charged on 16 February and later released: no evidence linked him | A paper in the station (decoy "Sadler") | [Wikipedia: Sadler][sadler]; [coles] |
| She was buried at **East London Cemetery, Plaistow**, on 25 February 1891 | The ending | [funeral][fun] |
| The **"Dear Boss"** letter, dated 25 Sept 1888, reached the **Central News Agency** on 27 Sept; it first used the name **"Jack the Ripper"**. Police officials came to think it a hoax by a journalist; DCI **Littlechild** (1913) called it "a smart piece of journalistic work" | The press room (decoy "Jack the Ripper") | [Wikipedia: Dear Boss letter][dear]; [Smithsonian][smith] |
| **Macnaghten**'s memorandum (23 Feb 1894): "the Whitechapel Murderer had 5 victims – & 5 victims only"; it became known in the late 1950s and set the "canonical five" | A later paper (decoy "five") | [jtro Macnaghten][mac]; [Wikipedia: Jack the Ripper][jtr] |

Wikipedia could not be opened from the build environment; facts above
were checked across at least two search results. The Pinchin Street date
(10 September 1889) was checked again before building; Frances Coles's age
varies between sources and is not given in the tale.

[wm]: https://en.wikipedia.org/wiki/Whitechapel_murders
[jtro]: https://www.jack-the-ripper.org/victims-of-jack-the-ripper.htm
[tl]: https://www.jack-the-ripper.org/timeline.htm
[coles]: https://www.jack-the-ripper.org/frances-coles.htm
[cb]: https://www.casebook.org/victims/coles.html
[sadler]: https://en.wikipedia.org/wiki/James_Thomas_Sadler
[fun]: https://www.jack-the-ripper-tour.com/generalnews/the-funeral-of-frances-coles/
[dear]: https://en.wikipedia.org/wiki/Dear_Boss_letter
[smith]: https://www.smithsonianmag.com/smart-news/were-ripper-letters-fabricated-journalists-180968004/
[mac]: https://www.jack-the-ripper.org/macnaghten.htm
[jtr]: https://en.wikipedia.org/wiki/Jack_the_Ripper

## Map

```
 file_room ─ leman_street (start) ─ swallow_gardens ─ milliner
                    │
               press_room (a newspaper's composing room, that night)
```

| Scene | What's there |
|---|---|
| `leman_street` (start) | The front office of H Division at 3 a.m.: the occurrence book with PC Thompson's entry, a gas lamp, the door to the file room, the street door; later, the seal |
| `swallow_gardens` | The railway arch, wet cobbles, a gas lamp; a constable's chalk; the black crêpe hat; the footsteps heard once |
| `milliner` | 25 Nottingham Street, shuttered; through the door, the counter, hat boxes, the order book: a black crêpe hat, sold at half past seven |
| `press_room` | A newspaper's composing room at night: the forme of the morning's front page, the type case, a copy of the 1888 letter on a spike |
| `file_room` | Shelves, a lamp, and the Whitechapel Murders file, which grows when no one is looking |

## New mechanics (Whitechapel 1891 only)

- **The file that grows (`unwatched`),** the height of the tale, and the
  frame's long-planned **E: a room that changes when not watched**. A shelf
  of folders, each a woman's name and date. Turn away (the lamp gutters,
  the screen goes dark a moment) and back: something on the shelf has
  changed. Tap what changed. Each round adds one of the six women the
  "five" leave out, in the order the file grew, and the later rounds
  shuffle other folders too, so the eye must really check. After *Rusty
  Lake*'s rooms that shift, and tied to the fact itself: the file kept
  growing, for three years.
- **Setting her name (`compose`).** The compositor's forme for the
  morning's front page has the headline set: *JACK THE RIPPER AGAIN?*, and
  her name nowhere. Set her name instead, letter by letter, from a type
  case where every letter is cut **in mirror**, as real type is: И for N,
  Ǝ for E, and letters that turn into others (p and q, b and d). The sorts
  go into the composing stick; a proof shows the line the right way round.
  Tactile, after *The Room*; tied to how a name was made in print.

## Puzzle flow (11 beats)

| # | Beat | Type | Clue | Reward |
|---|---|---|---|---|
| 1 | Leman Street | read | The occurrence book: 2.15 a.m., Swallow Gardens, footsteps, the whistle | Words (Frances Coles, Swallow Gardens) |
| 2 | Swallow Gardens | read, take | The arch; the chalk; the new hat, a milliner's ticket in its band | The hat's ticket (item) |
| 3 | The milliner's | use | The ticket against the shop's order book: sold the evening before | Words (7.30 p.m.); a man paid (Sadler, decoy) |
| 4 | Leman Street | read | A charge sheet: Sadler, charged and released | Decoy word |
| 5 | The press room | read | The 1888 letter on the spike; Littlechild's line (a later paper) | Decoy "Jack the Ripper" |
| 6 | **Her name** | **compose** | The headline without her; the mirrored case | Her name set in type |
| 7 | The file room | read | The file's docket: Whitechapel Murders, opened April 1888 | Word (Emma Smith) |
| 8 | **The file** | **unwatched** (6 rounds) | Each look away adds a folder | Words (eleven; the six names) |
| 9 | The file room | read | Macnaghten 1894, "5 victims only" (a later paper) | Decoy "five" |
| 10 | The seal | `deduction`, a new form | All the above | The tale is distilled |
| — | Secret | read twice | The file's docket, after the file is whole | The keeper's note |

## The seal

A new form, **`docket`**: the cover sheet of a police file, printed
headings, a register stamp, and the entry written in by hand.

"From {Emma Smith} to {Frances Coles}, the file holds {eleven} women."

Decoys: five, Mary Jane Kelly, Mary Ann Nichols, Jack the Ripper, Sadler,
1894.

**Ending:** "Frances Coles was buried at East London Cemetery on 25
February 1891. The file was never closed, and the eleven were never
counted as five in it. The name the newspapers gave the killer came from a
letter the police thought a journalist wrote." Then the keeper's line, if
found.

## Echoes and living things

- **Echoes:** a constable with a lantern at the arch (the 1888 figure);
  a compositor at the case. Faceless, as always. No woman is shown.
- **Living things (February night):** a rat under the arch; moths by the
  gas in the station and the file room.

## Audio

- **Music:** `whitechapel_1891` (a colder return of *whitechapel_fog*:
  drone, rain, a train over the arch once a loop).
- **Effects:** `footsteps_away`, `police_whistle`, `train_arch`.
  Interface: `type_sort`, `lamp_gutter`.

## Decisions (2026-09-30)

1. Both mechanics: the file that grows (`unwatched`), her name set in type
   (`compose`).
2. The seal on the file's cover (`docket`), with the sentence above.
3. "Jack the Ripper" appears only as the forme's headline and the 1888
   letter's signature, told as the police saw it.

## As built

- **Flow:** the occurrence book; the arch (the hat's ticket); the
  milliner's; a reporter's cab from the arch to the composing room
  (`compose`); back at Leman Street the charge sheet (a later paper) and the
  file room, now open (`unwatched`, six rounds); Macnaghten's memorandum;
  the seal on the occurrence book. The keeper's slip is inside the file's
  cover once the file is whole.
- **The shelf's rounds:** Smith and Tabram go in before the five; from the
  third round on, one other file moves each time (and moves back the
  next), so the eye must really check. The shelf ends in date order.
- **The type case:** R, N, C, S and L each have a wrongly cut twin; P, D
  and B are extra sorts.
- **Shelf III** now shows this jar and a sealed teaser
  (`sealed_guangxu_1908`) for the tales still to come.

## Things to watch when tested

- Whether the new file is found fairly on the phone, especially when
  another file has moved; and whether the dark while looking away is too
  long or too short (900 ms).
- Whether the mirrored letters in the type case are clear at phone size.
- Whether the chain from the milliner's to the composing room (the cab at
  the arch) is found without hints.
