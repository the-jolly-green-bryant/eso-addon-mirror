# PledgeRunner

*NOTE: this is an early version, so it is probably a bit buggy*
*NOTE2: zone / quest data has been compiled from numerous sources - the French and German versions may not be absolutely correct - if you want to help out, please let me know of any errors (see PledgeData.lua for the full list)*

This addon is mean for guild dungeon running activities. It notifies you when one of your guild mates (who's also running the addon) enters a dungeon zone, begins the run and finishes the corresponding pledge quest.

It is in its very early stages, more features are planned but not implemented yet.

What works:
- communication between guild mates running the plugin
- notification of a guild member entering a dungeon
- ...starting the dungeon
- ...leaving the dungeon
- ...and completing a pledge
- enable/disable per guild

Requirements:
Player needs to have permissions to read and write player guild notes.

Usage:
Either open the addon through the slash command /pledgerunner or (more convenient) set a keyboard shortcut through the Controls > Keybindings menu.
Check the "Enabled" checkbox for each guild that you would like this to work with. 
*By default all are unchecked!*

How the communication works:
Addons are not allowed to send chat messages to other players. So the addon is using a little workaround by putting its messages into the player's guild note. This, however, in turn means that the player needs permission to read/write their guild notes. Some guilds don't allow this, so unfortunately, the addon will not work then. Sorry.

Planned:
- (started) keeping a record of killed bosses, so dungeons can be run without pledges
- (potentially fixed already) fixing an issue where the dungeon timer will reset because the dungeon is split into multiple zones
- timer sometimes (often) misbehaves during unexpected zone changes
- Zone Data is incomplete in terms of boss numbers - these differ quite a bit. Falkreath has 5, City of Ash II has 11!