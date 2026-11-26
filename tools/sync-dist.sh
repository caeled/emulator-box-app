#!/usr/bin/env bash
# Assemble dist/ for The Emulator Box from a checkout of the
# Everyday Cool collection.
#
#   tools/sync-dist.sh [path-to-collection]
#
# The collection path defaults to ../everyday-cool (a sibling checkout).
# dist/ is rebuilt from scratch every run:
#   dist/index.html        <- interface/index.html (the shelf)
#   dist/about.html        <- interface/about.html
#   dist/emulators/        <- the Emulator Box overlay: the eleven Nerd
#                             Heaven console pages and their lessons,
#                             copied FLAT (the pages cross-link siblings
#                             by bare filename), plus their racks
#                             (javatari/, jsnes/, emulatorjs-snes/,
#                             emulatorjs-dos/, apple2ts/,
#                             emulatorjs-mame/, emulatorjs-7800/,
#                             emulatorjs-5200/,
#                             emulatorjs-genesis/, jsvecx/) copied whole.
#                             dist/emulators/index.html is a stub that
#                             bounces the consoles' room-index link back
#                             to the shelf.
#   src-tauri/resources/baton-box/  <- the Baton Box server bundle the
#                             app's Start-the-Baton-Box control runs:
#                             refreshed from a sibling ../baton-box
#                             checkout (override with BATON_BOX_DIR).
# Console and lesson files are copied as siblings so the relative links
# between them work unchanged. This script is the Arcade repo's overlay
# step (everyday-cool-arcade, tools/sync-dist.sh) standing alone: the
# Box has no games manifest of its own.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COLLECTION="$(cd "${1:-$REPO_ROOT/../everyday-cool}" && pwd)"
PROJECTS="$COLLECTION/projects"
DIST="$REPO_ROOT/dist"

if [ ! -d "$PROJECTS" ]; then
  echo "error: no projects/ directory under $COLLECTION" >&2
  exit 1
fi

rm -rf "$DIST"
mkdir -p "$DIST"
cp "$REPO_ROOT/interface/index.html" "$DIST/index.html"
cp "$REPO_ROOT/interface/about.html" "$DIST/about.html"

# ---------------------------------------------------------------------------
# The Emulator Box overlay. The eleven consoles are Nerd Heaven pages:
# each page expects its lesson, its sibling consoles, and its rack
# folder beside it under bare relative names, so the whole set is
# copied FLAT into dist/emulators/ and cross-links work unchanged.
# The one link that cannot resolve there is the consoles' room-index
# link (index.html); the stub written below bounces it to the shelf.
EMU_SRC="$PROJECTS/nerd-heaven-tech-support"
EMU="$DIST/emulators"
mkdir -p "$EMU"
emu_count=0
while IFS='|' read -r emu_page emu_lesson emu_title; do
  case "$emu_page" in ''|\#*) continue ;; esac
  cp "$EMU_SRC/$emu_page" "$EMU/$emu_page"
  cp "$EMU_SRC/$emu_lesson" "$EMU/$emu_lesson"
  emu_count=$((emu_count + 1))
  echo "  emulators: $emu_page + $emu_lesson"
done <<'EMU_LIST'
the-6502-bench.html|the-6502-bench-lesson.html|The 6502 Bench
the-2600-console.html|the-2600-console-lesson.html|The 2600 Console
the-nes-console.html|the-nes-console-lesson.html|The NES Console
the-snes-console.html|the-snes-console-lesson.html|The SNES Console
the-genesis-console.html|the-genesis-console-lesson.html|The Genesis Console
the-dos-console.html|the-dos-console-lesson.html|The DOS Console
the-apple-iie-console.html|the-apple-iie-console-lesson.html|The Apple IIe Console
the-vectrex-console.html|the-vectrex-console-lesson.html|The Vectrex Console
the-mame-console.html|the-mame-console-lesson.html|The MAME Console
the-7800-console.html|the-7800-console-lesson.html|The 7800 Console
the-5200-console.html|the-5200-console-lesson.html|The 5200 Console
EMU_LIST
for rack in javatari jsnes emulatorjs-snes nostalgist-snes emulatorjs-dos jsdos-dos apple2ts emulatorjs-mame emulatorjs-7800 emulatorjs-5200 emulatorjs-genesis jsvecx; do
  cp -r "$EMU_SRC/$rack" "$EMU/$rack"
done
cat > "$EMU/index.html" <<'EMU_STUB'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>The Emulator Box — back to the shelf</title>
<meta http-equiv="refresh" content="0; url=../index.html">
</head>
<body>
<p>The consoles live on the shelf — <a href="../index.html">back to the Emulator Box shelf</a>.</p>
</body>
</html>
EMU_STUB
echo "  emulators: $emu_count consoles, racks javatari jsnes emulatorjs-snes nostalgist-snes emulatorjs-dos jsdos-dos apple2ts emulatorjs-mame emulatorjs-7800 emulatorjs-5200 emulatorjs-genesis jsvecx -> $EMU"

# ---------------------------------------------------------------------------
# The Baton Box server bundle (src-tauri/resources/baton-box/): what the
# app's Start-the-Baton-Box control runs. Refreshed from a sibling
# checkout of the standalone box (override with BATON_BOX_DIR). The
# server file is copied byte-for-byte; runtime state (sessions.json,
# __pycache__) never rides into the bundle.
BATON_SRC="${BATON_BOX_DIR:-$REPO_ROOT/../baton-box}"
BATON_DEST="$REPO_ROOT/src-tauri/resources/baton-box"
if [ -f "$BATON_SRC/baton_box.py" ]; then
  rm -rf "$BATON_DEST"
  mkdir -p "$BATON_DEST"
  cp "$BATON_SRC/baton_box.py" "$BATON_DEST/baton_box.py"
  for extra in start-baton-box.bat README.md CONTRACT.md; do
    if [ -f "$BATON_SRC/$extra" ]; then
      cp "$BATON_SRC/$extra" "$BATON_DEST/$extra"
    fi
  done
  cp -r "$BATON_SRC/games" "$BATON_DEST/games"
  find "$BATON_DEST" -type d -name "__pycache__" -prune -exec rm -rf {} +
  find "$BATON_DEST" -name "sessions.json" -delete
  echo "  baton-box: server + games refreshed from $BATON_SRC -> $BATON_DEST"
else
  echo "  warning: no Baton Box checkout at $BATON_SRC — bundled resources left as they were" >&2
fi

echo "sync-dist: $emu_count consoles -> $DIST"
