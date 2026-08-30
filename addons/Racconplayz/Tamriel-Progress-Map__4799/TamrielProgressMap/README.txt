Tamriel Progress Map 2.4.56
===========================
Author: Raccoonplayz
Requires: LibAddonMenu-2.0 r43+ / LibZone 8.99+
ESO API: 101050 / 101051
Languages: German / English / Russian / French

Tamriel Progress Map turns ESO's world map into a completion journal with
three focused statistics pages: Progress, Economy and PvE / PvP.

MAIN FEATURES
-------------
- Zone completion percentages directly on the world map.
- Quick filters: All / Incomplete / <50% / 100% / Statistics.
- Detailed completion tooltips and category progress.
- Optional quest reward window and reward-quality coloring for vanilla quest names.
- Progress journal with Tamriel total, category progress and per-zone overview.
- Economy journal with live ESO balances and per-character received/spent tracking.
- PvE / PvP dashboard with local kill/death counters and bosses defeated.
- Separate 100-entry combat log for NPC/monster/animal/boss/player kills; manual X clear plus an Info tooltip, with automatic oldest-entry removal after 100.
- Separate 100-entry activity log for quests, dungeons, trials, arenas, battlegrounds and PvP activities; manual X clear plus an Info tooltip, with automatic oldest-entry removal after 100.
- Participation-based world-event logging for Dolmens, Abyssal Geysers, Harrowstorms, Volcanic Vents, Mirrormoor incursions, dragon/monster hunts and generic API-connected world events. Legacy dynamic-encounter rows are purged and no longer accepted.
- Combat targets are visually classified by difficulty; kill XP is paired from ESO's XP events.
- Character level/Champion Point XP and active-companion level XP are shown with progress bars.
- Activity entries can include name, Gold, XP, rewards, kills, deaths and duration when ESO exposes the required information.
- Per-character play-time display using ESO's /played API.
- Immediate in-addon language switching: DE / EN / RU / FR.

HOTFIX 2.4.56
-------------
- Quest reward details tooltip is anchored outside the full reward window instead of to the info icon inside it, preventing the reward panel from covering the tooltip.
- Standard LibAddonMenu controls now refresh their labels and tooltips immediately after TPM language changes.
- Checkbox ON/OFF text now follows the selected TPM language instead of remaining in the ESO client language.

HOTFIX 2.4.53
-------------
- Log Info popup now measures localized title/body text dynamically instead of using a fixed height.
- Prevents clipped/overflowing Info text at different UI scales and in DE/EN/RU.
- Language names shown in Settings are now fully localized for the currently selected addon language.
- The visible "ESO Classic" font label is localized in German and Russian.

HOTFIX 2.4.52
-------------
- Quest reward window is now independent from the zone-progress master toggle.
- Full-map quick filters no longer stay visible through minimap addons such as Votan's Minimap.
- Quest reward auto-size re-measures delayed ESO reward text and allows a taller window, reducing clipped reward lines such as skill-point rewards.
- Gamepad map progress header uses a separate upper-right anchor to avoid the zone title.
- DE/EN/RU live-language refresh was hardened and hard-coded Economy labels were localized.
- Added an assignable keybinding for opening/closing Tamriel Statistics.
- LibZone remains a required dependency for supported localized zone names.

TRACKING LIMITATIONS
--------------------
ESO does not expose complete retroactive combat/economy/activity logs to addons.
Local counters and the detailed activity history therefore start when the relevant
TPM tracking feature is installed. Live balances and ESO /played are read directly
from ESO where supported. Quest/activity rewards are recorded only when the client
exposes them at the time the activity completes.

PERFORMANCE / RELEASE HARDENING IN 2.4.38
-----------------------------------------
- Large statistics UI is created lazily only when the journal is opened.
- Map pins/labels are not rebuilt for unrelated events while the world map is closed.
- Quest reward polling is limited to the open world map.
- Activity arrays are defensively capped at 100 entries.
- Gold artwork is kept high-resolution while avoiding an unnecessary 4K texture load.
- Manifest, commands, README and DE/EN/RU release text were synchronized.

COMMANDS
--------
/tpm stats                         Open/close the journal
Keybinding                         Assignable under Controls > Keybindings > Tamriel Progress Map
/tpm page progress                 Open Progress
/tpm page economy                  Open Economy
/tpm page history                  Open PvE / PvP
/tpm lang auto|de|en|ru            Set addon language
/tpm refresh                       Refresh the map display
/tpm checkpoint                    Save an in-memory history checkpoint
/tpm debugreport                   Print a compact bug-report line
/tpm version                       Print the installed TPM version

INSTALLATION
------------
Extract the TamrielProgressMap folder into:
Documents/Elder Scrolls Online/live/AddOns/

LibAddonMenu-2.0 and LibZone are required and are not bundled.

LibZone is used for DE/EN/RU zone-name localization independent of the ESO client language.

HOTFIX 2.4.56
- Fixed French localization syntax errors.
- Completed French localization cleanup.
- Kept the category progress-bar spacing fix so 100% values no longer overlap the bar.
- Synchronized internal and manifest versions.
