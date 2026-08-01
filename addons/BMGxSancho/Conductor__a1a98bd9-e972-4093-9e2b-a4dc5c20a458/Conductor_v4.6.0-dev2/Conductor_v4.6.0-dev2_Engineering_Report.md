# Conductor v4.6.0-dev2 Engineering Report

## Root cause

The runtime encounter profile builder copied `source.burnWindows`, but the researched Rockgrove and Dreadsail Reef profiles store their guidance in `source.burnWindowGuide`. `FoundationEncounter` also failed to retain the supplied guide. As a result, `ExecutionPlanCompiler` received an encounter with no burn windows, `EncounterSequenceEngine` built no steps, and the Timeline correctly had nothing to display or call out.

A second design fault filtered events before they entered the Timeline. Events assigned to unresolved or absent providers could be discarded, turning incomplete provider information into a silent Timeline.

Finally, Timeline events were rendered visually but had no general Timeline-owned dispatcher connecting their preparation/NOW timing to the callout UI.

## Corrected execution path

Encounter profile -> BurnWindowGuide -> ExecutionPlanCompiler -> EncounterSequenceEngine -> TimelineEngine -> Timeline display and callouts

No Encounter Director or parallel authority was added.

## Scope

This build repairs the Timeline backbone and position persistence only. Sharing transport and unrelated dashboards were not redesigned.

## Verification boundary

The package passed syntax and automated Lua execution tests. ESO in-game validation is still required because the local harness cannot reproduce live boss unit tags, combat events, gamepad focus behavior, LibGroupBroadcast traffic, or SavedVariables writes performed by the game client.
