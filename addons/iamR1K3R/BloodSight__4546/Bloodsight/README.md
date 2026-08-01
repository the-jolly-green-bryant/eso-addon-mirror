# Bloodsight

An ESO addon that hides the overhead healthbars over your group members until one of them is actually in trouble. When an ally drops below a threshold (default 50%) for a short moment (default 250 ms), an arrow on your screen swings around to point at them, and the game's "Injured" overhead bar appears over the wounded ally.

The left-side group UI and the compass are left untouched.

## Features

- Overhead healthbars stay hidden in normal play. No clutter over healthy allies.
- When a teammate drops low, an arrow on your HUD points at them.
- Three bundled arrow styles: Simple, Bloody, Ornate.
- Parallax-aware: the arrow adjusts for its own screen position so it points correctly even when placed near the edges.
- Only triggers for living allies within a configurable distance (5m to 100m). Dead and out-of-zone allies are always ignored.
- If several allies are low at once, the arrow tracks whoever has the lowest HP percent.
- Configurable threshold (10% to 90%) and activation delay (0 to 2000 ms).
- Draggable arrow: unlock, place it anywhere, lock.

## Install

1. Close ESO.
2. Copy the `Bloodsight` folder into your AddOns directory:
   - **Windows:** `Documents\Elder Scrolls Online\live\AddOns\`
   - **Mac:** `Documents/Elder Scrolls Online/live/AddOns/`
3. Install **LibAddonMenu-2.0** from https://www.esoui.com/downloads/info7-LibAddonMenu.html into the same AddOns folder.
4. Launch ESO and enable Bloodsight in the AddOns menu.

On first load, Bloodsight automatically sets "Group Members (Show)" to "Injured" so the rest of the addon works correctly. You don't need to touch any ESO options.

## First-time arrow placement

1. Type `/bs unlock` in chat. The arrow appears on screen.
2. Drag it wherever you want.
3. Type `/bs lock`. The arrow now stays hidden until a teammate is wounded.

## Settings

Open Settings > AddOns > Bloodsight, or type `/bsmenu`.

**Arrow**
- Arrow style: pick from Simple (default), Bloody, or Ornate.
- Lock arrow: toggle placement mode.
- Arrow size: 32 to 256 pixels.
- Center arrow: snap the arrow back to the middle of the screen.

**Sensitivity**
- Health threshold (%): an ally must drop below this to trigger the arrow.
- Activation delay (ms): how long they must stay below before the arrow appears.
- Maximum distance (m): only track allies within this many meters.

**General**
- Addon enabled: master on/off toggle.

## Slash commands

- `/bs menu` or `/bsmenu` open the settings panel
- `/bs lock` / `/bs unlock` toggle arrow placement mode
- `/bs on` / `/bs off` enable or disable the addon
- `/bs status` print current state for debugging
- `/bs debug` toggle a translucent red hitbox over the arrow

## How it works

- On load, Bloodsight forces `SETTING_TYPE_NAMEPLATES` / `NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS` to `NEVER`, hiding all overhead group bars.
- It subscribes to `EVENT_POWER_UPDATE` filtered to health-type updates for group unit tags.
- When a teammate's HP drops below your threshold, a timestamp starts. If they stay low for the delay duration, the addon flips the setting to `INJURED`. The game then shows the overhead bar only for actually-injured members.
- Distance is computed from `GetUnitWorldPosition` in centimeters, converted to meters.
- The arrow is a `CT_TEXTURE` inside a `CT_TOPLEVELCONTROL`. A 50 ms ticker reads `GetMapPlayerPosition` for the player and target, plus `GetPlayerCameraHeading`, then calls `SetTextureRotation` so the arrow points at the wounded ally as you move and turn.
- When the group recovers, the setting flips back to `NEVER` and the arrow hides.

## Compatibility

- Built against API versions 101049 and 101050 (Update 50).
- Does not touch the left-side group frames or the compass.
- Conflicts with other addons that write to `NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS` (for example, HideGroup or HideGroupNecro). Use one at a time.
- PC UI only. The nameplate setter is a no-op on console.
