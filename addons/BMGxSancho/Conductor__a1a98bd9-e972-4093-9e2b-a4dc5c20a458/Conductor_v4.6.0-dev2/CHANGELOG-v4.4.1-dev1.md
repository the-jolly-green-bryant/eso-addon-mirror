# Conductor v4.4.1-dev1

## Engineering Stabilization Sprint

- Added a runtime-only live group session with deterministic roster fingerprint and generation.
- Added full runtime cancellation when the live group, zone activation context, or roster changes.
- Prevented saved rotation assignments from becoming executable unless the assigned account is in the current live group.
- Added context stamping and eligibility checks to Timeline events.
- Reset rotation modules, encounter sequence runtime, Timeline state, and network peer state on live-session invalidation.
- Removed persistence of the active trash rotation index; saved trash teams remain configuration only.
- Added stale-assignment diagnostics, disabled unless existing diagnostics are enabled.
- Updated addon version to 4.4.1-dev1.
