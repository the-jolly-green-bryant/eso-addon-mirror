CraftingStationSpCpDisplayNinja = CraftingStationSpCpDisplayNinja or {}

local ADDON = CraftingStationSpCpDisplayNinja

ADDON.NAME = "CraftingStationSpCpDisplayNinja"
ADDON.DISPLAY_NAME = "Crafting Station Sp Cp Display Ninja"
ADDON.SHORT_NAME = "[CSNinja]"
ADDON.AUTHOR = "@Shinntarou (NA, PC)"
ADDON.VERSION = "2.0"

local playerOnceActivated = false

function ADDON.onAddOnLoaded(event, addOnName)
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

function ADDON.onPlayerActivated()

	-- require once
	if (playerOnceActivated) then
		return
	end
	playerOnceActivated = true
	EVENT_MANAGER:UnregisterForEvent(ADDON.NAME, EVENT_PLAYER_ACTIVATED)

	ADDON.InitMessage()

	-- UI
	zo_callLater(
		function()
			ADDON.UI.Restore()
		end,
		100
	)
end

local function _onCraftInteract(eventCode, craftSkill, sameStation)

	ADDON.UI.CraftBegin(craftSkill)
end

local function _onCraftExit(eventCode, craftSkill)
	ADDON.UI.CraftEnd()
end

--------
-- event
--------

EVENT_MANAGER:RegisterForEvent(ADDON.NAME, EVENT_ADD_ON_LOADED, ADDON.onAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(ADDON.NAME, EVENT_PLAYER_ACTIVATED, ADDON.onPlayerActivated)
EVENT_MANAGER:RegisterForEvent(ADDON.name, EVENT_CRAFTING_STATION_INTERACT, _onCraftInteract)
EVENT_MANAGER:RegisterForEvent(ADDON.name, EVENT_END_CRAFTING_STATION_INTERACT, _onCraftExit)
