# Conductor v4.5.0-dev2

## Sequence Foundation
- Added canonical Sequence Runtime state layered on Runtime Context.
- Tracks the current stage, current step, pending steps, completed steps, and missed steps.
- Rebuilds from Encounter Sequence Engine events instead of introducing another polling loop.
- Invalidates sequence runtime automatically when the live roster or Runtime Context changes.

## Major Mending
- Added Major Mending to the canonical Effect Registry.
- Added it to Buffs - Timers and enabled it by default.
- Added normalized provider references for Obsidian Shield, Accelerated Growth, and Essence Drain.
- Added the Major Mending responsibility record.
- Runtime detection uses the existing EVENT_EFFECT_CHANGED path and the canonical effect name.

## Compatibility
- SavedVariables, network protocol, Raid Session sharing, team profiles, and encounter-profile formats are unchanged.
