# Ultivite 1.0.125

## Dependencies

Required:

* LibAddonMenu-2.0
* Fancy Action Bar+

These are the only declared dependencies in `Ultivite.txt`.

Bandits User Interface is optional and is used only for the Bandits minimap Quick Menu integration when Bandits is already installed. Azurah and LuiExtended are not dependencies. Ultivite only performs passive compatibility checks when either is present.

Ultivite is a unified Elder Scrolls Online combat HUD addon that combines player frame layouts, Dark Souls style HUD presets, combat warnings, buff and debuff tracking, live combat stats, set and stack trackers, PvP tools, sound suppression, and integration with the separate Fancy Action Bar+ addon.

## Required dependencies

1. LibAddonMenu-2.0
2. Fancy Action Bar+

Fancy Action Bar+ is installed separately and is not included in the Ultivite ZIP.

## Installation

1. Extract the ZIP into the Elder Scrolls Online AddOns folder.
2. The resulting path must end in `AddOns/Ultivite/Ultivite.txt`.
3. Do not leave another folder between `AddOns` and `Ultivite`.
4. Install and enable Fancy Action Bar+ separately. Do not place a FAB copy inside the Ultivite folder.
5. Start ESO and enable Ultivite in the AddOns list.
6. Open Settings, Addons, Ultivite.

## Fresh-install defaults

Ultivite 1.0.78 uses the author's supplied account-wide 1.0.71 profile as the factory baseline for new installs. Crosshair visibility now has its own UI Visibility control and defaults to normal ESO behavior (shown). Existing SavedVariables are never overwritten by this change. Notable defaults that differ from stock ESO are documented in the addon menu and release notes: the player bars use the author's custom positions/size, Compass hides in combat, while Quest Tracker and Champion Point progress hide in PvP, the legacy group-frame option is retained but defaults off and remains inactive, Mount Stamina and the Werewolf resource meter are hidden, chat stays visible by default, all enemy overhead health bars are enabled, and no sounds are suppressed by default. Fancy Action Bar+ remains separate and retains its own defaults/settings.

## First setup

1. Open `1. Start Here & Quick Setup`.
2. Choose account wide or character settings.
3. Choose a HUD preset.
4. Decide whether the combat HUD should show only in combat.
5. Move and resize player bars and the action bar.
6. Enable only the warnings, effects, trackers and stats you want.

## Main settings sections

1. Start Here & Quick Setup
2. UI Visibility
   * Includes optional Crown Direction Arrow and Feet Compass navigation helpers. Both are off by default, white, movable, resizable and opacity-adjustable.
   * Includes a bottom `Vanilla ESO Interface Toggles` section for native ESO Interface, Nameplates and Chat Bubble visibility settings.
3. Player HUD & Layouts
4. Combat Warnings & Effects
5. Trackers, Stats & PvP
6. Action Bar
7. Sound Suppressor
8. Advanced & Support

## Commands

`/ultivite` or `/ulti` opens Ultivite settings.

`/ultivite settings` opens a selectable export containing every setting in the active Ultivite profile. Press Ctrl+C to copy it.

`/ultivite printsettings` prints the complete active settings export to chat.

`/ultivite layout` prints the current layout values.

`/ultivite copy` opens the selectable layout report.

`/ultivite preset` restores the recommended normal HUD layout.

`/ultivite dsself` applies the Dark Souls Self preset.

`/ultivite fullsouls` applies the Full Dark Souls preset.

`/ultivite reload` reloads the UI.

Compatibility commands from the merged modules remain available.

## Settings preservation

Ultivite 1.0.78 keeps existing Ultivite SavedVariables. Fancy Action Bar+ now owns `FancyActionBarSV` itself. On first load, Ultivite migrates the previously embedded FAB settings snapshot into the standalone FAB+ SavedVariables once so the existing layout is preserved.
