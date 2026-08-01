# Movable HUD 2.2.4

Movable HUD repositions and resizes these ESO interface elements:

- Chat box: horizontal position, vertical position, width, height, and scale
- Quest tracker: horizontal position, vertical position, width, height, and scale
- Group and companion frames: horizontal position, vertical position, and scale

The group section uses scale as its size control because ESO manages group, raid, and companion members as separate unit frames.

## Console dependency

Movable HUD uses **LibHarvensAddonSettings** inside ESO to place its controls in the native settings interface. On console, select **LibVotans** as the dependency in the Bethesda.net/ESO uploader and mod page. LibVotans is the console distribution name, while the in-game manifest and runtime API remain `LibHarvensAddonSettings`.

## Open the settings

1. Open **Options**.
2. Choose **Settings**.
3. Choose **Addons**.
4. Select **Movable HUD**.

The old `/hudmover` popup and custom controller bindings have been removed. `/hudmover` now prints the menu path. Native settings navigation owns controller focus, preventing settings controls from also activating gameplay actions.

## Group and companion behavior

The **Group & Companion Frames** position and scale settings move:

- Normal small-group frames
- Raid frames
- Companions belonging to grouped players
- Your own companion name and health frame while you are solo

The solo companion frame automatically picks up the same saved group offset when summoned, after a UI reload, and after leaving a group.

## Live placement previews

Enable **Show exact live outlines while adjusting** at the top of the Movable HUD settings page. Chat and quest outlines attach directly to their real controls. The group outline uses the active group frames; while solo with a companion, it follows the local companion frame. The outlines disappear when you leave the Movable HUD page.

## Saving

All positions and sizes are saved account-wide through `ZO_SavedVars`. Changes apply immediately and are reapplied after UI reloads, loading screens, quest updates, group changes, companion state changes, and native HUD resets.

Settings saved by versions 2.0.x through 2.2.3 are retained.

## Reset controls

Each section has a Reset button. Reset All restores every supported element.

## Package structure

```text
MovableHUD/
  MovableHUD.addon
  MovableHUD.lua
  MovableHUDSettings.lua
  README.md
```

The console upload contains one `.addon` manifest directly under `MovableHUD/`.

## 2.2.4

- Added the local solo companion name and health frame to Group settings.
- Added reapplication after companion activation, dismissal, and group transitions.
- Updated the group preview to follow the companion frame while solo.
- Author remains **Rhyojaan**.
