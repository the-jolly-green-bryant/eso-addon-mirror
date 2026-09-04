# Flamechasers Dungeon, Trial & Arena Codex

Development disclosure: This addon was developed with AI assistance, then reviewed and tested in game.

In-game ESO dungeon, trial, and arena mechanics viewer with paste-ready notes.

## Current state

Version: 0.7.2

Current complete modules:

DLC Veteran and Hard Mode modules complete:

- Imperial City Prison
- White-Gold Tower
- Cradle of Shadows
- Ruins of Mazzatun
- Black Drake Villa
- Black Gem Foundry
- Bloodroot Forge
- Falkreath Hold
- Fang Lair
- Scalecaller Peak
- Moon Hunter Keep
- March of Sacrifices
- Frostvault
- Depths of Malatar
- Moongrave Fane
- Lair of Maarselok
- Icereach
- Unhallowed Grave
- Stone Garden
- Castle Thorn
- The Cauldron
- Red Petal Bastion
- The Dread Cellar
- Coral Aerie
- Shipwright's Regret
- Earthen Root Enclave
- Graven Deep
- Bal Sunnar
- Scrivener's Hall
- Oathsworn Pit
- Bedlam Veil
- Exiled Redoubt
- Lep Seclusa
- Naj-Caldeesh

All current DLC dungeon Veteran and Hard Mode modules are complete through Feast of Shadows. Non-DLC/base-game dungeon modules are intentionally excluded from this build.

All 14 currently released trials include both Veteran without Hard Mode and Veteran Hard Mode datasets:

- Aetherian Archive
- Hel Ra Citadel
- Sanctum Ophidia
- Maw of Lorkhaj
- Halls of Fabrication
- Asylum Sanctorium
- Cloudrest
- Sunspire
- Kyne's Aegis
- Rockgrove
- Dreadsail Reef
- Sanity's Edge
- Lucent Citadel
- Ossein Cage

All four finite ESO arenas include complete Veteran datasets:

- Dragonstar Arena
- Blackrose Prison
- Maelstrom Arena
- Vateshran Hollows

## Commands

```text
/dmc
/dmech
/dungeonmechs
/flamecodex
```

The addon also exposes keybinds under Controls for opening/closing the window and pasting the currently selected mechanic.

## Design notes

- The project covers both Veteran without Hard Mode and Veteran Hard Mode where those modes exist. Arenas expose Veteran only because ESO does not give these four arenas a separately activated Hard Mode.
- Use the `DUNGEONS / TRIALS / ARENAS` selector above the activity list to change collections. Entering any supported activity automatically selects it and opens its collection.
- The selected activity summary reuses ESO's own Activity Finder artwork as a restrained, low-contrast identity layer; no duplicate splash-art assets are bundled.
- Activity modules declare supported difficulties and role views. Group arenas retain Full, Quick, Tank, Healer, and DPS; solo arenas show only Full and Quick.
- Paste buttons use plain text only because ESO player chat does not reliably preserve pipe color formatting after sending.
- The mechanics section shows the exact same lines that the paste buttons send to the chat input.
- The mechanics view modes are **Full**, **Quick**, **Tank**, **Healer**, and **DPS**.
- **Full** is the complete group-facing explanation. Internally this still uses the original `all` data key for compatibility.
- **Quick** is a concise group-callout view. It is written manually per mechanic and preserves important conditions/timing instead of auto-shrinking text.
- Quick mode is available across all current DLC dungeon and trial modules.
- Boss summaries split into numbered paste buttons when the text exceeds one chat line.
- The addon does not force `/group`; it only pre-fills chat input so the player can choose the channel and press Enter manually.
- Veteran mode has its own summaries and encounter overrides; mechanics that exist only after activating Hard Mode are removed from the Veteran view and its paste output.
- Secret-boss unlock/path instructions and optional achievement context live in activity/boss summaries only; the mechanics section is reserved for encounter mechanics.
- Activity navigation, summaries, and mechanics use ESO's native scroll containers with mouse-wheel, track, and draggable-thumb support.
- Opening the Codex inside a supported dungeon, trial, or arena automatically selects that activity. The selection also updates after a loading screen while the window remains open.
- Every boss has an account-wide personal note field with Save, Revert, and numbered Paste controls.
- Personal boss notes are kept separately for Veteran and Hard Mode, stored by difficulty plus stable activity/boss IDs, support up to 900 characters, and split automatically into safe chat-sized parts when needed.
- Mechanics can include explicit boss attack / move labels through the `casts` field. These labels are used in both the UI title and paste prefix so players can match death recap/cast names more easily.

## Install

Extract the `DungeonMechsCodex` folder into:

```text
Documents\Elder Scrolls Online\live\AddOns\
```

Then run `/reloadui` in game.

## Privacy and dependencies

- No external libraries are required.
- The addon has no network access, telemetry, advertising, or external executable.
- It stores only local UI settings and personal boss notes in ESO SavedVariables.

## Language support

- The mechanics dataset and interface text are currently provided in English.
- Current-activity detection and text search compare the zone name and aliases
  against the English dataset, so automatic current-activity prioritization is
  intended for the English game client in this release.

## Research credits

Mechanic facts were cross-checked against official ESO information and patch notes, UESP, ESO-Hub, Xynode, Alcast, ArzyeL, ESO University, Hyperioxes, The Tank Club, current encounter-helper addons, and relevant community strategy discussions. All addon text was rewritten into original compact callouts.

## v0.2.50
- Added subtle visual-only mechanic card numbers in the Mechanics panel.
- Numbers help users track which mechanic card they are viewing/pasting after scrolling.
- The numbers are UI-only and are not included in pasted chat text.
- No dataset text changes.

## v0.2.33

Corrected scope: removed the accidental non-DLC module and restored the addon to DLC-only dungeon hard-mode coverage.

## v0.2.32

Added complete challenge-focused dataset for Ruins of Mazzatun.

## v0.2.31

Added complete challenge-focused dataset for Cradle of Shadows.

## v0.2.30

Added complete challenge-focused dataset for White-Gold Tower.

## v0.2.29

Added complete challenge-focused dataset for Naj-Caldeesh.

## v0.2.26

Added complete challenge-focused dataset for Exiled Redoubt.

## v0.2.25

Added complete challenge-focused dataset for Bedlam Veil.

## v0.2.24

Added complete challenge-focused dataset for Oathsworn Pit.

## v0.2.23

Added complete challenge-focused dataset for Scrivener's Hall.

## v0.2.22

Added complete challenge-focused dataset for Bal Sunnar.

## v0.2.21

Added complete challenge-focused dataset for Graven Deep.

## v0.2.20

Added complete challenge-focused dataset for Earthen Root Enclave.

## v0.2.19

Added complete challenge-focused dataset for Shipwright's Regret.

## v0.2.18

Added complete challenge-focused dataset for Coral Aerie.

## v0.2.17

Added complete challenge-focused dataset for The Dread Cellar.

## v0.2.16

Added complete challenge-focused dataset for The Cauldron.


### v0.2.50 QoL
Opening the addon window automatically enters cursor/UI mode. Closing the window restores camera mode only if the codex enabled cursor mode itself.
