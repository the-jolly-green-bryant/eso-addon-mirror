DefaultLanguageNinja = DefaultLanguageNinja or {}

local ADDON = DefaultLanguageNinja

ADDON.NAME = "DefaultLanguageNinja"
ADDON.DISPLAY_NAME = "Default Language Ninja - Language Selector"
ADDON.SHORT_NAME = "[DLNinja]"
ADDON.AUTHOR = "@Shinntarou (NA, PC)"
ADDON.VERSION = "1.0.3"

--------
-- in this file local use, private
--------

local intervalSecs = 60
local playerOnceActivated = false

local function intervalCallback()
	ADDON.develop("intervalCallback")

	-- timestamp
	ADDON.UpdateLastAccess()

	zo_callLater(
		function()
			intervalCallback()
		end,
		intervalSecs * 1000
	)
end

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

	ADDON.InitMessage()

	-- Load default language
	ADDON.LoadDefaultLangCodeAndReload()

	-- UI
	ADDON.UI.Restore()

	intervalCallback()
end

local function onReticleHiddenUpdate(eventCode, hidden)
	if (not playerOnceActivated) then
		return false
	end

	ADDON.UI.ReticleUpdate(hidden)
end

--------
-- event
--------

EVENT_MANAGER:RegisterForEvent(ADDON.NAME, EVENT_ADD_ON_LOADED, onAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(ADDON.NAME, EVENT_PLAYER_ACTIVATED, onPlayerActivated)
EVENT_MANAGER:RegisterForEvent(ADDON.name, EVENT_RETICLE_HIDDEN_UPDATE, onReticleHiddenUpdate)
