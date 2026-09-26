# Art & UI Style Guide — Stillroom

Status: **v1 direction**, approved by the developer on 2026-09-25. Gaps are
marked _open_. The UI in `lib/` already follows this guide; generated art
should too.

## Identity in one line

> A Victorian apothecary cabinet at midnight: aged paper, tarnished brass, and
> murky glass, lit by a single gas flame. Quiet, still, and wrong in small ways.

Horror comes from atmosphere and absence (stopped clocks, empty frames,
things left behind), **never from gore**. Violence stays off screen (PRD §1).

## Palette

Defined in `lib/core/theme/stillroom_palette.dart`; use the names in code.

| Name | Hex | Use |
|---|---|---|
| ink | `#0E0B09` | Backgrounds, letterbox |
| soot | `#17120E` | Panels, dialogs |
| walnut / walnutLight | `#2A1E15` / `#3D2C1F` | Wood: cabinets, frames, shelf |
| paper / paperShade | `#D8C9A8` / `#B9A883` | Notes, text on dark, labels |
| inkOnPaper | `#2A1F17` | Text on paper |
| faded | `#8C7A5B` | Secondary text |
| brass | `#A88B4A` | Trims, borders, icons |
| gaslight | `#E0A84A` | Selection, the "next step" glow |
| oxblood / oxbloodBright | `#6B1E1E` / `#9A2B25` | Primary buttons, wax seals, mistakes |
| fog | `#4E5A52` | Glass, cold light, night air |

Rules of thumb: at most one warm light source per scene (gaslight), and
everything else desaturated. Oxblood is rare and meaningful.

## Typography

- **IM FELL English** (serif) for all text. **IM FELL English SC** (small
  caps, letter-spaced) for titles and headings.
- Font files are bundled in `assets/fonts/` under the SIL Open Font License
  (`assets/fonts/OFL.txt`, shown in the app's license page).
- No bold: IM FELL has one weight. Use small caps, italics, or size for
  emphasis.
- IM FELL covers Latin only. Other scripts fall back to bundled fonts chosen
  to sit well beside it (`AppTheme.fallbackFor`): **Old Standard TT**
  (Cyrillic, 19th-century book face), **Noto Serif JP** and **Noto Serif SC**
  (Japanese, Simplified Chinese), regular weight only. The CJK fonts are
  subset to JIS X 0208 / GB 2312 by `tool/fonts/subset_cjk_fonts.py` (≈3.5 MB
  each). All fonts: SIL OFL 1.1, licenses in `assets/fonts/licenses/`.
- IM FELL uses old-style figures: **0 looks like a lowercase o**. Fine for
  atmosphere; keep it in mind for codes the player must read (e.g. 03:40).
  _Open: switch digits in clues/dials to a lining-figure font if playtesters
  misread them._

## UI treatment

| Element | Treatment |
|---|---|
| Every screen | Vignette + static film grain (`Atmosphere` widget) |
| Main menu | Small-caps title, italic tagline, brass rule; the suggested action glows gaslight |
| Episode picker | A shelf of jars, one per tale, labelled with place and year; sealed jars for tales to come; a wax seal on finished ones |
| Inventory | Walnut cabinet with a brass edge facing the scene; recessed compartments; the selected one is lit |
| Text box | A scrap of aged paper with a torn bottom edge, slightly askew |
| Examine view | The object in a brass-trimmed specimen case, name in small caps |
| Dialogs, hints | Soot panel with a thin brass border |
| Buttons | Near-square corners; primary in oxblood, others outlined in brass |
| Ending | Fade to ink; "The tale is distilled"; an oxblood drop |

## Art direction (for AI image generation)

**Look:** hand-painted 2D illustration with flat, muted colour fields and soft
painterly texture, thin dark ink outlines, and a strong vignette. Scenes are
shown **front-on and symmetrical**, like a stage set or a diorama box.
Perspective is simple and slightly flattened. Lighting comes from one warm
source; shadows fall into deep brown-black.

**Figures** (rarely shown): stiff, doll-like poses; faces pale and simplified
with dark, blank eyes; features small; hands and gestures formal. Never
graphic injury.

**Surreal touch:** one thing per scene is quietly impossible (a clock with no
hands that still ticks, fog inside a jar, a shadow that points the wrong way).

**Signature motifs:** glass jars and bottles, labels on paper, brass fittings,
moths, stopped clocks, candle smoke, empty picture frames, the number of
things matching the number of people lost.

_Open: character design sheet, the keeper of the Stillroom, and the logo._

### Prompt template

Keep the style block identical in every prompt so scenes stay consistent. Per
PRD §9A, **never name other games or studios** in prompts; describe the style.

```
STYLE: hand-painted 2D illustration, flat muted colour fields with soft
painterly texture, thin dark ink outlines, front-on symmetrical stage-set
composition, simplified flattened perspective, single warm gaslight source,
deep brown-black shadows, heavy vignette, palette of ink black, aged paper
beige, tarnished brass, oxblood red, fog green-grey, Victorian 1880s,
quietly surreal, atmospheric and melancholic, no gore, no text.

SUBJECT: <what is in the picture>
FRAMING: 16:9, 1920×1080, <view: wall / close-up / board>
```

- **Scene backgrounds:** 1920×1080, everything that never changes.
- **State variants** (drawer open/closed, candles lit): generate the scene
  once, then produce the variant by inpainting on the same image so nothing
  shifts. Export only the changed area as a transparent PNG layer at the
  `rect` used in JSON.
- **Item icons:** "single object, centred, transparent background, same
  STYLE". Examine views are square (e.g. 1024×1024).
- **Jars** (episode picker): "a single glass apothecary jar with a cork and a
  blank paper label, murky contents hinting at <tale>, transparent
  background". Keep the label blank: the game writes the title.

After art lands, adjust hotspot and layer `rect`s with the debug panel
(🐞 → show hotspots), then run `fvm dart run tool/validate_content.dart`.

### Code-drawn stand-in art

Until real files exist, most Whitechapel images are drawn in code
(`lib/core/art/`), keyed by the same asset paths as the JSON. Rendering tries,
in order: the real file, the code-drawn art, a labelled placeholder box. So
dropping a PNG at its path replaces the drawing with no code change. When all
of an episode's art has landed, its `*_art.dart` file can be deleted. The
drawings follow this guide (flat fills, ink outlines, the palette) but are
intentionally simple: they are for play-testing, not for release.

### Checklist per episode

The full asset list for each episode lives in its design doc (e.g.
`docs/episodes/whitechapel_1888.md`). Paths must match the JSON exactly;
missing files fall back to placeholders, so art can land gradually.
