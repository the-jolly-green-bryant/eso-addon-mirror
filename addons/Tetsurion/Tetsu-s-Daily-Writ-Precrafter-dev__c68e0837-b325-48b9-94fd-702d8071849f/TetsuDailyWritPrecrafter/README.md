# Tetsu's Daily Writ Precrafter 2.0.2

Gamepad / console (PS5) addon for Elder Scrolls Online.

Each character crafts **for themselves only**. No main/alts, no bank automation.

## Features

- **Pre-craft mode** (per character):
  - Toggle on/off in settings.
  - Slider 1–10 days.
  - R3 crafts the daily rotation sequence for the chosen number of days (including today).
- **Quest mode** (default):
  - R3 crafts only what the active daily writ needs.
  - If no active writ → nothing happens.
- **Alchemy & Provisioning**: fixed **5 days** when pre-craft is enabled. Crafts proper quantities.
- Auto-accept crafting writs from the board.
- Auto-turn-in at the crates.
- Auto-open reward boxes.
- Material + bag-space pre-check before any craft starts.
- Fully gamepad-friendly (R3 keybind strip, no slash commands required).

## Settings (LibHarvensAddonSettings)

- Auto-accept / turn-in writs
- Auto-open reward boxes
- **Pre-craft for the future** (this character) — default OFF
- **Days ahead** (1–10) — only relevant when pre-craft is ON

Settings for pre-craft are saved **per character**.

## Typical workflow

1. Open settings → enable “Pre-craft for the future” and set days (e.g. 5).
2. Go to blacksmith / clothier / woodworking / jewelry / enchanting station → press **R3** → confirm.
3. Do the same for alchemy and provisioning (always 5 days when pre-craft is on).
4. Next days: just pick up writs and turn them in (items already in bag).

When pre-craft is off, R3 only helps with the current active writ.

## Install (PS5 / console)

1. Copy the whole `TetsuDailyWritPrecrafter` folder into the game AddOns directory.
2. Install **LibHarvensAddonSettings** (required).
3. Enable both addons and reload UI.

## Version

2.0.2 — Fixed writ pattern detection (per-character rotation, not calendar day).
  Quest mode matches items via DoesItemLinkFulfillJournalQuestCondition.
  Fixed jewelry quantities (3 rings / 2 necks). Phase remembered for pre-craft.

2.0.1 — full UI localization (en, ru, de, es, fr, ja, zh).

2.0.0 — full architecture rewrite:
- Removed bank module
- Removed main/alts / character list / kits
- Each character pre-crafts only for themselves
- Per-character pre-craft toggle + days slider
- Alchemy/Provisioning fixed to 5 days

## Author

Tetsurion
