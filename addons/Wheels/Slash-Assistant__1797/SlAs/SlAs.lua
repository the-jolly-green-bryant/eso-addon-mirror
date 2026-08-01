local ADDON_NAME = "SlAs"

local function banker()
	if GetCollectibleUnlockStateById(6376) == COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED then
		UseCollectible(6376) --alfiq banker
	else
		UseCollectible(267) --banker
	end
end

local function fence()
	UseCollectible(300) -- fence
end

local function merch()
	if GetCollectibleUnlockStateById(6378) == COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED then
		UseCollectible(6378) -- alfiq merchant
	else
		UseCollectible(301) -- merchant
	end
end

local function onAddonLoaded(event, addonName)
	if addonName ~= ADDON_NAME then return end
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

SLASH_COMMANDS["/b"] = banker
SLASH_COMMANDS["/f"] = fence
SLASH_COMMANDS["/m"] = merch

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, onAddonLoaded)
