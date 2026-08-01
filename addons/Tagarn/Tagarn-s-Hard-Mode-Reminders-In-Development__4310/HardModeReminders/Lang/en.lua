-- SafeAddVersion and ZO_CreateStringId are called on this list (see bottom of file)
local HMR = HardModeReminders

local LOCAL_TEXT_COLOR_END = "|r"
local LOCAL_TEXT_COLOR_RED = "|cFF0000"
local LOCAL_TEXT_COLOR_YELLOW = "|cFFFF00"
local LOCAL_TEXT_COLOR_GREEN = "|c00FF00"
local LOCAL_TEXT_COLOR_ORANGE = "|cFFA500"

local LOCAL_TAGARN = "Tagarn"
local LOCAL_TAGARNS = LOCAL_TAGARN .. "'s"
local LOCAL_TAGARN_GREEN = LOCAL_TEXT_COLOR_GREEN .. LOCAL_TAGARN .. LOCAL_TEXT_COLOR_END
local LOCAL_TAGARNS_GREEN = LOCAL_TEXT_COLOR_GREEN .. LOCAL_TAGARNS .. LOCAL_TEXT_COLOR_END

local LOCAL_APP_NAME = "Hard Mode Reminders"
local LOCAL_APP_NAME_LONG = LOCAL_TAGARNS_GREEN .. " " .. LOCAL_APP_NAME
local LOCAL_ALPHA = "ɑ" -- ALT-224
local LOCAL_BETA = "ß"  -- ALT-225
local LOCAL_RELEASE_CANDIDATE = "RC"
local LOCAL_HMR_ABBREV = "[HMR] "
local LOCAL_HMR_ABBREV_RED = LOCAL_TEXT_COLOR_RED .. LOCAL_HMR_ABBREV .. LOCAL_TEXT_COLOR_END
local LOCAL_HMR_ABBREV_GREEN = LOCAL_TEXT_COLOR_GREEN .. LOCAL_HMR_ABBREV .. LOCAL_TEXT_COLOR_END
-- local INDENT1 = "|u10:0:: |u" -- "　　"
-- local INDENT2 = "|u40:0:: |u"-- "　　　　" -- alternate whitespace characters for indenting, so ESO doesn't filter them out
local INDENT1 = "　　"
local INDENT2 = "　　　　" -- alternate whitespace characters for indenting, so ESO doesn't filter them out


