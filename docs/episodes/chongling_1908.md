# Episode design: Chongling, 1908 (the death of the Guangxu Emperor)

Status: **built** (2026-09-30): draft text in seven languages, code-drawn
art (`lib/core/art/chongling_1908_art.dart`), generated audio, walkthrough
test. Approved by the developer with setting B, both mechanics, and the
`vermilion` seal leaving the hand unknown. Shelf III (opens after 4
tales), China, from the plan of 16 tales (`docs/stillroom_frame.md`, *The
full shelf*). It replaces the sealed teaser `sealed_guangxu_1908`; the
teaser on shelf III is now `sealed_alamut_1256`. Id: `chongling_1908`; jar
label **Beijing, 1908**, its map pin at Zhongnanhai.

## Premise

The Guangxu Emperor died on **14 November 1908**, aged 38, in the Hanyuan
Hall on **Yingtai**, the island in the palace lake where he had been kept
since the failed reforms of 1898. The Empress Dowager **Cixi** died the
next day. The court announced that he had died of a long **illness**, and
the physicians' records had spoken of illness for months.

A hundred years later the record changed. His tomb, **Chongling**, had been
robbed in **1938**; in **1980** the crypt was cleared and a chemical test of
his hair and a bone found no poison. From **2003** to **2008** a team
(the Qing Western Tombs office, the China Institute of Atomic Energy, and
the Beijing police forensic centre) tested his hair segment by segment by
neutron activation, and his robes by X-ray fluorescence. They found
**arsenic**, a lethal dose, concentrated about the stomach, the collar and
the shoulders, the inner clothes more than the outer. In November 2008 it
was announced that he died of **acute arsenic poisoning**.

**Who gave it is not known.** Cixi is the suspect most named; Yuan Shikai
and the eunuch Li Lianying are others. No record says. Some historians
still dispute the reading of the tests. The keeper's jar holds what is
known, and no more: not illness; arsenic; and an empty space where a name
would be.

## Tone and guardrails

- **No body, no remains shown.** The coffin stays closed. Hair appears
  only as sealed sample tubes; the robes as folded cloth in archive boxes.
  Nothing of the poisoning is described beyond the physician's own words
  (pain, a dark face).
- **No one is accused.** Cixi, Yuan Shikai and Li Lianying appear only as
  the names rumour gives, in a later paper, and the seal leaves the hand
  unknown.
- **The dispute is stated.** The 1980 test (no poison) and the doubts of
  some historians are told as part of the record.
- **Living scientists are not named or shown;** the team appears as
  faceless echoes and as the institutions that signed the report.
- **Legends are red herrings:** "died of illness", "Cixi did it".

## Historical facts used (checked 2026-09-30)

