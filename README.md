# Stillroom

Surreal point-and-click escape room for Android, built with Flutter + Flame.
Requirements: [docs/PRD.md](docs/PRD.md). Content schema: [docs/content_format.md](docs/content_format.md).

## Commands

Always through FVM (Flutter 3.41.7, pinned in `.fvmrc`).

```bash
fvm flutter pub get
fvm dart run build_runner build          # after changing freezed/riverpod code
fvm flutter run                          # on a connected Android device
fvm flutter analyze
fvm flutter test
fvm dart run tool/validate_content.dart  # content validator (add --errors-only)
```

## Layout

- `lib/engine/` — game rules, pure Dart (no Flutter/Flame), unit tested
- `lib/content/` — loading and validating JSON content
- `lib/state/` — Riverpod providers: session, save, settings
- `lib/features/` — game (Flame scene), inventory, puzzles, menu, settings
- `lib/core/` — storage, audio, hint gate, shared widgets
- `lib/debug/` — debug panel (debug builds only)
- `assets/content/` — episodes, scenes, items, puzzles, string tables
- `tool/` — content validator CLI

Content is data-driven: new rooms, items, and puzzles are JSON only.
Missing art and audio fall back to placeholders; drop files at the paths used
in the JSON to replace them.
