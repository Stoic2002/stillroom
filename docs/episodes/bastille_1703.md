# Episode design: Bastille, 1703 (the man in the mask)

Status: **design draft** (2026-09-30), for the developer's approval before
anything is built. Shelf II, Western Europe, from the plan of 16 tales
(`docs/stillroom_frame.md`, *The full shelf*). Proposed id:
`bastille_1703`; jar label **Bastille, 1703**.

## Premise

The Bastille, Paris, at the grey dawn of **20 November 1703**. Last night a
prisoner died in the third chamber of the Bertaudière tower. Today he will
be buried at Saint-Paul under a name that is not his. For thirty-four years
he was moved from fortress to fortress by the same jailer, and whenever he
could be seen, his face was covered.

Legend gave him an **iron mask** and made him the **king's twin**. The
record is smaller and stranger: the mask was **black velvet**, and the
letters that sent him to prison in 1669 call him **Eustache Dauger**,
"only a valet". Who he was, and why he was hidden, no one knows. The
keeper cannot give him a face. The keeper can give him back what the
record holds: the name in the letters, the cloth of his mask, and the name
he was buried under.

Why it fits the Stillroom: a man whose face was taken from him, written
into a register under the wrong name. Like Whitechapel, the tale is about
a name. Unlike Whitechapel, the answer is that no one knows, and the tale
says so.

## Tone and guardrails

- **Horror through atmosphere:** stone stairs, doors behind doors, a cold
  cell being emptied, the bell of Saint-Paul. **No violence, no body.** The
  prisoner has died; he is never shown, only a faceless **echo** at the
  cell window (echoes are faceless; this one is also masked).
- **Honour the man:** only what the record says. No invented face,
  history, crime, or last words. The tale never says who he "really" was.
- **Legends are red herrings:** the iron mask, the royal twin, General
  Bulonde (a codebreaker's guess), and Mattioli (the burial name read as
  his). They arrive as papers that should not be here yet, as Flannan's
  1912 magazine does.
- **Invented props are stated as invented:** the jar supplies a copy of
  Bazeries's 1893 worksheet (the key to the Great Cipher) and the later
  books. Their contents are real; their being in the Bastille in 1703 is
  the jar's doing.

## Historical facts used (checked 2026-09-30)

