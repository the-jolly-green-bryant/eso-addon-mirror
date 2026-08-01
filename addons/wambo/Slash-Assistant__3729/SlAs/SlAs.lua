local ADDON_NAME = "SlAs"

local function armory()
	if GetCollectibleUnlockStateById(10618) == COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED then
		UseCollectible(10618) --golden saint armory assistant
	else
		UseCollectible(9745) --orc armory assistant
	end
end

local function banker()
	if GetCollectibleUnlockStateById(11097) == COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED then
		UseCollectible(11097) --fire atronach banker
	elseif GetCollectibleUnlockStateById(9743) == COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED then
		UseCollectible(9743) --factotum banker
	elseif GetCollectibleUnlockStateById(8994) == COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED then
		UseCollectible(8994) --raven banker
	elseif GetCollectibleUnlockStateById(6376) == COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED then
			UseCollectible(6376) --alfiq banker
	else
		UseCollectible(267) --banker
	end
end

local function decon()
	if GetCollectibleUnlockStateById(10617) == COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED then
		UseCollectible(10617) --fargrave dregs dealer
	else
		UseCollectible(10184) -- Giladil the ragpicker
	end
end

local function fence()
	UseCollectible(300) -- fence
end

local function merch()
	if GetCollectibleUnlockStateById(11059) == COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED then
		UseCollectible(11059) --frost atronach merchant
	elseif GetCollectibleUnlockStateById(9744) == COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED then
		UseCollectible(9744) --factotum merchant
	elseif GetCollectibleUnlockStateById(8995) == COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED then
		UseCollectible(8995) --raven merchant
	elseif GetCollectibleUnlockStateById(6378) == COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED then
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
SLASH_COMMANDS["/d"] = decon
SLASH_COMMANDS["/a"] = armory

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, onAddonLoaded)
