# Flamechasers Dungeon Codex

Development disclosure: This addon was developed with AI assistance, then reviewed and tested in game.

In-game ESO dungeon mechanics viewer with paste-ready PUG notes.

## Current state

Version: 0.2.58

Current complete modules:

DLC HM modules complete:

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

All current DLC dungeon hard-mode modules are complete through Feast of Shadows. Non-DLC/base-game dungeon modules are intentionally excluded from this build.

## Commands

```text
/dmc
/dmech
/dungeonmechs
/flamecodex
```

The addon also exposes keybinds under Controls for opening/closing the window and pasting the currently selected mechanic.

## Design notes

- The project scope is DLC hard modes/challenge-banner clears only unless the user explicitly asks for another mode later.
- Paste buttons use plain text only because ESO player chat does not reliably preserve pipe color formatting after sending.
- The mechanics section shows the exact same lines that the paste buttons send to the chat input.
- The mechanics view modes are **Full**, **Quick**, **Tank**, **Healer**, and **DPS**.
- **Full** is the complete group-facing explanation. Internally this still uses the original `all` data key for compatibility.
- **Quick** is a concise group-callout view. It is written manually per mechanic and preserves important conditions/timing instead of auto-shrinking text.
- Quick mode has now been manually added across all current DLC dungeon modules.
- Boss summaries split into Paste 1 / 2 / 3 buttons when the paste text exceeds one chat line.
- The addon does not force `/group`; it only pre-fills chat input so the player can choose the channel and press Enter manually.
- The current dataset is built around challenge-banner clears. Normal/regular-mode data can be added later as a separate mode, not mixed into the same text.
- Secret-boss unlock/path instructions and optional achievement context live in dungeon/boss summaries only; the mechanics section is reserved for boss-fight mechanics.
- Dungeon and boss summaries now use mouse-wheel summary panes when text is too long for the visible box.
- Mechanics scrolling is mouse-wheel based; the right-side bar is a visual position indicator.
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
- It stores only local UI settings in ESO SavedVariables.

## Language support

- The mechanics dataset and interface text are currently provided in English.
- Current-dungeon detection and text search compare the zone name and aliases
  against the English dataset, so automatic current-dungeon prioritization is
  intended for the English game client in this release.

## Research credits

Mechanic facts were cross-checked against official ESO information, UESP, ESO-Hub, Xynode, Alcast, ArzyeL, Hyperioxes, The Tank Club, and relevant community strategy discussions. All addon text was rewritten into original compact callouts.

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
