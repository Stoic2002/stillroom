# Audio

Status (2026-09-26): **generated stand-ins.** Every sound effect and music
loop is built in code by `tool/audio/generate_audio.dart`. There are no
recordings, no licences to track, and no credits needed. The developer chose
this over CC0 libraries or AI generation for now. Real audio can replace any
file later: drop in a file with the same id and the game picks it up.

## Regenerate

```bash
fvm dart run tool/audio/generate_audio.dart            # everything
fvm dart run tool/audio/generate_audio.dart bell_toll  # one or more ids
```

- **Needs `ffmpeg`** on the PATH. It encodes Ogg Vorbis with the built-in
  encoder, which is why the files are stereo.
- **Output** goes to `assets/audio/sfx/<id>.ogg` and
  `assets/audio/music/<id>.ogg`.
- **Deterministic:** everything is seeded, so a rerun gives the same sound.
- **Levels:** sound effects are normalized to −3 dBFS peak; music to −6 dBFS.
- **Loops:** music loops are crossfaded into their start. Drone frequencies
  are rounded to whole cycles per loop, so the loop point can't be heard.

## Sound effects

| Id | Used by | How it's made |
|---|---|---|
| `clock_tick` | Whitechapel mantel clock; Lawang Sewu station clock | Tick and tock: a noise click plus small metal partials |
| `match_strike` | Whitechapel candles | A rising band-passed scratch with crackles, then a low flare |
| `door_rattle` | Locked doors (both tales) | Wooden thuds with a metal latch |
| `door_creak` | Opening doors | Stick-slip pulses through wood resonances |
| `bell_toll` | Whitechapel candles and frames solved | A church bell from ten partials (hum, prime, tierce, …), big reverb |
| `drawer_open` | Whitechapel desk drawer | A juddering wooden slide, a thump, and things rattling inside |
| `paper` | Whitechapel clippings and letter | Crinkle clicks over a soft rustle |
| `page_turn` | Lawang Sewu ledger and telegram form | A band-passed whoosh and a flap |
| `water_drip` | Lawang Sewu cellar | Rising "plips" in a long, wet reverb |
| `lantern_light` | Lawang Sewu cellar | The lantern door's clink, the wick catching |
| `distant_bells` | Lawang Sewu 1945 window | A far-off peal, low-passed, with a faint low rumble |
| `locker_close` | Lawang Sewu lockers | A sheet-metal slam and latch |
| `glass_chime` | Lawang Sewu stained glass | A rising arpeggio of glassy tones |
| `telegraph_click` | Lawang Sewu telegraph | A sounder tapping out **N·I·S** in Morse, the puzzle's own answer |
| `station_bell` | Lawang Sewu timetable | A handbell rung four times |

## Music

| Id | Where | Loop | How it's made |
|---|---|---|---|
| `stillroom_menu` | Main menu and shelf | 36 s | A low A drone; a quiet pendulum tick every second, matching the lobby clock's swing; a faint glass shimmer twice per loop |
| `whitechapel_fog` | Whitechapel | 48 s | A D-minor drone; wind; one distant bell; six footsteps that never come closer |
| `lawang_sewu_night` | Lawang Sewu (default) | 48 s | A low C-minor drone; two crickets (a tropical night); a far train whistle |
| `lawang_sewu_1907` | Lawang Sewu, 1907 office | 32 s | A warm F-major drone; the office clock; record-like crackle; the NIS telegraph far off |

## Playback

- **Missing files** play silently and show as validator warnings (PRD §0).
- **`MenuMusic`** plays `stillroom_menu` on the menu and shelf, and again when
  the player comes back from a tale.
- **The game screen** plays scene or episode music.
- **Stopping and restarting:** `AudioService.stopMusic(ifPlaying:)` stops only
  the music that screen started. `FlameAudioService` doesn't restart a track
  that is already playing.
