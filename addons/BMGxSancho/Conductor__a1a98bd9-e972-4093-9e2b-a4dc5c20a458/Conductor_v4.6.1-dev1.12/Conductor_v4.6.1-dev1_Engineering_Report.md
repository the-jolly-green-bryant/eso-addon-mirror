# Conductor v4.6.1-dev1 Engineering Report

## Purpose

This build is a focused stabilization branch created from the exact v4.6.0-dev3 baseline after the VAS2 test exposed severe combat lag, stale-player assignments, failed sharing, overlapping Timeline events, blank-name handling problems, and competing legacy callout ownership.

## Source-level corrections

### 1. Atomic assignment reset

`SupportRotationCallouts/Core.lua` now owns two explicit lifecycle operations:

- `ResetRaidAssignments(reason)` clears all live assignment containers and execution state.
- `RemoveAssignmentsNotInRoster(roster, reason)` removes absent players when the group generation changes.

The reset covers Colossus, Warhorn, Barrier, Nazaray, Pillager, Major Slayer provider rotations, four trash ultimate teams, manual responsibility overrides, active Raid Plans, encounter assignment selection, and trash cursor state.

### 2. Live-session invalidation

`Core/LiveSession.lua` now deduplicates invalid assignment notices by account, responsibility, and roster generation. Invalid owners can no longer create hundreds of identical diagnostic records during a pull.

### 3. One sequencing authority

The legacy support rotation modules still observe casts, effects, and readiness. They no longer render independent sequencing instructions or operate their own active 200 ms callout schedulers. This removes direct competition with the Sequence Runtime and Timeline.

### 4. Timeline conflict policy

The prior collision layout attempted to stack several concurrent instructions and generated `SIMULTANEOUS` summaries. The stabilization renderer selects:

- one highest-value current event near NOW;
- one highest-value next event.

No overflow stack is rendered during live combat.

### 5. Diagnostic cost control

The VAS2 capture reached the 1,500-entry limit and showed raw casts, raw effects, repeated invalid assignments, and rotation errors. This build:

- disables developer/research capture during migration;
- throttles identical records;
- reduces session retention;
- avoids hidden overlay formatting work.

### 6. Polling reduction

The build removes two permanent update registrations and reduces several remaining frequencies:

- Timeline authority: active only while running.
- Post-pull analytics: combat only.
- Recommendation checks: 1,000 ms with idle bypass.
- Timeline display: 200 ms.
- Player roster safety scan: 15 seconds plus event-driven refresh.

### 7. Sharing queue recovery

LibGroupBroadcast `Send()` returns whether a message was queued. A temporary full queue is not a permanent transport failure. Session transfer now holds its state and retries start, data, and completion packets with bounded attempts. Capability-profile sends yield while a Raid Plan transfer is active.

## Static validation completed

- 123 manifest-loaded Lua files.
- Every manifest path exists.
- No duplicate manifest entries.
- All 123 Lua files passed syntax loading through LuaTeX’s Lua runtime.
- Archive integrity verified after packaging.
- SavedVariables identifier preserved.
- LibGroupBroadcast and LibHarvens dependency declarations preserved.

## What static validation cannot prove

This environment cannot execute the ESO UI runtime, PlayStation gamepad scenes, LibGroupBroadcast’s live group channel, or real combat events. Therefore this package is a development validation build, not a verified public release. It must pass the included in-game test plan before publication.
