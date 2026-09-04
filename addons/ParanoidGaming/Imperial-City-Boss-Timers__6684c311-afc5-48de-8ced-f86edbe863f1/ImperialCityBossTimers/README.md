# Imperial City Boss Timers

**Author:** Paranoid Gaming  
**Version:** 1.4.0  
**ESO API:** 101050 and 101051  
**Required dependency:** LibAddonMenu-2.0 r43 or newer

Imperial City Boss Timers adds a compact six-row HUD matching the supplied reference. District names are white, active countdowns are red, completed timers display green `READY` text, and everything sits on a black background with adjustable opacity.

## Features

- Automatically starts a district timer from combat-death, unit-death, or recent-reticle-target detection for any of the 12 named Patrolling Horrors.
- Default Timer: 15 minutes.
- Special Event Timer: 7 minutes.
- Changing timer mode recalculates already-running timers from their recorded kill time.
- Solid background bars use ESO's native color fill, drain smoothly behind active district names, and stop before the countdown text.
- Countdown bars have no outline, are enabled by default, and can be disabled, recolored, or given a different opacity.
- District names default to white; countdown text defaults to red and ready text defaults to green.
- `READY` is the default completed-timer display.
- Active timers automatically move above ready districts, sorted with the shortest remaining time first.
- Six large, TV-readable rows designed for gamepad play.
- Compact 65% default size with scaling down to 40% or up to 165%.
- Controller-friendly pixel-position sliders with default X 1700 and Y 1000.
- Adjustable HUD size, colors, black-background opacity, and an optional window border that is off by default.
- Optional title and last-defeated boss line.
- The HUD automatically hides in menus and on the world map.
- An off-by-default `Preview HUD position` toggle keeps a live sample above the add-on settings menu while enabled.
- Preview mode uses a menu-level draw order so bar colors, opacity, size, and position changes remain visible while customizing.
- Optional chat and sound notifications.
- Manual start/ready controls for every district in case a combat event is missed.
- Timers survive `/reloadui` and are separated by server (NA, EU, or PTS).
- One `.addon` manifest for current PC and console add-on support.

## Boss roster

| District | Patrolling Horrors |
| --- | --- |
| Arena | Glorgoloch the Destroyer; King Khrogo |
| Arboretum | Lady Malygda; Ysenda Resplendent |
| Temple | Immolator Charr; Mazaluhad |
| Nobles | Amoncrul; Baron Thirsk |
| Elven Gardens | The Screeching Matron; Zoal the Ever-Wakeful |
| Memorial | Nunatak; Volghass |

Boss-name detection uses the English names above. Translated client names will require a future localization table.

## Installation on PC/Mac

1. Install and enable **LibAddonMenu-2.0 r43 or newer** as a separate add-on.
2. Extract the ZIP.
3. Place the complete `ImperialCityBossTimers` folder in:
   - Windows: `Documents\Elder Scrolls Online\live\AddOns\`
   - macOS: `~/Documents/Elder Scrolls Online/live/AddOns/`
4. Confirm this exact final path exists:
   `AddOns\ImperialCityBossTimers\ImperialCityBossTimers.addon`
5. Start ESO or run `/reloadui`.
6. Open **Settings > Add-ons > Imperial City Boss Timers**.

For console publication or testing, use the official ESO console add-on workflow. The required `.addon` manifest and gamepad-safe settings/UI code are included.

## Commands

- `/icbt` — open settings.
- `/icbt preview` — enable the positioning-preview toggle and open the settings panel.
- `/icbt show` — show the normal HUD.
- `/icbt hide` — hide the normal HUD while continuing to track boss deaths.
- `/icbt help` — show the command list.

## How detection works

The add-on combines ESO's `ACTION_RESULT_DIED` and `ACTION_RESULT_DIED_XP` combat results with unit-death-state detection. It also remembers a living named boss placed under the reticle and accepts that boss's death for up to 90 seconds. Matching reports are de-duplicated for six seconds, and any confirmed matching boss death in Imperial City starts the timer for that boss's district.

For the reticle fallback, look at the living boss at least once during the fight. This avoids treating an old corpse as a new kill. Because add-ons only receive events exposed by ESO, a death outside every client event's range can still be missed; use the manual controls in settings if that happens.

## License

MIT. See `LICENSE.txt`.
