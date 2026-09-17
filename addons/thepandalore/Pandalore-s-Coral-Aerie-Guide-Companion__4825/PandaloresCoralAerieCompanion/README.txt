Pandalore's Coral Aerie Guide Companion 1.1.0
Author: thepandalore
Build profile: RELEASE

AI-ASSISTED DEVELOPMENT DISCLOSURE
----------------------------------
Code development, source review, refactoring, test generation, and audit
documentation for this release were performed with OpenAI tooling under
maintainer direction. The maintainer remains responsible for in-client
validation, maintenance, and the public release.

STATUS
------
Version 1.1.0 is the mechanic-expansion release built from the live 1.0.2
baseline. It adds Maligalig incoming Yaghra Larva Popper guidance, a Building
Static SAFE TO JUMP reset cue, and identity-specific Varallion gryphon entry
guidance. It also replaces the original cumulative-distance Mind Link predictor
with an explicitly experimental recent-movement model that freezes at Mark of
the Sea BEGIN and presents two primary candidates plus one uncertainty candidate.
The predictor remains separately opt-in and disabled by default.

The new mechanic IDs and timing relationships are grounded in two independent
veteran Coral Aerie HM encounter captures. Encounter-log evidence establishes
correlation and timing but does not by itself prove native Lua event delivery;
new 1.1.0 surfaces therefore remain in the live-acceptance matrix below.

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
- CrutchAlerts 2.26.0+ (AddOnVersion 22600+).
- LibUnits2 1.03+ (AddOnVersion 103+).
- LibAddonMenu-2.0 r43+ (AddOnVersion 43+).

OPTIONAL DEPENDENCY
-------------------
- LibDebugLogger (optional; tested with AddOnVersion 180+).

The CrutchAlerts floor is intentional. The exact supplied 2.26.0 release archive
(AddOnVersion 22600; ZIP SHA-256
`3ecc85575f4f96ff9343a6678e11ed74a4d6a5d9985c578c22e69bc422b2e061`) was
inspected for every Crutch API PCAGC calls: SetAttachedIconForUnit,
RemoveAttachedIconForUnit, RemoveAllAttachedIcons, Drawing.CreateGroundCircle,
and Drawing.RemoveWorldTexture. The attached-icon API still accepts PCAGC's
Space API options, and the chevron texture path used by PCAGC is present.

INSTALLATION / SAVED SETTINGS
-----------------------------
Install to:

  .../Elder Scrolls Online/live/AddOns/PandaloresCoralAerieCompanion/

PandaloresCoralAerieGuideCompanionSaved is the sole account-wide settings table
used by 1.1.0. The pre-PCAGC MarkOfTheSeaTrackerSaved migration source remains
retired. Existing PCAGC settings are preserved because the active ZO_SavedVars
version remains 1. Presentation/settings state is validated and normalized at
load before it is passed to UI controls. New 1.1.0 mechanic toggles default to enabled when absent from existing
SavedVariables; the experimental predictor remains disabled by default.

MALIGALIG
---------
Building Static:
- 162279 is tracked from the local player's EVENT_EFFECT_CHANGED state using the
  native stackCount value.
- LEAVE NOW appears when the configurable threshold is reached; default 6.
- SAFE TO JUMP is shown only when 162279 fades after at least 7.5 seconds without
  a refresh, matching the approximately eight-second normal reset observed in the
  HM captures. Short phase/teardown fades do not produce the cue.

Incoming bomb-crab guidance:
- 160007 Toxic Ire ACTION_RESULT_BEGIN identifies an individual Yaghra Larva
  Popper source and its selected group target.
- Repeated Toxic Ire observations from the same source unit are deduplicated.
- Targeted players receive an orange attached chevron and BOMB INCOMING text.
- 159208 Toxic Burst shortens the remaining guidance lifetime for the matching
  source; a bounded fallback lifetime prevents stale state if no terminal signal
  is observed.
- This release does not claim a moving crab-to-player floor tether. The encounter
  log proves source/target correlation but not a persistent hostile unitTag/world
  position contract suitable for that renderer.

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

Experimental recent-movement predictor:
- Disabled by default and separately opt-in under the Varallion arrow settings.
- It is not required for authoritative Mark/Mind Link arrows or timers.
- While a prediction window is active, PCAGC keeps a rolling 10-second history
  of horizontal raw-world X/Z movement for continuously observed group members.
- At authoritative 149224 ACTION_RESULT_BEGIN it freezes a fixed seven-second
  pre-Mark scoring window. The seven-second constant is deliberately rounded
  inside the 5-8 second low-mobility region supported by the current HM dataset;
  it is not presented as the server's exact selection rule.
- The two lowest recent movers receive full purple prediction chevrons; rank
  three receives a smaller/dimmer uncertainty chevron. Rank four is unmarked.
- Death is not a hard selection disqualifier. A dead player can remain ranked if
  positional observation remains sufficiently continuous. Observation gaps or
  insufficient window coverage reduce eligibility rather than being interpreted
  as zero movement.
- Zone/world-position discontinuities are never added as travel distance.
- Prediction freezes at Mark BEGIN; movement during the Mark cast does not alter
  the current ranking.
- 149225/149227 remain authoritative. Their first observed endpoint removes all
  predictive chevrons immediately, and both endpoints are compared against the
  frozen ranking for diagnostic logging.
