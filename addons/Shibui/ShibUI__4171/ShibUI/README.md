# ShibUI

ShibUI is a minimal, modern UI overhaul for The Elder Scrolls Online. It reduces visual clutter, provides clear and consistent UI elements, and adds configurable styles for core HUD components while remaining lightweight and modular.

---

## Table of Contents

- [Key Features](#key-features)  
- [Requirements](#requirements)  
- [Installation](#installation)  
- [Quick Start / Usage](#quick-start--usage)  
- [Settings & Saved Variables](#settings--saved-variables)  
- [Keybindings & Slash Commands](#keybindings--slash-commands)  
- [Development & Architecture](#development--architecture)  
- [Troubleshooting](#troubleshooting)  
- [Contributing](#contributing)  
- [Credits & License](#credits--license)

---

## Key Features

- Clean, minimal HUD and action bar styling
- Configurable attribute bar (classic or pyramid layout)
- Optional player progress bar styling
- Target frame styling (lightweight template application)
- Toggleable action bar elements (weapon swap icon, keybinding text)
- Account-wide or character-specific saved settings
- Small, modular codebase designed for maintainability

---

## Requirements

- The Elder Scrolls Online (live)  
- LibAddonMenu-2.0 (recommended for the settings UI; ShibUI checks for it and degrades gracefully)

---

## Installation

1. Download or clone the repository.
2. Place the `ShibUI` folder into your ESO AddOns directory:
   - Windows: `Documents\Elder Scrolls Online\live\AddOns\ShibUI`
3. Launch ESO, open the AddOns menu and enable ShibUI.
4. (Optional) Install LibAddonMenu-2.0 for the in-game settings panel.

---

## Quick Start / Usage

- After enabling the addon, open the AddOns or keybind settings to access ShibUI controls, or use the Settings entry added to the LibAddonMenu panel.
- Most styling changes require a UI reload to fully apply (this is the most reliable and simplest approach).
- Toggle features directly from the settings panel; account-wide mode can be switched to affect all characters.

---

## Settings & Saved Variables

ShibUI stores settings using ESO's ZO_SavedVars system. The addon supports both account-wide and character-specific configuration.

Common settings exposed in the UI:

- `accountWide` — Use a single settings set across your account (default: true).
- `confirmReload` — Require confirmation before reloading the UI.
- `attributeBarPyramid` — Use the pyramid attribute layout.
- `attributeBarSize` — Compact / Default / Expanded sizing for the attribute bar.
- `playerProgressBar` — Enable the player progress bar styling.
- `showHostileOnly` — Show target frames only for hostile targets.
- `showWeaponSwap` — Show/hide the weapon swap icon.
- `showKeybindings` — Show/hide keybinding text on action buttons.
- `scaledUltimateButton` — Use a larger ultimate button styling.

Notes:
- Saved variables persist in `SavedVariables/ShibUI.lua`. If you change setting names or clean defaults, old keys remain in the file until manually removed.
- Changing account-wide vs character settings switches the underlying SavedVars table — the addon will prompt or ask you to reload to complete the switch.

---

## Keybindings & Slash Commands

- ShibUI registers relevant keybind descriptors and exposes a small set of slash commands depending on modules present. Example command used by the Reload UI helper:
```
/shibui -- open ShibUI settings panel (if LAM2 is installed)
/sui reload  -- invoke reload helper (see settings for binding)
/sui targetbarhostile -- toggle target bar hostile-only filter
/sui progressbar -- toggle player progress bar visibility
```
---

## Development & Architecture

ShibUI is modular and organized to make maintenance and extension straightforward:

- `ShibUI.lua` — main entry and initializer for modules
- `settings/` — settings and savedvars handling (defaults, LAM panel)
- `hud/` — visual modules for attribute bar, action bar, target frames, etc.
- Modules should:
  - declare `local sv` at file top
  - set `sv = SUI.SavedVars.saved` in their `Initialize()` after SavedVars are initialized
  - use `sv` for all runtime reads/writes to settings

Design principles:
- Keep initialization order deterministic: SavedVars must be initialized before any module that reads settings.
- Prefer applying templates at creation time; toggling live without reload is possible but more complex — the addon prefers the reliable `RELOAD_UI()` approach for toggles that affect templates.

---

## Troubleshooting

- Settings do not persist:
  - Confirm `ShibUI.lua` exists in `SavedVariables` and contains `$AccountWide` or character entries.
  - Ensure SavedVars initialization runs before modules read settings (SavedVars should be initialized in `SUI.SavedVars:Initialize()` and executed before other module initializers).
  - Check for typos in keys (settings are case-sensitive). Clean old keys manually if required.
- Styling not applied:
  - Some UI controls are created before your hook registration. Either register hooks from your module `Initialize()` after `sv` is set, or apply to existing controls and then hook for future creations.

---

## Contributing

Contributions are welcome. To contribute:

1. Fork the repository.
2. Create a topic branch for your feature or fix.
3. Keep changes small and module-scoped.
4. Open a pull request with a description of changes and rationale.

Please follow the existing coding conventions (module-local `sv` aliasing, initialize SavedVars once, avoid global pollution).

---

## Credits & License

Author: Kim Erik Reinhold (Shownie)  
Inspiration and thanks to many UI addons and their authors.

License: See the repository `LICENSE` file. If none provided, contact the author for usage permissions.

---