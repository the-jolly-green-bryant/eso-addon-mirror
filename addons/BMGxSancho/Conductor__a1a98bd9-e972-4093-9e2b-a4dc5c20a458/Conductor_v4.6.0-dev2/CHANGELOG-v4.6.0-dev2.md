# Conductor v4.6.0-dev2

## Timeline authority repair

- Restored authored encounter burn-window guidance to runtime encounter profiles. The previous profile conversion silently discarded `burnWindowGuide`, causing recognized Rockgrove and Dreadsail Reef encounters to compile zero Timeline steps.
- Kept the Timeline as the single execution authority. Callouts are now dispatched directly from active Timeline events at preparation and NOW stages.
- Added effect-first graceful degradation. Missing, unknown, or non-Conductor providers no longer remove an encounter instruction or suppress its callout.
- Moved audience filtering to display/delivery time so Timeline events are not permanently discarded when role or assignment context changes.
- Added a truthful visible fallback for recognized encounters that do not yet have validated strategy guidance instead of allowing a silent Timeline.
- Preserved lead-time metadata from sequence steps into Timeline events.

## Position persistence

- Timeline, Rotation Dashboard, and Buffs & Debuffs Dashboard now save their screen offsets on move stop and restore from SavedVariables.

## Validation

- Lua syntax validation passed for every addon Lua file.
- Automated Timeline harness passed for Rockgrove: Oaxiltso, Bahsei, and Xalvakka.
- Automated Timeline harness passed for Dreadsail Reef: Lylanar/Turlassil, Reef Guardian, and Taleria.
- Verified each tested encounter retained burn windows, compiled execution steps, scheduled a visible Timeline event, and generated a Timeline-sourced callout.
