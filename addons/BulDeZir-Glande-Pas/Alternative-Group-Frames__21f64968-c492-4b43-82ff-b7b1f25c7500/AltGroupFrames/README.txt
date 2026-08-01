Alternative Group Frames (Console)
Version 1.4.1 test build
PS5 / ESO API 101049-101050

OVERVIEW

Replaces ESO's default group and raid frames with compact custom frames designed
for gamepad play. Frames show group-member health, shields, trauma, names,
class icons, roles, group-leader status, target markers, range fading, death and
resurrection state, and companions.

CONSOLE ADAPTATION

This package is based on Alternative Group Frames by BulDeZir and Glande-Pas:
https://gitlab.com/teso-addons/alt-group-frames

The original project already contained a gamepad layout. This console package:

- Uses one concrete PS5/gamepad settings table instead of the PC platform-style chain.
- Uses console-safe group-capacity and UI-global fallbacks.
- Uses the original gamepad sizing and default layout automatically.
- Restores Settings > Addons integration through LibAddonMenu-2.0.
- Stores all user options account-wide.

VERSION 1.4.1 TEST CHANGES

- Adds an individually selectable Pillager's Profit Cooldown tracker, disabled by default.
- Tracks the 45-second per-member cooldown through ability 172056 combat events.
- Uses the visible 172055 Pillager uptime effect as a fallback if a console combat event is missed.
- Uses the familiar Pillager uptime icon instead of the cooldown effect's generic icon.
- Shows cooldown icons dimmed with an orange-red timer so they remain distinct from active uptime icons.
- Prevents duplicate combat/effect events from extending the same cooldown.

VERSION 1.4.0 TEST CHANGES

- Adds a separate Settings > Addons > Alternative Group Frames Buffs panel.
- All individual buff trackers are disabled by default to avoid immediate clutter.
- Shows selected active buffs to the right of every active frame, including your own.
- Shows whole-second countdowns in the center and stack counts in the corner.
- Buff icons inherit the existing group-frame scale; there is no separate icon scale.
- Uses event-driven refreshes plus a low-frequency safety rescan for missed changes.
- Tracks active uptime, plus the separately selectable Pillager's Profit 45-second cooldown.
- Keeps the overshield opacity slider available in the main settings panel.

VERSION 1.3.5 TEST CHANGES

- Keeps ESO's native group-frame data pipeline active while hiding its controls.
- Uses the native unit-frame health cache when console GetUnitPower has not yet
  initialized an untouched group member.
- Adds GetUnitPowerInfo as a secondary console-safe health source.
- Uses COMBAT_MECHANIC_FLAGS_HEALTH explicitly, matching ESO's current native UI.
- Prevents a transient living 0-health sample from erasing a valid number or bar.
- Continues to show a full bar while waiting, but now fills in the actual health
  number as soon as any authoritative source has it.

VERSION 1.3.4 TEST CHANGES

- Fixes the 1.3.3 regression where newly joined members could start at 0 health
  with the entire frame shown as missing health.
- Treats 0/0 as uninitialized data instead of a real health value.
- Keeps the last valid health value during ordinary group refreshes.
- Shows a full role-colored placeholder with no false 0 label while a new unit tag
  is waiting for valid health data.
- Retries initialization with a short backoff until ESO supplies valid health data,
  while normal health events remain the immediate update path.
- Prevents shield and trauma refreshes from replacing a valid health number with 0.

VERSION 1.3.3 TEST CHANGES

- Prevents online, living group members from being displayed with 0 health when
  ESO briefly returns uninitialized 0/0 power data for a newly assigned group tag.
- Keeps the last valid health value instead of allowing a transient zero to overwrite it.
- Adds a low-frequency health safety refresh so full-health members initialize even
  when ESO does not send a health-change event after they join.
- Uses maximum health as a temporary full-health fallback until the first valid
  current-health value arrives.

VERSION 1.3.2 TEST CHANGES

- Adds live health updates for the solo player preview, so missing health appears when damaged.
- Adds player and companion shield/trauma event listeners instead of only group-prefix listeners.
- Splits attribute-visual Added and Updated callbacks for the current ESO event signatures.
- Reads active shield and trauma values when a frame is shown, including effects already active.

VERSION 1.3.1 TEST CHANGES

- Fixes a pale/white overlay that could cover health and missing-health colors on console.
- Initializes overshield and trauma bars at zero and keeps them hidden until active.
- Removes the confusing Class colors choice from the settings menu.
- Keeps class icons unchanged; only the health-bar color mode was simplified.

VERSION 1.3.0 TEST CHANGES

- Adds a Health-bar color mode selector: Role colors or ESO default health color.
- Adds independent start/end gradient colors for Tank, Healer, and Damage Dealer roles.
- New-install role defaults are solid health red. Matching start/end colors create a solid bar.
- Adds a customizable missing-health color.
- Adds a customizable overshield color.
- Adds whole-container scale from 50% to 200% in 1% steps.
- Adds horizontal and vertical position sliders.
- Adds a Reset frame position button.
- Adds Show my frame while solo for previewing changes outside a group.
- Keeps settings account-wide.

DEFAULT CONSOLE LAYOUT

- One compact row per group member.
- Up to 12 members per column.
- Role-based health colors are enabled by default.
- Icons indicate class.
- Account names are shown.
- Group difficulty is shown on the leader.
- Out-of-range members fade.
- The frame is anchored near the upper-left of the HUD.

REQUIREMENT

LibAddonMenu-2.0 must be installed and enabled. Use the console distribution of
LibAddonMenu and its required gamepad settings dependency.

SETTINGS

Open ESO's main Settings menu, select Addons, and then select
Alternative Group Frames. A second panel named Alternative Group Frames Buffs contains the buff toggles.

The position sliders use UI coordinates. Position values are clamped when the
frame fits on screen. At very large scales the complete 12-player column can be
taller than the available HUD area, in which case the frame is anchored as close
to the chosen edge as possible.

SAVED-VARIABLE NOTE

Existing testing saves retain their previously stored role colors. Use the
settings panel's reset-to-default function, or change each role color manually,
to see the new solid-red defaults on an existing installation.

COMPATIBILITY

Other UI add-ons can draw their own group health bars. If duplicate bars appear,
disable the group/health-frame feature in the other add-on. In particular,
Khajiit Feng Shui has a health-frame option that should be disabled when using
Alternative Group Frames.

TESTING

1. Open Settings > Addons > Alternative Group Frames and enable the solo preview.
2. Change all six role gradient colors and confirm changes appear immediately.
3. Change missing-health and overshield colors.
4. Hold left/right on Frame scale and verify 1% changes from 50% through 200%.
5. Move the frame with both position sliders and test Reset frame position.
6. Join a two-player group and verify role colors follow each player's selected role.
7. Enter a four-player dungeon and test health, overshields, trauma, death,
   resurrection, range fading, and target markers.
8. Enter a trial and verify all members, column sizing, scale, and positioning.
9. Zone or relog and confirm the settings persist account-wide.
10. Confirm ESO's default group frames remain hidden.

LICENSE

Copyright remains with the original contributors. This modified source version
is distributed under the GNU General Public License v3.0 or later. See LICENSE.
