Tamriel Progress Map 2.6.16
===============================
Author: Raccoonplayz
Requires: LibAddonMenu-2.0 r43+ / LibZone 8.99+
ESO API: 101050 / 101051
Languages: German / English / Russian / French

2.6.16
----------
- Fixes the critical ESO UI error caused by enumerating the global API table while searching for the Tamriel Tomes HUD tracker.
- Skyshard HUD detection no longer touches private ESO API functions such as GetMarketProductInfo.
- Keeps the safe native HUD tracker registry lookup and visible UI-tree fallback from 2.6.15.
- Keeps the custom clickable/scrollable TPM zone-focus dropdown from 2.6.15.

2.6.14
----------
- Fixes Progress page 3 category localization when TPM language differs from the ESO client language.
- Adds a Progress focus selector: All Tamriel or one specific supported zone.
- Zone focus recalculates summary cards, completion categories and the zone list for the selected zone only.
- Keeps history, milestones, goals, Collections and Achievements account/Tamriel-wide.
- Adds Skyshard HUD position 1/2 around the Tamriel Tomes tracker.
- Skyshard HUD now hides with the normal HUD on World Map/menu scenes (M / ESC).

2.6.1
----------
- Adds three pages to the Progress completion block: Completion Categories / Collections / Achievements.
- Shows account-wide ESO collection counts (owned / total) for 15 collectible types.
- Collections are informational only and never change Tamriel completion %.
- Achievement points are read live from ESO by category and never change Tamriel completion %.
- Use the arrows beside the category heading to switch between Completion, Collections and Achievements.

2.4.57 HOTFIXES INCLUDED
------------------------
- /tpm stats and /tpm statistics open the World Map + Statistics when needed.
- Native ESO keybinding for Tamriel Statistics.
- Votan's Minimap/full-map visibility fixes.
- Quest Reward window works independently from Show Zone Progress.
- Improved delayed auto-sizing for long/Skill Point reward lines.
- Reward Details popup opens outside the Quest Reward window.
- Gamepad progress header uses a separate upper-right anchor.
- Completion-category bars are shorter so 100% does not overlap the bar.
- Live settings localization refresh improved, including ON/OFF text.
- Full DE / EN / RU / FR interface support.
- Log Info popup measures localized text dynamically.

MAIN FEATURES
-------------
- Zone completion percentages directly on the world map.
- Quick filters: All / Incomplete / <50% / 100% / Statistics.
- Progress, Economy and PvE / PvP statistics pages.
- Completion categories plus account-wide Collections and Achievement pages.
- Optional Quest Reward window.
- Character/Companion XP progress.
- Per-character combat and activity logs capped at 100 entries each.
- World Event participation tracking.
- Per-character play-time display using ESO's /played API.
- Immediate in-addon language switching: DE / EN / RU / FR.

COMMANDS
--------
/tpm stats                         Open/close Statistics (opens World Map if needed)
/tpm statistics                    Same as /tpm stats
Keybinding                         Controls > Keybindings > Tamriel Progress Map
/tpm page progress                 Open Progress
/tpm page economy                  Open Economy
/tpm page history                  Open PvE / PvP
/tpm lang auto|de|en|ru|fr         Set addon language
/tpm refresh                       Refresh the map display
/tpm checkpoint                    Save an in-memory history checkpoint
/tpm debugreport                   Print a compact bug-report line
/tpm version                       Print the installed TPM version

INSTALLATION
------------
Extract the TamrielProgressMap folder into:
Documents/Elder Scrolls Online/live/AddOns/

LibAddonMenu-2.0 and LibZone are required and are not bundled.
