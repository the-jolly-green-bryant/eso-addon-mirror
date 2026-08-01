# ESOGuildActivityAddon
Elder Scrolls Online Guild Activity Addon

This addon periodically logs your guild members' activity to a saved variables file. The format consists of:

 - Timestamp when the snapshot was saved,
 - Name of the guild,
 - @handle of the user,
 - Time (in seconds) since they were last online, or 0 if they're on now,
 - Their rank (represented as a number)

The saved variables file can be parsed by a Lua or LSON parser, or transformed into JSON (the latter is pretty easy with a series of regexes). You can then analyze the data how ever you like. I'm also working on a separate tool to store this data into a Google BigQuery datasource.

Check out https://github.com/allquixotic/ESOGuildActivityDataUpload !

This addon is hosted on ESOUI (Minion) at https://www.esoui.com/downloads/info2190-GuildActivity.html

**Requires LibStub and LibAddonMenu-2.0 to be installed separately. They are NOT bundled with the addon!**
