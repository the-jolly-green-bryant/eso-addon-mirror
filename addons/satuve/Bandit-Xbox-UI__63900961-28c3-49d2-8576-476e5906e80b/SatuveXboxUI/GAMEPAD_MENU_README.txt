SATUVE XBOX UI - GAMEPAD MENU INTEGRATION
Version 1.1.64-reloadui-init-fix

CHANGES
1. Native ESO main menu focus transfer:
   - LB while the RIGHT text list is active -> focus moves to the LEFT quick/icon rail.
   - RB while the LEFT quick/icon rail is active -> focus moves back to the RIGHT text list.
   - D-pad left/right is no longer used by this bridge.

2. Bandit UI settings grouping:
   - LibAddonMenu/LibGamepad now receives ONE top-level panel named "Bandit UI".
   - Base Options, Player Frames, Attackers Frame, Group Frames, Target Frame,
     Ability Timers, Buffs, Reticle, Damage Statistics, Notifications,
     Frames Settings, Meters, etc. are submenus inside that one panel.
   - Without LibAddonMenu the original Satuve/BUI menu remains as fallback.

CONTROLLER LIBRARIES
- Required for the controller tree and displayed by ESO under Required Add-Ons:
  LibGamepad AddOnVersion 107 (1.0.7) or newer
- Recommended for the classic settings path and fallback:
  LibAddonMenu-2.0 r41 or newer

LibGamepad must be installed and enabled for the Bandit UI controller settings
tree. Find it under ESO's Extensions / Manage My Extensions area.
The Side Panel Settings button opens the same controller panel directly.
LibGamepad is a required manifest dependency for this console-focused package.
LibAddonMenu-2.0 remains optional and recommended for the classic settings
path and fallback.

3. Minimap controller settings:
   - Minimap is now added as a submenu inside the single Bandit UI panel.
   - Enable/disable, size, title, pin scale, all zoom values, pin colors and reset
     are exposed through LibAddonMenu and therefore available to LibGamepad.
   - Changes use the original minimap callbacks and apply immediately.

1.1.24: Unified Bandit UI controller menu now sorts numbered pages 1..20, includes Side Panel (2), Minimap (9), Automation (18), Custom Bar (20), and keeps nested page groups such as Buffs/Advanced Options inside their parent page instead of the left navigation column.


1.1.25: Preserve native nested LAM submenu trees for compatible LibGamepad versions. Root Bandit UI contains only numbered pages 1..20; page-specific submenus such as Buffs/Passives stay inside their parent page. Minimap controller-safe values retained.

1.1.27: Direct LibGamepad hierarchy. Registration is delayed until after PLAYER_ACTIVATED so LibGamepad/ZO_SharedOptions are initialized; the duplicate legacy native settings panel is suppressed whenever the LibGamepad/LAM bridge is active. Root is limited to numbered sections 1..20 and nested page options remain nested.

1.1.28: Documented controller dependencies and menu location, restored Meters page 21, made Side Panel hover text readable in gamepad mode, and routed the Side Panel Settings button directly to the LibGamepad Bandit UI panel.

1.1.29: Declared LibGamepad as a required dependency so ESO displays it in the add-on details. Minimap size now accepts numeric controller values, saves the normalized value, and resizes all live Minimap controls immediately without rebuilding callbacks.

1.1.55: Custom Bandit UI checkboxes, sliders and dropdowns now call their original addon setters directly instead of entering ESO's protected SetSetting path. Minimap following now derives a fresh absolute viewport offset from the current player/map position and performs one named delayed recenter after scene, map and zone transitions.

1.1.56: Fixed the required LibGamepad dependency to internal AddOnVersion 107. LibGamepad 1.0.7+ is accepted.

1.1.57: Minimap map context now follows the player's real ESO map automatically.
City/local, interior and dungeon maps switch back to the correct outdoor/world
map after leaving them, without opening the full map manually. Map selection and
profile refreshes are event-driven. Normal player movement and arrow rotation are
smoothed at about 30 FPS from authoritative player coordinates without accumulated
offset drift. Zone/loading/teleport/map changes snap and recenter immediately.
The minimap hides in combat while context changes continue in the background, then
refreshes and snaps to the correct current map when combat ends.

1.1.58: Fixed blank delve/interior maps and half-clipped outdoor maps after leaving
local areas. Event-based context changes now run ESO's complete OnWorldMapChanged
tile, pin and pan/zoom initialization, followed by two lightweight viewport geometry
passes. The minimap now stays visible and continues smooth tracking during combat.
LibGamepad remains fixed at required AddOnVersion 107 (1.0.7) or newer.

1.1.59: Restored exact alignment between the minimap and ESO's normal full map.
The addon no longer resizes or repositions ESO's stock map coordinate root while
minimap mode is active. Player centering now prefers ESO's native current-map
coordinates, with universal coordinates used only as a temporary fallback when
the native position is unavailable. The 1.1.58 event-based tile initialization,
delayed viewport stabilization, combat visibility and LibGamepad 107 requirement
remain intact.

1.1.64: Made /reloadui startup idempotent and split the former single-frame
initialization burst into four one-shot stages. Scene fragments, global template
hooks, action-bar OnShow hooks, menu registration and event registration are now
guarded against duplicate installation. LibGamepad registration also handles the
case where PLAYER_ACTIVATED already fired. No layout or SavedVariables changed.
