# Conductor v4.7.0-dev1.1 Engineering Report

## Confirmed root cause

The v4.7.0-dev1 source assigned LibGroupBroadcast protocol ID 236 to both:

- Conductor capability discovery
- Public Raid Context

The live client also reported that protocol ID 236 was already registered as `Icon Selection`, creating an external collision before Conductor could initialize discovery.

## Source correction

The protocols now use distinct fixed development IDs:

- 231: capability payload transport
- 232-235: optional full session transfer
- 237: lightweight run synchronization
- 238: capability discovery
- 239: public raid context

Network, Run Sync, and Public Raid Context initialization now return immediately after successful initialization. This prevents duplicate ESO event registrations, update registrations, and LibGroupBroadcast declarations if an initialization path is invoked more than once during the same UI load.

## Scope

No Timeline, encounter, roster, assignment, effect-tracking, or UI behavior was changed.
