# The Emulator Box

A standalone desktop package containing **the eleven machines of Nerd Heaven's
Emulator Box, with their audit lessons attached** — and nothing else. Where
Dad's Arcade is the whole games shelf, the Emulator Box is just the machines:
one shelf of eleven consoles, a Play button and a 📖 Lesson button for each,
and a Start-the-Baton-Box control. The Box ships the machines, never the
games — players bring cartridges, disk images, and romsets from their own
libraries, loaded from their own files. Nothing uploads.

## The eleven machines

- **The 6502 Bench** — a bare NMOS 6502 with assembler, BASIC, and a Drive Shelf
- **The 2600 Console** — Javatari, vendored unmodified (AGPL v3)
- **The NES Console** — JSNES in one self-contained page (Apache-2.0)
- **The SNES Console** — EmulatorJS with the Snes9x core, vendored unmodified
- **The Genesis Console** — EmulatorJS, vendored unmodified; its key map was measured at the cartridge
- **The DOS Console** — DOSBox Pure through EmulatorJS; runs in full through
  the Baton Box (its core needs cross-origin isolation the app window can't give it)
- **The Apple IIe Console** — Apple2TS 3.8.0, vendored unmodified (MIT)
- **The Vectrex Console** — jsVecX, vendored unmodified; Mine Storm is built into the machine itself
- **The MAME Console** — MAME 2003-Plus through EmulatorJS, vendored unmodified
- **The 7800 Console** — ProSystem through EmulatorJS (GPL-2.0)
- **The 5200 Console** — the a5200 core through EmulatorJS (GPL-2.0); bring
  your own 5200.rom BIOS

Each console's license and provenance ride inside its rack folder in the
bundle, exactly as they do in the collection. Each lesson is the audit of the
machine it ships: what was measured driving the shipped code, what is real,
and what bends.

## The Baton Box control

The shelf carries the same Start-the-Baton-Box control as the Arcade app.
The Baton Box is a small stdlib-only Python server, bundled under
`src-tauri/resources/baton-box/`; the app runs a working copy from its local
data directory (refreshed only when the bundled server changes, so family
sessions survive updates), serves the DOS Console with the cross-origin
isolation headers its core needs, and relays the pass-and-play games — The
Relay, the 6502 Bench, the NES, SNES, and DOS consoles — to the home network.
It needs Python 3 on the machine, the same Python the standalone box uses.

## Layout

- `interface/` — the shelf (index.html) and About page, hand-written.
- `dist/` — the built frontend, assembled by `tools/sync-dist.sh` and
  committed, because CI builds the app straight from it.
- `tools/sync-dist.sh` — rebuilds `dist/` from a sibling checkout of the
  collection (`../everyday-cool`) and refreshes the Baton Box resources from
  a sibling `../baton-box` checkout. The consoles are copied FLAT into
  `dist/emulators/` (they cross-link siblings by bare filename) with their
  racks whole beneath; `dist/emulators/index.html` is a generated stub that
  bounces the consoles' room-index link back to the shelf.
- `src-tauri/` — the Tauri v2 shell: window, menus, Clear Cache, and the four
  Baton Box commands (`baton_start` / `baton_stop` / `baton_status` /
  `baton_open`). Adapted wholesale from the Arcade app's shell.

## Building a release

Releases build in GitHub Actions on a `v*` tag, the same workflow as the
other Everyday Cool apps. **One manual step first:** this repo's workflow
file cannot be pushed from the command line (the token has no `workflow`
scope), so `.github/workflows/build.yml` must be created once through the
GitHub web UI — its full text is committed here as `workflow-build.yml.txt`
at the repo root; paste it in as `.github/workflows/build.yml`. After that,
tagging `v1.0.0` and pushing the tag builds the Windows and macOS bundles and
attaches them to the release.

## Provenance

The consoles are the collection's, byte-for-byte: `tools/sync-dist.sh`
copies them from `caeled/everyday-cool` (the Emulator Box overlay is the same
assembly the Arcade app uses), and v1.0.0 was synced from collection commit
`79293ac` and byte-compared file by file — 18 console/lesson pages, 324 rack
files, 110 Baton Box resource files, zero differences. The app icons are the
Arcade app's icon set, reused for v1.0.0 and replaceable.
