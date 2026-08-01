-- Copyright (c) 2025 by Tagarn

-- This add-on may be copied, shared, and used as-is while playing Elder
-- Scrolls Online, provided this notice is left intact. However, this
-- add-on, in part or in full, may not be used in the creation of other
-- add-ons without the express written consent of Tagarn.

-- The Elder Scrolls Online add-on provided by Tagarn ("we," "us," or "our")
-- is for entertainment purposes only. UNDER NO CIRCUMSTANCE SHALL WE HAVE ANY
-- LIABILITY TO YOU FOR ANY LOSS OR DAMAGE OF ANY KIND INCURRED AS A RESULT OF
-- THE USE OF OUR ADD-ON. YOUR USE OF OUR ADD-ON IS SOLELY AT YOUR OWN RISK.



-- SafeAddVersion and ZO_CreateStringId are called on this list (see bottom of file)
local SPA = SkillPointAlerts

local LOCAL_TEXT_COLOR_END = "|r"
local LOCAL_TEXT_COLOR_RED = "|cFF0000"
local LOCAL_TEXT_COLOR_YELLOW = "|cFFFF00"
local LOCAL_TEXT_COLOR_GREEN = "|c00FF00"

local LOCAL_TAGARN = "Tagarn"
local LOCAL_TAGARNS = LOCAL_TAGARN .. "'s"
local LOCAL_TAGARN_GREEN = LOCAL_TEXT_COLOR_GREEN .. LOCAL_TAGARN .. LOCAL_TEXT_COLOR_END
local LOCAL_TAGARNS_GREEN = LOCAL_TEXT_COLOR_GREEN .. LOCAL_TAGARNS .. LOCAL_TEXT_COLOR_END

local LOCAL_APP_NAME = "Skill Point Alerts"
local LOCAL_APP_NAME_LONG = LOCAL_TAGARNS_GREEN .. " " .. LOCAL_APP_NAME
local LOCAL_ALPHA = "ɑ" -- ALT-224
local LOCAL_BETA = "ß"  -- ALT-225
local LOCAL_RELEASE_CANDIDATE = "RC"
local LOCAL_SPA_ABBREV = "[SPA] "
local LOCAL_SPA_ABBREV_RED = LOCAL_TEXT_COLOR_RED .. LOCAL_SPA_ABBREV .. LOCAL_TEXT_COLOR_END
-- local INDENT1 = "|u10:0:: |u" -- "　　"
-- local INDENT2 = "|u40:0:: |u"-- "　　　　" -- alternate whitespace characters for indenting, so ESO doesn't filter them out
local INDENT1 = "　　"
local INDENT2 = "　　　　" -- alternate whitespace characters for indenting, so ESO doesn't filter them out


