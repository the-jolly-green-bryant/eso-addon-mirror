Tamriel Progress Map 2.0.6
Author: Raccoonplayz

REQUIRED DEPENDENCY
-------------------
LibAddonMenu-2.0 r43 or newer MUST be installed separately.
The addon manifest uses: ## DependsOn: LibAddonMenu-2.0>=43

WHAT IT DOES
------------
Tamriel Progress Map adds clear completion percentages directly to ESO's world map and zone maps.
It also includes a movable Tamriel Statistics journal with total completion, category progress,
zone progress, level/Champion Point progress and side-quest statistics.

MAIN FEATURES
-------------
- Completion percentages on Tamriel/world overview maps.
- Large zone completion percentage on zone maps.
- Quick filters: All, Incomplete, <50%, 100%, Statistics.
- Tamriel Statistics journal with overall completion and per-zone details.
- Progress categories including main quests, wayshrines, delves, public dungeons,
  world bosses, skyshards, lorebooks and more.
- Side-quest statistics shown separately from ESO's native Zone Guide completion.
- Sort zone statistics by progress or A-Z.
- Movable statistics window with saved position and reset option.
- Live level / Champion Point progress in the statistics window.
- 10 native ESO font styles for percentage values.
- Adjustable percentage size and color, including custom color picker.
- 100% display as percentage, check mark or hidden.
- Optional zone names and detailed completion tooltips.
- Focused active quest reward window with movable/resizable layout.
- Full addon UI language selection: Automatic (ESO), Deutsch, English.

LANGUAGE
--------
The addon interface can be switched completely between German and English in:
Settings -> Addons -> Tamriel Progress Map -> Language.
The change applies immediately, including the settings panel.
ESO zone names themselves still follow the ESO client language.

COMMANDS
--------
/tpm
/tpm toggle
/tpm names
/tpm refresh
/tpm stats
/tpm rewards
/tpm completed
/tpm lang auto|de|en
/tpm mode objectives|categories
/tpm font <style>
/tpm questfont <style>

IMPORTANT NOTES
---------------
- Side quests are statistics-only and do NOT alter ESO's native zone-completion percentage.
- Quest reward information is only available for quests ESO exposes through the active journal API.
- The addon does not bundle LibAddonMenu-2.0; install/update the library separately.

VERSION 2.0.6
-------------
- Added complete German/English language switching for all addon UI text and settings.
- Settings panel now refreshes immediately after changing the addon language.
- Statistics sorting choice (Progress / A-Z) is now saved between sessions.
- Added a settings button to reset the statistics window position.
- Statistics window position is clamped after resolution/UI-size changes so it stays reachable.
- Statistics background is fully opaque while retaining the ESO-style border.
- Level/Champion Point progress updates live while the statistics window is open.
- Added Champion Point maximum handling instead of showing a nonexistent next CP at the cap.
- Reduced repeated statistics calculations with cached supported-zone discovery and statistics snapshots.
- Removed a duplicate full Tamriel calculation from the statistics refresh path.
- Completion-related events now invalidate the statistics cache and refresh visible map data.
- Added event filters for player-only XP/level events where supported.
- Localized remaining debug labels.
- Manifest supports API 101050 and 101051.
- Required dependency remains LibAddonMenu-2.0 r43 or newer.

DEVELOPMENT DISCLOSURE
----------------------
This addon was developed with AI assistance (OpenAI ChatGPT) for code generation,
debugging and review. Releases are tested in-game by the author before publication.
