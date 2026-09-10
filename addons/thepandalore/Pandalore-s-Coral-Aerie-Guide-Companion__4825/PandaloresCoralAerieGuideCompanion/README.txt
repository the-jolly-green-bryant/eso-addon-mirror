PANDALORE'S CORAL AERIE GUIDE COMPANION
FEATURE SPECIFICATION
Version: 1.0.0
Build profile: Stable

CREDITS
-------
- Big thank you to @Soarora, @dat.maggicjuice, and @Bear-TheGodKing for helping nail down the Mind Link selector conditions
- Huge thank you to @Soarora, @cacti-cacti, and @DawnWarrior for playtesting the addon with me.
- Branddi / Coral Aerie Helper: Varallion timing anchors and for kicking off my search for Mind Link selector conditions, and verified safe-zone coordinates.
- Kyzeragon / CrutchAlerts: attached-player arrows and world-drawing renderer.
- andy.s / LibUnits2: unit ID / unit-tag resolution.
- LibAddonMenu-2.0 contributors: settings framework.
- sirinsidiator / LibDebugLogger: optional structured diagnostics.

REQUIRED DEPENDENCIES
---------------------
- CrutchAlerts 2.24.0 or newer (AddOnVersion 22400+).
- LibUnits2 1.03 or newer (AddOnVersion 103+).
- LibAddonMenu-2.0 r43 or newer (AddOnVersion 43+).

1. RELEASE MODEL
----------------
- 1.0.0 is the first stable release line.
- Minor version increments add features (for example 1.1.0).
- Patch version increments are bug fixes (for example 1.1.1).

2. SCOPE AND ACTIVATION
-----------------------
- Operates only in Coral Aerie world-zone ID 1301.
- Supports the three main boss contexts: Maligalig, Sarydil, and Varallion.
- Encounter telemetry is runtime-only and is not persisted.

3. MALIGALIG
------------
Building Static:
- Ability ID: 162279.
- Tracks local-player gains/fades.
- Visible stack model: max(raw gains - 1, 0).
- Configurable LEAVE NOW threshold; default 6 visible stacks.
- Warning disappears when the effect fades.

4. SARYDIL
----------
Role gate:
- Sarydil assistance renders only for a local player whose selected group role is Healer.
- Active Sarydil rendering refreshes when the selected role changes.

Purge handling:
- Ignite: 168776.
- Aperture: 168897.
- State is tracked per target and per effect ID.
- Yellow PURGE notification is visible while any tracked purge target is active.
- Yellow target chevrons remain until every tracked purgeable effect for that target has faded.
- Purge chevron color and scale are independently configurable; default scale 0.65.

Pinpoint handling:
- Pinpoint IDs: 167569 and 158201.
- Maintains one current Pinpoint target.
- Renders a red target chevron and Healcheck @playername.
- Optional secondary text: well look who's dying again!
- Pinpoint color and scale are independently configurable; default scale 0.65.
- Humor line defaults enabled and may be disabled independently.

5. VARALLION
------------
Mark of the Sea timing:
- First Mark deadline = confirmed combat start +39 seconds.
- First countdown is visible for the final 20 seconds.
- Ability 149224 ACTION_RESULT_BEGIN is the only authoritative trigger for Mark of the Sea: Now.
- Predictions never synthesize an authoritative Mark start.

Mind Link / Tether:
- Mind Link endpoint A: 149225.
- Mind Link endpoint B: 149227.
- Beam A: 167437.
- Beam B: 167462.
- Tether window: 25 seconds.
- Next Mark deadline = final beam fade +20 seconds.
- Authoritative Mind Link chevrons use CrutchAlerts attached icons.

Path-distance predictor:
- Samples group-unit world positions every 100 ms.
- Accumulates 3D segment distance from successive position samples.
- Preserves movement history across death state, while display eligibility is limited to living players.
- Displays purple chevrons on the two eligible players with the lowest accumulated path distance.
- First sampling cycle starts at confirmed Varallion combat start.
- Later cycles restart after the final tether/beam fade.
- Tracking and prediction chevrons stop on authoritative 149224 ACTION_RESULT_BEGIN.
- Predictor color and scale are independently configurable from authoritative Mind Link arrows.

Fixed safe-zone markers:
- Four fixed Varallion safe-zone coordinates are rendered as configurable ground circles.
- Safe-zone visibility, circle radius, and color are configurable.

6. USER INTERFACE AND SETTINGS
------------------------------
- LibAddonMenu-2.0 provides the settings panel.
- /pcagc opens the addon settings panel.
- Notification area supports position, width, justification, font sizing, and color configuration.
- Authoritative arrow and predictor-arrow appearance are independently configurable.
- Settings are account-wide.

7. DEPENDENCIES
---------------
Required:
- CrutchAlerts >= 22400.
- LibUnits2 >= 103.
- LibAddonMenu-2.0 >= 43.

Optional:
- LibDebugLogger >= 180.

8. PERSISTENCE AND DATA BOUNDARIES
----------------------------------
Persisted:
- Presentation/settings values.
- Notification position.
- Legacy-migration completion state.

Not persisted:
- Encounter targets.
- Mark/tether deadlines.
- Path samples or predictor rankings.
- Runtime boss state.
- Combat telemetry.

9. COMING IN VERSION 1.1.0
---------------------------------
- Varallion gryphon-entry markers are not implemented or configured in 1.0.0 and are reserved for a future feature release.
- Maligalig Yaghra Larva Popper / Toxic Burst floor tether pending final event/target validation.
