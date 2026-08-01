# Conductor v4.5.0-dev1

## Runtime Intelligence

- Added a canonical `RuntimeContext` containing the live generation, roster fingerprint, Raid Session identity, encounter state, execution mode, Timeline state, responsibility state, effect state, and scheduler state.
- Added a live `ResponsibilityRuntime` that separates saved assignment ownership from current availability, readiness, activity, confirmation, and expiration state.
- Runtime identity is invalidated whenever the live roster changes, preventing work from a prior raid context from continuing.
- Timeline events now carry the Runtime Context generation, roster fingerprint, and Raid Session ID.
- Encounter mode changes now update the canonical Runtime Context.

## Event-driven execution

- The Encounter Sequence Engine no longer registers its 200 ms update permanently at addon startup.
- Its update loop now exists only while a sequence is active and unregisters on reset, invalidation, or completion.
- Each sequence captures its Runtime Context identity and cancels itself if that identity changes.
- Scheduler activity is exposed through Runtime Context diagnostics.

## Raid Session model

- Raid Session schema upgraded to version 2.
- Added `PREPARING` and `TRANSITION` lifecycle states.
- Runtime metadata now includes live generation and roster fingerprint fields.

## Compatibility

- SavedVariables name is unchanged.
- Network protocols are unchanged.
- Existing saved teams, session sharing, encounter profiles, Timeline display, Buffs & Debuffs, and role assignments remain compatible.
