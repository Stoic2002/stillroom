"""Builds the bundled Japanese, Simplified Chinese and Korean fonts.

Pins Noto Serif JP / SC / KR (variable, from Google Fonts, SIL OFL 1.1) to the
regular weight and subsets them to the standard character sets, so the app
stays small (NFR-02) while any ordinary text still renders:

- Japanese: JIS X 0208 (kana + ~6,300 kanji)
- Simplified Chinese: GB 2312 (~6,700 hanzi)
- Korean: KS X 1001 Hangul and symbols (2,350 syllables + jamo; no hanja)
- plus ASCII, Latin-1, general and CJK punctuation, full-width forms.

Usage (needs `pip install fonttools`):
    python tool/fonts/subset_cjk_fonts.py <NotoSerifJP[wght].ttf> <NotoSerifSC[wght].ttf> \
        <NotoSerifKR[wght].ttf>

test/content/font_coverage_test.dart fails if content uses a character the
bundled fonts lack; extend EXTRA below and rerun this script if that happens.
"""
import sys
from fontTools import subset
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

OUT = "assets/fonts"
EXTRA = "・「」『』〜…—–‘’“”№"


def charset(codec: str, lead: range, trail: range) -> set[int]:
    chars = set()
    for a in lead:
        for b in trail:
            try:
                chars.update(ord(c) for c in bytes([a, b]).decode(codec))
            except UnicodeDecodeError:
                pass
    return chars


def common() -> set[int]:
    chars = set(range(0x20, 0x7F)) | set(range(0xA0, 0x100))
    chars |= set(range(0x2000, 0x2070))   # general punctuation
    chars |= set(range(0x3000, 0x3040))   # CJK symbols and punctuation
    chars |= set(range(0xFF00, 0xFFF0))   # full-width / half-width forms
    chars |= {ord(c) for c in EXTRA}
    return chars


def build(source: str, target: str, chars: set[int]) -> None:
    font = TTFont(source)
    font = instancer.instantiateVariableFont(font, {"wght": 400})
    options = subset.Options()
    options.hinting = False
    options.desubroutinize = True
    options.layout_features = ["*"]
    subsetter = subset.Subsetter(options)
    subsetter.populate(unicodes=chars)
    subsetter.subset(font)
    font.save(f"{OUT}/{target}")
    print(f"{target}: {len(chars)} code points requested")


if __name__ == "__main__":
    jp_source, sc_source, kr_source = sys.argv[1], sys.argv[2], sys.argv[3]
    jis = charset("euc_jp", range(0xA1, 0xFF), range(0xA1, 0xFF))
    jis |= set(range(0x3040, 0x3100))     # hiragana + katakana
    gb = charset("gb2312", range(0xA1, 0xF8), range(0xA1, 0xFF))
    build(jp_source, "NotoSerifJP-Regular-subset.ttf", jis | common())
    build(sc_source, "NotoSerifSC-Regular-subset.ttf", gb | common())
    ksx = charset("euc_kr", range(0xA1, 0xC9), range(0xA1, 0xFF))
    build(kr_source, "NotoSerifKR-Regular-subset.ttf", ksx | common())
