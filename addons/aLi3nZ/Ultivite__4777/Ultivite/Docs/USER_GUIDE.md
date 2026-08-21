# Ultivite User Guide

## 1. Start Here & Quick Setup

This is the best place to begin. The controls here are shortcuts to the same saved settings used in the detailed sections.

Choose whether Ultivite uses one account wide profile or a separate character profile. Then select a HUD Preset and decide whether the combat HUD should hide outside combat.

The same section also gives quick access to common Fancy Action Bar+ controls plus normal ESO UI visibility settings. FAB+ itself is a separate required addon and is enabled from ESO's normal Add-Ons list.

## 2. UI Visibility

This is the central place for structural HUD visibility. Compass, Quest Tracker, Champion Point progress and Queue/Status each support On / Show, Hide in combat, Hide in PvP and Hide always. Other hide/show settings from the Player HUD, target frame and Fancy Action Bar+ integration are duplicated here for easier discovery.

## 3. Player HUD & Layouts

Use this section for player Health, Magicka and Stamina bars, Dark Souls layouts, player bar text, movement and sizing. Structural visibility controls are centralized under UI Visibility.

### HUD Preset

The preset selector contains the normal Ultivite layout and the Dark Souls variants.

### Move & Size Player Bars

Unlock the bars, drag them directly, then adjust width and thickness. Grid snapping is available when precise alignment is wanted.

### Dark Souls Self replacement bars

`Show bottom player Health` replaces ESO's normal player Health bar and automatically suppresses that native control even if Fancy Action Bar+ has moved it. `Add bottom Magicka and Stamina` does the same for the normal Magicka and Stamina controls. Turning the Dark Souls replacement off releases the native bars back to ESO and Fancy Action Bar+.

### UI Visibility

The main UI Visibility section is the central control hub for anything Ultivite deliberately hides or suppresses.

### Navigation Helpers

Ultivite includes two optional white navigation aids under `UI Visibility > Player HUD & Global Visibility`. Both are disabled by default. The Crown Direction Arrow points toward the current group leader and has size, opacity and screen-position controls. The Feet Compass sits beneath the character area and has its own size, opacity and position controls. Its root is fixed in screen space and only the heading rotates, which avoids tying the visual to the player's constantly changing world position.

Compass, Quest Tracker, Champion Point progress and Queue/Status use the same visibility modes:

1. On / Show keeps the element available normally.
2. Hide in combat hides it only while the player is in combat and restores it after combat ends.
3. Hide in PvP hides it only while physically inside Battlegrounds, Cyrodiil or Imperial City and restores it after leaving PvP.
4. Hide always suppresses it everywhere.

Player HUD, Dark Souls, target frame, nameplate and Fancy Action Bar+ integration visibility controls are also duplicated in this section so visibility does not need to be hunted down across different menus.

At the bottom, `Vanilla ESO Interface Toggles` mirrors ESO's own Interface, Nameplates and Chat Bubble visibility settings. This includes House and Quest trackers, quest and compass pins, Weapon and Armor indicators, NPC/player names, overhead Health bars, titles, guilds and chat bubbles. `Hide all NPC names` provides a single master switch while preserving the three NPC name settings it replaced so they can be restored.

## 4. Combat Warnings & Effects

Use this section for immediate combat information.

### Combat warnings

Major Resolve and food warnings, resource danger, shield broken, execute danger and burst damage warnings are grouped together.

### Self Effects

CC immunity and debuffs on the player are independent. Each can be enabled or disabled separately and moved separately.

### Target Effects

Major Breach and important target debuffs are independent. Their displays can be enabled, disabled and positioned separately.

### Action Bar Buff & Debuff Tracking

Fancy Action Bar+ owns its advanced ability/effect mapping. Open the standalone FAB+ panel from Ultivite's Action Bar section when you need those editors.

## 5. Trackers, Stats & PvP

### Set & Stack Trackers

Dedicated trackers include Onslaught, Balorgh, Tarnished Nightmare, Null Arca, Dragon's Appetite and Wretched Vitality. Generic slotted skill stack tracking and Streak fatigue are separate controls.

### Live Stats

Weapon or Spell Damage, front bar Resistance, back bar Resistance and Damage Shield strength can be shown as movable numeric widgets.

The live stat widgets are always movable and do not use an unlock mode.

### PvP

Kill and death counters and related PvP display options are grouped here.

## 6. Action Bar

Fancy Action Bar+ is a separate required addon. Ultivite does not include FAB+ source, XML, textures, effect tables or action-bar runtime code. This section is a convenience bridge to the installed FAB+ addon.

### Common controls in Ultivite

Ultivite keeps frequently used FAB controls in its own menu, including action-bar position, scale, visibility and the account-wide FAB skill/effect preference. These controls write directly to `FancyActionBarSV`, which remains owned by Fancy Action Bar+.

### Mirrored FAB settings

Ultivite asks the installed FAB+ addon for its current LibAddonMenu options at runtime and mirrors the sections that can safely be displayed twice. Changing one of these options changes the same standalone FAB+ setting.

### Full Fancy Action Bar+ settings

Use `Open Full Fancy Action Bar+ Settings` for FAB UI Presets, the full Actionbar Size & Position editor, Ability Configuration, Effect Widgets and blacklist editors. Those advanced editors use FAB+'s own named controls internally and intentionally remain in FAB+'s panel rather than being duplicated.

### Combat visibility

Ultivite's master Combat Only HUD setting can also hide the shared ESO action-bar root outside combat. FAB+ continues to own its own bar contents, effects, timers and weapon-lock behavior.

## 7. Sound Suppressor

Enable sound suppression, start a short capture, trigger the unwanted sound, identify the captured result and block only that exact sound.

Capture tuning and diagnostics are kept in the advanced sound submenu.

## 8. Advanced & Support

This section contains profile saving, layout restore tools, layout reports, target frame internals and diagnostics.

### Restore Recommended Layout

This restores the recommended normal Ultivite HUD positions and recommended combat toggles. It does not erase profiles, sound settings or sound blocklists.

### Show Layout Report

This opens a selectable text report containing player bar positions, Dark Souls geometry, Fancy Action Bar saved and actual positions, screen information and profile scope. Use Ctrl+C to copy the report for support.

Ultivite does not use ESO private clipboard APIs.

## Fresh install defaults

Version 1.0.73 uses the author's supplied account wide profile as the starting configuration for new installs. Existing users keep their SavedVariables unchanged. The most visible differences from an unmodified ESO HUD are documented in `UI Visibility`: Compass hides in combat, while Quest Tracker and Champion Point progress hide in PvP, Mount Stamina and the Werewolf resource meter are hidden, the player resource bars use the author's custom size and positions, and chat stays visible by default. The legacy group frame and old Battleground queue flags are retained only for compatibility and no longer hide those UI elements. Fancy Action Bar+ keeps its own standalone defaults.

## Saved settings

Account wide and character profiles include the complete Ultivite configuration. Fancy Action Bar+ owns its own `FancyActionBarSV`; Ultivite can mirror its account wide skill/effect preference and keeps a settings snapshot only for export, preset continuity and one time migration from older Ultivite builds. Upgrading from an older embedded FAB build migrates that snapshot to the separately installed Fancy Action Bar+ addon.
