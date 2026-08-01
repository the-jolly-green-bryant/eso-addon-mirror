NameLanguageNinja = NameLanguageNinja or {}

local ADDON = NameLanguageNinja
local LMN = LibMultilingualName

ADDON.NAME = "NameLanguageNinja"
ADDON.DISPLAY_NAME = "Name Language Ninja - Translation assistant"
ADDON.SHORT_NAME = "[NLNinja]"
ADDON.AUTHOR = "@Shinntarou (NA, PC)"
ADDON.VERSION = "1.1.17"

ADDON.ESO_STRING_VERSION = 1

--------
-- in this file local use, private
--------

local playerOnceActivated = false

local function onAddOnLoaded(event, addOnName)
	if (addOnName ~= ADDON.NAME) then
		return
	end

	-- Unregister Loaded Callback
	EVENT_MANAGER:UnregisterForEvent(ADDON.NAME, EVENT_ADD_ON_LOADED)

	-- ConfigMenu
	ADDON.RegisterPanel()

	-- Savedata
	ADDON.LoadSavedVariables()
end

local function onPlayerActivated()
	-- require once
	if (playerOnceActivated) then
		return
	end
	playerOnceActivated = true
	EVENT_MANAGER:UnregisterForEvent(ADDON.NAME, EVENT_PLAYER_ACTIVATED)

	ADDON.InitMessage()

	-- event hook
	ADDON.HookItemEvent()
	ADDON.HookSkillEvent()

	-- chat hook (it's need to avoid other add-on's initialization like pchat.)
	zo_callLater(
		function()
			ADDON.HookChatMessage()
		end,
		3 * 1000
	)
end

--------
-- in this ADDON use, protected
--------

ADDON.GetColoredText = function(langCode, text)
	local color = {r = 1.0, g = 1.0, b = 1.0}

	if langCode then
		if ADDON.SaveData.LanguageColors[langCode] then
			color = ADDON.SaveData.LanguageColors[langCode]
		end
	end

	local r = 255.0 * color.r
	local g = 255.0 * color.g
	local b = 255.0 * color.b

	local format = "|c%02x%02x%02x%s|r"
	local coloredText = string.format(format, r, g, b, text)

	ADDON.develop(
		"getColoredText: langCode:" ..
			langCode ..
				" color r,g,b:" .. color.r .. "," .. color.g .. "," .. color.b .. " format r,g,b: " .. r .. "," .. g .. "," .. b
	)

	return coloredText
end

--------
-- event
--------

EVENT_MANAGER:RegisterForEvent(ADDON.NAME, EVENT_ADD_ON_LOADED, onAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(ADDON.NAME, EVENT_PLAYER_ACTIVATED, onPlayerActivated)
