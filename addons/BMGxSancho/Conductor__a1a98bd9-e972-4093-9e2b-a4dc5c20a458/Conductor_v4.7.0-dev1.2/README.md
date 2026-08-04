# Conductor v4.6.1-dev1

Release stabilization build. See `CHANGELOG-v4.6.1-dev1.md`, the engineering report, and the in-game test plan.

## Current development build: v4.4.1-dev1

## v4.0.1-dev7: Wipe Reset Crash Hotfix

- Replaced the unavailable `zo_strtitle` call in Encounter Knowledge fallback labels with a safe local Lua formatter.
- Unknown or transitional mechanic keys can now be humanized during wipe, reset, and boss re-entry without generating a UI error.
- No combat listeners, network traffic, or runtime polling were added.

# Conductor v3.5.0-dev1

Development build for the Combat Context Engine sprint.

This build keeps player buffs useful for setup testing while restricting group coverage and hostile effects to the correct raid context:

- Self buffs: visible in or out of combat.
- Buffs on others: current group members only.
- Boss debuffs: active boss targets only.
- Trash debuffs: active pull actors engaged by the current group only.
- Nearby duelists, unrelated players, and unrelated enemies are ignored.

The first in-game load and live trial remain the authoritative runtime validation.


## v3.5 Encounter Sequence Engine

The Personalized Timeline is now driven by reusable encounter sequence packages. Timeline visibility uses the same Dashboard Visibility setting as Buffs & Debuffs: Always, Only In Combat, or Never.

## v3.6 Encounter Intelligence

Conductor now includes a passive encounter-observation layer. It watches boss health, boss availability, encounter transitions, and profile-defined combat events, then advances the Sequence Engine without requiring the Trial Lead to type commands or open menus during combat.

Rockgrove and Dreadsail Reef are the first intelligence-validation trials. Their profiles include explicit research confidence and source provenance. Unverified ability IDs or exact thresholds are intentionally treated as provisional until confirmed by live capture.

## v3.6.0-dev3 Timeline modes

The Timeline now follows the raid automatically. With Dashboard Visibility set to Always, it displays roster and ultimate readiness outside combat. During trash pulls it reads the current Raid Setup Ultimate Group and advances through the configured groups after each pull. When a boss is detected, the encounter profile and Sequence Engine replace the trash rotation automatically.


## v3.7.0 combat knowledge
Gear is presented using the names players recognize while preserving canonical set identities for detection. Werewolf is modeled separately from base class so any class can be recognized as a Werewolf DD/support build.


## v3.9.0-dev1: Encounter Knowledge Registry

- Unified structured encounter knowledge across every registered trial and boss.
- Mechanics now expose support response, DPS guidance, positioning, recovery, trigger type, confidence, and validation status.
- Pull Health is chat-only for the Trial Lead; the separate window has been removed.
- Spaulder of Ruin is available in Mythics with support intelligence and aliases.

## v3.8.0-dev1: Raid Intelligence and Post-Pull Health

- Adds automatic raid-state evaluation: Preparing, Pulling, Stable, Recovery, Burn, Execute, and Victory.
- Adds Trial Lead-only post-pull health reporting.
- Measures tracked support-effect uptime and average group coverage.
- Measures sequence completion, misses, skips, and average execution timing.
- Scores support synchronization and boss burn-window quality when sufficient data exists.
- Adds a compact movable and resizable pull-health window with no scrolling requirement.
- Adds an optional chat-HUD report for scrollback review.
- Does not add a generic raid-readiness score or block groups from pulling without ultimates.

## v4.0.0-dev1: Recommendation Engine

Conductor now protects the configured raid plan with automatic, raid-level recommendations. During combat it can issue HOLD BURN, USE BACKUP, REAPPLY, and RESUME BURN guidance through the role-aware Timeline. After each pull, the Trial Lead chat report identifies up to four next-pull coordination priorities. The engine does not grade pull readiness, invent strategy, or coach individual class rotations.


## v4.0.1-dev1: Stability and Performance
Timeline lifecycle persistence, trash assignment integrity, session-sharing diagnostics, and reduced combat update frequency.


## v4.0.1-dev2: Timeline Collision Hotfix

- Deduplicates identical callouts occurring within 1.2 seconds.
- Prioritizes mechanics, automatic recommendations, personal assignments, and major burn commands.
- Staggers simultaneous callouts into as many rows as the configured Timeline height can safely display.
- Collapses overflow into a concise `N MORE / SIMULTANEOUS` summary instead of drawing labels on top of one another.
- Keeps a single dominant callout in the execution position while preserving lower-priority information without illegible stacking.
- Performs collision layout only during the existing 10 Hz Timeline refresh, adding no new combat-event listeners.

## v4.0.1-dev4: Timeline Status Separation

- Treats pre-pull readiness as a fixed status board rather than Timeline events.
- Displays Supports, Waiting for Pull, and DPS readiness in stable positions.
- Prevents `SIMULTANEOUS` collision summaries from appearing outside combat.
- Reserves the center execution marker for actionable combat callouts.

## v4.0.1-dev5: Authoritative Raid Session Import

Accepted invitations now wait for the complete host snapshot. Once received, Conductor imports the shared roster, loadouts, assignments, responsibilities, and encounter context into the recipient's active Raid Session and Raid Setup view.

## v4.0.1-dev7 hotfix
Boss Timeline sequences now survive transient encounter-state resets during live combat. Selecting or opening a saved Prog Team immediately restores its roster into Raid Setup - Team.

## v4.1.0-dev1 usability structure

The console menu is organized around the normal player workflow: learn the addon, choose a role, review group coverage, configure displays, build and share a raid setup, choose tracked effects, and review encounter details. Automatic effect selection is disabled; the Buffs & Debuffs Dashboard follows the effects selected by the user.
