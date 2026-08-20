SATUVE XBOX UI - GAMEPAD MENU INTEGRATION
Version 1.1.19-xbox-menu-nav

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

RECOMMENDED LIBRARIES
- LibAddonMenu-2.0
- LibGamepad
