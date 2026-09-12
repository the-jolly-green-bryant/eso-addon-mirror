Pandalore's Coral Aerie Guide Companion 1.0.2
Author: thepandalore
Build profile: RELEASE

AI-ASSISTED DEVELOPMENT DISCLOSURE
----------------------------------
Source review, refactoring, test generation, and audit documentation for this
release were performed with OpenAI tooling under maintainer direction. The
maintainer remains responsible for in-client validation, maintenance, and the
public release.

STATUS
------
Version 1.0.2 is the ESOUI-readiness hardening release built from the final
re-audited 1.0.1 common core. It removes locale-dependent boss-name matching,
keeps the CrutchAlerts 2.24.0 minimum only after inspecting that release's exact
source API, and makes the experimental path-distance predictor a separate
opt-in feature that is disabled by default.

The source/package has been reviewed against ESO live API 101050 documentation,
current ESOUI release guidance, the exact CrutchAlerts 2.24.0 release source,
and a recorded veteran Coral Aerie encounter. Offline regression, static-policy,
syntax, archive-integrity, and round-trip checks do not replace the native
in-client acceptance cases listed under LIVE VALIDATION REQUIRED.

PURPOSE AND ACTIVATION
----------------------
A Coral Aerie encounter companion covering Maligalig, Sarydil, and Varallion.
The encounter runtime activates only in Coral Aerie world-zone ID 1301. Runtime
mechanic targets, timers, path samples, and encounter telemetry are not persisted.

Boss/encounter context is not established from localized boss names. Maligalig
and Sarydil context is recovered from their tracked mechanic ability IDs.
Varallion fresh-pull context uses two early combat signals observed in the
maintainer's Coral Aerie capture: 158553 and 158778. Mark of the Sea and its
later effects remain authoritative for their own mechanic state. The two early
Varallion IDs are encounter-log evidence and remain explicit live-acceptance
items; this README does not represent their Lua delivery as an undocumented ZOS
guarantee.

REQUIRED DEPENDENCIES
---------------------
- CrutchAlerts 2.24.0+ (AddOnVersion 22400+).
- LibUnits2 1.03+ (AddOnVersion 103+).
- LibAddonMenu-2.0 r43+ (AddOnVersion 43+).

OPTIONAL DEPENDENCY
-------------------
- LibDebugLogger AddOnVersion 180+.

The CrutchAlerts floor is intentional. The exact 2.24.0 release source at commit
`ec81872bcf135711bff01e4300db5014d01940a9` was inspected for every Crutch API
PCAGC calls: SetAttachedIconForUnit, RemoveAttachedIconForUnit,
RemoveAllAttachedIcons, Drawing.CreateGroundCircle, and
Drawing.RemoveWorldTexture.

INSTALLATION / SAVED SETTINGS
-----------------------------
Install to:

  .../Elder Scrolls Online/live/AddOns/PandaloresCoralAerieCompanion/

PandaloresCoralAerieGuideCompanionSaved is the sole account-wide settings table
used by 1.0.2. The pre-PCAGC MarkOfTheSeaTrackerSaved migration source remains
retired. Existing PCAGC settings are preserved because the active ZO_SavedVars
version remains 1. Presentation/settings state is validated and normalized at
load before it is passed to UI controls. New 1.0.2 predictor enablement defaults
to false when absent from existing SavedVariables.

MALIGALIG
---------
Building Static (162279) is tracked from the local player's effect state using
EVENT_EFFECT_CHANGED and the native stackCount value. LEAVE NOW appears when
the configurable threshold is reached; the default threshold is 6. The warning
clears when the effect fades.

SARYDIL - HEALER UI
-------------------
Sarydil assistance renders only when the local selected group role is Healer.
State is still tracked while the role gate suppresses presentation.

Purge:
- Ignited (168776) and Aperture (168897) are tracked independently per target.
- Yellow PURGE appears while at least one tracked purge target remains active.
- Yellow attached chevrons mark purge targets.
- If both tracked effects exist on one player, one effect fading does not remove
  that player until the other tracked effect also fades.

Pinpoint:
- 167569 and 158201 identify the current Pinpoint target.
- A red attached chevron and Healcheck @playername cue focus healing.
- Optional secondary line: well look who's dying again!

VARALLION
---------
Mark of the Sea / Mind Link / Tether:
- A fresh-pull Varallion context is established by early filtered combat signals
  158553 or 158778 instead of an English boss-name comparison.
- First forecast remains the true player combat edge +36 seconds and is visible
  for the final 20 seconds. An early signal that arrives after that edge does not
  shift the deadline. A signal that races just before the combat-state callback
  only caches encounter context until the real combat edge is received.
- A mid-combat reload does not invent a combat-start time. The first observed
  Varallion signal/mechanic restores encounter context in recovery mode instead.
- 149224 ACTION_RESULT_BEGIN is the authoritative Mark of the Sea: Now trigger.
- 149225 and 149227 identify the two Mind Link endpoints.
- 167437 and 167462 track the two beam effects.
- The first active beam starts the shared 25-second Tether display. Repeated
  effect updates do not restart that timer.
- The later Mark forecast remains final observed beam fade +17 seconds.