| Fact | Used in | Source |
|---|---|---|
| On **19 July 1669** Louvois wrote to **Bénigne Dauvergne de Saint-Mars**, governor of Pignerol, that a prisoner named **Eustache Dauger** was coming; being "only a **valet**", he needed little furniture | The 1669 letter (governor's office) | [Wikipedia: Man in the Iron Mask][wiki]; [Early Modern France, *The Valet*][emf] |
| Dauger was arrested near Calais on 28 July 1669 and held for **34 years** by Saint-Mars in four prisons: **Pignerol** (1669–1681), **Exilles** (1681–1687), **Île Sainte-Marguerite** (1687–1698), the **Bastille** (1698–1703) | The file; hints | [wiki]; [search summary][hh] |
| Louvois ordered isolation and silence: he was to be threatened with death if he spoke of anything but his needs; his cell to have **several doors** so he could not be heard | The doors (keyring); the 1669 letter | [wiki]; [emf] |
| From 1675 he was allowed to serve **Fouquet** at Pignerol as a valet, on strict conditions | The file (a card) | [wiki] |
| In 1687 he was carried to Sainte-Marguerite in a **sedan chair covered with oilcloth**, a twelve-day journey that nearly killed him; rumours of a mask began on that journey | The file (a card) | [The Dark Atlas][darkatlas]; [wiki] |
| **18 September 1698**: Saint-Mars arrived to govern the Bastille, bringing him. The King's lieutenant **Étienne du Junca** wrote in his journal that the prisoner was always masked, in **black velvet**. He was put in the **third chamber of the Bertaudière tower** | Du Junca's room; the cell | [wiki]; [search summary][bert] |
| He died on **19 November 1703**; buried at **Saint-Paul** the next day under the name **"Marchioly"**, aged "about 45" | The Saint-Paul register | [wiki]; [search summary][burial] |
| Later accounts say his things were burned and his cell scraped and whitewashed | The cell (told as "later accounts say") | [search summary][bert] |
| **Voltaire** first called the mask iron (letter to the abbé Dubos, 1738; *Le Siècle de Louis XIV*, 1751) | A later paper (decoy "iron") | [search summary][burial]; [CrimeReads][crimereads] |
| **Dumas**, *Le Vicomte de Bragelonne* (1847–1850), made him Louis XIV's **twin** | A later paper (decoy "twin") | [search summary][burial] |
| The **Great Cipher** of the Rossignols used numbers for syllables; **Étienne Bazeries** broke it about **1893**, starting from *les ennemis* (124-22-125-46-345) | The cipher puzzle | [Wikipedia: Great Cipher][gc]; [Cipher Museum][cm] |
| Bazeries read Louvois's 1691 letter to Catinat: arrest **General Bulonde** (who lifted the siege of Cuneo) and take him to Pignerol, to walk the battlements by day "with a **330 309**". Those two groups appear only once; Bazeries guessed *masque*. No known variant of the cipher had that word | The cipher puzzle's gap (decoy "Bulonde") | [gc]; [Gizmodo][giz] |
| Bulonde was held at Pignerol from **10 July 1691**, released **11 December 1691**, and died in **1709**, after the masked man | The file (a card) | [search summary][bul] |
| **Mattioli**, another candidate (the burial name looks like his), died on Sainte-Marguerite in **April 1694** | Saint-Paul (decoy "Mattioli") | [search summary][bul] |

Before building, the dates are checked once more against a second source
where the first was only a search summary (Wikipedia and Britannica could
not be opened from the build environment).

[wiki]: https://en.wikipedia.org/wiki/Man_in_the_Iron_Mask
[emf]: https://earlymodernfrance.org/journal/2016-volume-xvii/valet-marquis-louvois%E2%80%99s-invited-guest-mystery-man-iron-mask
[hh]: https://www.historyhit.com/facts-about-the-man-in-the-iron-mask/
[darkatlas]: https://thedarkatlas.com/posts/ile-sainte-marguerite-iron-mask-prison
[bert]: https://www.nationalgeographic.com/history/history-magazine/article/who-was-the-man-in-the-iron-mask-dumas
[burial]: https://en.wikisource.org/wiki/1911_Encyclop%C3%A6dia_Britannica/Iron_Mask
[crimereads]: https://crimereads.com/voltaire-man-in-the-iron-mask/
[gc]: https://en.wikipedia.org/wiki/Great_Cipher
[cm]: https://ciphermuseum.com/ciphers/great-cipher.html
[giz]: https://gizmodo.com/how-a-cryptoanalyst-discovered-the-identity-of-the-man-1581576707
[bul]: https://www.todayifoundout.com/index.php/2014/10/real-man-iron-mask/

## Map

```
            cell (third chamber of the Bertaudière)
               │  two doors (keyring)
            tower_stair
               │
 junca_room ─ courtyard (start) ─ governor_office
               │
            saint_paul (the parish vestry, across the street)
```

| Scene | What's there |
|---|---|
| `courtyard` (start) | The inner court at dawn, towers, the Bertaudière door, the turnkey's ring of keys on its nail, a cart, pigeons on the gutters |
| `junca_room` | Du Junca's desk, his journal open at 1703, a later paper (Bazeries's worksheet) |
| `governor_office` | Saint-Mars's desk, Louvois's letters (1669 plain, 1691 in cipher), the prisoner's file |
| `tower_stair` | A winding stone stair, two locked doors one above the other, a rat on the steps |
| `cell` | Third chamber: stripped bed, table, barred window; the black velvet mask on the table; a later book (Voltaire); the echo at the window |
| `saint_paul` | The vestry at Saint-Paul: the burial register being written, a candle, Dumas's novel left on a pew (a later paper) |

