DismissThis = {}

DismissThis.name = "DismissThis"

-- All the abilityIDs for Familiars and Clannfears
DismissThis.Familiars = { 23304, 30631, 30636, 30641, 23319, 30647, 30652, 30657, 23316, 30664, 30669, 30674 }

-- All the abilityIDs for Twilights
DismissThis.Twilights = { 24613, 30581, 30584, 30587, 24636, 30592, 30595, 30598, 24639, 30618, 30622, 30626 }

-- All the abilityIDs for Grizzly Bears
DismissThis.Grizzlys = { 85982, 85983, 85984, 85985, 85986, 85987, 85988, 85989, 85990, 85991, 85992, 85993 }

DismissThis.Assistants = {
	[267] = true, 
	["Tythis Andromo"] = true,
	[300] = true, 
	["Pirharri the Smuggler"] = true,
	[301] = true, 
	["Nuzhimeh the Merchant"] = true,
	[396] = true,
	["Allaria Erwen the Exporter"] = true,
	[397] = true,
	["Cassus Andronicus the Mercenary"] = true,
	[6378] = true, 
	["Fezez the Merchant"] = true,
	[6376] = true, 
	["Ezabi the Banker"] = true,
}

-- little hack to get the current interactable name
local lastInteractableName
ZO_PreHook(FISHING_MANAGER, "StartInteraction", function()
	local _, name = GetGameCameraInteractableActionInfo()
	lastInteractableName = name
end)

local function loadBanker()
	if GetCollectibleUnlockStateById(6376) == COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED then
		UseCollectible(6376) --alfiq banker
	else
		UseCollectible(267) --banker
	end
end

local function loadFence()
	UseCollectible(300) -- fence
end

local function loadMerch()
	if GetCollectibleUnlockStateById(6378) == COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED then
		UseCollectible(6378) -- alfiq merchant
	else
		UseCollectible(301) -- merchant
	end
end

function DismissThis:DismissAllPets()
	DismissThis:DismissPet(DismissThis.Familiars)
	DismissThis:DismissPet(DismissThis.Twilights)
	DismissThis:DismissPet(DismissThis.Grizzlys)
end

function DismissThis:DismissAllPetsAssistants()
	DismissThis:DismissPet(DismissThis.Familiars)
	DismissThis:DismissPet(DismissThis.Twilights)
	DismissThis:DismissPet(DismissThis.Grizzlys)
	ZO_SharedInteraction:CloseChatterAndDismissAssistant()
end

function DismissThis:DismissAssistants()
	ZO_SharedInteraction:CloseChatterAndDismissAssistant()
end

function DismissThis:DismissPet(petList)

	local i, k, v
	
	-- Walk through the player's active buffs
	for i = 1, GetNumBuffs("player") do
		local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff = GetUnitBuffInfo("player", i)
		-- Compare each buff's abilityID to the list of IDs we were given
		for k, v in pairs(petList) do
			if abilityId == v then
				-- Cancel the buff if we got a match
				CancelBuff(buffSlot)
			end
		end
	end
	
end

function DismissThis:SummonBanker()

	loadBanker()
	
end

function DismissThis:SummonMerchant()

	loadMerch()
	
end

function DismissThis:SummonFence()

	loadFence()
	
end

function DismissThis.OnAddOnLoaded(event, addonName)

	-- Initialization stuff
	
	if addonName == DismissThis.name then
	
		SLASH_COMMANDS["/b"] = loadBanker
		SLASH_COMMANDS["/f"] = loadFence
		SLASH_COMMANDS["/m"] = loadMerch

		-- Register our keybinding names
		ZO_CreateStringId("SI_BINDING_NAME_SUMMON_BANKER", "|c8334ebSummon|r Banker")
		ZO_CreateStringId("SI_BINDING_NAME_SUMMON_FENCE", "|c8334ebSummon|r Fence")
		ZO_CreateStringId("SI_BINDING_NAME_SUMMON_MERCHANT", "|c8334ebSummon|r Merchant")
		ZO_CreateStringId("SI_BINDING_NAME_DISMISS_FAMILIAR", "|c8334ebDismiss|r Familiar/Clannfear")
		ZO_CreateStringId("SI_BINDING_NAME_DISMISS_GRIZZLY", "|c8334ebDismiss|r Grizzly")
		ZO_CreateStringId("SI_BINDING_NAME_DISMISS_TWILIGHT", "|c8334ebDismiss|r Twilight")		
		ZO_CreateStringId("SI_BINDING_NAME_DISMISS_ALL_PETS", "|c8334ebDismiss|r All Pets")
		ZO_CreateStringId("SI_BINDING_NAME_DISMISS_ASSISTANTS", "|c8334ebDismiss|r Assistants")
		ZO_CreateStringId("SI_BINDING_NAME_DISMISS_ALL", "|c8334ebDismiss|r All Pets/Assistants")
	
		EVENT_MANAGER:UnregisterForEvent(DismissThis.name, EVENT_ADD_ON_LOADED)
	end
	
end

-- Handles dialogue start. It will fire on any NPC dialogue, so we need to filter out a bit
local function HandleChatterBegin(eventCode, optionCount)

    -- Ignore interactions with no options
    if optionCount == 0 then return end

    for i = 1, optionCount do
	    -- Get details of first option

	    local optionString, optionType = GetChatterOption(i)

		if not DismissThis.Assistants[lastInteractableName] then
			--do what you normally do
			return
		else
			SelectChatterOption(i)
		end
	end
end

EVENT_MANAGER:RegisterForEvent(DismissThis.name, EVENT_CHATTER_BEGIN, HandleChatterBegin)

-- Do initialization when we receive EVENT_ADD_ON_LOADED
EVENT_MANAGER:RegisterForEvent(DismissThis.name, EVENT_ADD_ON_LOADED, DismissThis.OnAddOnLoaded)