if not GuildAlert then GuildAlert = { } end
local GA = GuildAlert

if not GA.EventHandlers then GA.EventHandlers = { } end
if not GA.UI then GA.UI = { } end
if not GA.Util then GA.Util = { } end
if not GA.Setup then GA.Setup = { } end

local EH = GA.EventHandlers
local UI = GA.UI
local Util = GA.Util
local Setup = GA.Setup


------[[ Constants ]]------


GA.ADDON = {
	VERSION = "1.1",
	AUTHOR = "@Cardinal05",
	NAME = "GuildAlert",
	TITLE = "Guild Alert",
}

GA.ADDON.TITLE_LONG = GA.ADDON.TITLE .. " (v " .. GA.ADDON.VERSION .. ")"

GA.SAVED_VARS = {
	FILE = "GuildAlertSavedVars",
	VERSION = 1,
	DEFAULTS = {
		EnableAnnouncements = true,
		EnableChatMessages = true,
	},
}


------[[ Variables ]]------


GA.Vars = { }