## New mechanics (Bastille only)

- **The key ring (`keyring`).** A turnkey's ring of many keys and a lock
  seen from the front. Each key's bit has its own wards (notches); the
  keyhole shows the shape the bit must match. Pick a key and turn it the
  right way up to its silhouette. Two doors, the second with more keys and
  keys that only fit one way round. After *Her Trees* (silhouettes) and
  *The Room* (tactile locks), tied to the fact of the doors behind doors.
- **The Great Cipher (`cipher`).** A letter written in groups of numbers,
  and a key that gives syllables for most of them. Drag each syllable
  from the key onto its number until the letter reads. One group,
  **330 309**, is in no key: the player sees for themself that "mask" was
  only ever a guess.
- **The file (`sources`),** the height of the tale. Every paper about the
  prisoner as cards: who wrote it, when, and what it says. Sort them into
  two trays, *seen at the time* and *told afterwards*, working out
  undated cards from what they say (a novelist born in 1802 cannot have
  seen him). Once sorted, the tray of the record says nothing of iron or
  of a twin.

## Puzzle flow (11 beats)

| # | Beat | Type | Clue | Reward |
|---|---|---|---|---|
| 1 | The courtyard | pick up | The ring hangs by the tower door | The turnkey's keys |
| 2 | Du Junca's room | read | His journal: 1698, black velvet, always masked; 19 November 1703 | Words; Bazeries's worksheet (the key) |
| 3 | The governor's office | read | Louvois, 19 July 1669: Eustache Dauger, only a valet, silence | Words; the 1691 letter in cipher |
| 4 | **The first door** | **keyring** (four keys) | The keyhole's shape | The stair |
| 5 | **The second door** | **keyring** (six keys, one way round) | The same | The cell |
| 6 | The cell | read, take | The black velvet mask on the table (light, soft: not iron); Voltaire's book: iron | Words (black velvet; iron is a decoy) |
| 7 | **The 1691 letter** | **cipher** | Bazeries's worksheet | Bulonde, and the gap: 330 309 |
| 8 | Saint-Paul | read | The register: "Marchioly", about 45; Dumas's novel: the twin | Words (Marchioly; twin, Mattioli are decoys) |
| 9 | **The file** | **sources** | Every paper found | The record, cleared of legend |
| 10 | The seal | `deduction`, a new form | All the above | The tale is distilled |
| — | Secret | read twice | Du Junca's journal, after the file | The keeper's note |

## The seal

A new form, **`order`**: a royal order under the king's seal (*De par le
Roy*), the kind that sent men to the Bastille, written this once for him.

"The prisoner in the {black velvet} mask, buried as {Marchioly}, is the man
the letters call {Eustache Dauger}."

Decoys: iron, the king's twin, Bulonde, Mattioli, 1669, 1698, a valet.

**Ending:** the bell of Saint-Paul. "He was buried that afternoon. Who he
was, and why his face was hidden for thirty-four years, no one knows. The
letters called him Eustache Dauger. His mask was black velvet."

## Echoes and living things

- **Echoes:** the prisoner at the cell window (faceless, masked, gone when
  approached); a turnkey with a lantern on the stair.
- **Living things (Paris, November):** pigeons on the gutters, a rat on
  the stair, crows over Saint-Paul's churchyard.

## Audio (ids, to generate)

- **Music:** `bastille_dawn` (a low drone, far bells, wind in the towers).
- **Effects:** `key_turn`, `lock_open`, `door_heavy`, `bell_saint_paul`,
  `quill`. Interface: `key_try` (a key tried in a lock that does not turn).

## Open questions for the developer

1. The three mechanics (keyring, cipher, the file): all three?
2. The seal as a royal order (`order`), and its sentence?
3. The ending's wording, and whether Voltaire, Dumas and Bazeries appear
   by name (recommended: yes, as authors of the later papers).