local language = {
	SPA_APP_NAME = LOCAL_APP_NAME,
	SPA_APP_NAME_LONG = LOCAL_APP_NAME_LONG,
	SPA_TITLE = LOCAL_APP_NAME, -- in case the title differs (currently it does not)
	SPA_TAGARN_GREEN = LOCAL_TAGARN_GREEN,
	
	SPA_ABBREV = LOCAL_SPA_ABBREV,
	SPA_ABBREV_RED = LOCAL_SPA_ABBREV_RED,

	-- Testing version number
	SPA_VERSION = "<<1>> " .. LOCAL_BETA .. "<<2>>",
	SPA_VERSION_TOOLTIP = "The current test version number",

	-- General
	SPA_CHARACTER_COMPLETE = "All delve/dungeon skyshards/group events are complete for <<1>>",
	SPA_UI_DISABLED = LOCAL_APP_NAME .. " is disabled in this zone.",
	SPA_JUMP_MESSAGE = LOCAL_SPA_ABBREV_RED .. "Jumping to <<1>> in <<2>>, <<3>>",

	-- Current Zone box
	SPA_CURRENT_ZONE = "This zone:",

	-- Keybind names for Controls section
	SPA_KEYBIND_TOGGLE_UI = "Toggle UI",
	SPA_KEYBIND_TOGGLE_INFO = "Toggle Progress Information",
	SPA_KEYBIND_JUMP_DELVE = "Teleport to delve",
	SPA_KEYBIND_JUMP_DUNGEON = "Teleport to dungeon",
	SPA_KEYBIND_JUMP_EITHER = "Teleport to a delve or dungeon",

	-- Error Alerts
	SPA_ERROR_NO_TARGET_DELVE = "No Delve Available",
	SPA_ERROR_NO_TARGET_DUNGEON = "No Dungeon Available",
	SPA_ERROR_NO_TARGET_AVAILABLE = "No Target Available",

	-- Stats chat output
	SPA_STATS_TITLE = LOCAL_SPA_ABBREV_RED .. "Stats:",
	SPA_STATS_TITLE_DELVE = LOCAL_SPA_ABBREV_RED .. INDENT1 .. "- Delves:",
	SPA_STATS_PORTS_DELVE = LOCAL_SPA_ABBREV_RED .. INDENT2 .. "- Teleports: <<1>>",
	SPA_STATS_SKYSHARDS_DELVE = LOCAL_SPA_ABBREV_RED .. INDENT2 .. "- Skyshards: <<1>>",
	SPA_STATS_TITLE_DUNGEON = LOCAL_SPA_ABBREV_RED .. INDENT1 .. "- Public Dungeons:",
	SPA_STATS_PORTS_DUNGEON = LOCAL_SPA_ABBREV_RED .. INDENT2 .. "- Teleports: <<1>>",
	SPA_STATS_SKYSHARDS_DUNGEON = LOCAL_SPA_ABBREV_RED .. INDENT2 .. "- Skyshards: <<1>>",
	SPA_STATS_GROUP_EVENTS = LOCAL_SPA_ABBREV_RED .. INDENT2 .. "- Group Events: <<1>>",
	SPA_STATS_QUESTS = LOCAL_SPA_ABBREV_RED .. INDENT2 .. "- Quests: <<1>>",


	--
	-- Info Window 
	--

	-- List Headers
	SPA_TITLE_DELVE = "Delve",
	SPA_TITLE_DUNGEON = "Dungeon",
	SPA_TITLE_ZONE = "Zone",
	SPA_TITLE_TYPE = "Type",
	STA_TITLE_LOCKED = SPA.C.LOCK,

	-- Info window title
	SPA_INFO_TITLE = LOCAL_APP_NAME_LONG .. " - Progress Information",

	-- Delves side
	SPA_INFO_DELVES_SECTION_TITLE = "Delves",
	SPA_INFO_DELVES_COMPLETED_RATIO = "Completed: <<1>>/<<2>>",
	SPA_INFO_DELVES_DLC_LOCKED = "<<1>> are DLC Locked / not counted" .. LOCAL_TEXT_COLOR_END,
	SPA_INFO_DELVES_REMAIN_PERCENT = "Remaining: <<1>>%",
	SPA_INFO_DELVES_REMAINING_LIST_TITLE = "Remaining",
	SPA_INFO_DELVES_COMPLETED_TEXT = "All delve skyshards are completed",

	-- Public dungeons side
	SPA_INFO_DUNGEONS_SECTION_TITLE = "Public Dungeons",
	SPA_INFO_DUNGEONS_COMPLETED_RATIO = "Completed: <<1>>/<<2>>",
	SPA_INFO_DUNGEONS_DLC_LOCKED = "<<1>> are DLC Locked / not counted" .. LOCAL_TEXT_COLOR_END,
	SPA_INFO_DUNGEONS_REMAIN_PERCENT = "Remaining: <<1>>%",
	SPA_INFO_DUNGEONS_REMAINING_LIST_TITLE = "Remaining",
	SPA_INFO_DUNGEONS_COMPLETED_TEXT = "All dungeon skyshards are completed",

	--
	-- Dialogs
	--

	-- Quest Dialog 
	SPA_DIALOG_QUEST_TITLE = "Skill Point Quest Available",
	SPA_DIALOG_QUEST_BODY = "A quest with a skill point reward is available for this public dungeon. To get the quest \"<<1>>\", step outside the dungeon and talk to <<2>>.",

	-- Tag Dialog
	SPA_DIALOG_TAG_TITLE = "Meet My Maker",
	SPA_DIALOG_TAG_BODY = "You have ported to Tagarn, the developer of this add-on! Please tell him you've used " .. LOCAL_APP_NAME .. " to teleport <<1>> <<1[times/time/times]>>, and that you've gained <<2>> skill <<2[points/point/points]>> with it. :)",

	-- New Feature Dialog
	SPA_DIALOG_NEW_FEATURE_TITLE = "Skill Point Alerts\nNew Feature!",
	SPA_DIALOG_NEW_FEATURE_BODY = "Finding the location of your last few delves can be annoying. To help with that, clicking a delve's name in the Progress Information window will now open the map and zoom it to the delve's location.\n\nClick the" .. SPA.C.INFO .. "icon to open the Progress Information window.",

	-- Craglorn Group Delve Dialog
	SPA_DIALOG_CRAGLORN_GROUP_DELVES_TITLE = "Skill Point Alerts\nCraglorn Group Delves",
	SPA_DIALOG_CRAGLORN_GROUP_DELVES_BODY = "You've entered a Craglorn Group Delve — a unique, instanced type of delve. To teleport to someone inside, you must be in a group with them.\n\nIn the Settings Menu, you can enable an option to prioritize group members, ensuring Craglorn Group Delves will be the primary target shown by Skill Point Alerts.",

	--
	-- Settings Menu 
	--

	-- UI
	SPA_SETTINGS_UI = "UI",
	SPA_SETTINGS_UI_HIDE_IN_COMBAT = "Hide UI in combat",
	SPA_SETTINGS_UI_HIDE_IN_COMBAT_TOOLTIP = "The UI will hide when the player is in combat, and will show the UI when combat ends",
	SPA_SETTINGS_UI_HIDE_WHEN_EMPTY = "Hide UI when empty",
	SPA_SETTINGS_UI_HIDE_WHEN_EMPTY_TOOLTIP = "Hides the UI when no friends/guildies are in a needed delve/dungeon",
	SPA_SETTINGS_UI_SHOW_NEW = "Show UI on new target",
	SPA_SETTINGS_UI_SHOW_NEW_TOOLTIP = "Shows the UI when someone enters a needed delve/dungeon",
	SPA_SETTINGS_UI_SHOW_ONLY_FIRST = "Only for the first travel target",
	SPA_SETTINGS_UI_SHOW_ONLY_FIRST_TOOLTIP = "The UI is only shown if the UI is empty when a new travel target becomes available",

	-- Sounds
	SPA_SETTINGS_SOUNDS = "Notification sounds",
	SPA_SETTINGS_SOUNDS_TOOLTIP = "Play a notification sound when a friend/guildie enters a needed delve/dungeon",
	SPA_SETTINGS_SOUND_ONLY_FIRST = "Only for the first travel target",
	SPA_SETTINGS_SOUND_ONLY_FIRST_TOOLTIP = "A notification sound is only played if the UI is empty when a new travel target becomes available",
	SPA_SETTINGS_SOUND_UI_HIDDEN = "When the UI is hidden",
	SPA_SETTINGS_SOUND_UI_HIDDEN_TOOLTIP = "Play notification sounds when the UI is hidden",

	-- Teleport
	SPA_SETTINGS_TELEPORT = "Teleporting",
	-- SPA_SETTINGS_PRIORITY_FRIEND = "Prioritize teleporting to friends",
	-- SPA_SETTINGS_PRIORITY_FRIEND_TOOLTIP = "When there are more than one potential target, and one of them is a friend, choose the friend",
	SPA_SETTINGS_PRIORITY_DROPDOWN = "Prioritize teleporting to:",
	SPA_SETTINGS_PRIORITY_DROPDOWN_TOOLTIP = "When there are more than one potential target, prioritize this type first",
	SPA_SETTINGS_PRIORITY_DROPDOWN_GROUP = "Group members",
	SPA_SETTINGS_PRIORITY_DROPDOWN_FRIENDS = "Friends",
	SPA_SETTINGS_PRIORITY_DROPDOWN_GUILDIES = "Guild members",
	SPA_SETTINGS_PRIORITY_DROPDOWN_NONE = "None",

	-- Progress Window
	SPA_SETTINGS_CONTENT = "Progress Information",
	SPA_SETTINGS_INFO_COUNT_LOCKED = "Include locked delves & dungeons in stats",
	SPA_SETTINGS_INFO_COUNT_LOCKED_TOOLTIP = "The Progress Information statistics will include Delves and Dungeons that are locked by DLC restrictions", 
	
	SPA_SETTINGS_INFO_SHOW_LOCKED = "Show locked delves & dungeons in lists",
	SPA_SETTINGS_INFO_SHOW_LOCKED_TOOLTIP = "Progress Information \"Remaining\" lists will include Delves or Dungeons that are locked by DLC restrictions",	

	SPA_SETTINGS_INFO_PAN_AND_ZOOM = "Zoom map to the selection",
	SPA_SETTINGS_INFO_PAN_AND_ZOOM_TOOLTOP = "When a delve or dungeon name is clicked, and the game map opens, zoom the map to the delve or dungeon",

	SPA_SETTINGS_INFO_WAYPOINT = "Create a map destination marker at selection",
	SPA_SETTINGS_INFO_WAYPOINT_TOOLTOP = "When a delve or dungeon name is clicked, create a map destination at that location. Choosing another delve/dungeon will move the destination marker, and the marker will remain on the map until the player removes it.",
}

for key, value in pairs(language) do
	SafeAddVersion(key, 1)
	ZO_CreateStringId(key, value)
end
