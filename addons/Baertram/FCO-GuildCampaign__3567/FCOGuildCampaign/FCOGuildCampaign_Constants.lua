FCOGC = FCOGC or  {}
local FCOGuildCampaign              = FCOGC

--For debugging change to: true
FCOGuildCampaign.doDebug = false 

------------------------------------------------------------------------------------------------------------------------
--[Addon variables]
FCOGuildCampaign.addonVars          = {}
local addonVars                     = FCOGuildCampaign.addonVars
addonVars.addonVersion		        = 0.3
addonVars.addonSavedVarsVersion	    = "0.01"
addonVars.addonSavedVarsForAllTable = "SettingsForAll"
addonVars.addonSavedVarsNormalTable = "Settings"
addonVars.addonName				    = "FCOGuildCampaign"
addonVars.addonNameMenu  		    = "FCO GuildCampaign"
addonVars.addonNameMenuDisplay	    = "|c00FF00FCO |cFFFF00 GuildCampaign|r"
addonVars.addonSavedVariablesName   = "FCOGuildCampaign_Settings"
addonVars.settingsName   		    = "FCO GuildCampaign"
addonVars.addonAuthor			    = "Baertram"
addonVars.addonWebsite              = "https://www.esoui.com/downloads/info3567-FCOGuildCampaign.html"
addonVars.addonFeedback             = "https://www.esoui.com/portal.php?uid=2028"
addonVars.addonDonation             = "https://www.esoui.com/portal.php?id=136&a=faq&faqid=131"

------------------------------------------------------------------------------------------------------------------------
--[Libraries]
FCOGuildCampaign.LAM                = LibAddonMenu2
FCOGuildCampaign.LGR                = LibGuildRoster

------------------------------------------------------------------------------------------------------------------------
--[Settings]
FCOGuildCampaign.settingsVars                 = {}
FCOGuildCampaign.settingsVars.defaultSettings = {}
FCOGuildCampaign.settingsVars.settings        = {}
FCOGuildCampaign.settingsVars.defaults        = {}

------------------------------------------------------------------------------------------------------------------------
--[Controls]
--FCOGuildCampaign.ctrlVars = {}
FCOGuildCampaign.rowTooltipCtrl = nil --todo Add a tooltip

------------------------------------------------------------------------------------------------------------------------
--[Other addons]
--FCOGuildCampaign.otherAddons = {}

------------------------------------------------------------------------------------------------------------------------
--[Checks]
FCOGuildCampaign.playerActivatedDone          = false

------------------------------------------------------------------------------------------------------------------------
--[Constants]
--The delimiter which will be added to identify the campaignId in the guild member notes, e.g. ;~101
FCOGuildCampaign.campaignIdDelimiter          = ";~"


--[[
--Addon text for www.esoui.com
[B][SIZE="4"][COLOR="DarkOrange"]FCO GuildCampaign[/COLOR][/SIZE][/B]

Addon designed for PvP guilds: Add an icon at your guild rosters (for enabled guilds) showing if your guild members of other alliances are currently in the same campaignId as you are, or not.

[COLOR="Cyan"]This addon is still in beta mode so if you find any bug please report it via the addon comments, thank you![/COLOR]

[U][B][COLOR="DarkOrange"]Prerequisites[/COLOR]:[/B][/U]
Your guild members must use this addon or it won't work!
Your guild members need the privileges to change their guild member note, as the info which campaignId they currently play in is updated as a string suffix (;~<campaignId>) to their guild member note

If a member refuses to use the addon there is no way to show other guild members the campaignId of that other member!
If a member refuses to enable the guildIds in the settings of this addon there is no way to show other guild members the campaignId of that other member!

You will only "probably" notice not enabled addons by the yellow icons at the guild roster.


[B][U][COLOR="DarkOrange"]Mandatory dependencies[/COLOR]:[/U][/B]
[URL="https://www.esoui.com/downloads/info2784-LibGuildRoster.html"]LibGuildRoster[/URL]



[B][U][COLOR="DarkOrange"]Optional dependencies[/COLOR]:[/U][/B]
None



[U][B][COLOR="darkorange"]Features[/COLOR][/B][/U]
-Settings menu to control the guilds you want to enable the addon for
-Show a new column "C" at the guild roster (for enabled guilds), providing an icon for each guild member who got a character and where the character is in another fraction
Icon colors:
Red: Member's character is in another fraction but in your same campaign
Green: Member's character is in another fraction but in another campaign
Yellow: Guild member's note does not contain the needed idenifier (;~<campaignId>)
-A tooltip at those icons shows you the information abou the current status of that icon/member

-Chat messages will tell you if anything was not working as expected
-Chat messages will tell you if your guild member note could not be updated and if it will be tried once again automatically (as guild member notes cannot be edited in mass, they at least should have a delay of 2 seconds in between, sometimes even 30 seconds are best to prevent to get kicked by the server for message spam).


[U][B][COLOR="darkorange"]How does it work?[/COLOR][/B][/U]
Upon login/zone change with loading screen (e.g. porting into Cyrodiil/IC, or out) the in the settings enabled guildIds will be checked.
Your currently logged in character's campaignId will be written to your guild member note, wih a prefix ;~.
So e.g. it will be in there as ;~101
If your member note is already full it will overwrite the last 5 characters in there (if enabled in the settings -> else you need to take care of that yourself!)
All players using this addon will be able to see a column "C", and icons below that column, at the guild roster of the guilds they have enabled in the settings.
The icon will show different colors,a ccording to the own campaignId and the campaignId behind the ;~ in the members note. Tooltips at the icons will inform you what the color means.



[U][B]Known issues:[/B][/U]
1. The settings menu does not update if you join a new guild/leave a guild. Please do a reloadui after joining/leaving a guild!
2. The guild roster does not update the icons if you had the roster open and another guild member was changing the campaign.
Please change the guilds at the guild roster to update the roster.
]]