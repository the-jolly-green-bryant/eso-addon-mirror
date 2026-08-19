# Flamechasers Pledge Queue

Development disclosure: This addon was developed with AI assistance, then reviewed and tested in game.

A focused ESO dungeon-finder window that detects active Undaunted pledge quests and queues the selected pledge activities.

Its main window uses a subtle lavender perimeter frame that keeps the interface
visually grounded over the game world.

## Features

- Detects up to three active pledge quests.
- Displays ESO's own dungeon artwork as a subtle, darkened background for each
  detected pledge card, cropped from ESO's Activity Finder texture region and
  faded smoothly across the full card.
- Select Normal, Veteran, or both for each detected pledge.
- Queue all selected pledge dungeons with one button.
- Separate Random Normal and Random Veteran queue buttons.
- Leave the active queue from the same window.
- View and change the preferred Tank, Healer, or Damage role.
- Verify the active ESO role after selection and again before queueing, preventing
  an unintended role from being used silently.
- Automatically tracks the matching pledge quest after entering its dungeon.
- Open from `/fpq`, `/fpledge`, or an assigned keybind.

All queue starts require a direct user click. The addon does not queue automatically.

## Installation

Extract the `FlamechasersPledgeQueue` folder into:

```text
Documents\Elder Scrolls Online\live\AddOns\
```

Then restart ESO or run `/reloadui`.

## Privacy and dependencies

- No external libraries are required.
- The addon has no network access, telemetry, advertising, or external executable.
- Settings are stored only in ESO SavedVariables on the user's computer.
- Settings are separated by megaserver so NA, EU, and PTS cannot overwrite one another.
- Dungeon card artwork is loaded directly from ESO's Activity Finder assets;
  the addon does not bundle or download image files.

## Language support

- The interface text is currently English.
- Pledge detection compares localized quest and Activity Finder names supplied by the game client; it does not require English quest names.