Experimental path-distance predictor:
- Disabled by default and separately opt-in under the Varallion arrow settings.
- It is not required for authoritative Mark/Mind Link arrows or timers.
- When enabled before a prediction window, it samples grouped players' raw 3D
  world positions and accumulates traveled segment distance rather than simple
  displacement from origin. On the first Varallion cycle, sampling begins when
  the early locale-neutral Varallion signal establishes context, so movement
  between the combat edge and that first signal is intentionally not inferred.
- Purple chevrons mark the two living eligible players with the lowest measured
  path distance.
- Death removes a player from live eligibility without erasing accumulated
  distance; a resurrected player can re-enter the candidate set.
- Zone/world-position discontinuities are not added as movement distance.
- Enabling the predictor in the middle of an already-running forecast does not
  create a partial-window prediction; it begins with the next prediction window.
- Authoritative Mark begins stop prediction before authoritative Mind Link
  indicators render.

World markers:
- Four configurable fixed Varallion safe-zone circles use CrutchAlerts world
  drawing.
- Because 1.0.2 no longer reads localized boss names, the circles are first
  eligible to render after locale-neutral Varallion encounter context has been
  established, rather than being pre-pull name-triggered.
- Release capability validation requires only the world-drawing calls this
  release actually invokes.

EVENT / PERFORMANCE MODEL IN 1.0.2
----------------------------------
Stateful mechanics use nine separate ability-filtered EVENT_EFFECT_CHANGED
registrations. Building Static is additionally filtered to unitTag "player".

Combat BEGIN observations use three separate EVENT_COMBAT_EVENT registrations,
each filtered by both ability ID and ACTION_RESULT_BEGIN:
- 149224: Mark of the Sea authoritative start.
- 158553: early Varallion context signal observed in the encounter capture.
- 158778: early Varallion context signal observed in the encounter capture.

These native filters reject unrelated traffic before it reaches PCAGC's Lua
callbacks. No FPS, CPU, latency, or frame-time claim is inferred from callback
counts or source size.

The update callback exists only while dynamic work is pending: enabled path
sampling, forecast/Mark-now presentation, or Tether timing. Recovery/static
display state does not maintain an idle polling loop.

SETTINGS
--------
Open Settings > Addons > Pandalore's Coral Aerie Guide Companion.
Slash shortcut: /pcagc

User settings cover notification position/width/alignment/fonts/colors,
Maligalig threshold, Sarydil healer indicators/humor, Varallion safe-zone circles,
authoritative Mind Link arrows, and the separately opt-in experimental path
predictor. Predictor scale/color controls are disabled unless both the master
arrow option and the predictor itself are enabled.

PERSISTENCE
-----------
Only presentation/settings state and notification position are stored account-wide.
Encounter targets, encounter context, Mark or Tether deadlines, path samples,
rankings, and combat telemetry are runtime-only. This intentionally keeps UI
preferences shared across megaservers; no gameplay score/progress data is stored.

DEFERRED FEATURES
-----------------
- Varallion gryphon-entry markers / entry-position handling.
- Maligalig Yaghra Larva Popper / Toxic Burst floor tether. The recorded
  encounter confirms Toxic Burst 159208 -> 168115, but public behavior remains
  deferred until its desired target/rendering contract is finalized.

LIVE VALIDATION REQUIRED
------------------------
Before public upload, validate in the ESO client:
- Canonical shortened folder/manifest identity and one-shot initialization on a
  clean login and /reloadui.
- Clean load with the declared minimum dependency versions and with current ones.
- Native EVENT_COMBAT_EVENT ACTION_RESULT_BEGIN delivery for Varallion 158553
  and/or 158778 on fresh pulls, including first-forecast anchoring to the true
  combat edge rather than to the later signal timestamp.
- Building Static 162279 stackCount behavior and threshold timing on the player.
- Sarydil target identity, overlapping Ignited/Aperture state, Pinpoint, healer
  role gating, and attached-icon cleanup through death/wipe/role changes.
- Varallion Mark, endpoint, beam, wipe/reload, Tether, and recurrence sequencing.
- Safe-zone circle placement after Varallion context detection and complete
  cleanup after wipe, PTE, zone exit, addon disable, and reload.
- Mid-combat /reloadui recovery, including any EFFECT_RESULT_FULL_REFRESH events.
- CrutchAlerts attached-icon and ground-circle behavior at the 2.24.0 minimum
  and on the current release. Source compatibility is proven; native integration
  remains an in-client check.
- Experimental predictor behavior only after explicit opt-in: stationary/block
  walking, jogging/sprinting, roll-dodge, death/resurrection, and roster churn.
- Keyboard/gamepad settings and preview behavior where applicable.
- If performance claims are desired, measure actual client profiler/frame-time
  behavior with the addon disabled/enabled. Offline callback tests are not an
  FPS measurement.

CREDITS
-------
- Branddi / Coral Aerie Helper: prior Coral Aerie mechanic research, timing model,
  and safe-zone coordinates that informed the addon's development.
- Kyzeragon / CrutchAlerts: attached-player icons and world-drawing renderer.
- andy.s / LibUnits2: unit ID / unit-tag resolution.
- LibAddonMenu-2.0 contributors: settings framework.
- sirinsidiator / LibDebugLogger: optional structured diagnostics.

This addon does not bundle or redistribute those dependencies.