- Enabling the predictor in the middle of an already-running window waits for the
  next complete prediction window.

Gryphon entry guidance:
- Four checker effects observed at friendly gryphon Takeoff identify the incoming
  gryphon without localized-name matching:
    163185 Iliata    -> LEFT
    163184 Ofallo    -> ENTRANCE
    163188 Mafremare -> RIGHT
    163597 Kargaeda  -> EXIT
- The corresponding direction and gryphon identity are displayed for a bounded
  3.5-second entry window. Fixed 3D entry-position markers are not claimed in
  1.1.0 because the logs do not provide the CrutchAlerts raw-world coordinates
  needed to place them without inference.

World markers:
- Four configurable fixed Varallion safe-zone circles use CrutchAlerts world
  drawing.
- Because 1.0.2 no longer reads localized boss names, the circles are first
  eligible to render after locale-neutral Varallion encounter context has been
  established, rather than being pre-pull name-triggered.
- Release capability validation requires only the world-drawing calls this
  release actually invokes.

EVENT / PERFORMANCE MODEL IN 1.1.0
----------------------------------
Stateful mechanics use thirteen separate ability-filtered EVENT_EFFECT_CHANGED
registrations. Building Static remains additionally filtered to unitTag "player".
The four added effect filters are the Varallion gryphon checker IDs.

Combat BEGIN observations use five separate EVENT_COMBAT_EVENT registrations,
each filtered by both ability ID and ACTION_RESULT_BEGIN:
- 160007: Toxic Ire incoming Popper target.
- 159208: Toxic Burst transition for bounded Popper guidance cleanup.
- 149224: Mark of the Sea authoritative start.
- 158553: early Varallion context signal observed in the encounter capture.
- 158778: early Varallion context signal observed in the encounter capture.

These native filters reject unrelated traffic before it reaches PCAGC's Lua
callbacks. No FPS, CPU, latency, or frame-time claim is inferred from callback
counts or source size.

The update callback exists only while dynamic work is pending: enabled predictor
sampling, forecast/Mark-now presentation, Tether timing, bounded Maligalig timed
guidance, or bounded gryphon entry guidance. Static display state does not keep
an idle polling loop alive.

SETTINGS
--------
Open Settings > Addons > Pandalore's Coral Aerie Guide Companion.
Slash shortcut: /pcagc

User settings cover notification position/width/alignment/fonts/colors,
Maligalig threshold/bomb-crab/SAFE TO JUMP guidance, Sarydil healer
indicators/humor, Varallion gryphon guidance and safe-zone circles, authoritative
Mind Link arrows, and the separately opt-in experimental predictor. Predictor scale/color controls are disabled unless both the master
arrow option and the predictor itself are enabled.

PERSISTENCE
-----------
Only presentation/settings state and notification position are stored account-wide.
Encounter targets, encounter context, Mark or Tether deadlines, path samples,
rankings, and combat telemetry are runtime-only. This intentionally keeps UI
preferences shared across megaservers; no gameplay score/progress data is stored.

DEFERRED FEATURES
-----------------
- Moving Maligalig crab-to-player world tether: target identity is now supported,
  but a stable hostile-unit world-position contract still requires live/API proof.
- Fixed 3D Varallion gryphon entry markers: direction identity is supported in
  1.1.0; raw-world entry coordinates remain deliberately un-inferred.

LIVE VALIDATION REQUIRED
------------------------
Before public upload, validate in the ESO client:
- Canonical shortened folder/manifest identity and one-shot initialization on a
  clean login and /reloadui.
- Clean load with the declared minimum dependency versions and with current ones.
- Native EVENT_COMBAT_EVENT ACTION_RESULT_BEGIN delivery for Varallion 158553
  and/or 158778 on fresh pulls, including first-forecast anchoring to the true
  combat edge rather than to the later signal timestamp.
- Building Static 162279 stackCount behavior, LEAVE NOW threshold timing, and
  SAFE TO JUMP only after a normal approximately eight-second reset; verify short
  phase/teardown fades do not trigger it.
- Toxic Ire 160007 native ACTION_RESULT_BEGIN delivery with sourceUnitId and
  targetUnitId/name sufficient to resolve the intended group target; verify
  repeated casts from one Popper dedupe and arrows clean up after Burst/timeout.
- Sarydil target identity, overlapping Ignited/Aperture state, Pinpoint, healer
  role gating, and attached-icon cleanup through death/wipe/role changes.
- Varallion Mark, endpoint, beam, wipe/reload, Tether, and recurrence sequencing.
- Gryphon checker 163184/163185/163188/163597 native effect delivery and the
  LEFT/ENTRANCE/RIGHT/EXIT identity mapping during actual Takeoff/entry.
- Safe-zone circle placement after Varallion context detection and complete
  cleanup after wipe, PTE, zone exit, addon disable, and reload.
- Mid-combat /reloadui recovery, including any EFFECT_RESULT_FULL_REFRESH events.
- CrutchAlerts attached-icon and ground-circle behavior at the 2.26.0 minimum.
  Source compatibility is proven from the supplied 2.26.0 release archive; native
  integration remains an in-client check.
- Experimental predictor behavior only after explicit opt-in: seven-second
  freeze at 149224 BEGIN, ranks 1-2 primary and rank 3 uncertainty rendering,
  stationary/block-walking, jogging/sprinting, roll-dodge, death/resurrection,
  insufficient coverage, and roster churn.
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
