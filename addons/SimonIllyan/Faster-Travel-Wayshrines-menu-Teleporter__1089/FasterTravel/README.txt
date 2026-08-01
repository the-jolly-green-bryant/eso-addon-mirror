Original code by XanDDemoX
Updates by upyachka, Valandil, SimonIllyan
Currently maintained by SimonIllyan

Faster Travel adds two new tabs to the default world map information/navigation control and suggests approximately the closest known wayshrines to your current quest objectives.
Adds favourite wayshrines!
Also supports Cyrodiil campaigns and Transitus Wayshrines including queuing, entering, travelling and tooltip display!

Mandatory dependencies:
	LibWorldMapInfoTab
	LibAddonMenu-2.0
	LibSavedVars
Optional dependencies:
	LibZone

WAYSHRINES TAB
Marks the closest known wayshrine to your quests with the quest's icon from the map (when it is possible to obtain the data).
Displays quest objective tooltips when the mouse is over quest icons.
Numbers in magenta denote how many guild traders are close to every wayshrine.
Lets you fast travel to:
- a recently used wayshrine
- a favourite wayshrine
- a wayshrine in the current zone
- a wayshrine in another zone
- a wayshrine from an alphabetically sorted list
(normal costs apply to all the above, if you're not travelling from another wayshrine)
- a random wayshrine on the current map.
Right-click on wayshrines in this menu to add or remove favourites.

PLAYERS TAB
Lets you easily teleport (for free) to:
- players in your group
- players on your friends list
- zones using players on your friends list, in your group or guild
- players in any of your guilds
(you land at the wayshrine closest to your friend/guildmate's position).
Zones where you have survey or treasure maps are prefixed with green + or yellow *
and suffixed with the number of treasure map (in yellow) and survey (in green) locations
for maps you have in inventory (please note: locations, not maps, so if you have three surveys
pointing to the same location, the number is 1, not 3).

SLASH COMMANDS
/ft zoneName - attempts to teleport to a zone via a player (zoneName can be partial)
/ft zone - if zoneName is literally "zone", use current zone name
/ft @PlayerName - attempts to teleport to a player
/ft CharacterName - attempts to teleport a player using their character name
/ft group - attempts to teleport to the group leader (or a random member of your group if you are the leader)
/ft UnitTag - attempts to teleport to a group member using their unit tag (group1, group2 etc.)

For all of the above you can use /goto instead of /ft (for backward compatibility).

/ft alias name zonename - defines an alias "name" pointing to "zonename", so that if you use:
/ft alias fen Shadowfen
you can then go to Shadowfen with "/ft fen"
/ft alias name - removes a previously defined alias "name"
/ft alias - lists defined aliases
/ft verbosity n - sets verbosity level to n, where:
n = 0 - quiet (almost no messages in chat)
n = 1 - normal verbosity level (default)
n = 2 - a bit more verbose
n > 2 - for debugging only
/ft verbosity - shows verbosity level
/ft recents on|off - turns on/off your "Recent" list
/ft listlen n - sets the max length of "Recent" list to n, where 0<n<100 (default value is 10)
/ft listlen - shows the max length of "Recent" list

RECENT CHANGE LOG
Version 3.3.2 (by SimonIllyan 2026-06-23)
    - fixed off-by-one error in zone list caused by ZOS' renumbering maps

Version 3.3.1 (by SimonIllyan 2026-04-30)
    - Event Zone: Night Market now shows correctly on the WS list
      (in Shambles¿ despite the name, this WS is *not* in a separate Night Market zone)

Version 3.3.0 (by SimonIllyan 2026-04-24)
 	- update for API 101050

Version 3.2.2 (by SimonIllyan 2026-04-13)
	- fixed global variable leak (thanks to Bekkyboo)

Version 3.2.1 (by SimonIllyan 2026-03-13)
 	- undiscovered wayshrines now visible in Favourites/Recents/All lists, but greyed out

Version 3.2.0 (by SimonIllyan 2026-03-03)
 	- update for API 101049

Version 3.1.10 (by SimonIllyan 2025-11-01)
 	- update for API 101048

Version 3.1.9 (by SimonIllyan 2025-08-18)
 	- update for API 101047

Version 3.1.8 (by SimonIllyan 2025-06-11)
	- added zone Solstice and its wayshrines
	- updated dependencies (thanks, Baertram)

Version 3.1.7 (by SimonIllyan 2025-06-01)
 	- update for API 101046

Version 3.1.6 (by SimonIllyan 2025-03-25)
 	- update for API 101045

Version 3.1.5 (by SimonIllyan 2024-10-28)
 	- update for API 101044

Version 3.1.4 (by SimonIllyan 2024-07-16)
 	- update for API 101043

Version 3.1.3 (by SimonIllyan 2024-06-30)
	- circumvented game bug - GetPOIInfo() returning "Darkshade Caverns I" for both DC1 and DC2
	  caused DC2 to never appear on wayshrines lists
	
Version 3.1.2 (by SimonIllyan 2024-06-16)
	- "Jump to Wayshrine" will actually try to jump to current zone
	  (rather than immediately trying parent zone) in Tideholm, Brass Fortress, Artaeum, Apocrypha 
	  
Version 3.1.1 (by SimonIllyan 2024-06-08)
	- fixed Scholarium WS not appearing on the WS list
	- improved randomness of "Jump to Wayshrine" command

Version 3.1.0 (by SimonIllyan 2024-06-05)
	- fixed a bug causing West Weald not to show in the zones list
	- added correct trader count for Skingrad City WS

Version 3.0.10 (by SimonIllyan 2024-05-16)
	- further fixed map tab selection logic
	- fixed search field in Wayshrines tab not being applied in some circumstances

Version 3.0.9 (by SimonIllyan 2024-05-11)
	- fixed problem with changing tab identifier (which led to default tab setting not being preserved between logins)

Version 3.0.8 (by SimonIllyan 2024-05-04)
	- added "Initial tab" setting to select which tab is selected upon opening map;
	  "Automatic" means the former behaviour i.e. tab "Wayshrines" when on a wayshrine and "Players" otherwise,
	  "Last tab" means (rather obviously) the tab that was selected when map was previously closed, 
	  other options force opening a particular tab no matter what
	- removed the "verbosity not set" message appearing in chat on deferred logout

Version 3.0.7 (by SimonIllyan 2024-04-06)
	- apparently I made an april fool of myself, thinking that previous fix was correct; now I am rather sure it is
	
Version 3.0.6 (by SimonIllyan 2024-04-01, not published)
	- fixed "Jump to Wayshrine" sometimes going to locations without an active wayshrine (delves, dungeons)
	
Version 3.0.5 (by SimonIllyan 2024-02-29, not published)
	- fixed a bug causing "Jump to wayshrine" and "Jump to this zone" sometimes going to a wrong zone
	- fixed a (very rare) bug causing Lua errors while verbosity set to level "debug" due to erroneous behaviour of {...} with nil arguments
	
Version 3.0.4 (by SimonIllyan 2024-02-05)
 	- update for API 101041
	- fixed a bug causing only guildies (not friends nor groups members) to be included in headcount for any given zone
	- fixed a bug causing the same guildie to be counted as many times as you have guilds in common with them

Version 3.0.3 (by SimonIllyan 2024-02-01)
	- added a new (keybindable) button on the map screen, "Jump to wayshrine"; it works like "Jump to this zone" with two differences:
		* if it cannot jump to current zone, it will jump at random, no questions asked (like "Jump to this zone" when 'Jump at random if "Jump to this zone" not possible?' option is set to "Always")
		* it will always land you at a usable wayshrine, so if current zone doesn't contain one - like it is in case of delves, dungeons, trials and areas - you'll go to another zone, preferably one containing the current zone (so, for example, you'll go from Old Orsinium to Wrothgar); think of it as a "Get me the hell out of here" button

Version 3.0.2 (by SimonIllyan 2024-01-17)
	- fixed a regression created in 3.0.0 that caused MA/BRP/VH arenas not to appear in Dungeons/Trials, again
	  (seriously, why ZOS didn't assign them POI numbers in their respective zones?! Dragonstar Arena has its POI number…)
	  
Version 3.0.1 (by SimonIllyan 2023-12-26)
	- a bugfix for German translation

Version 3.0.0 (by SimonIllyan 2023-12-26)
	- internal changes to automatically add wayshrines from new content and circumvent everchanging zone indices
	- German translation improved (thanks to ProfKnibble)

Version 2.9.2 (by SimonIllyan 2023-11-05)
	- fixed lead/survey/treasure map count not refreshing immediately after acquiring/using a lead/survey/map
	- fixed White Gold Tower and Imperial City Prison showing twice in "Dungeons and Trials" and "All" categories
	- some internal improvements

Version 2.9.1 (by SimonIllyan 2023-10-29)
	- lead, treasure and survey counts now have customizable colors

Version 2.9.0 (by SimonIllyan 2023-10-11)
	- lead counts (in blue, and with ">" prefix) added in "Players" tab
	- all arenas (Dragonstar, Maelstrom, Blackrose Prison & Vateshran Hollows) now visible
	  in "All" and "Dungeons & Trials" categories
	- changed some internal data structures in preparation for Update 40
	- possibly broke something else

Version 2.8.10 (by SimonIllyan 2023-09-22)
	- update for API 101040
	- added new locations from Update 40
	
Version 2.8.9 (by SimonIllyan 2023-08-25)
	- corrected two more zone numbers
	
Version 2.8.8 (by SimonIllyan 2023-08-20)
	- update for API 101039

Version 2.8.7 (by SimonIllyan 2023-08-06)
	- "Dungeons & Trials" category in "Wayshrines" now hidden by default and keeps the state,
	  like "All" category

Version 2.8.6 (by SimonIllyan 2023-07-04)
	- fix for search in Wayshrines tab

Version 2.8.5 (by SimonIllyan 2023-07-03)
	- mistakenly uploaded wrong file to ESOUI, fixing it now	

Version 2.8.4 (by SimonIllyan 2023-07-01)
	- a new category "Dungeons & Trials" has been added below "All" in "Wayshrines" tab
	
Version 2.8.3 (by SimonIllyan 2023-06-24)
	- corrected number of Galen zone - how comes nobody noticed it earlier…
	
Version 2.8.2 (by SimonIllyan 2023-06-15)
	- removed some pre-U38 cruft
	
Version 2.8.1 (by SimonIllyan 2023-04-23)
	- corrected traders count for Necrom WS
	- fixed a cosmetic bug in "Wayshrines" tab

Version 2.8.0 (by SimonIllyan 2023-04-19)
	- update for API 101038 (Necrom)
	- added Necrom locations
	- fixed a bug regarding "All" category in "Wayshrines" tab

Version 2.7.3 (by SimonIllyan 2023-02-26)
	- update for API 101037 (Scribes of Fate)
	- corrected traders count for Gonfalon & Vastyr wayshrines
	
Version 2.7.2 (by SimonIllyan 2022-12-18)
	- Category All in Wayshrines tab now preserves state (stays collapsed/uncollapsed)
	
Version 2.7.1 (by SimonIllyan 2022-11-18)
	- fixed the problem with The Reach and Arkthzand Cavern being mixed up
	
Version 2.7.0 (by SimonIllyan 2022-11-13)
	- update for API 101036 (Galen and Y'ffelon)
	- Galen locations added
	- fixed minor bugs

Version 2.6.10 (by SimonIllyan 2022-08-19)
	- fixed a bug in sorting zones introduced in 2.6.9 
	
Version 2.6.9 (by SimonIllyan 2022-08-15)
	- update for API 101035 (Lost Depths)
	- added Lost Depths dungeon locations
	
Version 2.6.8 (by SimonIllyan 2022-06-19)
	- fixed display of Zones list (so that "Aurbis" and "Tamriel" are in the right places)

Version 2.6.7 (by SimonIllyan 2022-06-14)
	- fixed a bug preventing jumping to High Isle via "jump to this zone" or "jump to player"

Version 2.6.6 (by SimonIllyan 2022-06-02)
	- update for API 101034 (High Isle)
	- High Isle locations added

Version 2.6.5 (by SimonIllyan 2022-02-14)
	- update for API 101033 (Ascending Tide)
	
Version 2.6.4 (by SimonIllyan 2022-02-10)
	- reworked wayshrine search again, hopefully for the last time - now 
	  it does not collapse Recents nor Favourites
	  
Version 2.6.3 (by SimonIllyan 2022-01-31)
	- added "clear text" button to search field
	
Version 2.6.2 (by SimonIllyan 2022-01-18)
	- fixed "All" section not remaining hidden when it should
	
Version 2.6.1 (by SimonIllyan 2022-01-01)
	- corrected behaviour of the Search field (pressing Enter no longer clears the field,
	  Escape still does)
	- possibly other bugfixes
	
Version 2.6.0 (by SimonIllyan 2021-11-01)
	- updated for API 101032 (Deadlands)
	- Deadlands locations added
	
Version 2.5.14 (by SimonIllyan 2021-09-11)
	- fixed a bug in wayshrine sorting
	
Version 2.5.13 (by SimonIllyan 2021-08-13)
	- updated for API 101031 (Waking Flame)
	- added new locations

Version 2.5.12 (by SimonIllyan 2021-07-10)
	- Russian translation improved thanks to ForgottenLight
	
Version 2.5.11 (by SimonIllyan 2021-06-25)
	- improved random jump zone selection

Version 2.5.10 (by SimonIllyan 2021-06-22)
	- fixed number of traders in Leyawiin

Version 2.5.9 (by SimonIllyan 2021-06-06)
	- fixed some Blackwood wayshrines not showing up in the list
	- improved search for wayshrines by name
	- guild traders in Riften are actually closer to Skald's Retreat Wayshrine 

Version 2.5.8 (by SimonIllyan 2021-05-19)
	- fixed another bug with LibZone
	
Version 2.5.7 (by SimonIllyan 2021-05-18)
	- fixed bug regarding LibZone
	
Version 2.5.6 (by SimonIllyan 2021-05-16)
	- added option to sort Favourites alphabetically;
	  when set to off (default), Favourites are shown in the order they were added
	
Version 2.5.5 (by SimonIllyan 2021-04-25)
	- hopefully fixed problem with LibZone for non-EN users
	
Version 2.5.4 (by SimonIllyan 2021-04-23)
	- updated for API 100035 (Blackwood)
	- when you try to teleport to a zone and it is not possible, random jump will now
	  first try the parent zone of your original target (e.g. if you wanted Fungal Grotto
	  and it was not possible, Stonefalls will be used), unless it is not possible as well,
	  in which case the jump will be fully random; this feature requires LibZone installed
	- major refactoring of Teleport module - should be much more reliable now,
	  as soon as the fresh bugs are caught and fixed ;->
	
Version 2.5.3 (by SimonIllyan 2021-03-30)
	- minor fixes
	
Version 2.5.2 (by SimonIllyan 2021-03-05)
	- added the option (can be set to Never, Always or Ask) to jump to random zone 
	  if "Jump to This Zone" is impossible for lack of eligible players 
	- fixed storing Wayshrine tab settings
	- completely redesigned code responsible for updating Recents list
	
Version 2.5.1 (by SimonIllyan 2021-02-18)
	- fixed a bug regarding binding items (sic!) reported by Lexynide
	- probably fixed the double-cancel problem that I couldn't solve since version 2.1
	
Version 2.5.0 (by SimonIllyan 2021-02-14)
	- finally, Options/Addons/FasterTravel added
		* LibAddonMenu-2.0 and LibSavedVars become mandatory dependencies
		* settings from older versions not preserved

Version 2.4.4 (by SimonIllyan 2021-01-16)
	- search in Wayshrines tab added - centers the list on a wayshrine matching entered string
	
Version 2.4.3 (by SimonIllyan 2020-12-06)
	- the number of guild traders near every wayshrine is shown in zones and "All"
	- ability to sort "All" category either alphabetically by name (as it was before)
	  or by the above number
	- "Jump to current zone" (same as /goto zone) button added in the map
	- some bugs fixed

Version 2.4.2 (by SimonIllyan 2020-11-09)
	- "/ft zone" (or "/goto zone") will now jump to the current zone
	- added key binding for the above (suggested by GTMeteor)
	- added more localization strings and fixed spelling

Version 2.4.1 (by SimonIllyan 2020-11-07)
	- first step towards DE/FR/RU localizations
	- fixed the crash for client languages other than English
	- some other bugfixes and optimizations

Version 2.4.0 (by SimonIllyan 2020-10-26)
	- updated for API 100033 (Markarth)
	- The Reach locations added
	- several internal changes
	
Version 2.3.13 (by SimonIllyan 2020-09-19)
	- missing locations added
	
Version 2.3.12 (by SimonIllyan 2020-08-25)
	- updated for API 100032 (Stonethorn)
	- minor bugs fixed
	
Version 2.3.11 (by SimonIllyan 2020-07-23)
	- refreshed this README
	- fixed the incorrectly labelled "The Brass Fortress" (appeared as another Clockwork City)	

Version 2.3.10 (by SimonIllyan 2020-07-05)
	- added the two new wayshrines from Patch 6.0.8
	- minor bugs fixed
	 
Version 2.3.9 (by SimonIllyan 2020-06-15)
	- sorting in "Players" tab fixed - now ignores the article "The", just like in "Wayshrines" tab
	- fixed a bug causing LUA errors when visiting Greymoor zones with "recents" turned off
	
Version 2.3.8 (by SimonIllyan 2020-05-25)
	- updated for API 100031 (Greymoor)
	- LibWorldMapInfoTab by Votan is now a mandatory dependency (without it, tab icons get clobbered)
	
Version 2.3.7 (by SimonIllyan 2020-04-14)
	- minor bugs fixed
	
Version 2.3.6 (by SimonIllyan 2020-03-29)
	- the functionality added in 2.3.4 & 2.3.5 should now work for DE, FR, RU language versions
	
Version 2.3.5 (by SimonIllyan 2020-03-29)
	- the number of surveys/maps in a zone is also shown, if nonzero
	
Version 2.3.4 (by SimonIllyan 2020-03-26)
	- included (with author's permission) code of SurveyTheWorld addon;
	  now Players tab shows presence of surveys (+) and treasure maps (*) in a zone
	
Version 2.3.3 (by SimonIllyan 2020-02-24)
	- updated for API 100030 (Harrowstorm)

Version 2.3.2 (by SimonIllyan 2020-01-10)
	- added "/ft listlen" command
	
Version 2.3.1 (by SimonIllyan 2020-01-02)
	- fixed a bug causing jumping to group ("/goto group") or group members ("/goto group1" etc.) to fail
	
Version 2.3.0 (by SimonIllyan 2019-12-31)
	- "/agoto" command is dead, long live "/ft alias" command
	- "/recents" changed to "/ft recents"
	- "/ft verbosity" added
	- some internal changes (debugging etc.)
	
Version 2.2.16 (by SimonIllyan 2019-12-15)
	- fixed a bug introduced in 2.2.15, which prevented teleporting to players in delves/houses
	- fixed /goto @playername command, which now should work as advertised
	
Version 2.2.15 (by SimonIllyan 2019-12-10)
	- Dragonguard Sanctum Wayshrine now correctly located in its own zone: Tideholm
	- Murkmire wayshrines listed again
	- an annoying bug with player being sometimes teleported to "Coldharbour Surreal Estate" instead of just "Coldharbour" hopefully fixed
	- /goto zonename tries to teleport you to a different player each time - good for discovering wayshrines
	
Version 2.2.14 (by SimonIllyan 2019-10-22)
	- Updated for API 100029
	- Added Dragonhold (Update 24) locations
	
Version 2.2.13 (by SimonIllyan 2019-09-16)
	- Fixed some bugs introduced in 2.2.12

Version 2.2.12 (by SimonIllyan 2019-09-15)
	- Added cathegory ALL (containing all wayshrine names) under Wayshrines tab
	
Version 2.2.11 (by SimonIllyan 2019-08-12)
    - Updated for API 100028
	- Added Scalebreaker (Update 23) locations 
	- Fixed minor bugs
	
Version 2.2.10 (by SimonIllyan 2019-05-26)
	- Elsweyr locations added
	
Version 2.2.9 (by SimonIllyan 2019-05-13)
	- Fixed a bug in expanding shortened zone names
	
Version 2.2.8 (by Valandil 2019-05-01)
    - Get somewhat working on Elsweyr.

Version 2.2.7 (by Valandil 2019-05-01)
    - Incorporated fix by Votan for bug report:
    https://www.esoui.com/downloads/info1399-VotansMinimap.html#comments

Version 2.2.6 (by SimonIllyan 2019-04-24)
    - Fixed a bug where player teleported to a location that has a zone name as a substring rather than to the zone proper
      (for example, to Coldharbour Surreal Estate instead of Coldharbour)
    - /f5housing command renamed to /recents, since housing preview works whether this option is set or not -
      what changes is the availability of the "recent" location list
    - minor bugfixes and changes to predefined zone aliases

Version 2.2.5 (by SimonIllyan 2019-03-17)
    - Updated for API 100026 (Wrathstone)
    - minor changes to predefined zone aliases

Version 2.2.4 (by Valandil 2018-10-22)
    - Updated for API 100025 (Murkmire)

Version 2.2.3 (by SimonIllyan 2018-09-02)
    - /f5housing on|off now reloads UI by itself
    - favourites, aliases and the status of /f5housing are now account-wide (shared by all characters),
      recents are still per character

Version 2.2.2 (by SimonIllyan 2018-08-24)
    - Fixed sorting of zone names beginning with "The" ("The" should be ignored)
    - Fixed reverse alphabetical sorting

Version 2.2.1 (by SimonIllyan 2018-08-20)
    - Fixed alliance icons in Wayshrines tab
    - "/agoto" output is now sorted by value
    - When /f5housing is set to off, recents list is not being updated;
      as an interim solution it is hidden from view as well.

Version 2.2.0 (by SimonIllyan 2018-08-19)
    - /agoto without arguments now lists existing aliases, "/agoto key" removes an alias for "key"
    - Added predefined aliases for ambiguous zone names
    - Added "/f5housing on|off" command to dynamically enable/disable WfD's fix for house preview.
      This fix, unfortunately, has a side effect - cancelling a teleport must be done TWICE.
      Some people find it annoying, so now it is possible to switch it off and on;
      "/reloadui" is REQUIRED afterwards.

Version 2.1.1, 2.1.2 (by Valandil 2018-08-17)
    - Updated for API 100024

Version 2.1.0 (by SimonIllyan 2018-06-28)
	- Updated for API 100023
	- Added locations from chapters and DLCs - Vvardenfell, Summerset, Clockwork City, etc.
	- Fixed a bug causing F5 (previev house) to fail, thanks to WfD.

Version 2.0.5
	- Updated for API 100012 - Thanks Garkin!
	- Fixed incorrect Zone names
	- Fixed currency tooltip for recall

Version 2.0.4
	- Fixed teleport during interaction fall through map bug.

Version 2.0.3
	- Added favourites category and right click menu.
	- Added partial Zone Name matching for /goto command

Version 2.0.2
	- Added Craglorn Trial wayshrine support.
	- Added teleport error detection and attempt next player upon failure when teleporting by zone name.

Version 2.0.1
	- Fixed intermittent display of incorrect focused quest icon
	- Removed prefix from Cyrodiil queue status displays.
	- Fixed potential error message when clearing icons on world map open.
	- Fixed AD faction order table in LocationData.

DISCLAIMER
THIS ADDON IS NOT CREATED BY, ENDORSED, MAINTAINED OR SUPPORTED BY ZENIMAX OR ANY OF ITS AFFLIATES.