| Fact | Used in | Source |
|---|---|---|
| The Guangxu Emperor died on **14 November 1908** (Guangxu 34, 10th month, 21st day), aged 38, in the **Hanyuan Hall on Yingtai**, Zhongnanhai, where he had been held since **1898**; **Cixi** died on 15 November | The court papers | [Wikipedia: Guangxu Emperor][gx]; [zh.wikipedia][zhgx] |
| The court said he died of illness; physicians' records through 1908 describe a long illness ("no effect after long treatment") | The court's announcement, the physicians' records (the legend: "illness") | [ABC Science][abc]; [chinanews 2008][cn] |
| Dr **Qu Guiting** later wrote that three days before the death the emperor rolled in bed with **stomach pain**, his face dark and tongue yellow-black, "unrelated to his previous illness" | A later paper (Qu's memoir) | [QQ news][qq]; [zh.wikipedia][zhgx] |
| **Chongling** was looted in **1938**: the coffin was axed open and grave goods taken | The crypt | [CCTV][cctv]; [chinanews][cns] |
| In **June 1980** the crypt was cleared; a chemical test of the vertebrae and hair **found no poison** | A later paper (decoy "1980") | [Sina][sina1980] |
| From **2003**, two strands of hair (26 cm and about 65 cm) were cut into **1 cm segments** and measured by **neutron activation** at the China Institute of Atomic Energy's micro-reactor; arsenic varied sharply between segments, unlike chronic poisoning. The first strand peaked at its **10th segment, 2404 µg/g**; the second at its 26th (362.7 µg/g) and 45th (202.1 µg/g); the roots read lower than the middle and tips. The hair read 261 times Empress Longyu's and 132 times a Qing official's | The hair (`strand`) | [Aisixiang: team report][report]; [Sina][sina]; [Sina 2008-11-03][sina2]; [Guangming Daily][gmw] |
| Robes and remains were tested by **X-ray fluorescence** and other methods; arsenic was highest about the **stomach**, the **collar** and the **shoulders**, **inner garments more than outer** | The robe (`scan`) | [People's Daily][people]; [Sina][sina] |
| About **201.5 mg** of arsenic in the hair, the inner clothes and residues alone; **60–200 mg** kills | The report | [abc]; [Sina][sina] |
| **November 2008**: acute arsenic poisoning announced by the Qing history committee and the team (CCTV, CIAE, Beijing police forensic centre) | The report | [abc]; [CNN][cnn] |
| **Who** is unknown; Cixi, Yuan Shikai, Li Lianying are named by rumour and argument; some historians (e.g. Fang Delin) dispute the tests' reading | A later paper; the seal | [Sohu][sohu]; [Zhihu: Fang Delin][fang] |

Wikipedia could not be opened from the build environment; the facts above
were checked across at least two search results each. The segment peaks
were checked again before building. The game's strands are 14 segments
each, shaped after the report: strand I peaks at its 10th segment at
2404; strand II keeps the second strand's two peaks (363, then 202) close
together. The other readings are the game's own and are not presented as
the report's figures.

[gx]: https://en.wikipedia.org/wiki/Guangxu_Emperor
[zhgx]: https://zh.wikipedia.org/zh-hans/%E5%85%89%E7%BB%AA%E5%B8%9D
[abc]: https://www.abc.net.au/science/articles/2008/11/03/2408428.htm
[cn]: https://www.chinanews.com.cn/cul/news/2008/11-18/1454032.shtml
[qq]: https://news.qq.com/rain/a/20231202A01WPR00
[cctv]: https://news.cctv.com/china/20081202/106680.shtml
[cns]: http://www.chinanews.com/cul/news/2008/12-02/1470861.shtml
[sina1980]: http://collection.sina.com.cn/cqyw/20131129/0831135366.shtml
[report]: https://www.aisixiang.com/data/22689.html
[sina]: https://news.sina.cn/sa/2008-11-07/detail-ikkntian1057683.d.html
[people]: http://paper.people.com.cn/hqrw/html/2008-11/16/content_172402.htm
[cnn]: https://www.cnn.com/2008/WORLD/asiapcf/11/04/china.emperor/index.html
[sina2]: https://news.sina.com.cn/o/2008-11-03/061414670080s.shtml
[gmw]: https://epaper.gmw.cn/sz/html/2010-10/01/nw.D110000sz_20101001_4-02.htm
[sohu]: https://m.sohu.com/n/260392771/
[fang]: https://zhuanlan.zhihu.com/p/49837817

## Where it is set

- **A. Yingtai, the night of 14 November 1908** (the Forbidden City's
  lake, lanterns, the empty hall), with the 2003–2008 instruments arriving
  as things "that should not be here yet". Richest atmosphere, but the
  instruments stretch that device (so far only papers and books), and the
  tests need the robe and hair, which on that night are on the dead man.
- **B. Chongling, the Western Qing Tombs, during the tests (2003–2008)**
  (recommended): winter at the tomb; the crypt with the closed coffin; the
  site lab where the hair and robes are tested; an archive room where the
  1908 papers (the court's announcement, the physicians' records, Qu's
  memoir) arrive as papers "that should not be here yet" the other way
  round, from the past. Nothing has to be shown that should not be, and
  the puzzles are what really happened.

Built with **B**.

## Map (B)

```
         crypt (the closed coffin)
            │
 archive ─ stele court (start) ─ site lab
```

| Scene | What's there |
|---|---|
| `stele_court` (start) | Chongling in winter: the stele tower with the emperor's posthumous name, snow, a notice of the 1938 robbery |
| `crypt` | The underground palace: marble doors, the coffin closed and mended where it was axed in 1938, the 1980 clearance record |
| `archive` | Boxes of copies: the court's announcement, the physicians' records of 1908, Qu Guiting's memoir |
| `site_lab` | A heated work-room: the hair samples in tubes, the micro-reactor's data sheets, the robe laid out under the X-ray fluorescence probe; later the report |

## New mechanics (this tale only)

- **The strand (`strand`).** A strand of hair laid out as 1 cm segments,
  root to tip. Each measurement (neutron activation) shows one segment's
  arsenic, but the reactor time is short: only a few measurements per
  strand. Find the segment where it peaks, and choose which of two curves
  the strand follows: a steady line (years of small doses, as in chronic
  illness) or a sharp peak (a great dose at once). The height of the tale.
- **The robe (`scan`).** The robe laid on the table, outer and inner
  garment. Drag the probe over it; a needle shows the reading under it.
  Find and mark the three places it is highest (stomach, collar, shoulder),
  and see that the inner garment reads higher than the outer. Tactile, and
  unlike the beam or the lens: nothing is revealed, only measured.

## Puzzle flow (11 beats)

| # | Beat | Type | Clue | Reward |
|---|---|---|---|---|
| 1 | The stele court | read | The stele; the notice of 1938 | Word (1938) |
| 2 | The archive | read | The court's announcement: died of illness; the physicians' records | Words (illness, chronic) |
| 3 | The crypt | read | The closed coffin; the 1980 record: no poison found | Word (1980, decoy) |
| 4 | The archive | read | Qu Guiting's memoir: stomach pain, a dark face, "unrelated to his illness" | Word (stomach) |
| 5 | The site lab | take | The sample tubes, the reactor sheets | The strands |
| 6 | **The strand** | **strand** (two strands) | Limited measurements | The peak; word (arsenic) |
| 7 | **The robe** | **scan** (outer, inner) | The probe's needle | Stomach, collar, shoulder; inner higher |
| 8 | The site lab | read | The report: 201.5 mg; 60–200 mg kills; acute poisoning | Word (a lethal dose) |
| 9 | The archive | read | Rumour and argument: Cixi, Yuan Shikai, Li Lianying; the doubters | Decoy names; word (unknown) |
| 10 | The seal | `deduction`, a new form | All the above | The tale is distilled |
| — | Secret | read twice | The stele, after the seal's words are found | The keeper's note |

## The seal

A new form, **`vermilion`**: a sheet of imperial yellow, written in
vermilion, the emperor's own ink, where the court once wrote "illness".

"He did not die of {illness}: his hair and robe held {arsenic}, and whose
hand gave it is {unknown}."

Decoys: Cixi, Yuan Shikai, Li Lianying, 14 November 1908, 1938, 1980, 201.5 mg, the stomach.

**Ending:** "The Guangxu Emperor was buried at Chongling in 1913. The
tests of 2008 found arsenic, a lethal dose. Who gave it, no record says."

## Echoes and living things

- **Echoes:** faceless figures in lab coats at the bench; a tomb keeper
  with a lantern in the crypt. No emperor, no court.
- **Living things (Hebei, winter):** crows on the stele tower, dry grass
  in the court. (Crows would be a new creature; optional.)

## Audio (ids, to generate)

- **Music:** `chongling_winter` (a cold drone, wind in pines, a
  temple-bowl tone now and then).
- **Effects:** `stone_door` (the crypt's marble door), `geiger` (counts
  from the measurement), `wind_pines`. Interface: `probe_tick` (the scan
  probe's reading), `sample` (a tube placed).

## Decisions (2026-09-30)

1. Setting **B**: Chongling during the tests; the 1908 papers arrive in the
   archive as papers "that should not be here yet".
2. Both mechanics: the strand (`strand`) and the robe (`scan`).
3. The seal in vermilion (`vermilion`), with the hand left *not known*.

## As built

- **Flow:** the notice in the court (1938) opens the crypt; the 1980
  clearance record there (no poison found) sends what was kept to the
  work-room, which opens. The archive holds the court's announcement
  (*illness*, 14 November 1908), the physicians' records and Qu Guiting's
  memoir (*the stomach*) from the start. In the work-room: the hair
  (`strand`, gives *arsenic*), then the robe (`scan`), then the report
  (201.5 mg). The report puts the 2008 cuttings on the archive's pin
  board: Cixi, Yuan Shikai, Li Lianying, the doubters, and *not known*.
  The keeper's slip lies in the stone incense burner once the cuttings
  are read; the seal is written at the stele.
- **The strand:** two strands of 14 segments, 7 readings a sample, a new
  sample at any time. A search that halves towards the higher neighbour
  finds each peak within the budget (checked in the walkthrough test);
  strand II's second peak (202) can mislead a greedy search.
- **The robe:** the outer robe (scale 0.4) never reaches the red, so the
  player must lay the inner garment uppermost; four places: the stomach,
  the collar, both shoulders.
- **Words:** *illness*, *arsenic*, *not known* (the answers); *the
  stomach*, Cixi, Yuan Shikai, Li Lianying, 14 November 1908, 1938, 1980,
  201.5 mg (decoys). *Chronic* was dropped: it fit the first blank too
  well to be a fair decoy.
- **Echoes:** a tomb keeper with a lantern in the crypt, a scientist in
  the work-room. **Living things:** dry grass in the snow, pines.
- **Audio:** music `chongling_winter`; effects `stone_door`,
  `reactor_count`, `wind_pines`; interface `geiger`, `geiger_hot`,
  `sample`, `probe_tick`.

## Things to watch when tested

- Whether 7 readings per sample feel tight but fair, and whether the bars
  (against 2.2 times the strand's highest) read at phone size.
- Whether the faint outer robe leads the player to try the inner garment
  without the hint.
- Whether the probe is easy to drag on the phone, and the dial readable.
- Whether the snowy court's hotspots (the notice, the tunnel, the altar,
  the work-room door) are found at a glance.
