ResParse 0.3.0 release branch

Core scoring model:
- ResParse authoritatively tracks only successful resurrections performed by the local player.
- EVENT_RESURRECT_RESULT with RESURRECT_RESULT_SUCCESS is the scoring signal; channel duration is not used.
- Every successful other-player target is worth one point. A multi-target Necromancer resurrection can therefore add up to three points when three targets succeed.
- Self-resurrection results are excluded by matching both the local account display name and the local character name.
- Observer-side combat/effect/proximity inference and remote resurrection tracking are not used.

LibGroupBroadcast synchronization:
- Required dependency: LibGroupBroadcast.
- Handler: ResParse
- Custom event: ResParseCompletedResurrection, registered ID 4.
- Data protocol: ResParseScoresheet, registered ID 340.
- On each confirmed local success, ResParse increments the local authoritative total by one, fires the custom event, and publishes the new total through ResParseScoresheet.
- Receivers SET the sender's total to the received value rather than incrementing it, so duplicate protocol messages are idempotent.
- A joining/reloading client requests authoritative totals; the request also carries its own total, and peers coalesce burst responses before publishing their state.

Group/session behavior:
- The scoresheet is pruned against the current group roster on grouped load, group updates, joins, and departures. Raw EVENT_GROUP_UPDATE bursts are debounced to avoid repeated roster scans and UI rebuilds.
- Leaving a group clears the current group tally.
- Joining a new group starts a clean scoresheet and requests synchronization.
- 0.3.0 clears scores from older score-model revisions while retaining UI/settings state; the current revision also clears any tally that may have included a self-resurrection.
- Initial group lifecycle and synchronization run independently of UI creation; a UI failure cannot prevent the tracking/sync state machine from initializing.

Chat behavior:
- ResParse never prints unsolicited runtime or debug information to chat.
- /resparsers explicitly prints the current synchronized scoresheet.
- /resparse sync manually requests and republishes synchronized scoresheet state.
- Developer/debug/status/reset/show/hide slash-command options are not exposed in the release branch.
- The /rp alias is not registered in the release branch.

Commands:
/resparse sync - manually synchronize ResParse scoresheet state
/resparsers - print the current synchronized scoresheet to chat

UI behavior:
- The scoresheet window never displays debug/diagnostic information.
- The window is automatically hidden while ungrouped.
- Display visibility is configurable under Settings > Addons > ResParse.
- Background opacity and scoreboard width remain configurable live.
- LibAddonMenu-2.0 and LibGroupBroadcast are required dependencies.


Branch policy:
- This is the public RELEASE branch.
- DEV and release use the same ResParse addon identity, SavedVariables namespace, scoring model, LGB event ID 4, and LGB protocol ID 340.
- DEV and release versions advance in lockstep and are not intended to be installed simultaneously.