local language = {
	HMR_APP_NAME = LOCAL_APP_NAME,
	HMR_APP_NAME_LONG = LOCAL_APP_NAME_LONG,
	HMR_TITLE = LOCAL_APP_NAME, -- in case the title differs (currently it does not)
	HMR_TAGARN_GREEN = LOCAL_TAGARN_GREEN,
	
	HMR_ABBREV = LOCAL_HMR_ABBREV,
	HMR_ABBREV_RED = LOCAL_HMR_ABBREV_RED,
	HMR_ABBREV_GREEN = LOCAL_HMR_ABBREV_GREEN,

	-- Testing version number
	HMR_VERSION = "v<<1>> ",
	HMR_VERSION_BETA = "v<<1>> " .. LOCAL_BETA .. "<<2>>",
	HMR_VERSION_TOOLTIP = "The current test version number",

	-- Testing message
	HMR_TESTING_NO_DISTRIBUTION = "This version of Tagarn's Hard Mode Reminders is for your testing only, and should not be shared or distributed in any way. If someone is interested in this add-on, please direct them to the RAD Discord channel. Thanks!",

	-- Testing timeout
	HMR_ALMOST_EXPIRED_1 = "This version of Tagarn's Hard Mode Reminders expires in less than <<1>> <<1[days/day/days]>>.",
	HMR_ALMOST_EXPIRED_2 = "Please update with the latest development version.",

	HMR_EXPIRED_1 = "This version of Tagarn's Hard Mode Reminders has expired.",
	HMR_EXPIRED_2 = "Please update with the latest development version.",

	-- Notification Test
	HMR_NOTIFICATION_MESSAGE = "Wipe Reset Reliability (read the notes for details)",
	HMR_NOTIFICATION_PATCH_NOTES = "Patch notes:\n\nv0.51\n- Corrects an error that can happen when the group wipes\n\nv0.50\n- Several changes to make resets after group wipes more reliable\n-- This isn't quite perfect, but it does fix the majority of the issues\n- The \"Dungeon mode is set to normal\" message should only pop up once in a dungeon, rather than every time the player goes through a door",

	-- Text Matching
	HMR_DIFFICULTY_INCREASED = "Difficulty Increased",
	HMR_DIFFICULTY_DECREASED = "Difficulty Decreased",
	HMR_CENTER_ARCANE_KNOT = "The Arcane Knot",
	HMR_CENTER_ARCANE_KNOT_GROWS_UNSTABLE = "grows unstable",

	-- Ability Matching
	HMR_GRANT_SKEEVATON = "skeevaton", -- must be lower case


	-- Controls
	HMR_KEYBIND_STOP = "Immediately Stop Hard Mode Reminders",
	HMR_KEYBIND_TEST = "The test keybind. It could do anything!",
	HMR_KEYBIND_SETTINGS = "Open the settings menu (for testing)",
	--
	-- Settings Menu
	--
	HMR_SETTINGS_GENERAL = "General",
	HMR_SETTINGS_GENERAL_UI_UNLOCK = "Unlock UI",
	HMR_SETTINGS_GENERAL_UI_SHOW = "Show UI",
	HMR_SETTINGS_GENERAL_UI_RESET = "Reset UI Positions",

	HMR_SETTINGS_STATUS_UI = "Status UI",
	HMR_SETTINGS_STATUS_UI_CLOSE_BUTTON = "Show close button",
	HMR_SETTINGS_STATUS_UI_CLOSE_BUTTON_TOOLTIP = "Show a close button next to the status UI.\n\nNormal clicking this button will hide the UI until the current zone is completed or reset.\n\nSHIFT-clicking this button will cause the UI to always be hidden in the current zone.",

	HMR_SETTINGS_STATUS_UI_SHOWN = "Show the status UI",
	HMR_SETTINGS_STATUS_UI_ALWAYS_VISIBLE = "Always visible",
	HMR_SETTINGS_STATUS_UI_ALWAYS_VISIBLE_TOOLTIP = "The status UI is always visible in every zone",
	HMR_SETTINGS_STATUS_UI_VISIBLE_HM_CONTENT_ONLY = "Only in zones with hard mode content",
	HMR_SETTINGS_STATUS_UI_VISIBLE_HM_CONTENT_ONLY_TOOLTIP = "The status UI will always be visible if the player is in a dungeon or a trial",
	HMR_SETTINGS_STATUS_UI_COLOR = "Color UI text by status",

	HMR_SETTINGS_WARNING = "Warning Message",
	HMR_SETTINGS_WARNING_SHOW = "Show the hard mode warning message",
	HMR_SETTINGS_WARNING_FLASH = "Flash the large warning message",

	HMR_SETTINGS_NOT_YET_IMPLEMENTED = "This setting has not been implemented (yet!)",




	-- Hard mode NOT activated
	HMR_SETTINGS_NORMAL_MODE = "When hard mode is not activated",

	-- UI text
	HMR_UI_NORMAL_MODE = "Normal mode",
	HMR_UI_VETERAN_MODE = "Veteran mode",
	HMR_UI_HARD_MODE = "Hard mode",
	HMR_UI_HARD_MODE_UNAVAILABLE = "HM Unavailable",
	HMR_UI_WIPE_RESET = "Resetting...",

	HMR_UI_CLOSE_BUTTON_TOOLTIP = "Hide HMR (Hard Mode Reminders) until you leave the zone.\n\nUse SHIFT-click to always hide HMR in this zone.\n\nUse '/hmr show' to show HMR again.",

	-- Chat Messages
	HMR_CHAT_UI_HIDDEN = "Hard Mode Reminders has been hidden for this run through <<1>>",
	HMR_CHAT_UI_SHOWN = "Hard Mode Reminders will now be shown for bosses in <<1>>",
	HMR_CHAT_UI_DISABLED_NOW = "Hard Mode Reminders is now " .. LOCAL_TEXT_COLOR_ORANGE .. "disabled" .. LOCAL_TEXT_COLOR_END .. " for <<1>>.",
	HMR_CHAT_UI_DISABLED_CURRENTLY = "Hard Mode Reminders is currently disabled for <<1>>.",
	HMR_CHAT_UI_HOW_TO_SHOW = INDENT1 .. "It can be shown by typing '/hmr show' in chat.",
	HMR_CHAT_UI_HOW_TO_REENABLE = INDENT1 .. "It can be reenabled by typing '/hmr show' in chat.",
	HMR_CHAT_UI_REENABLED = "Hard Mode Reminders has been re-enabled for bosses in <<1>>.",
}

for key, value in pairs(language) do
	SafeAddVersion(key, 1)
	ZO_CreateStringId(key, value)
end
