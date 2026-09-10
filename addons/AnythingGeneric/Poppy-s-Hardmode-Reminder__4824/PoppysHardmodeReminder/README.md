# Poppy's Hardmode Reminder v0.4.0

Dependency-free Veteran dungeon hardmode reminders: 83 encounters across 51 dungeons, including 33 DLC dungeons. Three base-game encounters are confirmed by user tests; all other entries await in-game validation. English clients only. See ENCOUNTERS.md and DLC_ENCOUNTERS.md for coverage and sources. Trials and arenas are excluded. Lair of Maarselok remains pending because its boss name is reused before the final encounter.

## Install or upgrade
Extract the ZIP and copy PoppysHardmodeReminder into Documents\Elder Scrolls Online\live\AddOns\, replacing the old files. Use redirected Documents if applicable. The manifest must be at AddOns\PoppysHardmodeReminder\PoppysHardmodeReminder.txt. Enable the addon and run /reloadui. Restart ESO if a new installation does not appear.

## Commands
- /hmtest: preview the five-second warning and sound. Unsupported triangle symbols are replaced with exclamation marks.
- /hmdebug: toggle local logs, now including the Veteran flag and test mode.
- /hmnormaltest: toggle automatic encounter testing on Normal. Enabling it near a listed boss may immediately trigger the warning. Turn it off after testing.
- /hmrearm: manually re-arm and check the current encounter, useful after a wipe if the boss list never cleared.

## Next test
On a listed Veteran DLC encounter, enable /hmdebug and approach without pulling. Expect one banner. Repeated events for the same encounter should stay quiet; entering another listed hardmode encounter should trigger a fresh banner. Ordinary bosses should stay quiet. Walk away until the boss tags disappear, wait two seconds, then return to check re-arming. On Normal, automatic reminders should stay off unless /hmnormaltest is enabled. Send the logged zone and boss names if an encounter is missed.

Debug and Normal test mode reset to OFF after login or /reloadui. Reloading also resets duplicate suppression, so a currently visible eligible boss may trigger again.

## Behavior and limits
Boss changes, player activation, and combat transitions check the encounter. Nearby trash combat does not block warnings. Combat fallback shares duplicate suppression. An absent eligible boss for 1.5 seconds re-arms the reminder; brief empty refreshes and forceReset alone do not. Dead bosses are ignored.

This build does NOT detect whether hardmode is already active and may remind you after activation. Wipes with continuously visible boss tags do not automatically re-arm: use /hmrearm. No chat is sent to other players, and no settings are saved.

The v0.1 detector was observed identifying Kra'gh before combat on the user's Normal and Veteran runs. Automatic reminders are confirmed by the user for Kra'gh, The Whisperer, and High Kinlord Rilis. New entries still need in-game validation. Simulated checks cannot validate game timing or rendering.

API reference: https://raw.githubusercontent.com/esoui/esoui/live/ESOUIDocumentation.txt

