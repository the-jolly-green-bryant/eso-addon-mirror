# CompassHide

Hides the compass when you are near your focused quest objective, reducing HUD clutter for a more immersive experience. The compass reappears automatically as soon as you move away.

## Dependencies

- [LibGPS](https://www.esoui.com/downloads/info601-LibGPS.html) — required for accurate distance calculations in metres

## Recommended

- [PinKiller](https://www.esoui.com/downloads/info190-PinKiller.html) — highly recommended to hide quest pins from the map and HUD, complementing CompassHide for a fully immersive experience

## Installation

1. Download and extract `CompassHide.zip`
2. Copy the `CompassHide` folder into your addons directory:
   ```
   Documents\Elder Scrolls Online\live\AddOns\
   ```
3. Launch ESO and enable **CompassHide** in the AddOns menu

## Usage

The addon works automatically once enabled. When you are within the threshold distance of your assisted quest objective, the compass is hidden. It reappears when you move away.

> **Note:** The compass will not be hidden near breadcrumb objectives (transitional markers such as doors or zone entrances that lead you into the next part of a quest). Only active goal objectives trigger hiding.

### Slash commands

| Command | Description |
|---|---|
| `/compasshide` | Toggle the addon on or off |
| `/compasshide <value>` | Set the threshold radius in metres (e.g. `/compasshide 50`) |

## Configuration

There is no settings UI. The two options are stored in your SavedVariables file (`CompassHide_SavedVars`) and can be edited directly:

| Variable    | Default | Description                                                                 |
|-------------|---------|-----------------------------------------------------------------------------|
| `enabled`   | `true`  | Whether the addon is active                                                 |
| `threshold` | `100`   | Hide/show radius in metres. The compass is hidden when you are within this distance of the quest objective. Increase for a larger radius, decrease for a smaller one. |

SavedVariables are stored per account at:
```
Documents\Elder Scrolls Online\live\SavedVariables\CompassHide_SavedVars.lua
```

## Compatibility

- API Version: 101040
