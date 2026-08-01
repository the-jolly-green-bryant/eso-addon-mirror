# Conductor v4.6.0-dev1.2

- Fixed a startup UI error caused by Live Session runtime cancellation running before Display initialization.
- Made Display:Hide() safe and idempotent when controls have not yet been created.
- Preserved all Raid Plan, runtime, Timeline, assignment, capability-network, and sharing behavior from v4.6.0-dev1.

## Hotfix

- Added lazy roster storage initialization for startup-safe account and unit-tag lookups.
- Made ultimate-readiness cache access safe before GroupStats initialization completes.
- Preserved all Raid Plan, Timeline, assignment, and sharing behavior.
