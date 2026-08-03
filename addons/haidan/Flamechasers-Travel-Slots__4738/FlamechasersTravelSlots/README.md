# Flamechasers Travel Slots

Development disclosure: This addon was developed with AI assistance, then reviewed and tested in game.

A configurable ESO fast-travel speed dial with sixteen personal destination slots.

## Features

- Search permanent wayshrines, dungeons, trials, arenas, houses, and other supported travel nodes.
- Search by destination or zone name.
- Save player houses, the current house, group leader travel, and focused-quest routing.
- Focused Quest slots enter matching dungeons, trials, arenas, and Infinite Archive directly when ESO permits it, with nearest-wayshrine fallback.
- Customize each slot with a name, note, icon, and accent color.
- Open from `/fts`, `/ftravel`, the world-map button, or an assigned keybind.
- Assign separate keybinds for all sixteen travel slots.
- Left-click a slot to travel; right-click it to edit.
- The window stays over the world map and preserves wayshrine travel context.

## Installation

Extract the `FlamechasersTravelSlots` folder into:

```text
Documents\Elder Scrolls Online\live\AddOns\
```

Then restart ESO or run `/reloadui`.

## Privacy and dependencies

- No external libraries are required.
- The addon has no network access, telemetry, advertising, or external executable.
- Slot choices are stored only in ESO SavedVariables on the user's computer.
- Slot data is separated by megaserver so NA, EU, and PTS configurations cannot overwrite one another.
- Player account names are read only from ESO's in-game friend and group APIs, plus previously saved slot owners, to provide local house-owner suggestions.

## Language support

- The interface text is currently English.
- Destination type detection uses ESO's localized API identifiers rather than checking English destination names.
