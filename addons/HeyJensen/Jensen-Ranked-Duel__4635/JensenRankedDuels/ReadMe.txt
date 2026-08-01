Jensen Ranked Duels v1.2.8

New in v1.2.8:
The Leaderboard button now reloads UI automatically before opening.
After the reload, the leaderboard opens again with the newest data the client has synced.
The /jrd leaderboard and /jrd lb commands now do the same thing.

New in v1.2.7:
Added Join Queue and Leave Queue buttons to the main addon menu.
Join Queue sends a queue request to the Windows client after a UI reload.
When the client finds a match, it plays a queue pop sound, shows a Windows popup, and copies the invite command.
Added synced queue status support through QueueData.lua.

New in v1.2.6:
Added the official synced leaderboard inside the addon.
Added /jrd leaderboard and /jrd lb.
Added a Leaderboard button in the main menu.
The Windows client downloads official leaderboard data and writes it to the addon folder.
Use /reloadui after the client syncs to refresh the in game leaderboard.

New in v1.2.5:
Added companion client export support.
Ranked wins now save a JRDREPORT export line into SavedVariables for the Windows client.
The client can upload pending ranked wins to the Jensen Ranked Duels Worker.
Manual Discord copy and paste reports still work as a fallback.
Use /jrd client in game to see client info.

New in v1.2.4:
Forfeit handling was tightened again.
The addon now explicitly ignores DUEL_RESULT_FORFEIT.
The addon now only logs duels when ESO reports an actual DUEL_RESULT_WON result.
Forfeit, draw, cancel, or unreadable endings should not count as wins or losses and should not create ranked report commands.

New in v1.2.3:
Join Competitive now opens a local /say message that starts with Ranked Duels.
Join Unranked and Leave Queue now also use Ranked Duels wording.
Forfeit, draw, canceled, or unreadable duel endings are no longer logged as wins or losses.
Forfeit endings will not create ranked Discord report commands.

New in v1.2.2:
Join Competitive now opens a local /say message looking for a ranked 1v1 duel.
Join Unranked now opens a local /say message looking for an unranked 1v1 duel.
Leave Queue now opens a local /say message saying you left the local duel queue.
The addon fills the chat box, then the player presses Enter to send.
Added /jrd queue ranked, /jrd queue unranked, and /jrd queue leave.

New in v1.2.1:
Fixed a Lua syntax error caused by a leftover duplicate code block after the report command function.

New in v1.2.0:
Added Duel Log window in the addon menu.
Duel Log shows opponent records and recent local duel history.
Use the Scroll Up and Scroll Down buttons to move through the log.
Added /jrd log command.
Added Reset Local button in the Duel Log window.
5 digit report codes now change every second.
Report commands print opponent_eso without @ so Discord does not turn it into a mention.

Install:
1. Put the JensenRankedDuels folder inside your ESO AddOns folder.
2. Restart ESO or type /reloadui.
3. In game, type /jrd toggle to open the menu.

Commands:
/jrd
/jrd toggle
/jrd mini
/jrd log
/jrd ranked on
/jrd ranked off
/jrd stats
/jrd report
/jrd reset

Ranked flow:
1. Register in Discord with your exact ESO account name.
2. Turn ranked mode on in the addon.
3. Duel another registered player.
4. Fight must last longer than 10 seconds.
5. Winner copies the report command printed by the addon into Discord.
